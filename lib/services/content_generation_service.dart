import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import '../config/rag_config.dart';
import '../rag/models/rag_flashcard.dart';
import '../rag/models/rag_quiz.dart';
import '../rag/models/rag_worksheet.dart';
import 'mt_translation_service.dart';

enum GenerationArtifactType { flashcard, quiz, worksheet }

/// Exception thrown when a chapter has no corresponding entry in assets/textbook_assets/manifest.json.
class ChapterIndexNotFoundException implements Exception {
  final String chapterId;
  const ChapterIndexNotFoundException(this.chapterId);

  @override
  String toString() =>
      'ChapterIndexNotFoundException: Chapter "$chapterId" does not have an index in manifest.json.';
}

/// Typed exception thrown when content generation fails (Gemini API error, missing candidates, network issue).
class ContentGenerationException implements Exception {
  final String message;
  final dynamic cause;
  const ContentGenerationException(this.message, [this.cause]);

  @override
  String toString() =>
      'ContentGenerationException: $message${cause != null ? " (cause: $cause)" : ""}';
}

/// Service that calls the Gemini API to generate pedagogical content
/// (Flashcards, Quizzes, Worksheets) for a given chapter, then translates
/// them to Mundari using [MtTranslationService]. Results are cached on-device.
class ContentGenerationService {
  final Dio _dio;
  final MtTranslationService _mtService;
  Map<String, String>? _manifest;

  ContentGenerationService({Dio? dio, MtTranslationService? mtService})
      : _dio = dio ?? Dio(),
        _mtService = mtService ?? MtTranslationService.instance;

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
    if (!hasGeminiKey) {
      throw const MissingApiKeyException();
    }
    const model = kGeminiModel;
    final url =
        'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$kGeminiApiKey';

