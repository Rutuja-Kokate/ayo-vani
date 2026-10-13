import 'package:flutter_test/flutter_test.dart';
import 'package:ayo_vani/engine/mt_stage.dart';
import 'package:ayo_vani/engine/pipeline.dart' show TranslationDirection;
import 'package:ayo_vani/engine/loanwords.dart';
import 'package:ayo_vani/services/mt_translation_service.dart';
import 'package:ayo_vani/services/content_generation_service.dart';
import 'package:ayo_vani/rag/models/rag_flashcard.dart';
import 'package:ayo_vani/rag/models/rag_quiz.dart';
import 'package:ayo_vani/rag/models/rag_worksheet.dart';

class MockMtStage implements MtStage {
  bool initialized = false;
  int translateCallCount = 0;
  final Map<String, String> translationMap;

  MockMtStage({this.translationMap = const {}});

  bool get isInitialized => initialized;

  @override
  Future<void> initModel() async {
    initialized = true;
  }

  @override
  Future<MtResult> translate(
    String input, {
    TranslationDirection direction = TranslationDirection.hindiToMundari,
  }) async {
    translateCallCount++;
    final mapped = translationMap[input] ?? 'मुं($input)';
    return MtResult(
      displayText: mapped,
      synthesizeText: mapped,
      confidence: 0.95,
    );
  }

