import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart';

import 'pipeline.dart' show kDefaultSttThreads, TranslationDirection;

class SttStage {
  static const String _hindiModelAssetKey = 'assets/models/model.int8.onnx';
  static const String _hindiTokensAssetKey = 'assets/models/tokens.txt';

  static const String _mundariModelAssetKey = 'assets/models/asr_mundari/mundari_stt_ctc.int8.onnx';
  static const String _mundariTokensAssetKey = 'assets/models/asr_mundari/vocab.txt';

  final int threads;

  SttStage({this.threads = kDefaultSttThreads});

  OfflineRecognizer? _recognizer;
  String? _modelPath;
  String? _tokensPath;
  String? _activeProvider;
  TranslationDirection _currentDirection = TranslationDirection.hindiToMundari;

  bool get isReady => _recognizer != null;
  TranslationDirection get currentDirection => _currentDirection;
  String? get activeProvider => _activeProvider;

  final StreamController<SttClauseResult> _clauseController = StreamController<SttClauseResult>.broadcast();
  Stream<SttClauseResult> get clauseStream => _clauseController.stream;

  StreamSubscription<Uint8List>? _audioSub;

  int _clauseIndex = 0;
  String _emittedText = '';

  // VAD Constants (tuned for conversational speech)
  static const double kSilenceThresholdRms = 0.005;
  static const int kSilenceFramesToFlush = 3; // 480ms
  static const int kMaxBufferFrames = 15; // 2.4s
  static const int kMinBufferFramesToInfer = 4; // 640ms
  static const int kMinSpeechEnergyFrames = 2; // 320ms
  static const double kMaxCharsPerSecond = 25.0; // Accommodate Devanagari UTF-16 matras

  // Buffering state
  final List<Float32List> _chunkBuffer = [];
  int _silentFramesCount = 0;
  DateTime? _speechStartTime;

  Future<void> initModel({TranslationDirection direction = TranslationDirection.hindiToMundari}) async {
    _currentDirection = direction;
    final bool isMundari = direction == TranslationDirection.mundariToHindi;

    final dir = await getApplicationSupportDirectory();
    final asrDir = Directory('${dir.path}/asr');
    if (!await asrDir.exists()) await asrDir.create(recursive: true);

    final modelKey = isMundari ? _mundariModelAssetKey : _hindiModelAssetKey;
    final tokensKey = isMundari ? _mundariTokensAssetKey : _hindiTokensAssetKey;

    _modelPath = isMundari ? '${asrDir.path}/mundari_ctc.int8.onnx' : '${asrDir.path}/model.int8.onnx';
    _tokensPath = isMundari ? '${asrDir.path}/vocab_mundari.txt' : '${asrDir.path}/tokens.txt';

    await _extractAsset(modelKey, _modelPath!);
    await _extractAsset(tokensKey, _tokensPath!);

    OfflineRecognizerConfig createConfig(String provider) {
      return OfflineRecognizerConfig(
        feat: const FeatureConfig(sampleRate: 16000, featureDim: 80),
        model: OfflineModelConfig(
          nemoCtc: OfflineNemoEncDecCtcModelConfig(model: _modelPath!),
          tokens: _tokensPath!,
          provider: provider,
          numThreads: threads,
          debug: false,
        ),
        decodingMethod: 'greedy_search',
      );
    }

    // Free any existing recognizer before creating a new one (strictly one in memory)
    _recognizer?.free();
    _recognizer = null;

    // Try xnnpack provider first for optimized ARM latency, fallback to cpu inside try/catch
    try {
      _recognizer = OfflineRecognizer(createConfig('xnnpack'));
      _activeProvider = 'xnnpack';
      dev.log('[STT] Successfully initialized OfflineRecognizer with active provider: xnnpack');
    } catch (e) {
      dev.log('[STT] Provider xnnpack failed ($e), falling back to cpu');
      _recognizer = OfflineRecognizer(createConfig('cpu'));
      _activeProvider = 'cpu';
      dev.log('[STT] Successfully initialized OfflineRecognizer with active provider: cpu');
    }
  }

