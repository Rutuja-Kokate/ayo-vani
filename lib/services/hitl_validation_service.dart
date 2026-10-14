import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/hitl_validation_models.dart';
import 'teacher_profile_service.dart';

class HitlValidationService {
  static final HitlValidationService _instance =
      HitlValidationService._internal();
  static HitlValidationService get instance => _instance;
  factory HitlValidationService() => _instance;
  HitlValidationService._internal();

  File? _storageFile;
  bool _initialized = false;

  final List<FlaggedTranslation> _flaggedTranslations = [];
  final List<TeacherCorrection> _teacherCorrections = [];
  SyncMetadata _metadata = SyncMetadata(
    lastSyncedAt: DateTime.fromMillisecondsSinceEpoch(0),
    pendingSyncCount: 0,
  );

  /// Default confidence threshold for Hindi -> Mundari translation.
  /// Note: The IndicTrans2 Hindi->Mundari BLEU is low (hin->mun ~10.7),
  /// so conservative flagging (0.75 threshold) is intentionally chosen to route
  /// uncertain sentences to Human-In-The-Loop teacher review.
  static const double kDefaultHindiToMundariThreshold = 0.75;

  /// Default confidence threshold for Mundari -> Hindi translation.
  /// Note: Model quality is constrained by low-resource training data in the
  /// Mundari direction, requiring conservative flagging (0.70 threshold) to catch errors.
  static const double kDefaultMundariToHindiThreshold = 0.70;

  double hindiToMundariThreshold = kDefaultHindiToMundariThreshold;
  double mundariToHindiThreshold = kDefaultMundariToHindiThreshold;

  List<FlaggedTranslation> get flaggedTranslations =>
      List.unmodifiable(_flaggedTranslations);
  List<TeacherCorrection> get teacherCorrections =>
      List.unmodifiable(_teacherCorrections);
  SyncMetadata get metadata => _metadata;

