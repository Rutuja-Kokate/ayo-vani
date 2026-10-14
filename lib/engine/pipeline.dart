import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:typed_data';

import 'package:record/record.dart';

import 'audio_playback_worker.dart';
import 'mt_stage.dart';
import 'script_utils.dart' as script_utils;
import 'stt_stage.dart';
import 'tts_stage.dart';
import '../services/mt_translation_service.dart';

/// Supported translation directions.
enum TranslationDirection {
  hindiToMundari,
  mundariToHindi;

  String get label => this == TranslationDirection.hindiToMundari
      ? 'Hindi ➔ Mundari'
      : 'Mundari ➔ Hindi';

  String get sourceLanguage => this == TranslationDirection.hindiToMundari ? 'Hindi' : 'Mundari';
  String get targetLanguage => this == TranslationDirection.hindiToMundari ? 'Mundari' : 'Hindi';
}

/// Budgeted threads for STT.
const int kDefaultSttThreads = 2;

/// Budgeted threads for MT.
const int kDefaultMtThreads = 1;

/// Budgeted threads for TTS.
const int kDefaultTtsThreads = 1;

/// Result object returned by [SpeechPipeline.processFile].
class PipelineResult {
  final String sourceText;
  final String targetText;
  final TranslationDirection direction;
  final Uint8List audioBytes;
  final int audioSampleRate;
  final int sttMs;
  final int mtMs;
  final int ttsMs;
  final int firstClauseTtsMs;
  final int clauseCount;

  // Backwards compatibility getters
  String get hindiText => direction == TranslationDirection.hindiToMundari ? sourceText : targetText;
  String get mundariText => direction == TranslationDirection.hindiToMundari ? targetText : sourceText;

  int get totalMs => sttMs + mtMs + ttsMs;
  int get timeToFirstAudioMs => sttMs + mtMs + firstClauseTtsMs;

  const PipelineResult({
    required this.sourceText,
    required this.targetText,
    this.direction = TranslationDirection.hindiToMundari,
    required this.audioBytes,
    required this.audioSampleRate,
    required this.sttMs,
    required this.mtMs,
    required this.ttsMs,
    required this.firstClauseTtsMs,
    required this.clauseCount,
  });

  // Legacy constructor for backward compatibility
  factory PipelineResult.legacy({
    required String hindiText,
    required String mundariText,
    required Uint8List audioBytes,
    required int audioSampleRate,
    required int sttMs,
    required int mtMs,
    required int ttsMs,
    required int firstClauseTtsMs,
    required int clauseCount,
  }) => PipelineResult(
    sourceText: hindiText,
    targetText: mundariText,
    direction: TranslationDirection.hindiToMundari,
    audioBytes: audioBytes,
    audioSampleRate: audioSampleRate,
    sttMs: sttMs,
    mtMs: mtMs,
    ttsMs: ttsMs,
    firstClauseTtsMs: firstClauseTtsMs,
    clauseCount: clauseCount,
  );
}

/// Timing breakdown for a single clause in the live streaming pipeline.
class LiveClauseTiming {
  final int clauseIndex;
  final String sourceText;
  String targetText = '';
  final DateTime tMic;
  final DateTime tStt;
  final int chunkDurationMs;
  DateTime? tMt;
  DateTime? tTts;
  DateTime? tPlay;

  final TranslationDirection direction;

  // Backwards compatibility getters
  String get hindiText => direction == TranslationDirection.hindiToMundari ? sourceText : targetText;
  String get mundariText => direction == TranslationDirection.hindiToMundari ? targetText : sourceText;
  set mundariText(String val) => targetText = val;

  LiveClauseTiming({
    required this.clauseIndex,
    String? sourceText,
    String? hindiText,
    this.targetText = '',
    required this.tMic,
    required this.tStt,
    required this.chunkDurationMs,
    this.direction = TranslationDirection.hindiToMundari,
  }) : sourceText = sourceText ?? hindiText ?? '';

