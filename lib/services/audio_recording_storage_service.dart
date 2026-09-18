import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/audio_training_models.dart';

class AudioQualityMetrics {
  final double qualityScore; // 0.0 to 1.0
  final double rmsDb;
  final double spectralCentroidHz;
  final double zeroCrossingRate;

  AudioQualityMetrics({
    required this.qualityScore,
    required this.rmsDb,
    required this.spectralCentroidHz,
    required this.zeroCrossingRate,
  });

  /// Computes on-device DSP quality score given raw PCM buffer samples.
  factory AudioQualityMetrics.compute(List<int> pcmSamples, {int sampleRate = 16000}) {
    if (pcmSamples.isEmpty) {
      return AudioQualityMetrics(qualityScore: 0.0, rmsDb: -100.0, spectralCentroidHz: 0.0, zeroCrossingRate: 0.0);
    }

    // 1. RMS Energy
    double sumSquare = 0.0;
    for (final sample in pcmSamples) {
      final norm = sample / 32768.0;
      sumSquare += norm * norm;
    }
    final rms = math.sqrt(sumSquare / pcmSamples.length);
    final rmsDb = 20 * (math.log(math.max(rms, 1e-5)) / math.ln10);
    final rmsNorm = ((rmsDb + 50.0) / 40.0).clamp(0.0, 1.0);

    // 2. Zero-Crossing Rate (ZCR)
    int zeroCrossings = 0;
    for (int i = 1; i < pcmSamples.length; i++) {
      if ((pcmSamples[i] >= 0 && pcmSamples[i - 1] < 0) || (pcmSamples[i] < 0 && pcmSamples[i - 1] >= 0)) {
        zeroCrossings++;
      }
    }
    final zcr = zeroCrossings / (pcmSamples.length - 1);
    final zcrNorm = (zcr >= 0.02 && zcr <= 0.30) ? 1.0 : (1.0 - (zcr - 0.12).abs() * 3.0).clamp(0.0, 1.0);

    // 3. Spectral Centroid Approximation
    final approxFreqHz = zcr * (sampleRate / 2.0);
    final specNorm = (approxFreqHz >= 300.0 && approxFreqHz <= 3500.0) ? 1.0 : 0.4;

    // 4. Combined Quality Score (Weighted: 45% RMS + 35% ZCR + 20% Spectral)
    final composite = (0.45 * rmsNorm) + (0.35 * zcrNorm) + (0.20 * specNorm);

    return AudioQualityMetrics(
      qualityScore: composite.clamp(0.0, 1.0),
      rmsDb: rmsDb,
      spectralCentroidHz: approxFreqHz,
      zeroCrossingRate: zcr,
    );
  }
}

class AudioRecordingStorageService {
  static final AudioRecordingStorageService _instance = AudioRecordingStorageService._internal();
  factory AudioRecordingStorageService() => _instance;
  AudioRecordingStorageService._internal();

  File? _storageFile;
  bool _initialized = false;
  final List<AudioRecordingItem> _recordings = [];

  static const int hardQuotaBytes = 1000 * 1024 * 1024; // 1 GB limit
  static const int softQuotaBytes = 800 * 1024 * 1024;  // 800 MB warning limit

  List<AudioRecordingItem> get recordings => List.unmodifiable(_recordings);

