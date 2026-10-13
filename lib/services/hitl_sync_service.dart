import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/rag_config.dart';
import '../models/hitl_validation_models.dart';
import 'hitl_validation_service.dart';
import 'teacher_profile_service.dart';

class HitlSyncService {
  static final HitlSyncService instance = HitlSyncService._internal();
  factory HitlSyncService() => instance;

  final Dio _dio;
  String backendBaseUrl;
  bool _isSyncing = false;
  String? _lastError;

  HitlSyncService._internal({Dio? dio, String? backendBaseUrl})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
              ),
            ),
        backendBaseUrl = backendBaseUrl ?? kBackendBaseUrl;

  /// Constructor for testing to inject custom [Dio] and base URL.
  @visibleForTesting
  HitlSyncService.forTesting({required Dio dio, String? backendBaseUrl})
      : this._internal(dio: dio, backendBaseUrl: backendBaseUrl);

  bool get isSyncing => _isSyncing;
  String? get lastError => _lastError;

  /// Synchronizes pending teacher corrections to the backend.
  /// Enforces:
  /// - Base URL must be non-empty (reports "backend not configured" otherwise).
  /// - Marks items synced ONLY on 2xx responses.
  /// - On failure, records [lastError], keeps items pending, and retries with exponential backoff.
  Future<bool> syncPendingCorrections({
    int maxRetries = 3,
    Duration initialBackoff = const Duration(milliseconds: 500),
  }) async {
    if (_isSyncing) return false;

    if (backendBaseUrl.trim().isEmpty) {
      _lastError = 'Backend not configured (kBackendBaseUrl is empty)';
      debugPrint('[HITL Sync] $_lastError');
      return false;
    }

    _isSyncing = true;
    _lastError = null;

    final validationService = HitlValidationService();
    await validationService.init();

    final pending = validationService.getPendingSyncCorrections();
    if (pending.isEmpty) {
      _isSyncing = false;
      return true;
    }

    try {
      debugPrint('[HITL Sync] Starting sync for ${pending.length} pending corrections...');

      final deviceId = await TeacherProfileService.instance.getDeviceId();

      final payloadList = pending.map((c) {
        final flagged = validationService.flaggedTranslations.firstWhere(
          (f) => f.id == c.flaggedTranslationId,
          orElse: () => FlaggedTranslation(
            id: c.flaggedTranslationId,
            sourceText: '',
            targetText: '',
            confidence: null,
            languagePair: LanguagePairEnum.hindiToMundari,
            timestamp: DateTime.now(),
          ),
        );

        return {
          'correctionId': c.id,
          'flaggedId': c.flaggedTranslationId,
          'sourceText': flagged.sourceText,
          'targetText': flagged.targetText,
          'teacherEdit': c.teacherEdit,
          'isApproved': c.isApproved,
          'teacherId': c.teacherId,
          'confidence': flagged.confidence,
          'languagePair': flagged.languagePair.toShortString(),
          'editedAt': c.editedAt.toIso8601String(),
        };
      }).toList();

      final body = {
        'deviceId': deviceId,
        'appVersion': '1.0.0',
        'corrections': payloadList,
      };

      int attempt = 0;
      Duration currentDelay = initialBackoff;

      while (attempt < maxRetries) {
        attempt++;
        try {
          final response = await _dio.post(
            '$backendBaseUrl/corrections/batch',
            data: body,
            options: Options(headers: {'Content-Type': 'application/json'}),
          );

          final statusCode = response.statusCode ?? 0;
          if (statusCode >= 200 && statusCode < 300) {
            final ids = pending.map((c) => c.id).toList();
            await validationService.markCorrectionsSynced(ids);
            _lastError = null;
            debugPrint('[HITL Sync] Successfully synced ${ids.length} items to cloud (HTTP $statusCode).');
            _isSyncing = false;
            return true;
          } else {
            _lastError = 'Server returned HTTP $statusCode';
            debugPrint('[HITL Sync] Attempt $attempt failed: $_lastError');
          }
        } on DioException catch (dioErr) {
          _lastError = 'DioException (${dioErr.type}): ${dioErr.message}';
          debugPrint('[HITL Sync] Attempt $attempt network error: $_lastError');
        } catch (err) {
          _lastError = err.toString();
          debugPrint('[HITL Sync] Attempt $attempt unexpected error: $_lastError');
        }

        if (attempt < maxRetries) {
          await Future<void>.delayed(currentDelay);
          currentDelay *= 2;
        }
      }

      // Max retries exhausted without 2xx response. Items REMAIN pending.
      debugPrint('[HITL Sync] Sync failed after $maxRetries attempts. Items remain pending. Last error: $_lastError');
      return false;
    } finally {
      _isSyncing = false;
    }
  }

  Future<Map<String, dynamic>?> checkLatestModelUpdate() async {
    if (backendBaseUrl.trim().isEmpty) return null;

    try {
      final currentVersion =
          HitlValidationService().metadata.activeModelVersion;
      final response = await _dio.get(
        '$backendBaseUrl/models/latest',
        queryParameters: {
          'currentVersion': currentVersion,
          'languagePair': 'HINDI_MUNDARI',
        },
      );

      final statusCode = response.statusCode ?? 0;
      if (statusCode >= 200 && statusCode < 300 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('[HITL Sync] Model check network note: $e');
    }
    return null;
  }
}