  /// Dynamically switches the active ASR language model (Hindi vs Mundari).
  /// Strictly frees the old recognizer before creating the new one.
  Future<void> switchDirection(TranslationDirection direction) async {
    if (_currentDirection == direction && isReady) return;
    _recognizer?.free();
    _recognizer = null;
    await initModel(direction: direction);
  }

  Future<void> _extractAsset(String key, String destPath) async {
    final destFile = File(destPath);
    final assetByteData = await rootBundle.load(key);
    final assetLength = assetByteData.lengthInBytes;

    if (await destFile.exists()) {
      final destLength = await destFile.length();
      if (destLength == assetLength) {
        // Destination file exists and matches asset length; avoid rewriting 140-197MB
        return;
      }
    }

    await destFile.parent.create(recursive: true);
    await destFile.writeAsBytes(
      assetByteData.buffer.asUint8List(assetByteData.offsetInBytes, assetByteData.lengthInBytes),
      flush: true,
    );
  }

  /// Transcribes a WAV file using sherpa.readWave(path) instead of assuming a 44-byte WAV header.
  Future<String> transcribeFile(String wavPath) async {
    if (!isReady) throw StateError('Not initialized');

    final wave = readWave(wavPath);
    final stream = _recognizer!.createStream();
    stream.acceptWaveform(sampleRate: wave.sampleRate, samples: wave.samples);
    _recognizer!.decode(stream);
    final text = _recognizer!.getResult(stream).text;
    stream.free();

    return _cleanText(text);
  }

  Float32List _pcm16ToFloat32(Uint8List pcm16) {
    final int16List = pcm16.buffer.asInt16List(pcm16.offsetInBytes, pcm16.lengthInBytes ~/ 2);
    final float32List = Float32List(int16List.length);
    for (int i = 0; i < int16List.length; i++) {
      float32List[i] = int16List[i] / 32768.0;
    }
    return float32List;
  }

  double _computeRms(Float32List samples) {
    double sumSq = 0.0;
    for (final s in samples) {
      sumSq += s * s;
    }
    return math.sqrt(sumSq / samples.length);
  }

  // Ring buffer accumulation
  final List<int> _rawByteQueue = [];

  Future<void> startLive(Stream<Uint8List> pcm16Stream, {void Function(String partial)? onPartial}) async {
    if (!isReady) throw StateError('Call initModel() first.');

    _emittedText = '';
    _clauseIndex = 0;
    _chunkBuffer.clear();
    _silentFramesCount = 0;
    _rawByteQueue.clear();
    _speechStartTime = null;

    dev.log('[STT-Live] Starting IndicConformer offline-streaming session...');

    _audioSub = pcm16Stream.listen((data) {
      _rawByteQueue.addAll(data);
      // 160ms chunks = 2560 samples = 5120 bytes
      while (_rawByteQueue.length >= 5120) {
        final chunkBytes = Uint8List.fromList(_rawByteQueue.sublist(0, 5120));
        _rawByteQueue.removeRange(0, 5120);
        _processChunk(chunkBytes);
      }
    });
  }

  void _processChunk(Uint8List pcm16) {
    final float32Samples = _pcm16ToFloat32(pcm16);
    final rms = _computeRms(float32Samples);

    _chunkBuffer.add(float32Samples);
    _speechStartTime ??= DateTime.now();

    if (rms < kSilenceThresholdRms) {
      _silentFramesCount++;
    } else {
      _silentFramesCount = 0;
    }

    if (_silentFramesCount >= kSilenceFramesToFlush || _chunkBuffer.length >= kMaxBufferFrames) {
      _flushBuffer();
    }
  }