  Future<void> init() async {
    if (_initialized) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      _storageFile = File('${dir.path}/audio_recordings_store.json');

      if (await _storageFile!.exists()) {
        final raw = await _storageFile!.readAsString();
        if (raw.isNotEmpty) {
          final list = jsonDecode(raw) as List<dynamic>;
          _recordings.clear();
          _recordings.addAll(list.map((e) => AudioRecordingItem.fromJson(e as Map<String, dynamic>)));
        }
      } else {
        _seedDefaultRecordings();
        await _saveToDisk();
      }
    } catch (e) {
      debugPrint('[AudioStore] Storage init error: $e');
      _seedDefaultRecordings();
    }
    _initialized = true;
  }

  void _seedDefaultRecordings() {
    if (_recordings.isNotEmpty) return;
    final now = DateTime.now();

    _recordings.addAll([
      AudioRecordingItem(
        id: 'audio_rec_001',
        filePath: '/data/user/0/com.ayovaani/app_flutter/audio_001.opus',
        speakerType: AudioSpeakerTypeEnum.teacher,
        language: AudioLanguagePairEnum.hindi,
        durationSeconds: 14.5,
        qualityScore: 0.88,
        noiseLevelDb: -38.5,
        transcriptionText: 'आज की कक्षा में हम गणित के पाठ तीन की गणना का अभ्यास करेंगे।',
        approvedForTraining: true,
        consentStatus: AudioConsentStatusEnum.obtained,
        recordedAt: now.subtract(const Duration(minutes: 30)),
        fileSizeBytes: 28500,
        sha256Checksum: 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
      ),
      AudioRecordingItem(
        id: 'audio_rec_002',
        filePath: '/data/user/0/com.ayovaani/app_flutter/audio_002.opus',
        speakerType: AudioSpeakerTypeEnum.student,
        language: AudioLanguagePairEnum.mundari,
        durationSeconds: 22.0,
        qualityScore: 0.74,
        noiseLevelDb: -42.0,
        transcriptionText: 'तेञ़ इशकुल रे होनको मंडी जोोम तना।',
        approvedForTraining: true,
        consentStatus: AudioConsentStatusEnum.obtained,
        recordedAt: now.subtract(const Duration(hours: 3)),
        fileSizeBytes: 42100,
        sha256Checksum: '9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08',
      ),
      AudioRecordingItem(
        id: 'audio_rec_003',
        filePath: '/data/user/0/com.ayovaani/app_flutter/audio_003.opus',
        speakerType: AudioSpeakerTypeEnum.teacher,
        language: AudioLanguagePairEnum.mundari,
        durationSeconds: 18.2,
        qualityScore: 0.92,
        noiseLevelDb: -45.2,
        transcriptionText: 'मारंग माहातोय होनकोके पढ़ाव तादकोआ।',
        approvedForTraining: false,
        consentStatus: AudioConsentStatusEnum.obtained,
        recordedAt: now.subtract(const Duration(hours: 6)),
        fileSizeBytes: 35000,
        sha256Checksum: '6b86b273ff34fce19d6b804eff5a3f5747ada4eaa22f1d49c01e52ddb7875b4b',
      ),
      AudioRecordingItem(
        id: 'audio_rec_004',
        filePath: '/data/user/0/com.ayovaani/app_flutter/audio_004.opus',
        speakerType: AudioSpeakerTypeEnum.student,
        language: AudioLanguagePairEnum.hindi,
        durationSeconds: 9.8,
        qualityScore: 0.45,
        noiseLevelDb: -22.1,
        transcriptionText: 'सर, क्या मैं बाहर जा सकता हूँ?',
        approvedForTraining: false,
        consentStatus: AudioConsentStatusEnum.obtained,
        recordedAt: now.subtract(const Duration(days: 2)),
        fileSizeBytes: 19200,
        sha256Checksum: 'd41d8cd98f00b204e9800998ecf8427e',
      ),
      AudioRecordingItem(
        id: 'audio_rec_005',
        filePath: '/data/user/0/com.ayovaani/app_flutter/audio_005.opus',
        speakerType: AudioSpeakerTypeEnum.student,
        language: AudioLanguagePairEnum.mundari,
        durationSeconds: 31.0,
        qualityScore: 0.81,
        noiseLevelDb: -40.0,
        transcriptionText: 'गापा इशकुल रे छुटी ताइना।',
        approvedForTraining: true,
        consentStatus: AudioConsentStatusEnum.obtained,
        recordedAt: now.subtract(const Duration(days: 5)),
        fileSizeBytes: 58000,
        sha256Checksum: '4e07408562bedb8b60ce05c1decfe3ad16b72230967de01f640b7e4729b49fce',
      ),
    ]);
  }

  Future<void> _saveToDisk() async {
    if (_storageFile == null) return;
    try {
      final jsonList = _recordings.map((e) => e.toJson()).toList();
      await _storageFile!.writeAsString(jsonEncode(jsonList));
    } catch (e) {
      debugPrint('[AudioStore] Save disk error: $e');
    }
  }

  Future<void> toggleApproval(String id, bool approved) async {
    await init();
    final index = _recordings.indexWhere((e) => e.id == id);
    if (index != -1) {
      _recordings[index].approvedForTraining = approved;
      await _saveToDisk();
    }
  }

  int getTotalStorageUsedBytes() {
    return _recordings.fold(0, (sum, item) => sum + item.fileSizeBytes);
  }

  List<AudioRecordingItem> getPendingSyncRecordings() {
    return _recordings.where((item) =>
        item.approvedForTraining &&
        item.qualityScore >= 0.5 &&
        item.consentStatus == AudioConsentStatusEnum.obtained &&
        item.syncStatus == AudioSyncStatusEnum.pending
    ).toList();
  }

  Future<int> purgeRecordingsOlderThanDays(int days) async {
    await init();
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final toRemove = _recordings.where((e) => e.recordedAt.isBefore(cutoff)).toList();
    _recordings.removeWhere((e) => e.recordedAt.isBefore(cutoff));
    await _saveToDisk();
    return toRemove.length;
  }

  Future<int> purgeLowQualityRecordings({double threshold = 0.5}) async {
    await init();
    final toRemove = _recordings.where((e) => e.qualityScore < threshold).toList();
    _recordings.removeWhere((e) => e.qualityScore < threshold);
    await _saveToDisk();
    return toRemove.length;
  }
}
