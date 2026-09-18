enum AudioSpeakerTypeEnum { student, teacher }

extension AudioSpeakerTypeExtension on AudioSpeakerTypeEnum {
  String toDisplayName() {
    switch (this) {
      case AudioSpeakerTypeEnum.teacher:
        return 'शिक्षक (Teacher)';
      case AudioSpeakerTypeEnum.student:
        return 'छात्र (Student)';
    }
  }
}

enum AudioLanguagePairEnum { hindi, mundari }

extension AudioLanguagePairExtension on AudioLanguagePairEnum {
  String toDisplayName() {
    switch (this) {
      case AudioLanguagePairEnum.hindi:
        return 'हिंदी (Hindi)';
      case AudioLanguagePairEnum.mundari:
        return 'मुंडारी (Mundari)';
    }
  }
}

enum AudioSyncStatusEnum { pending, syncing, synced, failed }
enum AudioConsentStatusEnum { obtained, pending, declined }

class AudioRecordingItem {
  final String id;
  final String filePath;
  final AudioSpeakerTypeEnum speakerType;
  final AudioLanguagePairEnum language;
  final double durationSeconds;
  final int sampleRate;
  final double qualityScore;
  final double noiseLevelDb;
  final String? transcriptionText;
  bool approvedForTraining;
  AudioConsentStatusEnum consentStatus;
  final DateTime recordedAt;
  DateTime? syncedAt;
  AudioSyncStatusEnum syncStatus;
  final int fileSizeBytes;
  final String sttModelVersion;
  final String sha256Checksum;

  AudioRecordingItem({
    required this.id,
    required this.filePath,
    required this.speakerType,
    required this.language,
    required this.durationSeconds,
    this.sampleRate = 16000,
    required this.qualityScore,
    required this.noiseLevelDb,
    this.transcriptionText,
    this.approvedForTraining = false,
    this.consentStatus = AudioConsentStatusEnum.obtained,
    required this.recordedAt,
    this.syncedAt,
    this.syncStatus = AudioSyncStatusEnum.pending,
    required this.fileSizeBytes,
    this.sttModelVersion = 'v1.0.0_sherpa_onnx',
    required this.sha256Checksum,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'filePath': filePath,
        'speakerType': speakerType.name,
        'language': language.name,
        'durationSeconds': durationSeconds,
        'sampleRate': sampleRate,
        'qualityScore': qualityScore,
        'noiseLevelDb': noiseLevelDb,
        'transcriptionText': transcriptionText,
        'approvedForTraining': approvedForTraining,
        'consentStatus': consentStatus.name,
        'recordedAt': recordedAt.toIso8601String(),
        'syncedAt': syncedAt?.toIso8601String(),
        'syncStatus': syncStatus.name,
        'fileSizeBytes': fileSizeBytes,
        'sttModelVersion': sttModelVersion,
        'sha256Checksum': sha256Checksum,
      };

  factory AudioRecordingItem.fromJson(Map<String, dynamic> json) => AudioRecordingItem(
        id: json['id'] as String,
        filePath: json['filePath'] as String,
        speakerType: AudioSpeakerTypeEnum.values.firstWhere(
          (e) => e.name == json['speakerType'],
          orElse: () => AudioSpeakerTypeEnum.student,
        ),
        language: AudioLanguagePairEnum.values.firstWhere(
          (e) => e.name == json['language'],
          orElse: () => AudioLanguagePairEnum.hindi,
        ),
        durationSeconds: (json['durationSeconds'] as num).toDouble(),
        sampleRate: (json['sampleRate'] as num?)?.toInt() ?? 16000,
        qualityScore: (json['qualityScore'] as num).toDouble(),
        noiseLevelDb: (json['noiseLevelDb'] as num).toDouble(),
        transcriptionText: json['transcriptionText'] as String?,
        approvedForTraining: json['approvedForTraining'] as bool? ?? false,
        consentStatus: AudioConsentStatusEnum.values.firstWhere(
          (e) => e.name == json['consentStatus'],
          orElse: () => AudioConsentStatusEnum.obtained,
        ),
        recordedAt: DateTime.parse(json['recordedAt'] as String),
        syncedAt: json['syncedAt'] != null ? DateTime.parse(json['syncedAt'] as String) : null,
        syncStatus: AudioSyncStatusEnum.values.firstWhere(
          (e) => e.name == json['syncStatus'],
          orElse: () => AudioSyncStatusEnum.pending,
        ),
        fileSizeBytes: (json['fileSizeBytes'] as num).toInt(),
        sttModelVersion: json['sttModelVersion'] as String? ?? 'v1.0.0_sherpa_onnx',
        sha256Checksum: json['sha256Checksum'] as String? ?? '',
      );
}
