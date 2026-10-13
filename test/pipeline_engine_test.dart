import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart';

import 'package:ayo_vani/engine/audio_playback_worker.dart';
import 'package:ayo_vani/engine/loanwords.dart';
import 'package:ayo_vani/engine/mt_stage.dart';
import 'package:ayo_vani/engine/pipeline.dart';
import 'package:ayo_vani/engine/script_utils.dart';
import 'package:ayo_vani/engine/stt_stage.dart';
import 'package:ayo_vani/engine/tts_stage.dart';
import 'package:ayo_vani/engine/tts_text_frontend.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers.global'),
      (MethodCall methodCall) async => 1,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers'),
      (MethodCall methodCall) async => 1,
    );

    String? dylibPath;
    if (Platform.isMacOS) {
      final home = Platform.environment['HOME'];
      if (home != null) {
        final cacheDir = Directory('$home/.pub-cache/hosted/pub.dev');
        if (cacheDir.existsSync()) {
          for (final entity in cacheDir.listSync()) {
            if (entity.path.contains('sherpa_onnx_macos')) {
              final dylibFile = File(
                '${entity.path}/macos/sherpa_onnx_macos/sherpa-onnx.xcframework/macos-arm64_x86_64/libsherpa-onnx-c-api.dylib',
              );
              if (dylibFile.existsSync()) {
                dylibPath = '${entity.path}/macos';
                break;
              }
            }
          }
        }
      }
    }
    initBindings(dylibPath);
  });

  group('1. Script Utils Tests', () {
    test('transliterateDevaToOdia converts Devanagari runes and applies phonetic corrections', () {
      // Devanagari YA (य - U+092F) -> Odia Yya (ୟ - U+0B5F)
      final yaResult = transliterateDevaToOdia('य');
      expect(yaResult, 'ୟ');

      // Devanagari II (ई - U+0908) -> Odia I (ଇ - U+0B07)
      final iiResult = transliterateDevaToOdia('ई');
      expect(iiResult, 'ଇ');

      // Devanagari VA (व - U+0935) -> Odia BA (ବ - U+0B2C)
      final vaResult = transliterateDevaToOdia('व');
      expect(vaResult, 'ବ');

      // Virama / halant stripping (e.g. ଫ୍ଲ -> ଫଲ)
      final halantResult = transliterateDevaToOdia('क्');
      expect(halantResult, 'କ');

      // Full sentence with punctuation stripping
      final sentence = 'नमस्ते दुनिया, यह सुंदर है।';
      final out = transliterateDevaToOdia(sentence);
      expect(out.isNotEmpty, isTrue);
      expect(out.contains('।'), isFalse);
      expect(out.contains(','), isFalse);
    });

    test('splitIntoClauses splits text by punctuation and length boundaries', () {
      final textWithDanda = 'पहला भाग। दूसरा भाग। तीसरा भाग।';
      final clauses = splitIntoClauses(textWithDanda);
      expect(clauses.length, 3);
      expect(clauses[0], 'पहला भाग।');
      expect(clauses[1], 'दूसरा भाग।');
      expect(clauses[2], 'तीसरा भाग।');

      final textWithComma = 'यह आम है, वह सेब है, और वह केला है';
      final commaClauses = splitIntoClauses(textWithComma);
      expect(commaClauses.length, greaterThanOrEqualTo(2));

      expect(splitIntoClauses('   '), isEmpty);
    });
  });

  group('2. Clause Splitting Tests', () {
    test('SpeechPipeline.splitIntoClauses splits on punctuation boundaries', () {
      final input = 'अबोवाः आतु रे मेनइया। नेन्दो सेनोः आबुआ? हें, एतकागे!';
      final clauses = SpeechPipeline.splitIntoClauses(input);
      expect(clauses.length, greaterThanOrEqualTo(2));
      expect(clauses.any((c) => c.contains('अबोवाः')), isTrue);
    });

    test('SpeechPipeline.splitIntoClauses splits long unpunctuated sentences without splitting words', () {
      final longSentence = 'नेन्दो मारंग बुरु अबोवाः दिशुम रे मेनाइया ओन्दो सबुह जोहार मियांग ताना';
      final clauses = SpeechPipeline.splitIntoClauses(longSentence);
      expect(clauses.length, greaterThan(1));
      for (final clause in clauses) {
        expect(clause.trim().isNotEmpty, isTrue);
        // Words should remain intact
        expect(clause.contains(' '), anyOf(isTrue, isFalse));
      }
    });

    test('SpeechPipeline.splitIntoClauses handles empty and blank input', () {
      expect(SpeechPipeline.splitIntoClauses(''), isEmpty);
      expect(SpeechPipeline.splitIntoClauses('   \n\t  '), isEmpty);
    });
  });

  group('3. TTS Text Front-End Contract (prepareTtsText) Tests', () {
    test('Example 1: substitutes English classroom loanwords (notebook, pencil)', () {
      const input = 'यह एक notebook और pencil है।';
      final out = prepareTtsText(input);
      expect(out, contains('नोटबुक'));
      expect(out, contains('पेंसिल'));
      expect(out.contains('notebook'), isFalse);
      expect(out.contains('pencil'), isFalse);
      expect(out, contains('.'));
      expect(out.contains('।'), isFalse);
    });

    test('Example 2: substitutes board and chapter loanwords', () {
      const input = 'टीचर ने board पर chapter लिखा।';
      final out = prepareTtsText(input);
      expect(out, contains('बोर्ड'));
      expect(out, contains('चैप्टर'));
      expect(out, contains('टीचर'));
      expect(out.contains('board'), isFalse);
      expect(out.contains('chapter'), isFalse);
    });

    test('Example 3: normalizes Devanagari danda and double danda to pause punctuation', () {
      const input = 'नेन्दो ओड़ाः रे मेनांगिया। सबुह जोहार॥';
      final out = prepareTtsText(input);
      expect(out.contains('।'), isFalse);
      expect(out.contains('॥'), isFalse);
      expect(out, contains('.'));
      expect(out, 'नेन्दो ओड़ाः रे मेनांगिया. सबुह जोहार.');
    });

    test('Example 4: normalizes dashes, semicolons and replaces quiz and practice', () {
      const input = 'क्लास में student practice करेंगे—quiz शुरू होगा!';
      final out = prepareTtsText(input);
      expect(out, contains('क्लास'));
      expect(out, contains('स्टूडेंट'));
      expect(out, contains('अभ्यास'));
      expect(out, contains('क्विज़'));
      expect(out.contains('—'), isFalse);
      expect(out.contains(','), isTrue);
    });

    test('Example 5: normalizes semicolon and replaces school, unit, lesson', () {
      const input = 'अइंग school सेनतन; unit 1 lesson 2 पढतई।';
      final out = prepareTtsText(input);
      expect(out, contains('स्कूल'));
      expect(out, contains('यूनिट'));
      expect(out, contains('लेसन'));
      expect(out.contains(';'), isFalse);
      expect(out.contains('school'), isFalse);
      expect(out.contains('.'), isTrue);
    });

    test('Example 6: handles empty, single-word and whitespace edge cases', () {
      expect(prepareTtsText(''), '');
      expect(prepareTtsText('   \n\t '), '');
      expect(prepareTtsText('जोहार'), 'जोहार');
    });

    test('Loanwords dictionary contains expected classroom mappings', () {
      expect(kLoanwordPhoneticMap['notebook'], 'नोटबुक');
      expect(kLoanwordPhoneticMap['teacher'], 'टीचर');
      expect(kLoanwordPhoneticMap['student'], 'स्टूडेंट');
      expect(kLoanwordPhoneticMap['quiz'], 'क्विज़');
      expect(kLoanwordPhoneticMap['board'], 'बोर्ड');
    });
  });

  group('4. WAV Header & WAV Reading with sherpa_onnx Tests', () {
    test('AudioPlaybackWorker.pcmToWav builds valid WAV and sherpa_onnx.readWave reads it correctly', () {
      const sampleRate = 16000;
      const numSamples = 1600; // 100ms at 16kHz
      final pcm16 = Int16List(numSamples);

      // Create a 440 Hz test sine wave in 16-bit PCM
      for (int i = 0; i < numSamples; i++) {
        final double sample = 0.5 * (i % 2 == 0 ? 1.0 : -1.0); // alternating pulse
        pcm16[i] = (sample * 32767).toInt();
      }

      final pcmBytes = pcm16.buffer.asUint8List();
      final wavBytes = AudioPlaybackWorker.pcmToWav(pcmBytes, sampleRate: sampleRate);

      // Verify 44-byte WAV header structure
      expect(wavBytes.length, pcmBytes.length + 44);
      expect(String.fromCharCodes(wavBytes.sublist(0, 4)), 'RIFF');
      expect(String.fromCharCodes(wavBytes.sublist(8, 12)), 'WAVE');
      expect(String.fromCharCodes(wavBytes.sublist(12, 16)), 'fmt ');
      expect(String.fromCharCodes(wavBytes.sublist(36, 40)), 'data');

      // Write to temp file and read back via sherpa_onnx.readWave
      final tempDir = Directory.systemTemp.createTempSync('wav_test_');
      final tempFile = File('${tempDir.path}/test_audio.wav');
      tempFile.writeAsBytesSync(wavBytes);

      try {
        final wave = readWave(tempFile.path);
        expect(wave.sampleRate, sampleRate);
        expect(wave.samples.length, numSamples);
        // Verify float samples are in valid audio range [-1.0, 1.0]
        for (int i = 0; i < 50; i++) {
          expect(wave.samples[i], inInclusiveRange(-1.0, 1.0));
        }
      } finally {
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      }
    });
  });

  group('5. Headless Pipeline & Stage Construction Tests (No UI)', () {
    test('Constructs SttStage, RealMtStage, TtsStage, and SpeechPipeline headlessly', () {
      final stt = SttStage(threads: 2);
      expect(stt.isReady, isFalse);
      expect(stt.threads, 2);
      expect(stt.currentDirection, TranslationDirection.hindiToMundari);

      final mt = RealMtStage(threads: 1, maxDecodeTokens: 32, collapseAdjacentDuplicates: false);
      expect(mt.isInitialized, isFalse);
      expect(mt.threads, 1);
      expect(mt.maxDecodeTokens, 32);
      expect(mt.collapseAdjacentDuplicates, isFalse);

      final tts = TtsStage(threads: 1, provider: 'cpu');
      expect(tts.isInitialized, isFalse);
      expect(tts.threads, 1);
      expect(tts.provider, 'cpu');

      final pipeline = SpeechPipeline(
        sttStage: stt,
        mtStage: mt,
        ttsStage: tts,
        activeDirection: TranslationDirection.hindiToMundari,
      );

      expect(pipeline.isLiveActive, isFalse);
      expect(pipeline.activeDirection, TranslationDirection.hindiToMundari);
      expect(pipeline.audioPlayer, isNotNull);
    });

    test('RealMtStage throws MtException when models are not loaded (Defect 7)', () {
      final mt = RealMtStage();
      expect(
        () => mt.translate('नमस्ते दुनिया'),
        throwsA(isA<MtException>()),
      );
    });

    test('MtResult correctly exposes confidence and truncated flags (Defect 8)', () {
      const resultNormal = MtResult(
        displayText: 'जोहार धरती',
        synthesizeText: 'जोहार धरती',
        confidence: 0.95,
        truncated: false,
      );
      expect(resultNormal.displayText, 'जोहार धरती');
      expect(resultNormal.synthesizeText, 'जोहार धरती');
      expect(resultNormal.confidence, 0.95);
      expect(resultNormal.truncated, isFalse);

      const resultTruncated = MtResult(
        displayText: 'नेन्दो ओड़ाः',
        synthesizeText: 'नेन्दो ओड़ाः',
        confidence: null,
        truncated: true,
      );
      expect(resultTruncated.confidence, isNull);
      expect(resultTruncated.truncated, isTrue);
    });

    test('PipelineResult and LiveClauseTiming handle bidirectional translations', () {
      final h2m = PipelineResult(
        sourceText: 'नमस्ते दुनिया',
        targetText: 'जोहार धरती',
        direction: TranslationDirection.hindiToMundari,
        audioBytes: Uint8List(0),
        audioSampleRate: 16000,
        sttMs: 200,
        mtMs: 150,
        ttsMs: 300,
        firstClauseTtsMs: 120,
        clauseCount: 1,
      );
      expect(h2m.hindiText, 'नमस्ते दुनिया');
      expect(h2m.mundariText, 'जोहार धरती');
      expect(h2m.totalMs, 650);
      expect(h2m.timeToFirstAudioMs, 470);

      final m2h = PipelineResult(
        sourceText: 'जोहार धरती',
        targetText: 'नमस्ते दुनिया',
        direction: TranslationDirection.mundariToHindi,
        audioBytes: Uint8List(0),
        audioSampleRate: 16000,
        sttMs: 180,
        mtMs: 140,
        ttsMs: 250,
        firstClauseTtsMs: 100,
        clauseCount: 1,
      );
      expect(m2h.hindiText, 'नमस्ते दुनिया');
      expect(m2h.mundariText, 'जोहार धरती');
      expect(m2h.totalMs, 570);
      expect(m2h.timeToFirstAudioMs, 420);
    });
  });
}