  int get sttDurationMs => chunkDurationMs;
  int? get mtDurationMs => tMt?.difference(tStt).inMilliseconds;
  int? get ttsDurationMs => (tTts != null && tMt != null) ? tTts!.difference(tMt!).inMilliseconds : null;
  int? get queueWaitMs => (tPlay != null && tTts != null) ? tPlay!.difference(tTts!).inMilliseconds : null;

  int? get computeTurnaroundMs => tPlay?.difference(tStt).inMilliseconds;

  /// Turnaround time from when speech ends to when translated audio is heard.
  int? get totalLatencyToAudioHeardMs => computeTurnaroundMs;
}

/// Events emitted by [SpeechPipeline.liveEvents] during live concurrent operation.
enum LiveEventType { sttClause, mtClause, ttsClause, playbackStarted, finished }

class LivePipelineEvent {
  final LiveEventType type;
  final int clauseIndex;
  final String text;
  final LiveClauseTiming timing;
  final Uint8List? audioBytes;
  final double? confidence;

  LivePipelineEvent({
    required this.type,
    required this.clauseIndex,
    required this.text,
    required this.timing,
    this.audioBytes,
    this.confidence,
  });
}

/// Full speech pipeline: STT → MT → TTS with live concurrent streaming.
class SpeechPipeline {
  final SttStage sttStage;
  final MtStage mtStage;
  final TtsStage ttsStage;
  final AudioPlaybackWorker audioPlayer = AudioPlaybackWorker();

  bool _isMtLoaded = false;
  bool _isTtsLoaded = false;
  bool _isPlayerLoaded = false;

  AudioRecorder? _audioRecorder;
  StreamSubscription<SttClauseResult>? _sttClauseSub;
  StreamSubscription<int>? _playbackSub;
  StreamController<SttClauseResult>? _clauseQueue;
  final StreamController<LivePipelineEvent> _liveEventsController = StreamController<LivePipelineEvent>.broadcast();

  final Map<int, LiveClauseTiming> _activeTimings = {};
  bool _isLiveSessionActive = false;
  DateTime? _sessionStartTime;

  TranslationDirection activeDirection;

  SpeechPipeline({
    required this.sttStage,
    required this.mtStage,
    required this.ttsStage,
    this.activeDirection = TranslationDirection.hindiToMundari,
  });

  Stream<LivePipelineEvent> get liveEvents => _liveEventsController.stream;
  bool get isLiveActive => _isLiveSessionActive;
  bool get isLiveSessionActive => _isLiveSessionActive;

  /// Changes the active translation direction at runtime.
  Future<void> setDirection(TranslationDirection direction) async {
    if (activeDirection == direction) return;
    activeDirection = direction;
    dev.log('[Pipeline] Switching active direction to: ${direction.label}');
    await sttStage.switchDirection(direction);
  }

  /// Ensures the MT stage model is initialized lazily on first use.
  Future<void> ensureMtLoaded() async {
    if (!_isMtLoaded) {
      dev.log('[Pipeline] Lazy loading MT stage...');
      await mtStage.initModel();
      _isMtLoaded = true;
    }
  }

  /// Ensures the TTS stage model is initialized lazily on first use.
  Future<void> ensureTtsLoaded() async {
    if (!_isTtsLoaded) {
      dev.log('[Pipeline] Lazy loading TTS stage...');
      await ttsStage.initModel();
      _isTtsLoaded = true;
    }
  }

  /// Ensures the audio player is initialized.
  Future<void> ensurePlayerLoaded() async {
    if (!_isPlayerLoaded) {
      await audioPlayer.init();
      _isPlayerLoaded = true;
    }
  }

