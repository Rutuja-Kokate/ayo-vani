import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ayo_vani/engine/mt_stage.dart';
import 'package:ayo_vani/engine/pipeline.dart';

String escapeCsvField(String value) {
  if (value.contains(',') || value.contains('"') || value.contains('\n') || value.contains('\r')) {
    return '"${value.replaceAll('"', '""')}"';
  }
  return value;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Machine Translation Evaluation Harness', () {
    testWidgets('Translates 100 demo sentences with RealMtStage and exports CSV', (tester) async {
      // 1. Skip check on host machine (RealMtStage requires on-device ONNX runtime libraries)
      if (!Platform.isAndroid && !Platform.isIOS) {
        // ignore: avoid_print
        print(
          '[MT-Eval] SKIPPED ON HOST (${Platform.operatingSystem}). '
          'RealMtStage requires on-device ONNX Runtime dynamic libraries. '
          'Run on Android device/emulator: flutter test integration_test/mt_eval_test.dart',
        );
        return;
      }

      // ignore: avoid_print
      print('[MT-Eval] Running on device: ${Platform.operatingSystem}');

      // 2. Load demo corpus fixture
      String jsonContent;
      const fixtureDir = String.fromEnvironment('FIXTURE_DIR', defaultValue: 'test/fixtures');
      final fixtureFile = File('$fixtureDir/demo_corpus_100_sentences.json');
      if (await fixtureFile.exists()) {
        jsonContent = await fixtureFile.readAsString();
      } else {
        final fallback = File('test/fixtures/demo_corpus_100_sentences.json');
        if (await fallback.exists()) {
          jsonContent = await fallback.readAsString();
        } else {
          fail('Could not locate demo_corpus_100_sentences.json at "$fixtureDir". '
              'Push fixtures via adb and pass --dart-define=FIXTURE_DIR=<dir>');
        }
      }

      final Map<String, dynamic> data = jsonDecode(jsonContent) as Map<String, dynamic>;
      final List<dynamic> sentences = data['demo_corpus'] as List<dynamic>;
      expect(sentences, isNotEmpty, reason: 'Demo corpus must contain sentences');

      // 3. Initialize RealMtStage on device
      final mtStage = RealMtStage();
      final initWatch = Stopwatch()..start();
      await mtStage.initModel();
      initWatch.stop();
      // ignore: avoid_print
      print('[MT-Eval] RealMtStage model loaded in ${initWatch.elapsedMilliseconds}ms');

      final csvBuffer = StringBuffer();
      csvBuffer.writeln('hindi,reference,output,ms,truncated,confidence');

      int evaluatedCount = 0;
      final totalSentences = sentences.length;

      for (int i = 0; i < totalSentences; i++) {
        final item = sentences[i] as Map<String, dynamic>;
        final String hindi = (item['hindi'] as String? ?? '').trim();
        final String reference = (item['mundari_devanagari'] as String? ?? '').trim();

        if (hindi.isEmpty) continue;

        final watch = Stopwatch()..start();
        final MtResult result = await mtStage.translate(
          hindi,
          direction: TranslationDirection.hindiToMundari,
        );
        watch.stop();
        final int elapsedMs = watch.elapsedMilliseconds;

        final row = [
          escapeCsvField(hindi),
          escapeCsvField(reference),
          escapeCsvField(result.displayText),
          elapsedMs.toString(),
          result.truncated.toString(),
          result.confidence?.toStringAsFixed(6) ?? 'null',
        ].join(',');

        csvBuffer.writeln(row);
        evaluatedCount++;

        if ((i + 1) % 20 == 0 || i + 1 == totalSentences) {
          // ignore: avoid_print
          print('[MT-Eval] Processed ${i + 1}/$totalSentences sentences (last: ${elapsedMs}ms, conf: ${result.confidence})');
        }
      }

      mtStage.dispose();

      // 4. Write CSV results to file
      final Directory outputDir = await getApplicationDocumentsDirectory();
      final File csvFile = File('${outputDir.path}/mt_eval_results.csv');
      await csvFile.writeAsString(csvBuffer.toString(), flush: true);

      // ignore: avoid_print
      print('[MT-Eval] Evaluation complete ($evaluatedCount sentences).');
      // ignore: avoid_print
      print('[MT-Eval] CSV saved to: ${csvFile.path}');
      // ignore: avoid_print
      print('[MT-Eval] Score results with: python3 tool/score_mt.py ${csvFile.path}');

      expect(evaluatedCount, equals(totalSentences));
    });
  });
}
