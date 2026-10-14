import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ayo_vani/engine/pipeline.dart';
import 'package:ayo_vani/engine/stt_stage.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('STT Smoke Test (IndicConformer Offline ASR)', () {
    testWidgets('Transcribes bundled 16 kHz WAV (short_7s.wav) and verifies non-empty Hindi transcript', (tester) async {
      // 1. Skip on host machine if native ASR binaries are not available
      if (!Platform.isAndroid && !Platform.isIOS) {
        // ignore: avoid_print
        print(
          '[STT-Smoke] SKIPPED ON HOST (${Platform.operatingSystem}). '
          'Sherpa-ONNX ASR requires on-device native libraries (sherpa-onnx-jni/c-api). '
          'Run on Android device/emulator: flutter test integration_test/stt_smoke_test.dart',
        );
        return;
      }

      // ignore: avoid_print
      print('[STT-Smoke] Running on device: ${Platform.operatingSystem}');

      // 2. Prepare wav file path on device
      final Directory tempDir = await getTemporaryDirectory();
      final File targetWav = File('${tempDir.path}/short_7s.wav');

      const fixtureDir = String.fromEnvironment('FIXTURE_DIR', defaultValue: 'test/fixtures');
      final fixtureWav = File('$fixtureDir/short_7s.wav');
      if (await fixtureWav.exists()) {
        await fixtureWav.copy(targetWav.path);
      } else {
        final fallback = File('test/fixtures/short_7s.wav');
        if (await fallback.exists()) {
          await fallback.copy(targetWav.path);
        } else {
          fail('Could not locate short_7s.wav fixture at "$fixtureDir". '
              'Push fixtures via adb and pass --dart-define=FIXTURE_DIR=<dir>');
        }
      }

      expect(await targetWav.exists(), isTrue);
      final wavSize = await targetWav.length();
      // ignore: avoid_print
      print('[STT-Smoke] Prepared audio fixture at ${targetWav.path} ($wavSize bytes)');

      // 3. Initialize SttStage in Hindi -> Mundari direction (recognizes Hindi speech)
      final stt = SttStage();
      final initWatch = Stopwatch()..start();
      await stt.initModel(direction: TranslationDirection.hindiToMundari);
      initWatch.stop();

      expect(stt.isReady, isTrue);
      // ignore: avoid_print
      print('[STT-Smoke] SttStage initialized in ${initWatch.elapsedMilliseconds}ms');

      // 4. Run inference on bundled 16 kHz audio
      final inferWatch = Stopwatch()..start();
      final String transcript = await stt.transcribeFile(targetWav.path);
      inferWatch.stop();

      // ignore: avoid_print
      print('[STT-Smoke] ASR inference completed in ${inferWatch.elapsedMilliseconds}ms');
      // ignore: avoid_print
      print('[STT-Smoke] Result transcript: "$transcript"');

      // 5. Verification: transcript must be non-empty
      expect(
        transcript.trim(),
        isNotEmpty,
        reason: 'STT engine should transcribe speech from short_7s.wav and return non-empty Hindi text.',
      );

      stt.dispose();
      await targetWav.delete().catchError((_) => targetWav);
    });
  });
}
