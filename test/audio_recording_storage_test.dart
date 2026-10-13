import 'package:flutter_test/flutter_test.dart';
import 'package:ayo_vani/services/audio_recording_storage_service.dart';
import 'package:ayo_vani/services/audio_sync_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Audio Quality DSP Analyzer Unit Tests', () {
    test('Computes quality metrics correctly for speech PCM samples', () {
      final pcmSamples = List<int>.generate(16000, (i) => (1000 * (i % 32)).toInt());
      final metrics = AudioQualityMetrics.compute(pcmSamples, sampleRate: 16000);

      expect(metrics.qualityScore, greaterThan(0.0));
      expect(metrics.qualityScore, lessThanOrEqualTo(1.0));
      expect(metrics.rmsDb, greaterThan(-100.0));
    });
  });

  group('AudioRecordingStorageService Unit Tests', () {
    late AudioRecordingStorageService service;

    setUp(() async {
      service = AudioRecordingStorageService();
      await service.init();
    });

    test('Initializes with default recordings or storage items', () {
      expect(service.recordings.isNotEmpty, isTrue);
    });

    test('Calculates total storage used bytes correctly', () {
      final total = service.getTotalStorageUsedBytes();
      expect(total, greaterThan(0));
    });

    test('Toggles training approval status', () async {
      final item = service.recordings.first;
      final initialStatus = item.approvedForTraining;
      await service.toggleApproval(item.id, !initialStatus);
      expect(item.approvedForTraining, equals(!initialStatus));
    });

    test('Filters pending sync recordings with consent and quality checks', () {
      final pending = service.getPendingSyncRecordings();
      expect(pending.every((e) => e.approvedForTraining && e.qualityScore >= 0.5), isTrue);
    });
  });

  group('AudioSyncService Unit Tests', () {
    test('Batch sync returns false when Wi-Fi or charging constraints are not met', () async {
      final syncService = AudioSyncService();

      // Constraints not met → always returns false immediately
      final resultNoWifi = await syncService.syncPendingAudio(isWifiConnected: false, isCharging: true);
      expect(resultNoWifi, isFalse);

      final resultNoCharging = await syncService.syncPendingAudio(isWifiConnected: true, isCharging: false);
      expect(resultNoCharging, isFalse);
    });

    test('Batch sync returns false when backend is unreachable (never silently marks synced)', () async {
      final syncService = AudioSyncService();
      // In test environment there is no real backend. The service must return false,
      // not silently mark items as synced. This verifies Rule 4 compliance.
      final result = await syncService.syncPendingAudio(isWifiConnected: true, isCharging: true);
      // Backend is unreachable in test → must not lie that sync succeeded.
      expect(result, isFalse);
    });
  });
}
