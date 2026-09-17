import 'dart:convert';

enum LanguagePairEnum {
  hindiToMundari,
  mundariToHindi,
}

extension LanguagePairExtension on LanguagePairEnum {
  String toShortString() {
    return this == LanguagePairEnum.hindiToMundari ? 'HINDI_TO_MUNDARI' : 'MUNDARI_TO_HINDI';
  }

  String toDisplayName() {
    return this == LanguagePairEnum.hindiToMundari ? 'हिंदी → मुंडारी' : 'मुंडारी → हिंदी';
  }

  static LanguagePairEnum fromString(String val) {
    if (val == 'MUNDARI_TO_HINDI' || val == 'mundariToHindi') {
      return LanguagePairEnum.mundariToHindi;
    }
    return LanguagePairEnum.hindiToMundari;
  }
}

enum HitlStatusEnum {
  flagged,
  approved,
  edited,
  rejected,
}

extension HitlStatusExtension on HitlStatusEnum {
  String toShortString() {
    return toString().split('.').last.toUpperCase();
  }

  static HitlStatusEnum fromString(String val) {
    switch (val.toLowerCase()) {
      case 'approved':
        return HitlStatusEnum.approved;
      case 'edited':
        return HitlStatusEnum.edited;
      case 'rejected':
        return HitlStatusEnum.rejected;
      default:
        return HitlStatusEnum.flagged;
    }
  }
}

enum HitlSyncStateEnum {
  pending,
  syncing,
  synced,
  failed,
}

extension HitlSyncStateExtension on HitlSyncStateEnum {
  String toShortString() {
    return toString().split('.').last.toUpperCase();
  }

  static HitlSyncStateEnum fromString(String val) {
    switch (val.toLowerCase()) {
      case 'syncing':
        return HitlSyncStateEnum.syncing;
      case 'synced':
        return HitlSyncStateEnum.synced;
      case 'failed':
        return HitlSyncStateEnum.failed;
      default:
        return HitlSyncStateEnum.pending;
    }
  }
}

class FlaggedTranslation {
  final String id;
  final String sourceText;
  final String targetText;
  final double confidence;
  final LanguagePairEnum languagePair;
  final String modelVersion;
  final DateTime timestamp;
  HitlStatusEnum status;

  FlaggedTranslation({
    required this.id,
    required this.sourceText,
    required this.targetText,
    required this.confidence,
    required this.languagePair,
    this.modelVersion = 'v1.0.0_int8',
    required this.timestamp,
    this.status = HitlStatusEnum.flagged,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'sourceText': sourceText,
        'targetText': targetText,
        'confidence': confidence,
        'languagePair': languagePair.toShortString(),
        'modelVersion': modelVersion,
        'timestamp': timestamp.toIso8601String(),
        'status': status.toShortString(),
      };

  factory FlaggedTranslation.fromJson(Map<String, dynamic> json) => FlaggedTranslation(
        id: json['id'] as String,
        sourceText: json['sourceText'] as String,
        targetText: json['targetText'] as String,
        confidence: (json['confidence'] as num).toDouble(),
        languagePair: LanguagePairExtension.fromString(json['languagePair'] as String),
        modelVersion: json['modelVersion'] as String? ?? 'v1.0.0_int8',
        timestamp: DateTime.parse(json['timestamp'] as String),
        status: HitlStatusExtension.fromString(json['status'] as String? ?? 'FLAGGED'),
      );
}

class TeacherCorrection {
  final String id;
  final String flaggedTranslationId;
  final String teacherId;
  final String? teacherEdit;
  final bool isApproved;
  final DateTime editedAt;
  HitlSyncStateEnum syncState;

  TeacherCorrection({
    required this.id,
    required this.flaggedTranslationId,
    required this.teacherId,
    this.teacherEdit,
    required this.isApproved,
    required this.editedAt,
    this.syncState = HitlSyncStateEnum.pending,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'flaggedTranslationId': flaggedTranslationId,
        'teacherId': teacherId,
        'teacherEdit': teacherEdit,
        'isApproved': isApproved,
        'editedAt': editedAt.toIso8601String(),
        'syncState': syncState.toShortString(),
      };

  factory TeacherCorrection.fromJson(Map<String, dynamic> json) => TeacherCorrection(
        id: json['id'] as String,
        flaggedTranslationId: json['flaggedTranslationId'] as String,
        teacherId: json['teacherId'] as String,
        teacherEdit: json['teacherEdit'] as String?,
        isApproved: json['isApproved'] as bool,
        editedAt: DateTime.parse(json['editedAt'] as String),
        syncState: HitlSyncStateExtension.fromString(json['syncState'] as String? ?? 'PENDING'),
      );
}

class SyncMetadata {
  final DateTime lastSyncedAt;
  final String activeModelVersion;
  final String modelChecksum;
  final int pendingSyncCount;

  SyncMetadata({
    required this.lastSyncedAt,
    this.activeModelVersion = 'v1.0.0_int8',
    this.modelChecksum = 'sha256_palash_int8_default',
    required this.pendingSyncCount,
  });

  Map<String, dynamic> toJson() => {
        'lastSyncedAt': lastSyncedAt.toIso8601String(),
        'activeModelVersion': activeModelVersion,
        'modelChecksum': modelChecksum,
        'pendingSyncCount': pendingSyncCount,
      };

  factory SyncMetadata.fromJson(Map<String, dynamic> json) => SyncMetadata(
        lastSyncedAt: DateTime.parse(json['lastSyncedAt'] as String),
        activeModelVersion: json['activeModelVersion'] as String? ?? 'v1.0.0_int8',
        modelChecksum: json['modelChecksum'] as String? ?? 'sha256_palash_int8_default',
        pendingSyncCount: json['pendingSyncCount'] as int? ?? 0,
      );
}