  void _flushBuffer() {
    if (_chunkBuffer.isEmpty) return;

    final framesCount = _chunkBuffer.length;

    // Silence Trimming (Keep 2 chunks on each side)
    int startIndex = 0;
    while (startIndex < _chunkBuffer.length && _computeRms(_chunkBuffer[startIndex]) < kSilenceThresholdRms) {
      startIndex++;
    }
    startIndex = math.max(0, startIndex - 2);

    int endIndex = _chunkBuffer.length - 1;
    while (endIndex >= 0 && _computeRms(_chunkBuffer[endIndex]) < kSilenceThresholdRms) {
      endIndex--;
    }
    endIndex = math.min(_chunkBuffer.length - 1, endIndex + 2);

    // Gate 1: Min Buffer Context
    if (framesCount < kMinBufferFramesToInfer) {
      _chunkBuffer.clear();
      _silentFramesCount = 0;
      _speechStartTime = null;
      return;
    }

    // Gate 2: Min Speech Energy
    int activeFrames = 0;
    for (int i = startIndex; i <= endIndex; i++) {
      if (_computeRms(_chunkBuffer[i]) >= kSilenceThresholdRms) activeFrames++;
    }
    if (activeFrames < kMinSpeechEnergyFrames) {
      _chunkBuffer.clear();
      _silentFramesCount = 0;
      _speechStartTime = null;
      return;
    }

    // Prepare inference data
    final inferenceBuffer = _chunkBuffer.sublist(startIndex, endIndex + 1);
    final totalSamples = inferenceBuffer.length * 2560;
    final float32List = Float32List(totalSamples);
    int offset = 0;
    for (final chunk in inferenceBuffer) {
      float32List.setAll(offset, chunk);
      offset += chunk.length;
    }
    final durationSecs = float32List.length / 16000.0;

    // Clear buffer for next accumulation
    _chunkBuffer.clear();
    _silentFramesCount = 0;
    final startT = _speechStartTime!;
    _speechStartTime = null;

    // Run inference
    final stream = _recognizer!.createStream();
    stream.acceptWaveform(sampleRate: 16000, samples: float32List);
    _recognizer!.decode(stream);
    final rawText = _recognizer!.getResult(stream).text;
    stream.free();

    final text = _cleanText(rawText);
    if (text.isEmpty) return;

    // Gate 3: Character Rate Plausibility Filter
    final charsPerSec = text.length / durationSecs;
    if (charsPerSec > kMaxCharsPerSecond) {
      dev.log('[STT-Live] Hallucination dropped (rate $charsPerSec chars/s): "$text"');
      return;
    }

    // Post-Processing: Trailing Repetition Filter
    if (_emittedText.endsWith(text)) {
      dev.log('[STT-Live] Trailing repetition dropped: "$text"');
      return;
    }

    _emittedText += '$text ';
    _emitClause(text, startT, durationSecs);
  }

  String _cleanText(String input) {
    if (input.isEmpty) return '';
    var text = input.trim();
    // Prefix deduplication and Intra-word loop collapse
    text = text.replaceAll(RegExp(r'(.+?)\1{2,}'), r'$1'); // Collapse 3+ repeats of any pattern

    final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '';

    final cleanWords = <String>[];
    for (int i = 0; i < words.length; i++) {
      if (cleanWords.isNotEmpty) {
        // prefix deduplication: drop word if next word starts with it
        final prev = cleanWords.last;
        final curr = words[i];
        if (curr.startsWith(prev) && curr != prev) {
          cleanWords.removeLast();
        } else if (curr == prev) {
          continue; // Consecutive duplicate removal
        }
      }
      cleanWords.add(words[i]);
    }
    return cleanWords.join(' ');
  }

  void _emitClause(String text, DateTime startT, double durationSecs) {
    if (text.isEmpty) return;

    final emittedIndex = _clauseIndex++;
    final result = SttClauseResult(
      index: emittedIndex,
      text: text,
      timestamp: DateTime.now(),
      durationMs: (durationSecs * 1000).toInt(),
      isFinal: false,
    );
    dev.log('[STT-Live] Emitted clause #$emittedIndex: "$text"');
    _clauseController.add(result);
  }

  Future<String> stopLive() async {
    dev.log('[STT-Live] Stopping live session...');
    await _audioSub?.cancel();
    _audioSub = null;

    _flushBuffer(); // Process any remaining

    final finalTranscript = _emittedText.trim();
    dev.log('[STT-Live] Session stopped. Total final transcript: "$finalTranscript"');
    return finalTranscript;
  }

  Future<void> dispose() async {
    await stopLive();
    await _clauseController.close();
    _recognizer?.free();
    _recognizer = null;
  }
}

class SttClauseResult {
  final int index;
  final String text;
  final DateTime timestamp;
  final int durationMs;
  final bool isFinal;

  SttClauseResult({
    required this.index,
    required this.text,
    required this.timestamp,
    required this.durationMs,
    this.isFinal = false,
  });
}
