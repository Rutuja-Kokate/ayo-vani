import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';
import 'engine/mt_stage.dart';
import 'engine/pipeline.dart';
import 'engine/stt_stage.dart';
import 'engine/tts_stage.dart';
import 'providers/locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize and load saved locale preference before first frame
  final localeProvider = LocaleProvider();
  await localeProvider.loadSavedLocale();

  // Initialize real on-device Speech Pipeline
  final sttStage = SttStage();
  final mtStage = RealMtStage();
  final ttsStage = TtsStage();
  final pipeline = SpeechPipeline(
    sttStage: sttStage,
    mtStage: mtStage,
    ttsStage: ttsStage,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
        Provider<SpeechPipeline>.value(value: pipeline),
      ],
      child: const AyoVaaniApp(),
    ),
  );
}
