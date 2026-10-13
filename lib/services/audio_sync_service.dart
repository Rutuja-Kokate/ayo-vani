import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/rag_config.dart';
import '../models/audio_training_models.dart';
import 'audio_recording_storage_service.dart';
import 'teacher_profile_service.dart';

class AudioSyncService {
  static final AudioSyncService instance = AudioSyncService._internal();
  factory AudioSyncService() => instance;

  final Dio _dio;
  final Connectivity _connectivity;
  final Battery _battery;
  String backendBaseUrl;
  bool _isSyncing = false;
  String? _lastError;

  AudioSyncService._internal({
    Dio? dio,
    Connectivity? connectivity,
    Battery? battery,
    String? backendBaseUrl,
  })  : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 45),
              ),
            ),
        _connectivity = connectivity ?? Connectivity(),
        _battery = battery ?? Battery(),
        backendBaseUrl = backendBaseUrl ?? kBackendBaseUrl;

  /// Constructor for testing with dependency injection.
  @visibleForTesting
  AudioSyncService.forTesting({
    required Dio dio,
    required Connectivity connectivity,
    required Battery battery,
    String? backendBaseUrl,
  })  : this._internal(
          dio: dio,
          connectivity: connectivity,
          battery: battery,
          backendBaseUrl: backendBaseUrl,
        );

  bool get isSyncing => _isSyncing;
  String? get lastError => _lastError;

  /// Checks if device is currently connected to Wi-Fi.
  Future<bool> checkIsWifiConnected() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.contains(ConnectivityResult.wifi);
    } catch (e) {
      debugPrint('[AudioSync] Connectivity check error: $e');
      return false;
    }
  }

  /// Checks if device is currently charging or fully charged.
  Future<bool> checkIsCharging() async {
    try {
      final state = await _battery.batteryState;
      return state == BatteryState.charging || state == BatteryState.full;
    } catch (e) {
      debugPrint('[AudioSync] Battery check error: $e');
      return false;
    }
  }

  /// Performs sync of consented pending audio recordings when Wi-Fi and charging
  /// constraints are satisfied.
  ///
  /// Constraints enforced:
  /// - Wi-Fi connection required (via [connectivity_plus]).
  /// - Device must be charging (via [battery_plus]).
  /// - [kBackendBaseUrl] must be configured.
  /// - Only recordings with [AudioConsentStatusEnum.obtained] are uploaded.
  /// - Attaches actual audio files as multipart FormData parts with SHA-256 checksums.
  /// - Items marked synced ONLY on 2xx responses; never on failure.
  Future<bool> syncPendingAudio({
    bool? isWifiConnected,
    bool? isCharging,
    int maxRetries = 3,
    Duration initialBackoff = const Duration(milliseconds: 500),
  }) async {
    if (_isSyncing) return false;

    // 1. Enforce Wi-Fi constraint
    final hasWifi = isWifiConnected ?? await checkIsWifiConnected();
    // 2. Enforce charging constraint
    final charging = isCharging ?? await checkIsCharging();

    if (!hasWifi || !charging) {
      _lastError =
          'Constraints not met: Wi-Fi=$hasWifi, Charging=$charging';
      debugPrint('[AudioSync] $_lastError');
      return false;
    }

    // 3. Verify backend configuration
    if (backendBaseUrl.trim().isEmpty) {
      _lastError = 'Backend not configured (kBackendBaseUrl is empty)';
      debugPrint('[AudioSync] $_lastError');
      return false;
    }

    _isSyncing = true;
    _lastError = null;

    final store = AudioRecordingStorageService();
    await store.init();

    final allPending = store.getPendingSyncRecordings();

    // 4. Strict consent check: NEVER upload recordings without recorded consent
    final consentedPending = allPending
        .where((r) => r.consentStatus == AudioConsentStatusEnum.obtained)
        .toList();

    if (consentedPending.isEmpty) {
      _isSyncing = false;
      return true;
    }

    try {
      debugPrint(
        '[AudioSync] Starting multipart upload for ${consentedPending.length} consented audio recording(s)...',
      );

      final deviceId = await TeacherProfileService.instance.getDeviceId();

      Future<FormData> buildFormData() async {
        final formData = FormData();
        formData.fields.add(MapEntry('deviceId', deviceId));
        formData.fields.add(const MapEntry('appVersion', '1.0.0'));

        final metadataList = <Map<String, dynamic>>[];
        for (final item in consentedPending) {
          metadataList.add({
            'id': item.id,
            'speaker_type': item.speakerType.name,
            'language': item.language.name,
            'quality_score': item.qualityScore,
            'noise_level_db': item.noiseLevelDb,
            'transcription_text': item.transcriptionText,
            'consent_status': item.consentStatus.name,
            'stt_model_version': item.sttModelVersion,
            'sha256_checksum': item.sha256Checksum,
            'duration_seconds': item.durationSeconds,
            'file_size_bytes': item.fileSizeBytes,
          });

          final file = File(item.filePath);
          if (await file.exists()) {
            formData.files.add(
              MapEntry(
                'audio_files',
                await MultipartFile.fromFile(
                  item.filePath,
                  filename: '${item.id}.opus',
                  headers: {
                    'x-sha256-checksum': [item.sha256Checksum],
                  },
                ),
              ),
            );
          } else {
            debugPrint(
                '[AudioSync] Warning: audio file not found on disk at ${item.filePath}');
          }
        }

        formData.fields
            .add(MapEntry('metadata', jsonEncode(metadataList)));
        return formData;
      }

      int attempt = 0;
      Duration currentDelay = initialBackoff;

      while (attempt < maxRetries) {
        attempt++;
        try {
          final formData = await buildFormData();
          final response = await _dio.post(
            '$backendBaseUrl/audio/batch',
            data: formData,
          );

          final statusCode = response.statusCode ?? 0;
          if (statusCode >= 200 && statusCode < 300) {
            final now = DateTime.now();
            for (final item in consentedPending) {
              item.syncedAt = now;
              item.syncStatus = AudioSyncStatusEnum.synced;
            }
            _lastError = null;
            debugPrint(
              '[AudioSync] Successfully synced ${consentedPending.length} audio file(s) (HTTP $statusCode).',
            );
            _isSyncing = false;
            return true;
          } else {
            _lastError = 'Server returned HTTP $statusCode';
            debugPrint('[AudioSync] Attempt $attempt failed: $_lastError');
          }
        } on DioException catch (dioErr) {
          _lastError = 'DioException (${dioErr.type}): ${dioErr.message}';
          debugPrint('[AudioSync] Attempt $attempt network error: $_lastError');
        } catch (err) {
          _lastError = err.toString();
          debugPrint('[AudioSync] Attempt $attempt unexpected error: $_lastError');
        }

        if (attempt < maxRetries) {
          await Future<void>.delayed(currentDelay);
          currentDelay *= 2;
        }
      }

      // Max retries exhausted without 2xx response. Items REMAIN pending.
      debugPrint(
        '[AudioSync] Sync failed after $maxRetries attempts. Items remain pending. Last error: $_lastError',
      );
      return false;
    } finally {
      _isSyncing = false;
    }
  }
}