  /// Initializes stages sequentially to avoid OOM risk on low-memory (2GB) devices.
  /// STT is loaded for the active direction only; MT and TTS are lazy-loaded on first use
  /// unless [loadAllSequentially] is explicitly set to true.
  Future<void> init({bool loadAllSequentially = false}) async {
    final t0 = DateTime.now();
    dev.log('[Pipeline] Initializing STT stage sequentially for active direction: $activeDirection...');
    await sttStage.initModel(direction: activeDirection);

    if (loadAllSequentially) {
      dev.log('[Pipeline] Sequentially loading MT stage...');
      await ensureMtLoaded();

      dev.log('[Pipeline] Sequentially loading TTS stage...');
      await ensureTtsLoaded();

      dev.log('[Pipeline] Sequentially initializing AudioPlayer...');
      await ensurePlayerLoaded();
    } else {
      await ensurePlayerLoaded();
    }

    final elapsed = DateTime.now().difference(t0).inMilliseconds;
    dev.log('[Pipeline] Pipeline initialization finished in ${elapsed}ms');
  }

  /// Runs the full pipeline on a pre-recorded WAV file in batch mode.
  Future<PipelineResult> processFile(
    String wavPath, {
    void Function(String partialText)? onPartialTranscript,
    void Function(int clauseIndex, int totalClauses, Uint8List pcmChunk)? onTtsChunkReady,
  }) async {
    final file = File(wavPath);
    if (!await file.exists()) {
      throw FileSystemException('Audio file not found', wavPath);
    }

    final totalStart = DateTime.now();
    dev.log('[Pipeline] Starting batch file pipeline on $wavPath (${activeDirection.label})');

    // Ensure MT and TTS stages are loaded lazily before execution
    await ensureMtLoaded();
    await ensureTtsLoaded();

    // Stage 1: STT
    final sttStart = DateTime.now();
    final sourceText = await sttStage.transcribeFile(wavPath);
    final sttMs = DateTime.now().difference(sttStart).inMilliseconds;
    dev.log('[Pipeline] [STT] Emitted: "$sourceText" in ${sttMs}ms');

    // Stage 2: MT
    final mtStart = DateTime.now();
    final mtResult = await mtStage.translate(sourceText, direction: activeDirection);
    final mtMs = DateTime.now().difference(mtStart).inMilliseconds;
    dev.log('[Pipeline] [MT] Display: "${mtResult.displayText}", TTS: "${mtResult.synthesizeText}" in ${mtMs}ms');

    // Stage 3: TTS (Streaming Clauses)
    final ttsStart = DateTime.now();
    final clauses = splitIntoClauses(mtResult.synthesizeText);
    dev.log('[Pipeline] [TTS] Split text into ${clauses.length} clauses for streaming synthesis');

    int firstClauseTtsMs = 0;
    int sampleRate = 16000;
    final List<Uint8List> audioChunks = [];

    await for (final chunk in ttsStage.synthesizeClauses(clauses, direction: activeDirection)) {
      if (chunk.index == 0) {
        firstClauseTtsMs = DateTime.now().difference(ttsStart).inMilliseconds;
        final ttfa = sttMs + mtMs + firstClauseTtsMs;
        dev.log('⚡ [TTS-Stream] FIRST CLAUSE READY at ${ttfa}ms since start (TTS time: ${firstClauseTtsMs}ms)');
      }

      final sinceStart = DateTime.now().difference(totalStart).inMilliseconds;
      dev.log('⚡ [TTS-Stream] Clause ${chunk.index + 1}/${chunk.totalClauses} ready at ${sinceStart}ms (synth: ${chunk.synthesisMs}ms): "${chunk.clauseText}" (${chunk.audioBytes.length} bytes)');

      sampleRate = chunk.sampleRate;
      audioChunks.add(chunk.audioBytes);
      onTtsChunkReady?.call(chunk.index, chunk.totalClauses, chunk.audioBytes);
    }

    final builder = BytesBuilder(copy: false);
    for (final chunk in audioChunks) {
      builder.add(chunk);
    }
    final combinedAudioBytes = builder.takeBytes();
    final ttsMs = DateTime.now().difference(ttsStart).inMilliseconds;

    return PipelineResult(
      sourceText: sourceText,
      targetText: mtResult.displayText,
      direction: activeDirection,
      audioBytes: combinedAudioBytes,
      audioSampleRate: sampleRate,
      sttMs: sttMs,
      mtMs: mtMs,
      ttsMs: ttsMs,
      firstClauseTtsMs: firstClauseTtsMs,
      clauseCount: clauses.length,
    );
  }

