import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/rag_config.dart';
import '../pipeline/demo_cache_manager.dart';
import 'mt_translation_service.dart';

enum TranslationSource { demoCache, realTime }

class S2STranslationResult {
  final String hindiText;
  final String mundariText;
  final String? audioPath;
  final Uint8List? audioBytes;
  final TranslationSource source;
  final int latencyMs;
  final int? cacheEntryId;

  S2STranslationResult({
    required this.hindiText,
    required this.mundariText,
    this.audioPath,
    this.audioBytes,
    required this.source,
    required this.latencyMs,
    this.cacheEntryId,
  });

  bool get isCacheHit => source == TranslationSource.demoCache;
  bool get isRealTime => source == TranslationSource.realTime;
}

// Mock interfaces for pipeline components
class HindiSpeechToText {
  Future<String> transcribeHindiAudio(String audioFilePath) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return 'तुम्हारे कितने हाथ हैं?'; 
  }
}

class HindiToMundariTranslator {
  static final Dio _dio = Dio();

  /// Map of English loanwords to Devanagari transliteration for single-pass Mundari TTS
  static final Map<String, String> loanwordDevanagariMap = {
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

  /// Dynamic cache for dynamically transliterated loanwords
  static final Map<String, String> _dynamicCache = Map.from(loanwordDevanagariMap);

  /// Dynamically transliterates any list of English words into Devanagari phonemes using Gemini API
  /// with offline fallback to rule-based phoneme mapping.
  static Future<Map<String, String>> transliterateWords(List<String> words) async {
    final unmapped = <String>[];
    final result = <String, String>{};

    for (final w in words) {
      final key = w.toLowerCase().trim();
      if (key.isEmpty) continue;
      if (_dynamicCache.containsKey(key)) {
        result[key] = _dynamicCache[key]!;
      } else {
        unmapped.add(key);
      }
    }

    if (unmapped.isEmpty) return result;

    // Call Gemini to dynamically transliterate all unmapped English words
    if (kGeminiApiKey.isNotEmpty && kGeminiApiKey != 'YOUR_GEMINI_API_KEY_HERE') {
      try {
        final url =
            'https://generativelanguage.googleapis.com/v1beta/models/$kGeminiModel:generateContent?key=$kGeminiApiKey';
        final prompt = '''
Transliterate the following English loanwords/terms into Devanagari script phonemes suitable for Hindi/Mundari primary school instruction.
Return ONLY valid JSON mapping each lowercase English word to its Devanagari transliteration.
Words: ${unmapped.join(', ')}
JSON Example: {"blackboard": "ब्लैकबोर्ड", "science": "साइंस"}
''';

        final response = await _dio.post(
          url,
          data: {
            'contents': [
              {
                'role': 'user',
                'parts': [
                  {'text': prompt}
                ]
              }
            ],
            'generationConfig': {
              'temperature': 0.1,
              'responseMimeType': 'application/json',
            },
          },
          options: Options(
            headers: {'Content-Type': 'application/json'},
            sendTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        );

        final candidates = response.data['candidates'] as List<dynamic>?;
        if (candidates != null && candidates.isNotEmpty) {
          final rawText = candidates.first['content']['parts'][0]['text'] as String;
          final jsonMap = jsonDecode(rawText) as Map<String, dynamic>;
          jsonMap.forEach((k, v) {
            final wordKey = k.toLowerCase().trim();
            final devVal = v.toString();
            _dynamicCache[wordKey] = devVal;
            result[wordKey] = devVal;
            unmapped.remove(wordKey);
          });
        }
      } catch (e) {
        debugPrint('[MT Transliteration] Gemini call error: $e — using rule-based fallback');
      }
    }

    // Rule-based fallback for any remaining unmapped words
    for (final w in unmapped) {
      final devVal = ruleBasedTransliterate(w);
      _dynamicCache[w] = devVal;
      result[w] = devVal;
    }

    return result;
  }

  /// Rule-based fallback converter for English graphemes to Devanagari phonemes
  static String ruleBasedTransliterate(String word) {
    String w = word.toLowerCase();

    w = w.replaceAll('tion', 'शन');
    w = w.replaceAll('sion', 'जन');
    w = w.replaceAll('sch', 'स्क');
    w = w.replaceAll('ch', 'च');
    w = w.replaceAll('sh', 'श');
    w = w.replaceAll('th', 'थ');
    w = w.replaceAll('ph', 'फ');
    w = w.replaceAll('kh', 'ख');
    w = w.replaceAll('gh', 'घ');
    w = w.replaceAll('bh', 'भ');
    w = w.replaceAll('dh', 'ध');
    w = w.replaceAll('ck', 'क');
    w = w.replaceAll('ee', 'ी');
    w = w.replaceAll('oo', 'ू');
    w = w.replaceAll('ea', 'ी');
    w = w.replaceAll('ai', 'ै');
    w = w.replaceAll('ou', 'ौ');
    w = w.replaceAll('ow', 'ौ');

    final charMap = {
      'a': 'ा', 'b': 'ब', 'c': 'क', 'd': 'ड', 'e': 'े',
      'f': 'फ', 'g': 'ग', 'h': 'ह', 'i': 'ि', 'j': 'ज',
      'k': 'क', 'l': 'ल', 'm': 'म', 'n': 'न', 'o': 'ो',
      'p': 'प', 'q': 'क', 'r': 'र', 's': 'स', 't': 'ट',
      'u': 'ु', 'v': 'व', 'w': 'व', 'x': 'क्स', 'y': 'य', 'z': 'ज़',
    };

    final buffer = StringBuffer();
    for (int i = 0; i < w.length; i++) {
      final ch = w[i];
      if (charMap.containsKey(ch)) {
        buffer.write(charMap[ch]);
      } else {
        buffer.write(ch);
      }
    }
    return buffer.toString();
  }

  /// Ensures that any text containing English words is dynamically transliterated into 100% Devanagari script.
  static Future<String> ensureFullDevanagari(String text) async {
    final engWordRegex = RegExp(r'\b[a-zA-Z]{2,}\b');
    final matches = engWordRegex.allMatches(text).map((m) => m.group(0)!).toSet().toList();
    if (matches.isEmpty) return text;

    final map = await transliterateWords(matches);
    String result = text;

    for (final match in matches) {
      final dev = map[match.toLowerCase()] ?? ruleBasedTransliterate(match);
      result = result.replaceAll(RegExp(r'\b' + match + r'\b', caseSensitive: false), dev);
    }

    return result;
  }

  Future<String> translateHindiToMundari(String hindiText) async {
    final mt = MtTranslationService();
    try {
      await mt.loadModel(numThreads: 2);
      return await mt.translateToMundari(hindiText);
    } finally {
      await mt.unloadModel();
    }
  }

  /// Translates Hindi text to Mundari while protecting tagged English loanwords ({ENG:...}).
  /// Masks {ENG:term} -> __ENG_i__ -> runs NMT -> unmasks to Devanagari transliterated English.
  Future<String> translateHindiToMundariWithProtection(String hindiText) async {
    final loanwordMatches = RegExp(r'\{ENG:([^}]+)\}').allMatches(hindiText).toList();

    if (loanwordMatches.isNotEmpty) {
      final savedTerms = <String>[];
      String maskedHindi = hindiText;
      for (int i = 0; i < loanwordMatches.length; i++) {
        final match = loanwordMatches[i];
        final term = match.group(1) ?? '';
        savedTerms.add(term);
        maskedHindi = maskedHindi.replaceFirst(match.group(0)!, '__ENG_${i}__');
      }

      String translatedMundari = await translateHindiToMundari(maskedHindi);

      // Dynamically transliterate all saved English terms via Gemini / fallback
      final transliteratedMap = await transliterateWords(savedTerms);

      for (int i = 0; i < savedTerms.length; i++) {
        final origTerm = savedTerms[i];
        final lowerTerm = origTerm.toLowerCase();
        final devanagariReplacement = transliteratedMap[lowerTerm] ?? ruleBasedTransliterate(origTerm);
        translatedMundari = translatedMundari.replaceAll('__ENG_${i}__', devanagariReplacement);
      }

      return ensureFullDevanagari(translatedMundari);
    }

    final translated = await translateHindiToMundari(hindiText);
    return ensureFullDevanagari(translated);
  }
}

class MundariTextToSpeech {
  Future<Uint8List> synthesizeMundariSpeech(String mundariText) async {
    await Future.delayed(const Duration(seconds: 1));
    return Uint8List(0); // Mock empty audio bytes
  }
}

class SpeechToSpeechService {
  final DemoCacheManager _cacheManager = DemoCacheManager();
  final HindiSpeechToText stt;
  final HindiToMundariTranslator mt;
  final MundariTextToSpeech tts;
  final bool useDemoCache;

  SpeechToSpeechService({
    required this.stt,
    required this.mt,
    required this.tts,
    this.useDemoCache = true,
  });

  Future<void> initialize() async {
    if (useDemoCache) {
      await _cacheManager.initialize();
    }
  }

  Future<S2STranslationResult> translateSpeech({
    required String audioFilePath,
    bool forceRealTime = false,
  }) async {
    final startTime = DateTime.now();

    // 1. Hindi STT
    final hindiText = await stt.transcribeHindiAudio(audioFilePath);

    // 2. Check cache
    if (useDemoCache && !forceRealTime) {
      final cached = _cacheManager.findByHindiText(hindiText);
      if (cached != null) {
        return S2STranslationResult(
          hindiText: hindiText,
          mundariText: cached.mundariDevanagari,
          audioPath: _cacheManager.getAudioAssetPath(cached),
          audioBytes: null,
          source: TranslationSource.demoCache,
          latencyMs: DateTime.now().difference(startTime).inMilliseconds,
          cacheEntryId: cached.id,
        );
      }
    }

    // 3. Full pipeline (MT + TTS)
    final mundariText = await mt.translateHindiToMundari(hindiText);
    final audioBytes = await tts.synthesizeMundariSpeech(mundariText);

    return S2STranslationResult(
      hindiText: hindiText,
      mundariText: mundariText,
      audioPath: null,
      audioBytes: audioBytes,
      source: TranslationSource.realTime,
      latencyMs: DateTime.now().difference(startTime).inMilliseconds,
      cacheEntryId: null,
    );
  }
}
