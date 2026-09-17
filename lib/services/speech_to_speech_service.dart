import 'dart:typed_data';
import '../pipeline/demo_cache_manager.dart';

enum TranslationSource { demoCache, realTime }

class S2STranslationResult {
  final String hindiText;
  final String mundariText;
  final String? audioPath;
  final Uint8List? audioBytes;
  final TranslationSource source;
  final int latencyMs;
  final int? cacheEntryId;

  S2STranslationResult({
    required this.hindiText,
    required this.mundariText,
    this.audioPath,
    this.audioBytes,
    required this.source,
    required this.latencyMs,
    this.cacheEntryId,
  });

  bool get isCacheHit => source == TranslationSource.demoCache;
  bool get isRealTime => source == TranslationSource.realTime;
}

// Mock interfaces for pipeline components
class HindiSpeechToText {
  Future<String> transcribeHindiAudio(String audioFilePath) async {
    // In a real implementation, this would send audio to a Whisper model.
    // For this demo, we'll return a hardcoded sentence to trigger the cache.
    await Future.delayed(const Duration(milliseconds: 500));
    return 'तुम्हारे कितने हाथ हैं?'; 
  }
}

class HindiToMundariTranslator {
  Future<String> translateHindiToMundari(String hindiText) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return '[मुंडारी] $hindiText';
  }
}

class MundariTextToSpeech {
  Future<Uint8List> synthesizeMundariSpeech(String mundariText) async {
    await Future.delayed(const Duration(seconds: 1));
    return Uint8List(0); // Mock empty audio bytes
  }
}

class SpeechToSpeechService {
  final DemoCacheManager _cacheManager = DemoCacheManager();
  final HindiSpeechToText stt;
  final HindiToMundariTranslator mt;
  final MundariTextToSpeech tts;
  final bool useDemoCache;

  SpeechToSpeechService({
    required this.stt,
    required this.mt,
    required this.tts,
    this.useDemoCache = true,
  });

  Future<void> initialize() async {
    if (useDemoCache) {
      await _cacheManager.initialize();
    }
  }

  Future<S2STranslationResult> translateSpeech({
    required String audioFilePath,
    bool forceRealTime = false,
  }) async {
    final startTime = DateTime.now();

    // 1. Hindi STT
    final hindiText = await stt.transcribeHindiAudio(audioFilePath);

    // 2. Check cache
    if (useDemoCache && !forceRealTime) {
      final cached = _cacheManager.findByHindiText(hindiText);
      if (cached != null) {
        return S2STranslationResult(
          hindiText: hindiText,
          mundariText: cached.mundariOdia,
          audioPath: _cacheManager.getAudioAssetPath(cached),
          audioBytes: null,
          source: TranslationSource.demoCache,
          latencyMs: DateTime.now().difference(startTime).inMilliseconds,
          cacheEntryId: cached.id,
        );
      }
    }

    // 3. Full pipeline (MT + TTS)
    final mundariText = await mt.translateHindiToMundari(hindiText);
    final audioBytes = await tts.synthesizeMundariSpeech(mundariText);

    return S2STranslationResult(
      hindiText: hindiText,
      mundariText: mundariText,
      audioPath: null,
      audioBytes: audioBytes,
      source: TranslationSource.realTime,
      latencyMs: DateTime.now().difference(startTime).inMilliseconds,
      cacheEntryId: null,
    );
  }
}