  /// Starts real-time live overlapping pipeline from the tablet microphone or a custom audio stream.
  Future<void> startLivePipeline({
    Stream<Uint8List>? customAudioStream,
    void Function(String partialText)? onPartialTranscript,
  }) async {
    if (_isLiveSessionActive) return;
    _isLiveSessionActive = true;
    MtTranslationService.isLivePipelineActive = true;
    _sessionStartTime = DateTime.now();
    _activeTimings.clear();

    // Ensure downstream models are loaded before streaming starts
    await ensureMtLoaded();
    await ensureTtsLoaded();
    await ensurePlayerLoaded();

    Stream<Uint8List> pcmStream;
    if (customAudioStream != null) {
      pcmStream = customAudioStream;
    } else {
      // 1. Initialize microphone recording stream (16kHz, 1-channel PCM16)
      _audioRecorder = AudioRecorder();
      final hasPermission = await _audioRecorder!.hasPermission();
      if (!hasPermission) {
        throw StateError('Microphone permission not granted. Please grant Microphone permissions in Android Settings.');
      }

      pcmStream = await _audioRecorder!.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
          autoGain: true,
          echoCancel: true,
          noiseSuppress: true,
        ),
      );
    }

    // 2. Listen to audio player playback start events to log true end-to-end latency
    _playbackSub = audioPlayer.onClausePlaybackStarted.listen((clauseIndex) {
      final timing = _activeTimings[clauseIndex];
      if (timing != null) {
        timing.tPlay = DateTime.now();
        dev.log('⚡ [Pipeline-Live] Step 4: PLAYBACK STARTED for clause #$clauseIndex! | '
            'Speech Utterance: ${timing.sttDurationMs}ms | '
            'MT: ${timing.mtDurationMs}ms | '
            'TTS: ${timing.ttsDurationMs}ms | '
            'Queue Wait: ${timing.queueWaitMs}ms | '
            '⚡ TRUE TURNAROUND TO AUDIO: ${timing.totalLatencyToAudioHeardMs}ms');

        _liveEventsController.add(LivePipelineEvent(
          type: LiveEventType.playbackStarted,
          clauseIndex: clauseIndex,
          text: timing.targetText,
          timing: timing,
        ));
      }
    });

    // 3. Asynchronous queue to process incoming STT clauses concurrently through MT and TTS
    await _clauseQueue?.close();
    _clauseQueue = StreamController<SttClauseResult>();
    _sttClauseSub = sttStage.clauseStream.listen((clause) {
      if (_isLiveSessionActive) {
        _clauseQueue?.add(clause);
      }
    });

    // Start worker loop that pipes clauses through MT and TTS
    _runConcurrentStageWorker(_clauseQueue!.stream);

    // 4. Start Live STT Session
    await sttStage.startLive(
      pcmStream,
      onPartial: onPartialTranscript,
    );

    dev.log('[Pipeline] 🎙️ Live overlapping pipeline active (${activeDirection.label}) (Thread Budget: STT=$kDefaultSttThreads, MT=$kDefaultMtThreads, TTS=$kDefaultTtsThreads)!');
  }

  /// Concurrently processes STT clauses through MT, TTS, and queues audio into the gapless player.
  Future<void> _runConcurrentStageWorker(Stream<SttClauseResult> stream) async {
    try {
      await for (final sttClause in stream) {
        if (!_isLiveSessionActive) break;

        final clauseIdx = sttClause.index;
        final tMic = _sessionStartTime ?? sttClause.timestamp;
        final tStt = sttClause.timestamp;

        final timing = LiveClauseTiming(
          clauseIndex: clauseIdx,
          sourceText: sttClause.text,
          tMic: tMic,
          tStt: tStt,
          chunkDurationMs: sttClause.durationMs,
          direction: activeDirection,
        );
        _activeTimings[clauseIdx] = timing;

        dev.log('⚡ [Pipeline-Live] Step 1: STT emitted clause #$clauseIdx: "${sttClause.text}" (${timing.sttDurationMs}ms speech)');
        _liveEventsController.add(LivePipelineEvent(
          type: LiveEventType.sttClause,
          clauseIndex: clauseIdx,
          text: sttClause.text,
          timing: timing,
        ));

        // Step 2: MT Translation
        final mtResult = await mtStage.translate(sttClause.text, direction: activeDirection);
        if (!_isLiveSessionActive) break;

        timing.tMt = DateTime.now();
        timing.targetText = mtResult.displayText;
        dev.log('⚡ [Pipeline-Live] Step 2: MT translated clause #$clauseIdx: "${mtResult.displayText}" (MT time: ${timing.mtDurationMs}ms)');

        _liveEventsController.add(LivePipelineEvent(
          type: LiveEventType.mtClause,
          clauseIndex: clauseIdx,
          text: mtResult.displayText,
          timing: timing,
          confidence: mtResult.confidence,
        ));

        // Step 3: TTS Synthesis
        final ttsResult = await ttsStage.synthesize(mtResult.synthesizeText, direction: activeDirection);
        if (!_isLiveSessionActive) break;

        timing.tTts = DateTime.now();

        dev.log('⚡ [Pipeline-Live] Step 3: TTS synthesized clause #$clauseIdx (${ttsResult.audioBytes.length} bytes, TTS time: ${timing.ttsDurationMs}ms)');

        _liveEventsController.add(LivePipelineEvent(
          type: LiveEventType.ttsClause,
          clauseIndex: clauseIdx,
          text: mtResult.synthesizeText,
          timing: timing,
          audioBytes: ttsResult.audioBytes,
        ));

        // Step 4: Queue audio for playback
        if (_isLiveSessionActive) {
          await audioPlayer.queueClauseAudio(clauseIdx, ttsResult.audioBytes, sampleRate: ttsResult.sampleRate);
        }
      }
    } catch (e, st) {
      dev.log('[Pipeline] Worker error: $e\n$st');
      _liveEventsController.add(LivePipelineEvent(
        type: LiveEventType.finished,
        clauseIndex: -1,
        text: 'Pipeline error: $e',
        timing: LiveClauseTiming(
          clauseIndex: -1,
          sourceText: '',
          tMic: DateTime.now(),
          tStt: DateTime.now(),
          chunkDurationMs: 0,
          direction: activeDirection,
        ),
      ));
    }
  }

  /// Stops the live streaming pipeline session.
  Future<void> stopLivePipeline() async {
    if (!_isLiveSessionActive) return;
    _isLiveSessionActive = false;
    MtTranslationService.isLivePipelineActive = false;

    dev.log('[Pipeline] Stopping live pipeline...');
    await _audioRecorder?.stop();
    await _audioRecorder?.dispose();
    _audioRecorder = null;

    final finalTranscript = await sttStage.stopLive();

    await _sttClauseSub?.cancel();
    _sttClauseSub = null;
    await _clauseQueue?.close();
    _clauseQueue = null;
    await _playbackSub?.cancel();
    _playbackSub = null;
    await audioPlayer.stop();

    _liveEventsController.add(LivePipelineEvent(
      type: LiveEventType.finished,
      clauseIndex: -1,
      text: finalTranscript,
      timing: LiveClauseTiming(
        clauseIndex: -1,
        sourceText: finalTranscript,
        tMic: _sessionStartTime ?? DateTime.now(),
        tStt: DateTime.now(),
        chunkDurationMs: 1500,
        direction: activeDirection,
      ),
    ));
  }

  /// Splits [text] into natural clauses on punctuation and length boundaries.
  static List<String> splitIntoClauses(String text) {
    if (text.trim().isEmpty) return const [];
    return script_utils.splitIntoClauses(text);
  }

  void dispose() {
    stopLivePipeline();
    sttStage.dispose();
    mtStage.dispose();
    ttsStage.dispose();
    audioPlayer.dispose();
    _liveEventsController.close();
  }
}
