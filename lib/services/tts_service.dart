import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;
import 'package:audioplayers/audioplayers.dart';
import 'speech_to_speech_service.dart';

/// Service that synthesises speech offline using Sherpa-ONNX Mundari TTS model (mundari.onnx)
/// with fallback to flutter_tts.
class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  sherpa.OfflineTts? _sherpaTts;
  bool _initialized = false;
  bool _isInitializing = false;

  /// Initialise the service. Must be called before any playback.
  Future<void> init() async {
    if (_initialized) return;
    if (_isInitializing) {
      while (_isInitializing) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return;
    }

    _isInitializing = true;
    
    try {
      if (Platform.isAndroid) {
        await _flutterTts.setEngine('com.google.android.tts');
      }

      await _flutterTts.setLanguage('hi-IN');
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setPitch(1.0);
      await _flutterTts.awaitSpeakCompletion(true);

      // Initialize local Sherpa-ONNX Mundari TTS Model
      await _initSherpaMundariTts();
    } catch (e) {
      debugPrint('TTS Init error: $e');
    } finally {
      _initialized = true;
      _isInitializing = false;
    }
  }

  Future<void> _initSherpaMundariTts() async {
    try {
      // 1. Initialize native C++ bindings for sherpa_onnx first
      sherpa.initBindings();

      final appDir = await getApplicationDocumentsDirectory();
      final ttsDir = Directory('${appDir.path}/tts_model');
      if (!ttsDir.existsSync()) ttsDir.createSync(recursive: true);

      final modelFile = File('${ttsDir.path}/mundari.onnx');
      final tokensFile = File('${ttsDir.path}/tokens.txt');

      // Force overwrite modelFile and tokensFile if not present or incorrect size
      if (!modelFile.existsSync() || modelFile.lengthSync() < 1000000) {
        debugPrint('[TTS] Extracting assets/models/tts/mundari.onnx to filesystem...');
        final modelBytes = await rootBundle.load('assets/models/tts/mundari.onnx');
        await modelFile.writeAsBytes(modelBytes.buffer.asUint8List(), flush: true);
      }

      if (!tokensFile.existsSync() || tokensFile.lengthSync() > 10000 || tokensFile.lengthSync() < 100) {
        debugPrint('[TTS] Extracting assets/models/tts/tokens.txt (161 VITS phoneme tokens) to filesystem...');
        final tokensBytes = await rootBundle.load('assets/models/tts/tokens.txt');
        await tokensFile.writeAsBytes(tokensBytes.buffer.asUint8List(), flush: true);
      }

      final config = sherpa.OfflineTtsConfig(
        model: sherpa.OfflineTtsModelConfig(
          vits: sherpa.OfflineTtsVitsModelConfig(
            model: modelFile.path,
            tokens: tokensFile.path,
            lexicon: tokensFile.path,
          ),
          numThreads: 2,
          debug: false,
        ),
      );

      _sherpaTts = sherpa.OfflineTts(config);
      debugPrint('[TTS] Local Sherpa-ONNX Mundari TTS Model initialized ✓');
    } catch (e, st) {
      debugPrint('[TTS] Sherpa ONNX TTS init error (fallback to FlutterTts): $e\n$st');
      _sherpaTts = null;
    }
  }

  /// Change the speech rate dynamically
  Future<void> setSpeechRate(double rate) async {
    if (!_initialized) await init();
    await _flutterTts.setSpeechRate(rate);
  }

  /// Stop any ongoing speech
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      await _audioPlayer.stop();
    } catch (e) {
      debugPrint('TTS Stop error: $e');
    }
  }

  /// Phonetic map converting English classroom terms to Devanagari phonemes
  static final Map<String, String> loanwordPhoneticMap = {
    'notebook': 'नोटबुक',
    'chapter': 'चैप्टर',
    'page': 'पेज',
    'board': 'बोर्ड',
    'quiz': 'क्विज़',
    'team': 'टीम',
    'pencil': 'पेंसिल',
    'book': 'बुक',
    'teacher': 'टीचर',
    'warm-up': 'वार्म-अप',
    'introduction': 'परिचय',
    'practice': 'अभ्यास',
    'unit': 'यूनिट',
    'class': 'क्लास',
    'lesson': 'लेसन',
    'student': 'स्टूडेंट',
    'school': 'स्कूल',
    'section': 'सेक्शन',
  };

  /// Synthesize and play general text
  Future<void> speak(String text) async {
    await speakWordAndMundari(text, null);
  }

  /// Synthesize and play code-mixed (Mundari + English) classroom scripts using local ONNX Mundari TTS.
  Future<void> speakCodeMixedClassroomScript(String scriptText) async {
    if (!_initialized) await init();

    String normalizedText = scriptText;

    // Unmask tagged {ENG:term} placeholders
    normalizedText = normalizedText.replaceAllMapped(RegExp(r'\{ENG:([^}]+)\}'), (match) {
      final term = match.group(1) ?? '';
      return loanwordPhoneticMap[term.toLowerCase()] ?? term;
    });

    // Ensure EVERY single English word in any context is dynamically transliterated to Devanagari script via Gemini/fallback
    normalizedText = await HindiToMundariTranslator.ensureFullDevanagari(normalizedText);

    if (_sherpaTts != null) {
      try {
        debugPrint('[TTS] Synthesizing speech using local Sherpa-ONNX Mundari TTS model...');
        final audio = _sherpaTts!.generate(text: normalizedText, sid: 0, speed: 1.0);
        final samples = audio.samples;
        final sampleRate = audio.sampleRate;
        if (samples.isNotEmpty) {
          final wavBytes = _createWavBytes(samples, sampleRate);
          final tempDir = await getTemporaryDirectory();
          final tempWav = File('${tempDir.path}/mundari_tts_output.wav');
          await tempWav.writeAsBytes(wavBytes);
          await _audioPlayer.stop();
          await _audioPlayer.play(DeviceFileSource(tempWav.path));
          debugPrint('[TTS] Playing synthesized Mundari ONNX audio ✓');
          return;
        }
      } catch (e) {
        debugPrint('[TTS] Sherpa synthesis error, fallback to flutter_tts: $e');
      }
    }

    await speak(normalizedText);
  }

  Uint8List _createWavBytes(Float32List samples, int sampleRate) {
    final numSamples = samples.length;
    final numChannels = 1;
    final bitsPerSample = 16;
    final byteRate = sampleRate * numChannels * (bitsPerSample ~/ 8);
    final blockAlign = numChannels * (bitsPerSample ~/ 8);
    final dataSize = numSamples * (bitsPerSample ~/ 8);
    final chunkSize = 36 + dataSize;

    final bytes = ByteData(44 + dataSize);
    // RIFF
    bytes.setUint8(0, 0x52); bytes.setUint8(1, 0x49); bytes.setUint8(2, 0x46); bytes.setUint8(3, 0x46);
    bytes.setUint32(4, chunkSize, Endian.little);
    // WAVE
    bytes.setUint8(8, 0x57); bytes.setUint8(9, 0x41); bytes.setUint8(10, 0x56); bytes.setUint8(11, 0x45);
    // fmt 
    bytes.setUint8(12, 0x66); bytes.setUint8(13, 0x6D); bytes.setUint8(14, 0x74); bytes.setUint8(15, 0x20);
    bytes.setUint32(16, 16, Endian.little);
    bytes.setUint16(20, 1, Endian.little);
    bytes.setUint16(22, numChannels, Endian.little);
    bytes.setUint32(24, sampleRate, Endian.little);
    bytes.setUint32(28, byteRate, Endian.little);
    bytes.setUint16(32, blockAlign, Endian.little);
    bytes.setUint16(34, bitsPerSample, Endian.little);
    // data
    bytes.setUint8(36, 0x64); bytes.setUint8(37, 0x61); bytes.setUint8(38, 0x74); bytes.setUint8(39, 0x61);
    bytes.setUint32(40, dataSize, Endian.little);

    int offset = 44;
    for (int i = 0; i < numSamples; i++) {
      double sample = samples[i].clamp(-1.0, 1.0);
      int val = (sample * 32767).toInt();
      bytes.setInt16(offset, val, Endian.little);
      offset += 2;
    }

    return bytes.buffer.asUint8List();
  }

  /// Synthesize and play a word (English) together with its Devanagari
  /// representation (if provided).
  Future<void> speakWordAndMundari(String word, String? mundari) async {
    if (!_initialized) await init();
    
    final String combined = mundari != null ? '$word, $mundari' : word;

    try {
      final bool isHindi = RegExp(r'[\u0900-\u097F]').hasMatch(combined);
      
      if (isHindi) {
          await _flutterTts.setLanguage('hi-IN');
      } else {
          await _flutterTts.setLanguage('en-US');
      }
      
      await _flutterTts.stop();
      await _flutterTts.speak(combined);
    } catch (e) {
      debugPrint('Audio playback error: $e');
    }
  }
}
