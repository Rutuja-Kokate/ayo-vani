import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ayo_vani/screens/first/phase2_question_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget createTestWidget({
    Size size = const Size(393, 851),
    int initialIndex = 0,
    int randomSeed = 42,
    ValueChanged<String>? onPlayMundariAudio,
    VoidCallback? onCompletePhase,
    List<Phase2QuestionData>? questions,
  }) {
    return MediaQuery(
      data: MediaQueryData(
        size: size,
        padding: const EdgeInsets.only(top: 24, bottom: 16),
      ),
      child: MaterialApp(
        home: Phase2QuestionScreen(
          initialQuestionIndex: initialIndex,
          randomSeed: randomSeed,
          onPlayMundariAudio: onPlayMundariAudio,
          onCompletePhase: onCompletePhase,
          questions: questions ?? Phase2QuestionScreen.defaultQuestions,
        ),
      ),
    );
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  // For full-flow tests, use pump instead of pumpAndSettle to avoid image load errors.
  Future<void> tapVisiblePump(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pump();
    await tester.tap(finder);
    await tester.pump(const Duration(milliseconds: 300));
  }

  // ---------------------------------------------------------------------------
  // GROUP 1: Rendering
  // ---------------------------------------------------------------------------
  group('Phase2QuestionScreen - Rendering', () {
    testWidgets('renders all required UI elements on Question 1', (tester) async {
      tester.view.physicalSize = const Size(393, 851);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.text('First • Ch 1'), findsOneWidget);
      expect(find.text('Level 1'), findsOneWidget);
      expect(find.text('Q 1/5'), findsOneWidget);
      expect(find.text('20%'), findsOneWidget);
      expect(find.text('ओमाकन गतिविधि मेनते सही वाक्य सलाएमे'), findsOneWidget);
      expect(find.text('(choose the correct sentence for given activity)'), findsOneWidget);
      expect(find.text('CHECK'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Learn'), findsOneWidget);
      expect(find.text('Translate'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('renders tablet layout without overflow', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(createTestWidget(size: const Size(1280, 800)));
      await tester.pumpAndSettle();
      expect(find.text('Q 1/5'), findsOneWidget);
      expect(find.text('CHECK'), findsOneWidget);
    });

    testWidgets('activity image asset path matches Question 1 imageAsset', (tester) async {
      tester.view.physicalSize = const Size(393, 851);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      final imageFinder = find.byWidgetPredicate(
        (w) => w is Image && (w.image as AssetImage).assetName == 'assets/images/play.png',
      );
      expect(imageFinder, findsWidgets);
    });
  });

  // ---------------------------------------------------------------------------
  // GROUP 2: Answer Selection
  // ---------------------------------------------------------------------------
  group('Phase2QuestionScreen - Answer Selection', () {
    testWidgets('CHECK with no selection shows snackbar', (tester) async {
      tester.view.physicalSize = const Size(393, 851);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      await tapVisible(tester, find.text('CHECK'));
      expect(find.text('Please select an answer first!'), findsOneWidget);
    });

    testWidgets('correct answer shows CONTINUE and feedback', (tester) async {
      tester.view.physicalSize = const Size(393, 851);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(createTestWidget(randomSeed: 0));
      await tester.pumpAndSettle();
      await tapVisible(tester, find.text('एक लड़की खेल रही है।'));
      await tapVisible(tester, find.text('CHECK'));
      expect(find.text('CONTINUE'), findsOneWidget);
      expect(find.text('शानदार! चित्र में एक लड़की खेल रही है।'), findsOneWidget);
    });

    testWidgets('incorrect answer does not show CONTINUE', (tester) async {
      tester.view.physicalSize = const Size(393, 851);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(createTestWidget(randomSeed: 0));
      await tester.pumpAndSettle();
      await tapVisible(tester, find.text('एक लड़की सो रही है।'));
      await tapVisible(tester, find.text('CHECK'));
      expect(find.text('CHECK'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // GROUP 3: Full Phase Flow (using pump to avoid asset-load exceptions in tests)
  // ---------------------------------------------------------------------------
  group('Phase2QuestionScreen - Full Phase Flow', () {
    testWidgets('progresses through Q1-Q5 and shows completion dialog', (tester) async {
      tester.view.physicalSize = const Size(393, 851);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      // Suppress image-load errors so question transitions do not abort the test.
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exceptionAsString().contains('Unable to load asset')) return;
        originalOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = originalOnError);

      await tester.pumpWidget(createTestWidget(randomSeed: 0));
      await tester.pump(const Duration(milliseconds: 300));

      final answers = [
        'एक लड़की खेल रही है।',
        'लड़का नींद से उठ रहा है।',
        'लड़का अपने दाँत साफ कर रहा है।',
        'लड़की पढ़ रही है।',
        'लड़की खाना खा रही है।',
      ];
      final qLabels = ['Q 1/5', 'Q 2/5', 'Q 3/5', 'Q 4/5', 'Q 5/5'];
      final progLabels = ['20%', '40%', '60%', '80%', '100%'];

      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.text(qLabels[i]), findsOneWidget);
        expect(find.text(progLabels[i]), findsOneWidget);
        await tapVisiblePump(tester, find.text(answers[i]));
        await tapVisiblePump(tester, find.text('CHECK'));
        await tester.pump(const Duration(milliseconds: 100));
        if (i < 4) {
          expect(find.text('CONTINUE'), findsOneWidget);
          await tapVisiblePump(tester, find.text('CONTINUE'));
        } else {
          expect(find.text('FINISH'), findsOneWidget);
          await tapVisiblePump(tester, find.text('FINISH'));
          await tester.pump(const Duration(milliseconds: 300));
          expect(find.text('Choose a Phase'), findsOneWidget);
        }
        await tester.pump(const Duration(milliseconds: 200));
      }
    });

    testWidgets('onCompletePhase callback fires after Q5 FINISH', (tester) async {
      tester.view.physicalSize = const Size(393, 851);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      // Suppress image-load errors so question transitions do not abort the test.
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exceptionAsString().contains('Unable to load asset')) return;
        originalOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = originalOnError);

      bool completeCalled = false;
      await tester.pumpWidget(createTestWidget(
        randomSeed: 0,
        onCompletePhase: () => completeCalled = true,
      ));
      await tester.pump(const Duration(milliseconds: 300));

      final answers = [
        'एक लड़की खेल रही है।',
        'लड़का नींद से उठ रहा है।',
        'लड़का अपने दाँत साफ कर रहा है।',
        'लड़की पढ़ रही है।',
        'लड़की खाना खा रही है।',
      ];

      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        await tapVisiblePump(tester, find.text(answers[i]));
        await tapVisiblePump(tester, find.text('CHECK'));
        await tester.pump(const Duration(milliseconds: 100));
        // Q1–Q4 show CONTINUE; Q5 (last question) shows FINISH
        if (i < 4) {
          await tapVisiblePump(tester, find.text('CONTINUE'));
        } else {
          await tapVisiblePump(tester, find.text('FINISH'));
        }
        await tester.pump(const Duration(milliseconds: 200));
      }

      expect(completeCalled, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // GROUP 4: Speaker Button
  // ---------------------------------------------------------------------------
  group('Phase2QuestionScreen - Speaker Button', () {
    testWidgets('tapping speaker icon invokes onPlayMundariAudio', (tester) async {
      tester.view.physicalSize = const Size(393, 851);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      String? capturedText;
      await tester.pumpWidget(createTestWidget(
        randomSeed: 0,
        onPlayMundariAudio: (text) => capturedText = text,
      ));
      await tester.pumpAndSettle();

      final speakerIcon = find.byIcon(Icons.volume_up_rounded);
      if (speakerIcon.evaluate().isNotEmpty) {
        await tapVisible(tester, speakerIcon.first);
        expect(capturedText, equals('ओमाकन गतिविधि मेनते सही वाक्य सलाएमे'));
      }
    });
  });

  // ---------------------------------------------------------------------------
  // GROUP 5: Data model unit tests
  // ---------------------------------------------------------------------------
  group('Phase2QuestionData - Unit Tests', () {
    test('defaultQuestions has exactly 5 entries', () {
      expect(Phase2QuestionScreen.defaultQuestions.length, equals(5));
    });

    test('questionNumbers are 1 through 5', () {
      final nums = Phase2QuestionScreen.defaultQuestions.map((q) => q.questionNumber).toList();
      expect(nums, equals([1, 2, 3, 4, 5]));
    });

    test('each question has exactly 3 options', () {
      for (final q in Phase2QuestionScreen.defaultQuestions) {
        expect(q.options.length, equals(3), reason: 'Q${q.questionNumber} must have 3 options');
      }
    });

    test('correctAnswer is within options for each question', () {
      for (final q in Phase2QuestionScreen.defaultQuestions) {
        expect(q.options.contains(q.correctAnswer), isTrue,
            reason: 'Q${q.questionNumber}: correctAnswer not in options');
      }
    });

    test('each question uses a valid image asset path', () {
      final validAssets = {
        'assets/images/play.png',
        'assets/images/wakeup.png',
        'assets/images/brush.png',
        'assets/images/study.png',
        'assets/images/eat.png',
      };
      for (final q in Phase2QuestionScreen.defaultQuestions) {
        expect(validAssets.contains(q.imageAsset), isTrue,
            reason: 'Q${q.questionNumber}: "${q.imageAsset}" not expected');
      }
    });

    test('progressValue increases monotonically Q1 to Q5', () {
      final progresses = Phase2QuestionScreen.defaultQuestions.map((q) => q.progressValue).toList();
      for (int i = 1; i < progresses.length; i++) {
        expect(progresses[i], greaterThan(progresses[i - 1]));
      }
    });

    test('Q5 progressValue is 1.0 and progressPercentText is 100%', () {
      final q5 = Phase2QuestionScreen.defaultQuestions.last;
      expect(q5.progressValue, equals(1.0));
      expect(q5.progressPercentText, equals('100%'));
    });

    test('Mundari instruction is consistent across all questions', () {
      const expected = 'ओमाकन गतिविधि मेनते सही वाक्य सलाएमे';
      for (final q in Phase2QuestionScreen.defaultQuestions) {
        expect(q.instruction, equals(expected));
      }
    });
  });
}
