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
    if (_isInitializing) return;

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
            lexicon: '',
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

  /// Transliterate Devanagari text to Latin phonemes compatible with Sherpa-ONNX VITS model tokens.txt
  static String devanagariToPhonemes(String text) {
    if (text.isEmpty) return text;
    // If text contains no Devanagari, return as-is
    if (!RegExp(r'[\u0900-\u097F]').hasMatch(text)) {
      return text.toLowerCase();
    }

    // Normalize nukta variations (composite vs combining nukta)
    String input = text
        .replaceAll('ड़', 'r')
        .replaceAll('ढ़', 'rh')
        .replaceAll('ड़', 'r')
        .replaceAll('ढ़', 'rh')
        .replaceAll('फ़', 'f')
        .replaceAll('ज़', 'z');

    final Map<String, String> vowels = {
      'अ': 'a', 'आ': 'a', 'इ': 'i', 'ई': 'i', 'उ': 'u', 'ऊ': 'u',
      'ऋ': 'ri', 'ए': 'e', 'ऐ': 'ai', 'ओ': 'o', 'औ': 'au', 'अं': 'an', 'अः': 'ah',
    };

    final Map<String, String> matras = {
      'ा': 'a', 'ि': 'i', 'ी': 'i', 'ु': 'u', 'ू': 'u', 'ृ': 'ri',
      'े': 'e', 'ै': 'ai', 'ो': 'o', 'ौ': 'au', 'ं': 'n', 'ः': 'h',
      'ॅ': 'e', 'ॉ': 'o',
    };

    final Map<String, String> consonants = {
      'क': 'k', 'ख': 'kh', 'ग': 'g', 'घ': 'gh', 'ङ': 'ng',
      'च': 'c', 'छ': 'ch', 'ज': 'j', 'झ': 'jh', 'ञ': 'ny',
      'ट': 't', 'ठ': 'th', 'ड': 'd', 'ढ': 'dh', 'ण': 'n',
      'त': 't', 'थ': 'th', 'द': 'd', 'ध': 'dh', 'न': 'n',
      'प': 'p', 'फ': 'f', 'ब': 'b', 'भ': 'bh', 'म': 'm',
      'य': 'y', 'र': 'r', 'ल': 'l', 'व': 'v',
      'श': 'sh', 'ष': 'sh', 'स': 's', 'ह': 'h',
    };

    final StringBuffer sb = StringBuffer();
    final runes = input.runes.toList();
    final int len = runes.length;

    for (int i = 0; i < len; i++) {
      final String char = String.fromCharCode(runes[i]);

      // Ignore combining nukta U+093C if encountered standalone
      if (char == '़') continue;

      // Independent Vowels
      if (vowels.containsKey(char)) {
        sb.write(vowels[char]);
        continue;
      }

      // Consonants
      if (consonants.containsKey(char)) {
        String base = consonants[char]!;

        // Check next char for nukta, matra, or virama
        if (i + 1 < len) {
          final String nextChar = String.fromCharCode(runes[i + 1]);

          if (nextChar == '़') {
            if (base == 'd') {
              base = 'r';
            } else if (base == 'dh') {
              base = 'rh';
            } else if (base == 'j') {
              base = 'z';
            } else if (base == 'f') {
              base = 'f';
            }
            i++; // skip nukta
          }
        }

        // Re-check next char after optional nukta
        if (i + 1 < len) {
          final String nextChar = String.fromCharCode(runes[i + 1]);

          if (nextChar == '्') {
            // Virama (halant): suppress inherent 'a'
            sb.write(base);
            i++; // skip virama
            continue;
          } else if (matras.containsKey(nextChar)) {
            // Matra present: write base consonant + matra vowel
            sb.write(base);
            sb.write(matras[nextChar]);
            i++; // skip matra
            continue;
          }
        }

        // Check if consonant is at word end or before non-Devanagari char (schwa deletion)
        bool isWordEnd = true;
        if (i + 1 < len) {
          final String nextChar = String.fromCharCode(runes[i + 1]);
          if (RegExp(r'[\u0900-\u097F]').hasMatch(nextChar)) {
            isWordEnd = false;
          }
        }

        if (isWordEnd) {
          sb.write(base);
        } else {
          sb.write('${base}a');
        }
        continue;
      }

      // Matras standalone
      if (matras.containsKey(char)) {
        sb.write(matras[char]);
        continue;
      }

      // Preserve non-Devanagari characters (spaces, punctuation, digits, Latin letters)
      sb.write(char.toLowerCase());
    }

    return sb.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Synthesize and play general text
  Future<void> speak(String text) async {
    await speakCodeMixedClassroomScript(text);
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

    // Convert Devanagari text to Latin phonemes for Sherpa-ONNX model
    final String phoneticText = devanagariToPhonemes(normalizedText);

    if (_sherpaTts != null) {
      try {
        debugPrint('[TTS] Synthesizing speech for "$phoneticText" (from "$normalizedText") using local Sherpa-ONNX Mundari TTS model...');
        final audio = _sherpaTts!.generate(text: phoneticText, sid: 0, speed: 1.0);
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

    // Fallback to flutter_tts
    await speakWordAndMundari(normalizedText, null);
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
