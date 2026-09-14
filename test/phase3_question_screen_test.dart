import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ayo_vani/screens/first/phase3_question_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget createTestWidget({
    Size size = const Size(393, 851),
    int initialIndex = 0,
    int randomSeed = 42,
    ValueChanged<String>? onPlayMundariAudio,
    VoidCallback? onCompletePhase,
    List<Phase3QuestionData>? questions,
  }) {
    return MediaQuery(
      data: MediaQueryData(
        size: size,
        padding: const EdgeInsets.only(top: 24, bottom: 16),
      ),
      child: MaterialApp(
        home: Phase3QuestionScreen(
          initialQuestionIndex: initialIndex,
          randomSeed: randomSeed,
          onPlayMundariAudio: onPlayMundariAudio,
          onCompletePhase: onCompletePhase,
          questions: questions ?? Phase3QuestionScreen.defaultQuestions,
        ),
      ),
    );
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pump();
    await tester.tap(finder);
    await tester.pump(const Duration(milliseconds: 300));
  }

  // ---------------------------------------------------------------------------
  // GROUP 1: Rendering
  // ---------------------------------------------------------------------------
  group('Phase3QuestionScreen - Rendering', () {
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
      expect(find.text('सही हिन्दी वाक्य सलाएमे'), findsOneWidget);
      expect(find.text('(Choose the correct sentence in hindi)'), findsOneWidget);
      expect(find.text('अमअः नुतुम चेकनअः?'), findsOneWidget);
      expect(find.text("Let's learn\ntogether!"), findsOneWidget);
      expect(find.text('CHECK'), findsOneWidget);

      // Cartoon asset present
      final cartoonFinder = find.byWidgetPredicate(
        (w) => w is Image && (w.image as AssetImage).assetName == 'assets/images/cartoon.png',
      );
      expect(cartoonFinder, findsOneWidget);

      // All Q1 tiles rendered
      expect(find.text('आपका'), findsWidgets);
      expect(find.text('नाम'), findsWidgets);
      expect(find.text('क्या'), findsWidgets);
      expect(find.text('है'), findsWidgets);
    });

    testWidgets('renders tablet layout without overflow', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(size: const Size(1280, 800)));
      await tester.pumpAndSettle();

      expect(find.text('Q 1/5'), findsOneWidget);
      expect(find.text('CHECK'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // GROUP 2: Tile Interaction & Validation
  // ---------------------------------------------------------------------------
  group('Phase3QuestionScreen - Tile Interaction & Validation', () {
    testWidgets('CHECK with no selection shows snackbar', (tester) async {
      tester.view.physicalSize = const Size(393, 851);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tapVisible(tester, find.text('CHECK'));

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('कृपया शब्द चुनें'), findsOneWidget);
    });

    testWidgets('Tapping word tile moves it to answer area', (tester) async {
      tester.view.physicalSize = const Size(393, 851);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap on the word tile 'आपका'
      final tileFinder = find.text('आपका');
      await tapVisible(tester, tileFinder.first);

      // Tap CHECK before selecting all words -> prompt to select all words
      await tapVisible(tester, find.text('CHECK'));

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('कृपया सभी 4 शब्दों का उपयोग करें'), findsOneWidget);
    });

    testWidgets('Tapping word in answer area removes it', (tester) async {
      tester.view.physicalSize = const Size(393, 851);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap word tile 'आपका'
      await tapVisible(tester, find.text('आपका').first);

      // Now answer area has 'आपका' with remove icon
      // Tap on the answer area chip to remove it
      final removeIcon = find.byIcon(Icons.close_rounded);
      expect(removeIcon, findsOneWidget);
      await tester.tap(removeIcon);
      await tester.pumpAndSettle();

      // Answer area is empty again, close icon gone
      expect(find.byIcon(Icons.close_rounded), findsNothing);
    });
  });

  // ---------------------------------------------------------------------------
  // GROUP 3: Evaluation, Progression & Completion
  // ---------------------------------------------------------------------------
  group('Phase3QuestionScreen - Evaluation & Progression', () {
    testWidgets('Correct word order shows success banner and CONTINUE button', (tester) async {
      tester.view.physicalSize = const Size(393, 851);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap words in correct order: 'आपका', 'नाम', 'क्या', 'है'
      await tapVisible(tester, find.text('आपका').first);
      await tapVisible(tester, find.text('नाम').first);
      await tapVisible(tester, find.text('क्या').first);
      await tapVisible(tester, find.text('है').first);

      // Tap CHECK
      await tapVisible(tester, find.text('CHECK'));

      // Success feedback banner
      expect(find.textContaining('शानदार! सही उत्तर'), findsOneWidget);
      expect(find.text('CONTINUE'), findsOneWidget);
    });

    testWidgets('Incorrect word order shows try again banner', (tester) async {
      tester.view.physicalSize = const Size(393, 851);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap words in wrong order: 'है', 'क्या', 'नाम', 'आपका'
      await tapVisible(tester, find.text('है').first);
      await tapVisible(tester, find.text('क्या').first);
      await tapVisible(tester, find.text('नाम').first);
      await tapVisible(tester, find.text('आपका').first);

      // Tap CHECK
      await tapVisible(tester, find.text('CHECK'));

      // Error feedback banner
      expect(find.textContaining('गलत उत्तर'), findsOneWidget);
      expect(find.text('CHECK'), findsOneWidget);
    });

    testWidgets('Tapping CONTINUE advances to Question 2', (tester) async {
      tester.view.physicalSize = const Size(393, 851);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Complete Q1
      await tapVisible(tester, find.text('आपका').first);
      await tapVisible(tester, find.text('नाम').first);
      await tapVisible(tester, find.text('क्या').first);
      await tapVisible(tester, find.text('है').first);

      await tapVisible(tester, find.text('CHECK'));
      expect(find.text('CONTINUE'), findsOneWidget);

      // Tap CONTINUE
      await tapVisible(tester, find.text('CONTINUE'));

      // Should now be on Q 2/5
      expect(find.text('Q 2/5'), findsOneWidget);
      expect(find.text('40%'), findsOneWidget);
      expect(find.text('तिसिङ आम चिलका मेनाःमा?'), findsOneWidget);
    });

    testWidgets('Completing Question 5 triggers onCompletePhase callback', (tester) async {
      tester.view.physicalSize = const Size(393, 851);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      bool completed = false;
      await tester.pumpWidget(createTestWidget(
        initialIndex: 4,
        onCompletePhase: () => completed = true,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Q 5/5'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
      expect(find.text('अमअः सुकु सनङ जोमेअः चिनअः तना?'), findsOneWidget);

      // Q5 correct order: 'आपका', 'पसंदीदा', 'खाना', 'क्या', 'है'
      await tapVisible(tester, find.text('आपका').first);
      await tapVisible(tester, find.text('पसंदीदा').first);
      await tapVisible(tester, find.text('खाना').first);
      await tapVisible(tester, find.text('क्या').first);
      await tapVisible(tester, find.text('है').first);

      await tapVisible(tester, find.text('CHECK'));
      expect(find.text('CONTINUE'), findsOneWidget);

      await tapVisible(tester, find.text('CONTINUE'));
      expect(completed, isTrue);
    });

    testWidgets('Mundari sentence speaker tap invokes audio callback', (tester) async {
      tester.view.physicalSize = const Size(393, 851);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      String? playedAudio;
      await tester.pumpWidget(createTestWidget(
        onPlayMundariAudio: (text) => playedAudio = text,
      ));
      await tester.pumpAndSettle();

      // Find speaker button next to the Mundari sentence
      final volumeUpIcon = find.byIcon(Icons.volume_up_rounded);
      expect(volumeUpIcon, findsWidgets);

      // Tap speaker icon
      await tester.tap(volumeUpIcon.last);
      await tester.pumpAndSettle();

      expect(playedAudio, equals('अमअः नुतुम चेकनअः?'));
    });
  });
}
