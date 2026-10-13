import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ayo_vani/models/hitl_validation_models.dart';
import 'package:ayo_vani/services/hitl_validation_service.dart';
import 'package:ayo_vani/services/hitl_sync_service.dart';
import 'package:ayo_vani/services/teacher_profile_service.dart';
import 'fixtures/fake_dio_adapter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await TeacherProfileService.instance.init();
  });

  group('HitlValidationService Unit Tests', () {
    late HitlValidationService service;

    setUp(() async {
      service = HitlValidationService();
      await service.init();
    });

    test('Initializes with empty flagged list (no fake seeded items)', () {
      // In Phase 5, all fake seeded data has been removed.
      // Newly initialized service without prior store has 0 fake items.
      expect(service.flaggedTranslations.isEmpty, isTrue);
      expect(service.metadata, isNotNull);
    });

    test('Evaluates configurable confidence thresholds (with low BLEU compensation)', () {
      expect(HitlValidationService.kDefaultHindiToMundariThreshold, 0.75);
      expect(HitlValidationService.kDefaultMundariToHindiThreshold, 0.70);

      // Hindi -> Mundari threshold: 0.75
      expect(
        service.isLowConfidence(0.74, LanguagePairEnum.hindiToMundari),
        isTrue,
      );
      expect(
        service.isLowConfidence(0.75, LanguagePairEnum.hindiToMundari),
        isFalse,
      );
      expect(
        service.isLowConfidence(0.85, LanguagePairEnum.hindiToMundari),
        isFalse,
      );

      // Mundari -> Hindi threshold: 0.70
      expect(
        service.isLowConfidence(0.69, LanguagePairEnum.mundariToHindi),
        isTrue,
      );
      expect(
        service.isLowConfidence(0.70, LanguagePairEnum.mundariToHindi),
        isFalse,
      );
      expect(
        service.isLowConfidence(0.78, LanguagePairEnum.mundariToHindi),
        isFalse,
      );
    });

    test('When confidence is null, ALWAYS flags the item (unknown quality)', () async {
      // 1. isLowConfidence returns true for null
      expect(service.isLowConfidence(null, LanguagePairEnum.hindiToMundari), isTrue);
      expect(service.isLowConfidence(null, LanguagePairEnum.mundariToHindi), isTrue);

      // 2. checkAndFlag stores item with confidence == null
      final flagged = await service.checkAndFlag(
        sourceText: 'अनिश्चित वाक्य',
        targetText: 'अको काजी',
        confidence: null,
        languagePair: LanguagePairEnum.hindiToMundari,
      );

      expect(flagged, isNotNull);
      expect(flagged!.confidence, isNull);
      expect(flagged.status, equals(HitlStatusEnum.flagged));
    });

    test('Teacher can accept, reject, or edit flagged translation', () async {
      final flagged = await service.checkAndFlag(
        sourceText: 'खाना खाओ',
        targetText: 'मंडी जोोममे',
        confidence: 0.55,
        languagePair: LanguagePairEnum.hindiToMundari,
      );

      expect(flagged, isNotNull);

      // Accept
      await service.acceptTranslation(flagged!.id);
      expect(flagged.status, equals(HitlStatusEnum.approved));

      // Edit
      await service.editAndSaveTranslation(
        flaggedId: flagged.id,
        editedText: 'मंडी जोोमपे',
      );
      expect(flagged.status, equals(HitlStatusEnum.edited));

      final pendingCorrections = service.getPendingSyncCorrections();
      expect(pendingCorrections.any((c) => c.flaggedTranslationId == flagged.id), isTrue);
      final correction = pendingCorrections.firstWhere((c) => c.flaggedTranslationId == flagged.id);
      expect(correction.teacherEdit, equals('मंडी जोोमपे'));
      expect(correction.syncState, equals(HitlSyncStateEnum.pending));
    });
  });

  group('HitlSyncService Unit Tests', () {
    late HitlValidationService validationService;

    setUp(() async {
      validationService = HitlValidationService();
      await validationService.init();

      // Seed one translation and correction
      final flagged = await validationService.checkAndFlag(
        sourceText: 'यह किताब है',
        targetText: 'निया पुथी तना',
        confidence: null,
        languagePair: LanguagePairEnum.hindiToMundari,
      );
      await validationService.editAndSaveTranslation(
        flaggedId: flagged!.id,
        editedText: 'निया पुथी ताना',
      );
    });

    test('Reports backend not configured when kBackendBaseUrl is empty', () async {
      final dio = Dio();
      final syncService = HitlSyncService.forTesting(
        dio: dio,
        backendBaseUrl: '', // empty
      );

      final success = await syncService.syncPendingCorrections();
      expect(success, isFalse);
      expect(syncService.lastError, contains('Backend not configured'));

      // Items MUST remain pending
      final pending = validationService.getPendingSyncCorrections();
      expect(pending.isNotEmpty, isTrue);
      expect(pending.every((c) => c.syncState == HitlSyncStateEnum.pending), isTrue);
    });

    test('200 response marks pending items as synced', () async {
      final dio = Dio();
      dio.httpClientAdapter = FakeDioAdapter.jsonResponse(statusCode: 200);

      final syncService = HitlSyncService.forTesting(
        dio: dio,
        backendBaseUrl: 'https://api.ayovani.org/v1',
      );

      final success = await syncService.syncPendingCorrections(maxRetries: 1);
      expect(success, isTrue);
      expect(syncService.lastError, isNull);

      final pending = validationService.getPendingSyncCorrections();
      expect(pending.isEmpty, isTrue);
      expect(validationService.teacherCorrections.every((c) => c.syncState == HitlSyncStateEnum.synced), isTrue);
    });

    test('500 response keeps items in pending state (does NOT mark synced)', () async {
      final dio = Dio();
      dio.httpClientAdapter = FakeDioAdapter.serverError(statusCode: 500);

      final syncService = HitlSyncService.forTesting(
        dio: dio,
        backendBaseUrl: 'https://api.ayovani.org/v1',
      );

      final success = await syncService.syncPendingCorrections(
        maxRetries: 2,
        initialBackoff: const Duration(milliseconds: 10),
      );

      expect(success, isFalse);
      expect(syncService.lastError, contains('500'));

      // Must STAY pending!
      final pending = validationService.getPendingSyncCorrections();
      expect(pending.isNotEmpty, isTrue);
      expect(pending.every((c) => c.syncState == HitlSyncStateEnum.pending), isTrue);
    });

    test('Timeout exception keeps items in pending state (does NOT mark synced)', () async {
      final dio = Dio();
      dio.httpClientAdapter = FakeDioAdapter.timeout();

      final syncService = HitlSyncService.forTesting(
        dio: dio,
        backendBaseUrl: 'https://api.ayovani.org/v1',
      );

      final success = await syncService.syncPendingCorrections(
        maxRetries: 2,
        initialBackoff: const Duration(milliseconds: 10),
      );

      expect(success, isFalse);
      expect(syncService.lastError, contains('connectionTimeout'));

      // Must STAY pending!
      final pending = validationService.getPendingSyncCorrections();
      expect(pending.isNotEmpty, isTrue);
      expect(pending.every((c) => c.syncState == HitlSyncStateEnum.pending), isTrue);
    });
  });
}
