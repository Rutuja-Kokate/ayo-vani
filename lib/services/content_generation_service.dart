import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import '../config/rag_config.dart';
import '../data/english_activities_data.dart';
import '../rag/models/rag_flashcard.dart';
import '../rag/models/rag_quiz.dart';
import '../rag/models/rag_worksheet.dart';
import 'mt_translation_service.dart';

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

  final MtTranslationService _mtService = MtTranslationService();

  Future<List<String>> _translateBatch(List<String> hindiTexts) async {
    if (hindiTexts.isEmpty) return [];

    try {
      // Load MT model on 2 threads for batch translation
      await _mtService.loadModel(numThreads: 2);
      return await _mtService.translateBatch(hindiTexts);
    } finally {
      // Always unload MT model when translation completes to free RAM and avoid app crash / device slowdown
      await _mtService.unloadModel();
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

    // Try loading extracted textbook JSON asset index
    final localRAG = await _loadLocalChapterRAG(chapterName);
    final rawVocab = (localRAG?['cards'] as List<dynamic>? ?? []);

    if (rawVocab.isNotEmpty) {
      debugPrint('[RAG] Building flashcards from local extracted textbook assets for "$chapterName"');
      final cardsList = <Map<String, dynamic>>[];
      for (int i = 0; i < rawVocab.length; i++) {
        final item = rawVocab[i] as Map<String, dynamic>;
        cardsList.add({
          'id': 'fc_${i + 1}',
          'word': item['word'] as String? ?? 'शब्द',
          'word_mundari': item['word_mundari'] as String? ?? '[मुंडारी]',
          'meaning': item['meaning'] as String? ?? 'Meaning',
          'meaning_mundari': '[मुंडारी अर्थ]',
          'emoji': item['emoji'] as String? ?? '📖',
          if (item['imageAsset'] != null) 'imageAsset': item['imageAsset'],
        });
      }

      final localResult = {
        'id': 'fc_${chapterName.toLowerCase().replaceAll(' ', '_')}',
        'title': chapterName,
        'title_mundari': '[मुंडारी] $chapterName',
        'chapterName': chapterName,
        'cards': cardsList,
      };

      await _saveCache(chapterName, GenerationArtifactType.flashcard, localResult);
      return RagFlashcardSet.fromJson(localResult);
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

    try {
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
    } catch (e) {
      debugPrint('[RAG] Gemini call failed for flashcards, building dynamic local fallback: $e');
      final fallbackSet = _buildFallbackFlashcards(chapterName, className, localRAG, subject);
      await _saveCache(chapterName, GenerationArtifactType.flashcard, fallbackSet);
      return RagFlashcardSet.fromJson(fallbackSet);
    }
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

    final localRAG = await _loadLocalChapterRAG(chapterName);
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

    try {
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
    } catch (e) {
      debugPrint('[RAG] Gemini call failed for quiz, building dynamic local fallback: $e');
      final fallbackQuiz = _buildFallbackQuiz(chapterName, className, localRAG);
      await _saveCache(chapterName, GenerationArtifactType.quiz, fallbackQuiz);
      return RagQuiz.fromJson(fallbackQuiz);
    }
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

    final localRAG = await _loadLocalChapterRAG(chapterName);
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

    try {
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
    } catch (e) {
      debugPrint('[RAG] Gemini call failed for worksheet, building dynamic local fallback: $e');
      final fallbackWs = _buildFallbackWorksheet(chapterName, className, localRAG);
      await _saveCache(chapterName, GenerationArtifactType.worksheet, fallbackWs);
      return RagWorksheet.fromJson(fallbackWs);
    }
  }

  /// Helper to load extracted textbook JSON index assets from assets/textbook_assets/
  Future<Map<String, dynamic>?> _loadLocalChapterRAG(String chapterName) async {
    final lowerName = chapterName.toLowerCase();
    final cleanSlug = lowerName.replaceAll(RegExp(r'[^a-z0-9]'), '_');

    final candidatePaths = [
      'assets/textbook_assets/${cleanSlug}_index.json',
      'assets/textbook_assets/ch_${cleanSlug}_index.json',
      'assets/textbook_assets/ch_1_${cleanSlug}_index.json',
      'assets/textbook_assets/ch_2_${cleanSlug}_index.json',
      'assets/textbook_assets/ch_1_two_little_hands_index.json',
      'assets/textbook_assets/ch_2_greetings_index.json',
      'assets/textbook_assets/ch_1_the_four_seasons_index.json',
      'assets/textbook_assets/aemr109_index.json',
    ];

    if (lowerName.contains('hand') || lowerName.contains('little') || lowerName.contains('two')) {
      candidatePaths.insert(0, 'assets/textbook_assets/ch_1_two_little_hands_index.json');
    }
    if (lowerName.contains('greet') || lowerName.contains('welcome') || lowerName.contains('namaste')) {
      candidatePaths.insert(0, 'assets/textbook_assets/ch_2_greetings_index.json');
    }
    if (lowerName.contains('season') || lowerName.contains('four') || lowerName.contains('weather')) {
      candidatePaths.insert(0, 'assets/textbook_assets/ch_1_the_four_seasons_index.json');
    }

    for (final path in candidatePaths) {
      try {
        final raw = await rootBundle.loadString(path);
        final parsed = jsonDecode(raw);
        if (parsed is Map<String, dynamic>) {
          debugPrint('[RAG] Loaded local textbook index from $path');
          if (parsed['full_chapter_text'] is String) {
            parsed['full_chapter_text'] = _cleanTextbookText(parsed['full_chapter_text'] as String);
          }
          return parsed;
        } else if (parsed is List<dynamic>) {
          debugPrint('[RAG] Loaded list index from $path');
          return {
            'chapter_slug': cleanSlug,
            'cards': parsed,
          };
        }
      } catch (_) {
        // Continue trying candidates
      }
    }
    return null;
  }

  /// Cleans textbook RAG text: removes reprint headers, Unit/Chapter filler titles, copyright metadata, and cuts off exercises/questions/activities
  String _cleanTextbookText(String text) {
    if (text.isEmpty) return text;

    final lines = text.split('\n').where((line) {
      final l = line.trim().toLowerCase();
      if (l.contains('reprint') ||
          l.contains('2026-2027') ||
          l.contains('2025-2026') ||
          l.contains('2024-2025') ||
          l.contains('2023-2024') ||
          l.contains('isbn') ||
          l.contains('ncert') ||
          l.contains('rationalised') ||
          l.startsWith('page ') ||
          l.startsWith('unit ') ||
          l.startsWith('chapter ') ||
          RegExp(r'^(unit|chapter|खंड|इकाई)\s*[\d\-:]*$', caseSensitive: false).hasMatch(l) ||
          RegExp(r'^\d+\s*$').hasMatch(l)) {
        return false;
      }
      return true;
    }).toList();

    String cleaned = lines.join('\n');

    final cutoffKeywords = [
      'प्रश्न और उत्तर',
      'प्रश्न-उत्तर',
      'बातचीत के लिए',
      'अभ्यास कार्य',
      'अभ्यास',
      'गतिविधि',
      'खाली स्थान',
      'शब्द और अर्थ',
      'Let us talk',
      'Let us do',
      'Exercises',
      'Questions',
      'Group Activity',
      'Pair Activity',
    ];

    for (final kw in cutoffKeywords) {
      final idx = cleaned.indexOf(kw);
      if (idx != -1) {
        cleaned = cleaned.substring(0, idx).trim();
      }
    }

    return cleaned.trim();
  }

  Map<String, dynamic> _buildFallbackFlashcards(
    String chapterName,
    String className,
    Map<String, dynamic>? localRAG,
    String subject,
  ) {
    final rawVocab = (localRAG?['vocabulary_image_assets'] as List<dynamic>? ?? localRAG?['cards'] as List<dynamic>? ?? []);
    final cardsList = <Map<String, dynamic>>[];

    if (rawVocab.isNotEmpty) {
      for (int i = 0; i < rawVocab.length; i++) {
        final item = rawVocab[i] as Map<String, dynamic>;
        cardsList.add({
          'id': 'fc_${i + 1}',
          'word': item['word'] as String? ?? 'शब्द',
          'word_mundari': item['word_mundari'] as String? ?? '[मुंडारी]',
          'meaning': item['meaning'] as String? ?? 'Meaning',
          'meaning_mundari': '[मुंडारी अर्थ]',
          'emoji': item['emoji'] as String? ?? '📖',
          if (item['imageAsset'] != null) 'imageAsset': item['imageAsset'],
        });
      }
    } else {
      final hardcoded = EnglishActivitiesData.getWords(chapterName);
      if (hardcoded != null && hardcoded.isNotEmpty) {
        for (int i = 0; i < hardcoded.length; i++) {
          final w = hardcoded[i];
          cardsList.add({
            'id': 'fc_${i + 1}',
            'word': w.english,
            'word_mundari': w.mundariDevanagari.isNotEmpty ? w.mundariDevanagari : w.mundariRoman,
            'meaning': w.meaning,
            'meaning_mundari': w.mundariDisplay,
            'emoji': w.emoji,
          });
        }
      } else {
        cardsList.addAll([
          {
            'id': 'fc_1',
            'word': chapterName,
            'word_mundari': '[मुंडारी] $chapterName',
            'meaning': 'अध्याय मुख्य विषय',
            'meaning_mundari': 'पाठ्य अभ्यास',
            'emoji': '📖',
          },
          {
            'id': 'fc_2',
            'word': 'कक्षा अभ्यास',
            'word_mundari': 'इतु-पाठ',
            'meaning': 'छात्र शिक्षण गतिविधियां',
            'meaning_mundari': 'होन को शिक्षण',
            'emoji': '🌟',
          },
        ]);
      }
    }

    return {
      'id': 'fc_${chapterName.toLowerCase().replaceAll(' ', '_')}',
      'title': chapterName,
      'title_mundari': '[मुंडारी] $chapterName',
      'chapterName': chapterName,
      'cards': cardsList,
    };
  }

  Map<String, dynamic> _buildFallbackQuiz(
    String chapterName,
    String className,
    Map<String, dynamic>? localRAG,
  ) {
    final stanzas = (localRAG?['stanzas_verbatim'] as List<dynamic>? ?? []);
    final questions = <Map<String, dynamic>>[];

    if (stanzas.isNotEmpty) {
      for (int i = 0; i < stanzas.length; i++) {
        final stanza = stanzas[i] as Map<String, dynamic>;
        final txt = stanza['text_verbatim'] as String? ?? '';
        final line = txt.split('\n').firstWhere((l) => l.trim().isNotEmpty, orElse: () => txt);
        questions.add({
          'id': 'q_${i + 1}',
          'question': 'पंक्ति पहचानें: "$line" किस पाठ से है?',
          'question_mundari': 'निया काजी: "$line" अको पाठ रेयाः तना?',
          'options': [chapterName, 'अन्य पाठ', 'बाल कविता', 'व्याकरण'],
          'options_mundari': [chapterName, 'अन्य पाठ', 'बाल कविता', 'व्याकरण'],
          'answerIndex': 0,
          'explanation': 'यह पंक्ति $chapterName से ली गई है।',
          'explanation_mundari': 'निया पंक्ति $chapterName रेयाः तना।',
          'difficulty': i % 2 == 0 ? 'easy' : 'medium',
          'points': i % 2 == 0 ? 1 : 2,
        });
      }
    } else {
      final hardcoded = EnglishActivitiesData.getQuizQuestions(chapterName);
      if (hardcoded != null && hardcoded.isNotEmpty) {
        for (int i = 0; i < hardcoded.length; i++) {
          final q = hardcoded[i];
          questions.add({
            'id': 'q_${i + 1}',
            'question': q.question,
            'question_mundari': q.questionOdia,
            'options': q.options,
            'options_mundari': q.optionsOdia,
            'answerIndex': q.correctIndex,
            'explanation': q.explanation,
            'explanation_mundari': 'बुगी उत्तर ओलोः पे।',
            'difficulty': 'easy',
            'points': 1,
          });
        }
      }
    }

    if (questions.isEmpty) {
      questions.add({
        'id': 'q_1',
        'question': '$chapterName अध्याय का मुख्य उद्देश्य क्या है?',
        'question_mundari': '$chapterName उद्देश्य चिनाः तना?',
        'options': ['पाठ्य अभ्यास एवं भाषा ज्ञान', 'केवल खेल', 'गणित', 'चित्रकला'],
        'options_mundari': ['अभ्यास आर भाषा', 'खेल', 'गणित', 'चित्रकला'],
        'answerIndex': 0,
        'explanation': 'पाठ्य पुस्तक में भाषा और संकल्पनाओं का अभ्यास कराया जाता है।',
        'explanation_mundari': 'भाषा अभ्यास कराया जाता है।',
        'difficulty': 'easy',
        'points': 1,
      });
    }

    return {
      'id': 'quiz_${chapterName.toLowerCase().replaceAll(' ', '_')}',
      'title': '$chapterName - पूरक RAG क्विज़',
      'chapterName': chapterName,
      'durationMinutes': 15,
      'totalPoints': questions.length * 2,
      'questions': questions,
    };
  }

  Map<String, dynamic> _buildFallbackWorksheet(
    String chapterName,
    String className,
    Map<String, dynamic>? localRAG,
  ) {
    final vocab = (localRAG?['vocabulary_image_assets'] as List<dynamic>? ?? localRAG?['cards'] as List<dynamic>? ?? []);
    final fibs = <Map<String, dynamic>>[];
    final mps = <Map<String, dynamic>>[];
    final sas = <Map<String, dynamic>>[];

    if (vocab.isNotEmpty) {
      for (int i = 0; i < min(5, vocab.length); i++) {
        final v = vocab[i] as Map<String, dynamic>;
        final w = v['word'] as String? ?? 'शब्द';
        final wm = v['word_mundari'] as String? ?? '[मुंडारी]';
        fibs.add({
          'id': 'fib_${i + 1}',
          'promptWithBlank': 'चित्र एवं पाठ के अनुसार रिक्त स्थान भरें: ______ ($w)',
          'promptWithBlank_mundari': 'चित्र नेल ते सही शब्द ऑल पे: ______ ($wm)',
          'answer': w,
          'answer_mundari': wm,
          'wordBank': [w, 'हाथ', 'नमस्ते', 'सूरज', 'अध्याय'],
          'wordBank_mundari': [wm, 'ती', 'जोहार', 'सिङ्गि', 'पाठ'],
        });

        mps.add({
          'id': 'mp_${i + 1}',
          'columnA': w,
          'columnA_mundari': wm,
          'columnB': v['meaning'] as String? ?? 'अर्थ',
          'columnB_mundari': '[मुंडारी अर्थ]',
        });
      }
    } else {
      fibs.add({
        'id': 'fib_1',
        'promptWithBlank': '$chapterName पाठ्य अभ्यास: ______',
        'promptWithBlank_mundari': '$chapterName अभ्यास: ______',
        'answer': 'पाठ',
        'answer_mundari': 'पाठ',
        'wordBank': ['पाठ', 'चित्र', 'शब्द', 'कविता'],
        'wordBank_mundari': ['पाठ', 'चित्र', 'शब्द', 'कविता'],
      });

      mps.add({
        'id': 'mp_1',
        'columnA': chapterName,
        'columnA_mundari': chapterName,
        'columnB': 'पाठ्य अध्याय',
        'columnB_mundari': 'अध्याय',
      });
    }

    sas.add({
      'id': 'sa_1',
      'question': '$chapterName से आपने क्या सीखा?',
      'question_mundari': '$chapterName एते चिनाः पे इतुआना?',
      'sampleAnswer': '$chapterName के नए शब्द और मुंडारी अनुवाद का अभ्यास किया।',
      'sampleAnswer_mundari': 'इतु-पाठ अभ्यास।',
      'maxMarks': 5,
    });

    return {
      'id': 'ws_${chapterName.toLowerCase().replaceAll(' ', '_')}',
      'title': '$chapterName - पूरक RAG कार्यपत्रक (Worksheet)',
      'chapterName': chapterName,
      'fillInTheBlanks': fibs,
      'matchPairs': mps,
      'shortAnswers': sas,
    };
  }

  /// Generates all artifact types (Flashcards, Quiz, Worksheet) for a chapter simultaneously.
  Future<void> generateAll(String chapterName, String className, {bool forceRefresh = false}) async {
    await Future.wait([
      generateFlashcards(chapterName, className, forceRefresh: forceRefresh),
      generateQuiz(chapterName, className, forceRefresh: forceRefresh),
      generateWorksheet(chapterName, className, forceRefresh: forceRefresh),
    ]);
  }
}