  Future<void> init() async {
    if (_initialized) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      _storageFile = File('${dir.path}/hitl_validation_store.json');

      if (await _storageFile!.exists()) {
        final raw = await _storageFile!.readAsString();
        if (raw.isNotEmpty) {
          final data = jsonDecode(raw) as Map<String, dynamic>;

          if (data['flagged'] != null) {
            final list = data['flagged'] as List<dynamic>;
            _flaggedTranslations.clear();
            _flaggedTranslations.addAll(list.map(
                (e) => FlaggedTranslation.fromJson(e as Map<String, dynamic>)));
          }

          if (data['corrections'] != null) {
            final list = data['corrections'] as List<dynamic>;
            _teacherCorrections.clear();
            _teacherCorrections.addAll(list.map(
                (e) => TeacherCorrection.fromJson(e as Map<String, dynamic>)));
          }

          if (data['metadata'] != null) {
            _metadata = SyncMetadata.fromJson(
                data['metadata'] as Map<String, dynamic>);
          }
        }
      }
    } catch (e) {
      debugPrint('[HITL] Initialization error: $e');
    }
    _initialized = true;
  }

  Future<void> _saveToDisk() async {
    if (_storageFile == null) return;
    try {
      final pendingCount = _teacherCorrections
          .where((c) => c.syncState == HitlSyncStateEnum.pending)
          .length;
      _metadata = SyncMetadata(
        lastSyncedAt: _metadata.lastSyncedAt,
        activeModelVersion: _metadata.activeModelVersion,
        modelChecksum: _metadata.modelChecksum,
        pendingSyncCount: pendingCount,
      );

      final data = {
        'flagged': _flaggedTranslations.map((e) => e.toJson()).toList(),
        'corrections': _teacherCorrections.map((e) => e.toJson()).toList(),
        'metadata': _metadata.toJson(),
      };
      await _storageFile!.writeAsString(jsonEncode(data));
    } catch (e) {
      debugPrint('[HITL] Disk save error: $e');
    }
  }

  /// Evaluates whether a translation has low confidence or unknown quality.
  /// When [confidence] is null, ALWAYS returns true to flag the item for teacher review.
  bool isLowConfidence(double? confidence, LanguagePairEnum pair) {
    if (confidence == null) return true;
    final threshold = pair == LanguagePairEnum.hindiToMundari
        ? hindiToMundariThreshold
        : mundariToHindiThreshold;
    return confidence < threshold;
  }

  /// Checks translation confidence against thresholds. If low or null, records
  /// the item for Human-In-The-Loop teacher review.
  Future<FlaggedTranslation?> checkAndFlag({
    required String sourceText,
    required String targetText,
    required double? confidence,
    required LanguagePairEnum languagePair,
    String? teacherId,
    String modelVersion = 'v1.0.0_int8',
  }) async {
    await init();
    if (!isLowConfidence(confidence, languagePair)) return null;

    final resolvedTeacherId =
        teacherId ?? await TeacherProfileService.instance.getTeacherId();

    final existing = _flaggedTranslations.firstWhere(
      (item) =>
          item.sourceText.trim() == sourceText.trim() &&
          item.status == HitlStatusEnum.flagged,
      orElse: () => FlaggedTranslation(
        id: 'flag_${DateTime.now().millisecondsSinceEpoch}',
        sourceText: sourceText,
        targetText: targetText,
        confidence: confidence,
        languagePair: languagePair,
        modelVersion: modelVersion,
        timestamp: DateTime.now(),
        teacherId: resolvedTeacherId,
      ),
    );

    if (!_flaggedTranslations.contains(existing)) {
      _flaggedTranslations.insert(0, existing);
      await _saveToDisk();
      final confStr = confidence != null
          ? '${(confidence * 100).toStringAsFixed(1)}%'
          : 'null (unknown quality)';
      debugPrint(
          '[HITL] Flagged translation ($confStr): "$sourceText"');
    }
    return existing;
  }

  List<FlaggedTranslation> getPendingByPair(LanguagePairEnum pair) {
    return _flaggedTranslations
        .where((item) =>
            item.languagePair == pair && item.status == HitlStatusEnum.flagged)
        .toList();
  }

  Future<void> acceptTranslation(String flaggedId, {String? teacherId}) async {
    await init();
    final actualTeacherId =
        teacherId ?? await TeacherProfileService.instance.getTeacherId();
    final index = _flaggedTranslations.indexWhere((e) => e.id == flaggedId);
    if (index != -1) {
      _flaggedTranslations[index].status = HitlStatusEnum.approved;
      _recordCorrection(
        flaggedId: flaggedId,
        teacherId: actualTeacherId,
        teacherEdit: null,
        isApproved: true,
      );
      await _saveToDisk();
    }
  }

  Future<void> rejectTranslation(String flaggedId, {String? teacherId}) async {
    await init();
    final actualTeacherId =
        teacherId ?? await TeacherProfileService.instance.getTeacherId();
    final index = _flaggedTranslations.indexWhere((e) => e.id == flaggedId);
    if (index != -1) {
      _flaggedTranslations[index].status = HitlStatusEnum.rejected;
      _recordCorrection(
        flaggedId: flaggedId,
        teacherId: actualTeacherId,
        teacherEdit: null,
        isApproved: false,
      );
      await _saveToDisk();
    }
  }

  Future<void> editAndSaveTranslation({
    required String flaggedId,
    required String editedText,
    String? teacherId,
  }) async {
    await init();
    final actualTeacherId =
        teacherId ?? await TeacherProfileService.instance.getTeacherId();
    final index = _flaggedTranslations.indexWhere((e) => e.id == flaggedId);
    if (index != -1) {
      _flaggedTranslations[index].status = HitlStatusEnum.edited;
      _recordCorrection(
        flaggedId: flaggedId,
        teacherId: actualTeacherId,
        teacherEdit: editedText,
        isApproved: true,
      );
      await _saveToDisk();
    }
  }

  void _recordCorrection({
    required String flaggedId,
    required String teacherId,
    required String? teacherEdit,
    required bool isApproved,
  }) {
    _teacherCorrections.removeWhere((c) => c.flaggedTranslationId == flaggedId);
    _teacherCorrections.add(
      TeacherCorrection(
        id: 'corr_${DateTime.now().millisecondsSinceEpoch}',
        flaggedTranslationId: flaggedId,
        teacherId: teacherId,
        teacherEdit: teacherEdit,
        isApproved: isApproved,
        editedAt: DateTime.now(),
        syncState: HitlSyncStateEnum.pending,
      ),
    );
  }

  List<TeacherCorrection> getPendingSyncCorrections() {
    return _teacherCorrections
        .where((c) => c.syncState == HitlSyncStateEnum.pending)
        .toList();
  }

  Future<void> markCorrectionsSynced(List<String> ids) async {
    for (final id in ids) {
      final index = _teacherCorrections.indexWhere((c) => c.id == id);
      if (index != -1) {
        _teacherCorrections[index].syncState = HitlSyncStateEnum.synced;
      }
    }
    _metadata = SyncMetadata(
      lastSyncedAt: DateTime.now(),
      activeModelVersion: _metadata.activeModelVersion,
      modelChecksum: _metadata.modelChecksum,
      pendingSyncCount: getPendingSyncCorrections().length,
    );
    await _saveToDisk();
  }
}