    try {
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
        throw const ContentGenerationException('Gemini returned no candidates');
      }
      final rawText = candidates.first['content']['parts'][0]['text'] as String;
      return jsonDecode(rawText) as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ContentGenerationException(
          'Gemini API request failed (${e.type}): ${e.message}', e);
    } catch (e) {
      if (e is ContentGenerationException || e is MissingApiKeyException) rethrow;
      throw ContentGenerationException(
          'Failed to communicate with Gemini API: $e', e);
    }
  }

  // ── MT Translation ─────────────────────────────────────────────────────────

  Future<List<MtTranslationResult>> _translateBatch(List<String> hindiTexts) async {
    if (hindiTexts.isEmpty) return [];
    return await _mtService.translateBatch(hindiTexts);
  }

  // ── Flashcard Generation ───────────────────────────────────────────────────

  Future<RagFlashcardSet> generateFlashcards(
      String chapterName, String className,
      {bool forceRefresh = false, String subject = 'Hindi'}) async {
    // Check cache first
    if (!forceRefresh) {
      final cached =
          await _loadCache(chapterName, GenerationArtifactType.flashcard);
      if (cached != null) {
        debugPrint('[RAG] Loaded flashcards from cache for "$chapterName"');
        return RagFlashcardSet.fromJson(cached);
      }
    }

    // Try loading extracted textbook JSON asset index via explicit manifest
    final localRAG = await _loadLocalChapterRAG(chapterName);
    final rawVocab = (localRAG['cards'] as List<dynamic>? ?? []);

    if (rawVocab.isNotEmpty) {
      debugPrint(
          '[RAG] Building flashcards from local extracted textbook assets for "$chapterName"');
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
          'source': 'curated',
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

    debugPrint(
        '[RAG] Generating flashcards via Gemini for "$chapterName" (subject: $subject)...');

    final isEnglish = subject.toLowerCase() == 'english';
    final contentLang = isEnglish ? 'English' : 'Hindi';
    final exampleWord = isEnglish ? 'Eye' : 'आँख';
    final exampleMeaning =
        isEnglish ? 'The organ used for seeing' : 'देखने का अंग';

    final textbookContext = localRAG['full_chapter_text'] as String?;
    final contextPrompt = (textbookContext != null && textbookContext.isNotEmpty)
        ? '\nTextbook content:\n"""\n$textbookContext\n"""\n'
        : '';

    final prompt = '''
You are an educational content creator for Indian primary school students (Grade: $className, Subject: $subject).
Generate a set of 8 vocabulary flashcards for the chapter: "$chapterName".$contextPrompt
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

    int tIdx = 0;
    final mundariCards = <Map<String, dynamic>>[];
    for (int i = 0; i < cards.length; i++) {
      final card = cards[i] as Map<String, dynamic>;
      final wordRes = translated[tIdx++];
      final meaningRes = translated[tIdx++];
      final cardSource =
          wordRes.source == MtResultSource.glossary ? 'glossary' : 'nmt';
      mundariCards.add({
        'id': card['id'],
        'word': card['word'],
        'word_mundari': wordRes.text,
        'meaning': card['meaning'],
        'meaning_mundari': meaningRes.text,
        'emoji': card['emoji'],
        'source': cardSource,
      });
    }

    final titleMundari = translated[tIdx].text;
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

  Future<RagQuiz> generateQuiz(String chapterName, String className,
      {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await _loadCache(chapterName, GenerationArtifactType.quiz);
      if (cached != null) {
        debugPrint('[RAG] Loaded quiz from cache for "$chapterName"');
        return RagQuiz.fromJson(cached);
      }
    }

    final localRAG = await _loadLocalChapterRAG(chapterName);
    debugPrint('[RAG] Generating quiz via Gemini for "$chapterName"...');

    final textbookContext = localRAG['full_chapter_text'] as String?;
    final contextPrompt = (textbookContext != null && textbookContext.isNotEmpty)
        ? '\nTextbook content:\n"""\n$textbookContext\n"""\n'
        : '';

    final prompt = '''
You are an educational content creator for Indian primary school students (Grade: $className).
Generate a 10-question multiple-choice quiz for the chapter: "$chapterName".$contextPrompt
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
      final qMundari = translated[tIdx++];
      final optionsMundari = translated
          .sublist(tIdx, tIdx + optionCount)
          .map((r) => r.text)
          .toList();
      final explMundari = translated[tIdx + optionCount];
      mundariQuestions.add({
        ...qMap,
        'question_mundari': qMundari.text,
        'options_mundari': optionsMundari,
        'explanation_mundari': explMundari.text,
        'source': 'gemini',
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
      String chapterName, String className,
      {bool forceRefresh = false}) async {
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

    final textbookContext = localRAG['full_chapter_text'] as String?;
    final contextPrompt = (textbookContext != null && textbookContext.isNotEmpty)
        ? '\nTextbook content:\n"""\n$textbookContext\n"""\n'
        : '';

    final prompt = '''
You are an educational content creator for Indian primary school students (Grade: $className).
Generate a worksheet for the chapter: "$chapterName" with three sections:$contextPrompt
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
      toTranslate
          .addAll((fib['wordBank'] as List<dynamic>? ?? []).map((e) => e.toString()));
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
      final promptMundari = translated[tIdx++];
      final answerMundari = translated[tIdx++];
      final wbMundari =
          translated.sublist(tIdx, tIdx + wbCount).map((r) => r.text).toList();
      mundariFibs.add({
        ...fibMap,
        'promptWithBlank_mundari': promptMundari.text,
        'answer_mundari': answerMundari.text,
        'wordBank_mundari': wbMundari,
        'source': 'gemini',
      });
      tIdx += wbCount;
    }

    final mundariMps = <Map<String, dynamic>>[];
    for (final mp in mps) {
      final colAMundari = translated[tIdx++];
      final colBMundari = translated[tIdx++];
      mundariMps.add({
        ...(mp as Map<String, dynamic>),
        'columnA_mundari': colAMundari.text,
        'columnB_mundari': colBMundari.text,
        'source': 'gemini',
      });
    }

    final mundariSas = <Map<String, dynamic>>[];
    for (final sa in sas) {
      final qMundari = translated[tIdx++];
      final saMundari = translated[tIdx++];
      mundariSas.add({
        ...(sa as Map<String, dynamic>),
        'question_mundari': qMundari.text,
        'sampleAnswer_mundari': saMundari.text,
        'source': 'gemini',
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

  /// Helper to load extracted textbook JSON index assets using assets/textbook_assets/manifest.json
  Future<Map<String, dynamic>> _loadLocalChapterRAG(String chapterName) async {
    if (_manifest == null) {
      try {
        final manifestStr =
            await rootBundle.loadString('assets/textbook_assets/manifest.json');
        final decoded = jsonDecode(manifestStr) as Map<String, dynamic>;
        _manifest = decoded.map((k, v) =>
            MapEntry(k.toString().toLowerCase().trim(), v.toString()));
      } catch (e) {
        throw ContentGenerationException(
            'Failed to load textbook manifest assets/textbook_assets/manifest.json',
            e);
      }
    }

    final trimmed = chapterName.trim().toLowerCase();
    final slug = trimmed.replaceAll(RegExp(r'[^a-z0-9]'), '_');

    String? indexPath = _manifest![trimmed] ?? _manifest![slug];
    if (indexPath == null) {
      for (final entry in _manifest!.entries) {
        final key = entry.key;
        if (key.isNotEmpty &&
            (trimmed.contains(key) ||
                key.contains(trimmed) ||
                slug.contains(key) ||
                key.contains(slug))) {
          indexPath = entry.value;
          break;
        }
      }
    }

    if (indexPath == null) {
      throw ChapterIndexNotFoundException(chapterName);
    }

    try {
      final raw = await rootBundle.loadString(indexPath);
      final parsed = jsonDecode(raw);
      if (parsed is Map<String, dynamic>) {
        debugPrint('[RAG] Loaded local textbook index from $indexPath');
        if (parsed['full_chapter_text'] is String) {
          parsed['full_chapter_text'] =
              _cleanTextbookText(parsed['full_chapter_text'] as String);
        }
        return parsed;
      } else if (parsed is List<dynamic>) {
        debugPrint('[RAG] Loaded list index from $indexPath');
        return {
          'chapter_slug': slug,
          'cards': parsed,
        };
      } else {
        throw ContentGenerationException(
            'Unexpected JSON structure in chapter index: $indexPath');
      }
    } catch (e) {
      if (e is ChapterIndexNotFoundException ||
          e is ContentGenerationException) {
        rethrow;
      }
      throw ContentGenerationException(
          'Failed to read textbook index asset "$indexPath"', e);
    }
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
          RegExp(r'^(unit|chapter|खंड|इकाई)\s*[\d\-:]*$', caseSensitive: false)
              .hasMatch(l) ||
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

  /// Generates all artifact types (Flashcards, Quiz, Worksheet) for a chapter simultaneously.
  Future<void> generateAll(String chapterName, String className,
      {bool forceRefresh = false}) async {
    await Future.wait([
      generateFlashcards(chapterName, className, forceRefresh: forceRefresh),
      generateQuiz(chapterName, className, forceRefresh: forceRefresh),
      generateWorksheet(chapterName, className, forceRefresh: forceRefresh),
    ]);
  }
}
