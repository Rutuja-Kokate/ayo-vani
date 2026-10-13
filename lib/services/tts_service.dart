import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:ayo_vani/engine/audio_playback_worker.dart';
import 'package:ayo_vani/engine/hindi_tts_service.dart';
import 'package:ayo_vani/engine/loanwords.dart';
import 'package:ayo_vani/engine/pipeline.dart' show TranslationDirection;
import 'package:ayo_vani/engine/tts_stage.dart';

/// Thin service wrapper that synthesises speech offline using Sherpa-ONNX Mundari TTS via TtsStage
/// and Hindi speech via HindiTtsService / flutter_tts.
class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final TtsStage _ttsStage = TtsStage(threads: 2, provider: 'cpu');
  bool _initialized = false;
  bool _isInitializing = false;

  /// Expose loanword phonetic map for backwards compatibility
  static Map<String, String> get loanwordPhoneticMap => kLoanwordPhoneticMap;

  /// Initialise the service. Must be called before any playback.
  Future<void> init() async {
    if (_initialized) return;
    if (_isInitializing) return;

    _isInitializing = true;

    try {
      await HindiTtsService.instance.init();
      await _flutterTts.setLanguage('hi-IN');
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setPitch(1.0);
      await _flutterTts.awaitSpeakCompletion(true);

      // Initialize on-device Mundari TTS stage
      await _ttsStage.initModel();
    } catch (e) {
      debugPrint('TTS Init error: $e');
    } finally {
      _initialized = true;
      _isInitializing = false;
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
      await HindiTtsService.instance.stop();
      await _flutterTts.stop();
      await _audioPlayer.stop();
    } catch (e) {
      debugPrint('TTS Stop error: $e');
    }
  }

  /// Synthesize and play general text
  Future<void> speak(String text) async {
    await speakCodeMixedClassroomScript(text);
  }

  /// Synthesize and play Hindi text directly using HindiTtsService (hi-IN voice).
  Future<void> speakHindi(String text) async {
    if (!_initialized) await init();
    final ok = await HindiTtsService.instance.speak(text);
    if (!ok) {
      try {
        await _flutterTts.setLanguage('hi-IN');
        await _flutterTts.stop();
        await _flutterTts.speak(text);
      } catch (e) {
        debugPrint('Hindi TTS playback fallback error: $e');
      }
    }
  }

  /// Synthesize and play code-mixed (Mundari + English) classroom scripts using local ONNX Mundari TTS.
  Future<void> speakCodeMixedClassroomScript(String scriptText) async {
    if (!_initialized) await init();

    String normalizedText = scriptText;

    // Unmask tagged {ENG:term} placeholders
    normalizedText = normalizedText.replaceAllMapped(
      RegExp(r'\{ENG:([^}]+)\}'),
      (match) {
        final term = match.group(1) ?? '';
        return kLoanwordPhoneticMap[term.toLowerCase()] ?? term;
      },
    );

    // Normalize English loanwords to Devanagari phonetics
    normalizedText = replaceLoanwords(normalizedText);

    try {
      if (!_ttsStage.isInitialized) {
        await _ttsStage.initModel();
      }

      final result = await _ttsStage.synthesize(
        normalizedText,
        direction: TranslationDirection.hindiToMundari,
      );

      if (result.audioBytes.isNotEmpty) {
        final wavBytes = AudioPlaybackWorker.pcmToWav(
          result.audioBytes,
          sampleRate: result.sampleRate,
        );

        await _audioPlayer.stop();
        await _audioPlayer.play(BytesSource(wavBytes));
        debugPrint('[TTS] Playing synthesized Mundari ONNX audio ✓');
        return;
      }
    } catch (e) {
      debugPrint('[TTS] Mundari synthesis error, fallback to HindiTtsService: $e');
    }

    // Fallback to Hindi offline TTS
    await speakHindi(normalizedText);
  }

  /// Synthesize and play a word (English) together with its Devanagari
  /// representation (if provided).
  Future<void> speakWordAndMundari(String word, String? mundari) async {
    if (!_initialized) await init();

    if (mundari != null && mundari.isNotEmpty) {
      await speakCodeMixedClassroomScript('$word, $mundari');
    } else {
      try {
        final isHindi = RegExp(r'[\u0900-\u097F]').hasMatch(word);
        if (isHindi) {
          await speakHindi(word);
        } else {
          await _flutterTts.setLanguage('en-US');
          await _flutterTts.stop();
          await _flutterTts.speak(word);
        }
      } catch (e) {
        debugPrint('Audio playback error: $e');
      }
    }
  }

  /// Transliterate Devanagari text to Latin phonemes compatible with Sherpa-ONNX VITS model tokens.txt
  static String devanagariToPhonemes(String text) {
    if (text.isEmpty) return text;
    if (!RegExp(r'[\u0900-\u097F]').hasMatch(text)) {
      return text.toLowerCase();
    }

    String input = text
        .replaceAll('-', ' ')
        .replaceAll('ड़', 'r')
        .replaceAll('ढ़', 'rh')
        .replaceAll('ड़', 'r')
        .replaceAll('ढ़', 'rh')
        .replaceAll('फ़', 'f')
        .replaceAll('ज़', 'z');

    final Map<String, String> vowels = {
      'अ': 'a',
      'आ': 'a',
      'इ': 'i',
      'ई': 'i',
      'उ': 'u',
      'ऊ': 'u',
      'ऋ': 'ri',
      'ए': 'e',
      'ऐ': 'ai',
      'ओ': 'o',
      'औ': 'au',
      'अं': 'an',
      'अः': 'ah',
    };

    final Map<String, String> matras = {
      'ा': 'a',
      'ि': 'i',
      'ी': 'i',
      'ु': 'u',
      'ू': 'u',
      'ृ': 'ri',
      'े': 'e',
      'ै': 'ai',
      'ो': 'o',
      'ौ': 'au',
      'ं': 'n',
      'ः': 'h',
      'ॅ': 'e',
      'ॉ': 'o',
    };

    final Map<String, String> consonants = {
      'क': 'k',
      'ख': 'kh',
      'ग': 'g',
      'घ': 'gh',
      'ङ': 'ng',
      'च': 'c',
      'छ': 'ch',
      'ज': 'j',
      'झ': 'jh',
      'ञ': 'ny',
      'ट': 't',
      'ठ': 'th',
      'ड': 'd',
      'ढ': 'dh',
      'ण': 'n',
      'त': 't',
      'थ': 'th',
      'द': 'd',
      'ध': 'dh',
      'न': 'n',
      'प': 'p',
      'फ': 'f',
      'ब': 'b',
      'भ': 'bh',
      'म': 'm',
      'य': 'y',
      'र': 'r',
      'ल': 'l',
      'व': 'v',
      'श': 'sh',
      'ष': 'sh',
      'स': 's',
      'ह': 'h',
    };

    final StringBuffer sb = StringBuffer();
    final runes = input.runes.toList();
    final int len = runes.length;

    for (int i = 0; i < len; i++) {
      final String char = String.fromCharCode(runes[i]);

      if (char == '़') continue;

      if (vowels.containsKey(char)) {
        sb.write(vowels[char]);
        continue;
      }

      if (consonants.containsKey(char)) {
        String base = consonants[char]!;

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
            i++;
          }
        }

        if (i + 1 < len) {
          final String nextChar = String.fromCharCode(runes[i + 1]);

          if (nextChar == '्') {
            sb.write(base);
            i++;
            continue;
          } else if (matras.containsKey(nextChar)) {
            sb.write(base);
            sb.write(matras[nextChar]);
            i++;
            continue;
          }
        }

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

      if (matras.containsKey(char)) {
        sb.write(matras[char]);
        continue;
      }

      sb.write(char.toLowerCase());
    }

    return sb.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