  @override
  void dispose() {
    initialized = false;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MtTranslationService - Curated Glossary Override', () {
    late MockMtStage mockStage;
    late MtTranslationService service;

    setUp(() {
      MtTranslationService.isLivePipelineActive = false;
      mockStage = MockMtStage();
      service = MtTranslationService.withStage(mockStage);
    });

    test('Single-word Hindi body part returns glossary override with source: glossary', () async {
      final result = await service.translateSentence('हाथ');
      expect(result.source, MtResultSource.glossary);
      expect(result.text, 'तिः');
      expect(result.confidence, 1.0);
      expect(mockStage.translateCallCount, 0, reason: 'NMT should not be called for glossary override');
    });

    test('Single-word English body part returns glossary override with source: glossary', () async {
      final result = await service.translateSentence('head');
      expect(result.source, MtResultSource.glossary);
      expect(result.text, 'बोहः');
      expect(result.confidence, 1.0);
      expect(mockStage.translateCallCount, 0);
    });

    test('Single-word classroom term returns glossary override with source: glossary', () async {
      final result = await service.translateSentence('किताब');
      expect(result.source, MtResultSource.glossary);
      expect(result.text, 'पुथी');
      expect(result.confidence, 1.0);
      expect(mockStage.translateCallCount, 0);
    });

    test('Multi-word phrase containing a glossary word routes through NMT with source: nmt', () async {
      final result = await service.translateSentence('यह हाथ है');
      expect(result.source, MtResultSource.nmt);
      expect(result.text, 'मुं(यह हाथ है)');
      expect(mockStage.translateCallCount, 1);
    });
  });

  group('MtTranslationService - {ENG:term} Loanword Protection', () {
    late MockMtStage mockStage;
    late MtTranslationService service;

    setUp(() {
      MtTranslationService.isLivePipelineActive = false;
      mockStage = MockMtStage(
        translationMap: {
          'यह एक': 'निया मित्',
          'है': 'ताना',
          'और': 'आर',
          'मेरा': 'अइञाः',
        },
      );
      service = MtTranslationService.withStage(mockStage);
    });

    test('Splits around single {ENG:term} marker and transliterates loanword via loanword map', () async {
      final result = await service.translateSentence('यह एक {ENG:notebook} है');
      expect(result.source, MtResultSource.nmt);
      expect(result.text, 'निया मित् नोटबुक ताना');
      expect(mockStage.translateCallCount, 2);
    });

    test('Handles multiple {ENG:term} markers preserving surrounding spacing', () async {
      final result = await service.translateSentence('{ENG:pencil} और {ENG:notebook}');
      expect(result.source, MtResultSource.nmt);
      expect(result.text, 'पेंसिल आर नोटबुक');
      expect(mockStage.translateCallCount, 1);
    });

    test('Falls back to phonetic rule-based transliteration for unknown English loanword', () async {
      // "laptop" is not in kLoanwordPhoneticMap
      final devanagariLaptop = getLoanwordDevanagari('laptop');
      expect(devanagariLaptop, isNotEmpty);

      final result = await service.translateSentence('मेरा {ENG:laptop}');
      expect(result.source, MtResultSource.nmt);
      expect(result.text, 'अइञाः $devanagariLaptop');
      expect(mockStage.translateCallCount, 1);
    });

    test('translateBatch processes sentences and preserves loanword protection', () async {
      final results = await service.translateBatch([
        'हाथ',
        'यह एक {ENG:notebook} है',
        'किताब',
      ]);

      expect(results.length, 3);
      expect(results[0].source, MtResultSource.glossary);
      expect(results[0].text, 'तिः');

      expect(results[1].source, MtResultSource.nmt);
      expect(results[1].text, 'निया मित् नोटबुक ताना');

      expect(results[2].source, MtResultSource.glossary);
      expect(results[2].text, 'पुथी');
    });
  });

  group('MtTranslationService - Concurrency & Live Pipeline Guard', () {
    late MockMtStage mockStage;
    late MtTranslationService service;

    setUp(() {
      mockStage = MockMtStage();
      service = MtTranslationService.withStage(mockStage);
    });

    tearDown(() {
      MtTranslationService.isLivePipelineActive = false;
    });

    test('Throws MtLivePipelineActiveException when speech pipeline is active during translateSentence', () async {
      MtTranslationService.isLivePipelineActive = true;

      expect(
        () => service.translateSentence('हाथ'),
        throwsA(isA<MtLivePipelineActiveException>()),
      );
    });

    test('Throws MtLivePipelineActiveException when speech pipeline is active during translateBatch', () async {
      MtTranslationService.isLivePipelineActive = true;

      expect(
        () => service.translateBatch(['हाथ', 'पैर']),
        throwsA(isA<MtLivePipelineActiveException>()),
      );
    });
  });

  group('ContentGenerationService - Manifest & Typed Exceptions', () {
    test('Throws ChapterIndexNotFoundException when chapter is not in manifest', () async {
      final service = ContentGenerationService();

      expect(
        () => service.generateFlashcards('NonExistentChapterXYZ999', '1'),
        throwsA(isA<ChapterIndexNotFoundException>()),
      );

      expect(
        () => service.generateQuiz('NonExistentChapterXYZ999', '1'),
        throwsA(isA<ChapterIndexNotFoundException>()),
      );

      expect(
        () => service.generateWorksheet('NonExistentChapterXYZ999', '1'),
        throwsA(isA<ChapterIndexNotFoundException>()),
      );
    });
  });

  group('Source Provenance on Artifact Models', () {
    test('RagFlashcardItem serializes and deserializes source correctly', () {
      final item = RagFlashcardItem(
        id: 'fc_1',
        wordHindi: 'हाथ',
        wordMundari: 'तिः',
        meaningHindi: 'शरीर का अंग',
        meaningMundari: 'हड़मो रेयाः अंग',
        emoji: '✋',
        source: 'curated',
      );

      final json = item.toJson();
      expect(json['source'], 'curated');

      final fromJson = RagFlashcardItem.fromJson(json);
      expect(fromJson.source, 'curated');
    });

    test('RagQuizQuestion serializes and deserializes source correctly', () {
      final q = RagQuizQuestion(
        id: 'q_1',
        questionHindi: 'प्रश्न',
        questionMundari: 'कुली',
        optionsHindi: ['क', 'ख'],
        optionsMundari: ['क', 'ख'],
        answerIndex: 0,
        explanationHindi: 'व्याख्या',
        explanationMundari: 'काजी',
        source: 'gemini',
      );

      final json = q.toJson();
      expect(json['source'], 'gemini');

      final fromJson = RagQuizQuestion.fromJson(json);
      expect(fromJson.source, 'gemini');
    });

    test('RagWorksheet items serialize and deserialize source correctly', () {
      final fib = RagFillInTheBlankItem(
        id: 'fib_1',
        promptHindi: 'रिक्त स्थान ______',
        promptMundari: 'खाली जागा ______',
        answerHindi: 'उत्तर',
        answerMundari: 'काजी',
        wordBankHindi: ['उत्तर'],
        wordBankMundari: ['काजी'],
        source: 'gemini',
      );
      expect(fib.toJson()['source'], 'gemini');
      expect(RagFillInTheBlankItem.fromJson(fib.toJson()).source, 'gemini');

      final mp = RagMatchPairItem(
        id: 'mp_1',
        columnAHindi: 'क',
        columnAMundari: 'क',
        columnBHindi: 'ख',
        columnBMundari: 'ख',
        source: 'curated',
      );
      expect(mp.toJson()['source'], 'curated');
      expect(RagMatchPairItem.fromJson(mp.toJson()).source, 'curated');

      final sa = RagShortAnswerItem(
        id: 'sa_1',
        questionHindi: 'प्रश्न',
        questionMundari: 'कुली',
        sampleAnswerHindi: 'उत्तर',
        sampleAnswerMundari: 'काजी',
        source: 'nmt',
      );
      expect(sa.toJson()['source'], 'nmt');
      expect(RagShortAnswerItem.fromJson(sa.toJson()).source, 'nmt');
    });
  });
}
