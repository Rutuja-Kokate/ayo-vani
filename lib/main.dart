import 'package:flutter/material.dart';
import 'app/app.dart';

import 'package:provider/provider.dart';
import 'pipeline/demo_cache_manager.dart';
import 'pipeline/hindi_stt_service.dart';
import 'services/speech_to_speech_service.dart';
import 'services/audio_player_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize demo cache manager
  final cacheManager = DemoCacheManager();
  await cacheManager.initialize();
  debugPrint('✓ Demo cache loaded: ${cacheManager.totalSentences} sentences');

  // Initialize STT service (lazy init in translate screen)
  final hindiStt = HindiSttService();

  // Initialize S2ST service (lazy init in translate screen)
  final s2stService = SpeechToSpeechService(
    stt: HindiSpeechToText(),
    mt: HindiToMundariTranslator(),
    tts: MundariTextToSpeech(),
    useDemoCache: true, // Enable cache by default
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<DemoCacheManager>.value(value: cacheManager),
        Provider<HindiSttService>.value(value: hindiStt),
        Provider<SpeechToSpeechService>.value(value: s2stService),
        Provider<S2SAudioPlayerService>(create: (_) => S2SAudioPlayerService()),
      ],
      child: const AyoVaaniApp(),
    ),
  );
}
