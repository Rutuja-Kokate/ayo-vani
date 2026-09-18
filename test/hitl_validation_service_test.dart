import 'package:flutter_test/flutter_test.dart';
import 'package:ayo_vani/models/hitl_validation_models.dart';
import 'package:ayo_vani/services/hitl_validation_service.dart';
import 'package:ayo_vani/services/hitl_sync_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HitlValidationService Unit Tests', () {
    late HitlValidationService service;

    setUp(() async {
      service = HitlValidationService();
      await service.init();
    });

    test('Initializes with default items or storage state', () {
      expect(service.flaggedTranslations.isNotEmpty, isTrue);
      expect(service.metadata, isNotNull);
    });

    test('Evaluates low confidence thresholds correctly', () {
      expect(
        service.isLowConfidence(0.60, LanguagePairEnum.hindiToMundari),
        isTrue,
      );
      expect(
        service.isLowConfidence(0.85, LanguagePairEnum.hindiToMundari),
        isFalse,
      );
      expect(
        service.isLowConfidence(0.65, LanguagePairEnum.mundariToHindi),
        isTrue,
      );
      expect(
        service.isLowConfidence(0.75, LanguagePairEnum.mundariToHindi),
        isFalse,
      );
    });

    test('Flags low confidence translations dynamically', () async {
      final flagged = await service.checkAndFlag(
        sourceText: 'पानी लाओ',
        targetText: 'दाः आगुयेम',
        confidence: 0.65,
        languagePair: LanguagePairEnum.hindiToMundari,
      );

      expect(flagged, isNotNull);
      expect(flagged!.sourceText, equals('पानी लाओ'));
      expect(flagged.status, equals(HitlStatusEnum.flagged));
    });

    test('Teacher can accept translation', () async {
      final flagged = await service.checkAndFlag(
        sourceText: 'खाना खाओ',
        targetText: 'मंडी जोोममे',
        confidence: 0.55,
        languagePair: LanguagePairEnum.hindiToMundari,
      );

      await service.acceptTranslation(flagged!.id);
      expect(flagged.status, equals(HitlStatusEnum.approved));
    });

    test('Teacher can edit and save translation correction', () async {
      final flagged = await service.checkAndFlag(
        sourceText: 'घर जाओ',
        targetText: 'ओड़ाः सेनमे',
        confidence: 0.50,
        languagePair: LanguagePairEnum.hindiToMundari,
      );

      await service.editAndSaveTranslation(
        flaggedId: flagged!.id,
        editedText: 'ओड़ाः सेनोग़मे',
      );

      expect(flagged.status, equals(HitlStatusEnum.edited));
      final pendingCorrections = service.getPendingSyncCorrections();
      expect(pendingCorrections.any((c) => c.flaggedTranslationId == flagged.id), isTrue);
    });
  });

  group('HitlSyncService Unit Tests', () {
    test('Sync pending corrections handles offline fallback gracefully', () async {
      final syncService = HitlSyncService();
      final success = await syncService.syncPendingCorrections();
      expect(success, isTrue);
    });
  });
}
