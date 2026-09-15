import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../config/rag_config.dart';
import '../rag/models/rag_flashcard.dart';
import '../rag/models/rag_quiz.dart';
import '../rag/models/rag_worksheet.dart';

enum GenerationArtifactType { flashcard, quiz, worksheet }

/// Service that calls the Gemini API to generate educational content
/// (Flashcards, Quizzes, Worksheets) for a given chapter, then translates
/// them to Mundari using an MT service. Results are cached on-device.
class ContentGenerationService {
  final Dio _dio;

  ContentGenerationService() : _dio = Dio();

  // ── Cache helpers ──────────────────────────────────────────────────────────

  Future<Directory> _cacheDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final rag = Directory('${dir.path}/rag_cache');
    if (!rag.existsSync()) rag.createSync(recursive: true);
    return rag;
  }

  String _cacheKey(String chapterName, GenerationArtifactType type) {
    final safe = chapterName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
    final typeName = type.name;
    return '${typeName}_$safe.json';
  }

  Future<Map<String, dynamic>?> _loadCache(
      String chapterName, GenerationArtifactType type) async {
    try {
      final dir = await _cacheDir();
      final file = File('${dir.path}/${_cacheKey(chapterName, type)}');
      if (file.existsSync()) {
        final raw = await file.readAsString();
        return jsonDecode(raw) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('[RAG] Cache read error: $e');
    }
    return null;
  }

  Future<void> _saveCache(String chapterName, GenerationArtifactType type,
      Map<String, dynamic> data) async {
    try {
      final dir = await _cacheDir();
      final file = File('${dir.path}/${_cacheKey(chapterName, type)}');
      await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
    } catch (e) {
      debugPrint('[RAG] Cache write error: $e');
    }
  }

  Future<bool> isCached(String chapterName, GenerationArtifactType type) async {
    final dir = await _cacheDir();
    return File('${dir.path}/${_cacheKey(chapterName, type)}').existsSync();
  }

  // ── Gemini API ─────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> _callGemini(String prompt) async {
    if (kGeminiApiKey == 'YOUR_GEMINI_API_KEY_HERE' || kGeminiApiKey.isEmpty) {
      throw StateError(
          'Gemini API key not set. Please update lib/config/rag_config.dart.');
    }
    const model = kGeminiModel;
    final url =
        'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$kGeminiApiKey';

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
          'temperature': 0.2,
          'responseMimeType': 'application/json',
        },
      },
      options: Options(
        headers: {'Content-Type': 'application/json'},
        sendTimeout: const Duration(seconds: 90),
        receiveTimeout: const Duration(seconds: 90),
      ),
    );

    final candidates = response.data['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      throw Exception('Gemini returned no candidates');
    }
    final rawText = candidates.first['content']['parts'][0]['text'] as String;
    return jsonDecode(rawText) as Map<String, dynamic>;
  }

  // ── MT Translation ─────────────────────────────────────────────────────────

  Future<List<String>> _translateBatch(List<String> hindiTexts) async {
    if (hindiTexts.isEmpty) return [];

    // If no MT endpoint configured, use mock (prepend [मुंडारी] prefix)
    if (kMtEndpointUrl.isEmpty) {
      debugPrint('[RAG] No MT endpoint configured — using MockMTService');
      return hindiTexts.map((t) => '[मुंडारी] $t').toList();
    }

    try {
      final response = await _dio.post(
        kMtEndpointUrl,
        data: {
          'inputs': hindiTexts,
          'src_lang': 'hin_Deva',
          'tgt_lang': 'unr_Deva',
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );
      final data = response.data;
      if (data is List) return data.map((e) => e.toString()).toList();
      if (data is Map && data.containsKey('translations')) {
        return (data['translations'] as List<dynamic>)
            .map((e) => e.toString())
            .toList();
      }
      if (data is Map && data.containsKey('translated_texts')) {
        return (data['translated_texts'] as List<dynamic>)
            .map((e) => e.toString())
            .toList();
      }
      throw Exception('Unexpected MT response format: $data');
    } catch (e) {
      debugPrint('[RAG] MT translation error: $e — falling back to mock');
      return hindiTexts.map((t) => '[मुंडारी] $t').toList();
    }
  }

  // ── Flashcard Generation ───────────────────────────────────────────────────

  Future<RagFlashcardSet> generateFlashcards(
      String chapterName, String className, {bool forceRefresh = false, String subject = 'Hindi'}) async {
    // Check cache first
    if (!forceRefresh) {
      final cached = await _loadCache(chapterName, GenerationArtifactType.flashcard);
      if (cached != null) {
        debugPrint('[RAG] Loaded flashcards from cache for "$chapterName"');
        return RagFlashcardSet.fromJson(cached);
      }
    }

    debugPrint('[RAG] Generating flashcards via Gemini for "$chapterName" (subject: $subject)...');

    // Determine content language based on subject
    final isEnglish = subject.toLowerCase() == 'english';
    final contentLang = isEnglish ? 'English' : 'Hindi';
    final exampleWord = isEnglish ? 'Eye' : 'आँख';
    final exampleMeaning = isEnglish
        ? 'The organ used for seeing'
        : 'देखने का अंग';

    final prompt = '''
You are an educational content creator for Indian primary school students (Grade: $className, Subject: $subject).
Generate a set of 8 vocabulary flashcards for the chapter: "$chapterName".
Each flashcard should be a key concept, object, or word from the chapter.

IMPORTANT: Since this is a $subject subject, ALL words and meanings MUST be in $contentLang.
Do NOT use Hindi if the subject is English. Do NOT use English words if the subject is Hindi.

Return ONLY valid JSON matching this exact schema (no markdown, no explanation):
{
  "id": "fc_${chapterName.toLowerCase().replaceAll(' ', '_')}",
  "title": "$chapterName",
  "chapterName": "$chapterName",
  "cards": [
    {
      "id": "fc_001",
      "word": "$exampleWord",
      "meaning": "$exampleMeaning",
      "emoji": "👁️"
    }
  ]
}
''';

    final hindiJson = await _callGemini(prompt);

    // Extract all strings for translation
    final cards = (hindiJson['cards'] as List<dynamic>? ?? []);
    final toTranslate = <String>[];
    for (final card in cards) {
      toTranslate.add(card['word'] as String? ?? '');
      toTranslate.add(card['meaning'] as String? ?? '');
    }
    toTranslate.add(hindiJson['title'] as String? ?? chapterName);

    final translated = await _translateBatch(toTranslate);

    // Reconstruct with Mundari translations
    int tIdx = 0;
    final mundariCards = <Map<String, dynamic>>[];
    for (int i = 0; i < cards.length; i++) {
      final card = cards[i] as Map<String, dynamic>;
      mundariCards.add({
        'id': card['id'],
        'word': card['word'],
        'word_mundari': translated[tIdx++],
        'meaning': card['meaning'],
        'meaning_mundari': translated[tIdx++],
        'emoji': card['emoji'],
      });
    }

    final titleMundari = translated[tIdx];
    final resultJson = {
      'id': hindiJson['id'],
      'title': hindiJson['title'],
      'title_mundari': titleMundari,
      'chapterName': chapterName,
      'cards': mundariCards,
    };

    await _saveCache(chapterName, GenerationArtifactType.flashcard, resultJson);
    return RagFlashcardSet.fromJson(resultJson);
  }

  // ── Quiz Generation ────────────────────────────────────────────────────────

  Future<RagQuiz> generateQuiz(String chapterName, String className, {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await _loadCache(chapterName, GenerationArtifactType.quiz);
      if (cached != null) {
        debugPrint('[RAG] Loaded quiz from cache for "$chapterName"');
        return RagQuiz.fromJson(cached);
      }
    }

    debugPrint('[RAG] Generating quiz via Gemini for "$chapterName"...');

    final prompt = '''
You are an educational content creator for Indian primary school students (Grade: $className).
Generate a 10-question multiple-choice quiz for the chapter: "$chapterName".
Each question should have:
- A clear question in Hindi
- 4 options in Hindi
- The correct answer index (0-based integer)
- A brief explanation in Hindi
- A difficulty level: "easy", "medium", or "hard"
- Points: 1 for easy, 2 for medium, 3 for hard

Return ONLY valid JSON matching this exact schema (no markdown, no explanation):
{
  "id": "quiz_${chapterName.toLowerCase().replaceAll(' ', '_')}",
  "title": "Quiz title in Hindi",
  "chapterName": "$chapterName",
  "durationMinutes": 15,
  "totalPoints": 15,
  "questions": [
    {
      "id": "q_001",
      "question": "Hindi question here",
      "options": ["Option A", "Option B", "Option C", "Option D"],
      "answerIndex": 0,
      "explanation": "Brief Hindi explanation",
      "difficulty": "easy",
      "points": 1
    }
  ]
}
''';

    final hindiJson = await _callGemini(prompt);

    final questions = (hindiJson['questions'] as List<dynamic>? ?? []);
    final toTranslate = <String>[];
    for (final q in questions) {
      toTranslate.add(q['question'] as String? ?? '');
      toTranslate.addAll(
          (q['options'] as List<dynamic>? ?? []).map((e) => e.toString()));
      toTranslate.add(q['explanation'] as String? ?? '');
    }

    final translated = await _translateBatch(toTranslate);

    int tIdx = 0;
    final mundariQuestions = <Map<String, dynamic>>[];
    for (final q in questions) {
      final qMap = q as Map<String, dynamic>;
      final optionCount = (qMap['options'] as List<dynamic>? ?? []).length;
      mundariQuestions.add({
        ...qMap,
        'question_mundari': translated[tIdx++],
        'options_mundari': translated.sublist(tIdx, tIdx + optionCount),
        'explanation_mundari': translated[tIdx + optionCount],
      });
      tIdx += optionCount + 1;
    }

    final resultJson = {
      ...hindiJson,
      'chapterName': chapterName,
      'questions': mundariQuestions,
    };

    await _saveCache(chapterName, GenerationArtifactType.quiz, resultJson);
    return RagQuiz.fromJson(resultJson);
  }

  // ── Worksheet Generation ───────────────────────────────────────────────────

  Future<RagWorksheet> generateWorksheet(
      String chapterName, String className, {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached =
          await _loadCache(chapterName, GenerationArtifactType.worksheet);
      if (cached != null) {
        debugPrint('[RAG] Loaded worksheet from cache for "$chapterName"');
        return RagWorksheet.fromJson(cached);
      }
    }

    debugPrint('[RAG] Generating worksheet via Gemini for "$chapterName"...');

    final prompt = '''
You are an educational content creator for Indian primary school students (Grade: $className).
Generate a worksheet for the chapter: "$chapterName" with three sections:
1. Fill in the blanks (5 items) — with a blank marked as "______" and a word bank
2. Match the following (5 pairs) — Column A to Column B
3. Short answer questions (3 items) — with a sample answer and max marks

All text must be in Hindi.

Return ONLY valid JSON matching this exact schema (no markdown, no explanation):
{
  "id": "ws_${chapterName.toLowerCase().replaceAll(' ', '_')}",
  "title": "Worksheet title in Hindi",
  "chapterName": "$chapterName",
  "fillInTheBlanks": [
    {
      "id": "fib_001",
      "promptWithBlank": "Sentence with ______ blank in Hindi",
      "answer": "correct word",
      "wordBank": ["word1", "word2", "word3", "word4", "word5"]
    }
  ],
  "matchPairs": [
    {
      "id": "mp_001",
      "columnA": "Term in Hindi",
      "columnB": "Definition in Hindi"
    }
  ],
  "shortAnswers": [
    {
      "id": "sa_001",
      "question": "Short answer question in Hindi",
      "sampleAnswer": "Sample answer in Hindi",
      "maxMarks": 2
    }
  ]
}
''';

    final hindiJson = await _callGemini(prompt);

    // Collect all strings for translation
    final toTranslate = <String>[];
    final fibs = hindiJson['fillInTheBlanks'] as List<dynamic>? ?? [];
    final mps = hindiJson['matchPairs'] as List<dynamic>? ?? [];
    final sas = hindiJson['shortAnswers'] as List<dynamic>? ?? [];

    for (final fib in fibs) {
      toTranslate.add((fib as Map)['promptWithBlank'] as String? ?? '');
      toTranslate.add(fib['answer'] as String? ?? '');
      toTranslate.addAll((fib['wordBank'] as List<dynamic>? ?? []).map((e) => e.toString()));
    }
    for (final mp in mps) {
      toTranslate.add((mp as Map)['columnA'] as String? ?? '');
      toTranslate.add(mp['columnB'] as String? ?? '');
    }
    for (final sa in sas) {
      toTranslate.add((sa as Map)['question'] as String? ?? '');
      toTranslate.add(sa['sampleAnswer'] as String? ?? '');
    }

    final translated = await _translateBatch(toTranslate);
    int tIdx = 0;

    final mundariFibs = <Map<String, dynamic>>[];
    for (final fib in fibs) {
      final fibMap = fib as Map<String, dynamic>;
      final wbCount = (fibMap['wordBank'] as List<dynamic>? ?? []).length;
      mundariFibs.add({
        ...fibMap,
        'promptWithBlank_mundari': translated[tIdx++],
        'answer_mundari': translated[tIdx++],
        'wordBank_mundari': translated.sublist(tIdx, tIdx + wbCount),
      });
      tIdx += wbCount;
    }

    final mundariMps = <Map<String, dynamic>>[];
    for (final mp in mps) {
      mundariMps.add({
        ...(mp as Map<String, dynamic>),
        'columnA_mundari': translated[tIdx++],
        'columnB_mundari': translated[tIdx++],
      });
    }

    final mundariSas = <Map<String, dynamic>>[];
    for (final sa in sas) {
      mundariSas.add({
        ...(sa as Map<String, dynamic>),
        'question_mundari': translated[tIdx++],
        'sampleAnswer_mundari': translated[tIdx++],
      });
    }

    final resultJson = {
      ...hindiJson,
      'chapterName': chapterName,
      'fillInTheBlanks': mundariFibs,
      'matchPairs': mundariMps,
      'shortAnswers': mundariSas,
    };

    await _saveCache(chapterName, GenerationArtifactType.worksheet, resultJson);
    return RagWorksheet.fromJson(resultJson);
  }

  /// Generates all three artifact types for a chapter simultaneously.
  Future<void> generateAll(String chapterName, String className, {bool forceRefresh = false}) async {
    await Future.wait([
      generateFlashcards(chapterName, className, forceRefresh: forceRefresh),
      generateQuiz(chapterName, className, forceRefresh: forceRefresh),
      generateWorksheet(chapterName, className, forceRefresh: forceRefresh),
    ]);
  }
}
