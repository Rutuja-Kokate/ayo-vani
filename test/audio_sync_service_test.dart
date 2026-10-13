import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ayo_vani/models/audio_training_models.dart';
import 'package:ayo_vani/services/audio_recording_storage_service.dart';
import 'package:ayo_vani/services/audio_sync_service.dart';
import 'package:ayo_vani/services/teacher_profile_service.dart';
import 'fixtures/fake_dio_adapter.dart';

class FakeConnectivity implements Connectivity {
  final List<ConnectivityResult> results;
  FakeConnectivity(this.results);

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => results;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      Stream.value(results);
}

class FakeBattery implements Battery {
  final BatteryState state;
  FakeBattery(this.state);

  @override
  Future<BatteryState> get batteryState async => state;

  @override
  Future<int> get batteryLevel async => 90;

  @override
  Stream<BatteryState> get onBatteryStateChanged => Stream.value(state);

  @override
  Future<bool> get isInBatterySaveMode async => false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await TeacherProfileService.instance.init();
  });

  group('AudioSyncService Unit Tests', () {
    late AudioRecordingStorageService storageService;

    setUp(() async {
      storageService = AudioRecordingStorageService();
      await storageService.init();
      for (final r in storageService.recordings) {
        r.approvedForTraining = true;
        r.consentStatus = AudioConsentStatusEnum.obtained;
        r.syncStatus = AudioSyncStatusEnum.pending;
        r.syncedAt = null;
      }
    });

    test('Fails sync when device is not connected to Wi-Fi', () async {
      final dio = Dio();
      final syncService = AudioSyncService.forTesting(
        dio: dio,
        connectivity: FakeConnectivity([ConnectivityResult.mobile]), // Not Wi-Fi
        battery: FakeBattery(BatteryState.charging),
        backendBaseUrl: 'https://api.ayovani.org/v1',
      );

      final result = await syncService.syncPendingAudio();
      expect(result, isFalse);
      expect(syncService.lastError, contains('Wi-Fi=false'));
    });

    test('Fails sync when device is not charging', () async {
      final dio = Dio();
      final syncService = AudioSyncService.forTesting(
        dio: dio,
        connectivity: FakeConnectivity([ConnectivityResult.wifi]),
        battery: FakeBattery(BatteryState.discharging), // Not charging
        backendBaseUrl: 'https://api.ayovani.org/v1',
      );

      final result = await syncService.syncPendingAudio();
      expect(result, isFalse);
      expect(syncService.lastError, contains('Charging=false'));
    });

    test('Fails sync when backend is not configured', () async {
      final dio = Dio();
      final syncService = AudioSyncService.forTesting(
        dio: dio,
        connectivity: FakeConnectivity([ConnectivityResult.wifi]),
        battery: FakeBattery(BatteryState.charging),
        backendBaseUrl: '', // empty
      );

      final result = await syncService.syncPendingAudio();
      expect(result, isFalse);
      expect(syncService.lastError, contains('Backend not configured'));
    });

    test('Strict consent check: Never uploads recordings with pending or declined consent', () async {
      // Ensure there are recordings with different consent statuses
      final recordings = storageService.recordings;
      for (final r in recordings) {
        r.consentStatus = AudioConsentStatusEnum.declined;
      }

      final dio = Dio();
      var postCalled = false;
      dio.httpClientAdapter = FakeDioAdapter((options) async {
        postCalled = true;
        return ResponseBody.fromString('{"status":"ok"}', 200);
      });

      final syncService = AudioSyncService.forTesting(
        dio: dio,
        connectivity: FakeConnectivity([ConnectivityResult.wifi]),
        battery: FakeBattery(BatteryState.charging),
        backendBaseUrl: 'https://api.ayovani.org/v1',
      );

      final result = await syncService.syncPendingAudio();
      expect(result, isTrue); // Returns true because 0 consented items to upload
      expect(postCalled, isFalse, reason: 'Network POST must not be called when no items have consent');
    });

    test('200 response marks consented pending recordings as synced', () async {
      // Set consent to obtained for recordings
      final pending = storageService.getPendingSyncRecordings();
      for (final r in pending) {
        r.consentStatus = AudioConsentStatusEnum.obtained;
        r.syncStatus = AudioSyncStatusEnum.pending;
      }

      final dio = Dio();
      dio.httpClientAdapter = FakeDioAdapter.jsonResponse(statusCode: 200);

      final syncService = AudioSyncService.forTesting(
        dio: dio,
        connectivity: FakeConnectivity([ConnectivityResult.wifi]),
        battery: FakeBattery(BatteryState.charging),
        backendBaseUrl: 'https://api.ayovani.org/v1',
      );

      final result = await syncService.syncPendingAudio(maxRetries: 1);
      expect(result, isTrue);
      expect(syncService.lastError, isNull);

      final updatedPending = storageService.getPendingSyncRecordings();
      expect(updatedPending.isEmpty, isTrue);
    });

    test('500 response keeps recordings pending (does NOT mark synced)', () async {
      final pending = storageService.getPendingSyncRecordings();
      for (final r in pending) {
        r.consentStatus = AudioConsentStatusEnum.obtained;
        r.syncStatus = AudioSyncStatusEnum.pending;
      }

      final dio = Dio();
      dio.httpClientAdapter = FakeDioAdapter.serverError(statusCode: 500);

      final syncService = AudioSyncService.forTesting(
        dio: dio,
        connectivity: FakeConnectivity([ConnectivityResult.wifi]),
        battery: FakeBattery(BatteryState.charging),
        backendBaseUrl: 'https://api.ayovani.org/v1',
      );

      final result = await syncService.syncPendingAudio(
        maxRetries: 2,
        initialBackoff: const Duration(milliseconds: 10),
      );

      expect(result, isFalse);
      expect(syncService.lastError, contains('500'));

      // Recordings MUST remain pending
      for (final r in pending) {
        expect(r.syncStatus, equals(AudioSyncStatusEnum.pending));
        expect(r.syncedAt, isNull);
      }
    });

    test('Timeout exception keeps recordings pending (does NOT mark synced)', () async {
      final pending = storageService.getPendingSyncRecordings();
      for (final r in pending) {
        r.consentStatus = AudioConsentStatusEnum.obtained;
        r.syncStatus = AudioSyncStatusEnum.pending;
      }

      final dio = Dio();
      dio.httpClientAdapter = FakeDioAdapter.timeout();

      final syncService = AudioSyncService.forTesting(
        dio: dio,
        connectivity: FakeConnectivity([ConnectivityResult.wifi]),
        battery: FakeBattery(BatteryState.charging),
        backendBaseUrl: 'https://api.ayovani.org/v1',
      );

      final result = await syncService.syncPendingAudio(
        maxRetries: 2,
        initialBackoff: const Duration(milliseconds: 10),
      );

      expect(result, isFalse);
      expect(syncService.lastError, contains('connectionTimeout'));

      // Recordings MUST remain pending
      for (final r in pending) {
        expect(r.syncStatus, equals(AudioSyncStatusEnum.pending));
        expect(r.syncedAt, isNull);
      }
    });
  });
}
