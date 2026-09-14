import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ayo_vani/screens/first/phase1_question1_screen.dart';
import 'package:ayo_vani/widgets/mundari_audio_text.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget createTestWidget({
    Size size = const Size(393, 851),
    int initialIndex = 0,
    ValueChanged<String>? onPlayMundariAudio,
  }) {
    return MediaQuery(
      data: MediaQueryData(
        size: size,
        padding: const EdgeInsets.only(top: 24, bottom: 16),
      ),
      child: MaterialApp(
        home: Phase1Question1Screen(
          initialQuestionIndex: initialIndex,
          onPlayMundariAudio: onPlayMundariAudio,
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

  group('Phase1Question1Screen Tests', () {
    testWidgets('renders all visual elements matching reference design', (tester) async {
      tester.view.physicalSize = const Size(393, 851);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 1. Progress Header Card elements
      expect(find.text('First • Ch 1'), findsOneWidget);
      expect(find.text('Level 1'), findsOneWidget);
      expect(find.text('Q 1/5'), findsOneWidget);
      expect(find.text('20%'), findsOneWidget);

      // 2. Cartoon Speech Bubble & Question Text
      expect(find.text("Let's learn\ntogether!"), findsOneWidget);
      expect(find.text('सरते ओरोतो सलाएमे'), findsOneWidget);
      expect(find.text('(choose the correct meaning)'), findsOneWidget);
      expect(find.text('एंगा'), findsOneWidget);

      // 3. Answer Options
      expect(find.text('माँ'), findsOneWidget);
      expect(find.text('पिता'), findsOneWidget);
      expect(find.text('भाई'), findsOneWidget);

      // 4. Action Button & Bottom Navigation
      expect(find.text('CHECK'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Learn'), findsOneWidget);
      expect(find.text('Translate'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('initial state has no option selected and check prompts selection', (tester) async {
      tester.view.physicalSize = const Size(393, 851);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check button tapped without selecting an option
      await tapVisible(tester, find.text('CHECK'));

      // Prompt snackbar shown
      expect(find.text('Please select an answer first!'), findsOneWidget);
    });

    testWidgets('complete Phase 1 Question Flow: Q1 -> Q2 -> Q3 -> Q4 -> Q5 (Matching)', (tester) async {
      tester.view.physicalSize = const Size(393, 851);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // ==========================================
      // QUESTION 1: "एंगा", Answer: "माँ"
      // ==========================================
      expect(find.text('Q 1/5'), findsOneWidget);
      expect(find.text('20%'), findsOneWidget);
      expect(find.text('एंगा'), findsOneWidget);

      await tapVisible(tester, find.text('माँ'));
      await tapVisible(tester, find.text('CHECK'));

      expect(find.text('शानदार! सही उत्तर (Excellent! Correct)'), findsOneWidget);
      expect(find.text('"एंगा" का अर्थ "माँ" होता है।'), findsOneWidget);
      expect(find.text('CONTINUE'), findsOneWidget);

      // Tap CONTINUE -> opens Question 2
      await tapVisible(tester, find.text('CONTINUE'));

      // ==========================================
      // QUESTION 2: "अपुते", Answer: "पिता"
      // ==========================================
      expect(find.text('Q 2/5'), findsOneWidget);
      expect(find.text('40%'), findsOneWidget);
      expect(find.text('अपुते'), findsOneWidget);
      expect(find.text('CHECK'), findsOneWidget);

      // Select correct answer: "पिता"
      await tapVisible(tester, find.text('पिता'));
      await tapVisible(tester, find.text('CHECK'));

      expect(find.text('शानदार! सही उत्तर (Excellent! Correct)'), findsOneWidget);
      expect(find.text('"अपुते" का अर्थ "पिता" होता है।'), findsOneWidget);
      expect(find.text('CONTINUE'), findsOneWidget);

      // Tap CONTINUE -> opens Question 3
      await tapVisible(tester, find.text('CONTINUE'));

      // ==========================================
      // QUESTION 3: "हगा", Answer: "भाई"
      // ==========================================
      expect(find.text('Q 3/5'), findsOneWidget);
      expect(find.text('60%'), findsOneWidget);
      expect(find.text('हगा'), findsOneWidget);
      expect(find.text('CHECK'), findsOneWidget);

      await tapVisible(tester, find.text('भाई'));
      await tapVisible(tester, find.text('CHECK'));

      expect(find.text('शानदार! सही उत्तर (Excellent! Correct)'), findsOneWidget);
      expect(find.text('"हगा" का अर्थ "भाई" होता है।'), findsOneWidget);
      expect(find.text('CONTINUE'), findsOneWidget);

      // Tap CONTINUE -> opens Question 4
      await tapVisible(tester, find.text('CONTINUE'));

      // ==========================================
      // QUESTION 4: "मिसी", Answer: "बहन" (4 Options)
      // ==========================================
      expect(find.text('Q 4/5'), findsOneWidget);
      expect(find.text('80%'), findsOneWidget);
      expect(find.text('मिसी'), findsOneWidget);
      expect(find.text('CHECK'), findsOneWidget);

      await tapVisible(tester, find.text('बहन'));
      await tapVisible(tester, find.text('CHECK'));

      expect(find.text('शानदार! सही उत्तर (Excellent! Correct)'), findsOneWidget);
      expect(find.text('"मिसी" का अर्थ "बहन" होता है।'), findsOneWidget);
      expect(find.text('CONTINUE'), findsOneWidget);

      // Tap CONTINUE -> opens Question 5
      await tapVisible(tester, find.text('CONTINUE'));

      // ==========================================
      // QUESTION 5: Matching Question (Q 5/5, 100%)
      // ==========================================
      expect(find.text('Q 5/5'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
      expect(find.text('सरते ओरोतो को जोकाएपे'), findsOneWidget);
      expect(find.text('(match the correct meanings)'), findsOneWidget);

      // Column Headings
      expect(find.text('मुंडारी शब्द'), findsOneWidget);
      expect(find.text('हिंदी अर्थ'), findsOneWidget);

      // 5 Mundari items
      expect(find.text('कोड़ा'), findsOneWidget);
      expect(find.text('कुड़िहोन'), findsOneWidget);
      expect(find.text('दुअर'), findsOneWidget);
      expect(find.text('लिजअः'), findsOneWidget);
      expect(find.text('चटु'), findsOneWidget);

      // 5 Hindi items
      expect(find.text('दरवाजा'), findsOneWidget);
      expect(find.text('पति'), findsOneWidget);
      expect(find.text('कपड़ा'), findsOneWidget);
      expect(find.text('बर्तन'), findsOneWidget);
      expect(find.text('पत्नी'), findsOneWidget);

      // Check before matching -> prompts to match all 5 pairs
      await tapVisible(tester, find.text('CHECK'));
      expect(find.text('कृपया सभी 5 जोड़ों का मिलान करें (Please match all 5 pairs!)'), findsOneWidget);

      // Pair 1: कोड़ा → पति
      await tapVisible(tester, find.text('कोड़ा'));
      await tapVisible(tester, find.text('पति'));

      // Pair 2: कुड़िहोन → पत्नी
      await tapVisible(tester, find.text('कुड़िहोन'));
      await tapVisible(tester, find.text('पत्नी'));

      // Pair 3: दुअर → दरवाजा
      await tapVisible(tester, find.text('दुअर'));
      await tapVisible(tester, find.text('दरवाजा'));

      // Pair 4: लिजअः → कपड़ा
      await tapVisible(tester, find.text('लिजअः'));
      await tapVisible(tester, find.text('कपड़ा'));

      // Pair 5: चटु → बर्तन
      await tapVisible(tester, find.text('चटु'));
      await tapVisible(tester, find.text('बर्तन'));

      // Press CHECK
      await tapVisible(tester, find.text('CHECK'));

      // Verify Correct Feedback
      expect(find.text('शानदार! सही उत्तर (Excellent! Correct)'), findsOneWidget);
      expect(find.text('CONTINUE'), findsOneWidget);

      // Tap CONTINUE -> opens Phase 1 Completed Dialog!
      await tapVisible(tester, find.text('CONTINUE'));
      expect(find.text('Phase 1 Completed!'), findsOneWidget);
    });

    testWidgets('renders Question 5 cleanly on tablet layout without overflow', (tester) async {
      tester.view.physicalSize = const Size(800, 1280);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      // Test tablet with Question 5 (Matching)
      await tester.pumpWidget(createTestWidget(size: const Size(800, 1280), initialIndex: 4));
      await tester.pumpAndSettle();

      expect(find.text('First • Ch 1'), findsOneWidget);
      expect(find.text('Level 1'), findsOneWidget);
      expect(find.text('Q 5/5'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
      expect(find.text('सरते ओरोतो को जोकाएपे'), findsOneWidget);
      expect(find.text('मुंडारी शब्द'), findsOneWidget);
      expect(find.text('हिंदी अर्थ'), findsOneWidget);
      expect(find.text('कोड़ा'), findsOneWidget);
      expect(find.text('दरवाजा'), findsOneWidget);
      expect(find.text('CHECK'), findsOneWidget);
    });

    testWidgets('renders subtle natural grass decoration (grass1.png & grass2.png) on mobile and tablet', (tester) async {
      // 1. Check on Pixel 4 / Mobile Screen
      tester.view.physicalSize = const Size(393, 851);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(size: const Size(393, 851)));
      await tester.pumpAndSettle();

      // Verify cartoon asset
      expect(
        find.byWidgetPredicate(
          (w) => w is Image && (w.image as AssetImage).assetName == 'assets/images/cartoon.png',
        ),
        findsOneWidget,
      );

      // Verify grass1.png assets exist in decoration
      expect(
        find.byWidgetPredicate(
          (w) => w is Image && (w.image as AssetImage).assetName == 'assets/images/grass1.png',
        ),
        findsWidgets,
      );

      // Verify grass2.png assets exist in decoration
      expect(
        find.byWidgetPredicate(
          (w) => w is Image && (w.image as AssetImage).assetName == 'assets/images/grass2.png',
        ),
        findsWidgets,
      );

      // 2. Check on Tablet Screen
      tester.view.physicalSize = const Size(800, 1280);
      await tester.pumpWidget(createTestWidget(size: const Size(800, 1280)));
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (w) => w is Image && (w.image as AssetImage).assetName == 'assets/images/grass1.png',
        ),
        findsWidgets,
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is Image && (w.image as AssetImage).assetName == 'assets/images/grass2.png',
        ),
        findsWidgets,
      );
    });

    testWidgets('renders clickable speaker icons before all Mundari content in Questions 1 to 5', (tester) async {
      tester.view.physicalSize = const Size(393, 851);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      String? lastPlayedAudio;
      await tester.pumpWidget(
        createTestWidget(
          onPlayMundariAudio: (text) => lastPlayedAudio = text,
        ),
      );
      await tester.pumpAndSettle();

      // ==========================================
      // Question 1: Instruction & Word "एंगा"
      // ==========================================
      final q1InstructionSpeaker = find.byWidgetPredicate(
        (w) => w is MundariAudioButton && w.text == 'सरते ओरोतो सलाएमे',
      );
      expect(q1InstructionSpeaker, findsOneWidget);
      await tester.tap(q1InstructionSpeaker);
      expect(lastPlayedAudio, 'सरते ओरोतो सलाएमे');

      final q1WordSpeaker = find.byWidgetPredicate(
        (w) => w is MundariAudioButton && w.text == 'एंगा',
      );
      expect(q1WordSpeaker, findsOneWidget);
      await tester.tap(q1WordSpeaker);
      expect(lastPlayedAudio, 'एंगा');

      // Answer Q1 -> Q2
      await tapVisible(tester, find.text('माँ'));
      await tapVisible(tester, find.text('CHECK'));
      await tapVisible(tester, find.text('CONTINUE'));

      // ==========================================
      // Question 2: Word "अपुते"
      // ==========================================
      final q2WordSpeaker = find.byWidgetPredicate(
        (w) => w is MundariAudioButton && w.text == 'अपुते',
      );
      expect(q2WordSpeaker, findsOneWidget);
      await tester.tap(q2WordSpeaker);
      expect(lastPlayedAudio, 'अपुते');

      // Answer Q2 -> Q3
      await tapVisible(tester, find.text('पिता'));
      await tapVisible(tester, find.text('CHECK'));
      await tapVisible(tester, find.text('CONTINUE'));

      // ==========================================
      // Question 3: Word "हगा"
      // ==========================================
      final q3WordSpeaker = find.byWidgetPredicate(
        (w) => w is MundariAudioButton && w.text == 'हगा',
      );
      expect(q3WordSpeaker, findsOneWidget);
      await tester.tap(q3WordSpeaker);
      expect(lastPlayedAudio, 'हगा');

      // Answer Q3 -> Q4
      await tapVisible(tester, find.text('भाई'));
      await tapVisible(tester, find.text('CHECK'));
      await tapVisible(tester, find.text('CONTINUE'));

      // ==========================================
      // Question 4: Word "मिसी"
      // ==========================================
      final q4WordSpeaker = find.byWidgetPredicate(
        (w) => w is MundariAudioButton && w.text == 'मिसी',
      );
      expect(q4WordSpeaker, findsOneWidget);
      await tester.tap(q4WordSpeaker);
      expect(lastPlayedAudio, 'मिसी');

      // Answer Q4 -> Q5
      await tapVisible(tester, find.text('बहन'));
      await tapVisible(tester, find.text('CHECK'));
      await tapVisible(tester, find.text('CONTINUE'));

      // ==========================================
      // Question 5: Matching Question
      // Instruction "सरते ओरोतो को जोकाएपे"
      // Mundari items: कोड़ा, कुड़िहोन, दुअर, लिजअः, चटु
      // ==========================================
      final q5InstructionSpeaker = find.byWidgetPredicate(
        (w) => w is MundariAudioButton && w.text == 'सरते ओरोतो को जोकाएपे',
      );
      expect(q5InstructionSpeaker, findsOneWidget);
      await tester.tap(q5InstructionSpeaker);
      expect(lastPlayedAudio, 'सरते ओरोतो को जोकाएपे');

      for (final mundariWord in ['कोड़ा', 'कुड़िहोन', 'दुअर', 'लिजअः', 'चटु']) {
        final itemSpeaker = find.byWidgetPredicate(
          (w) => w is MundariAudioButton && w.text == mundariWord,
        );
        expect(itemSpeaker, findsOneWidget);
        await tapVisible(tester, itemSpeaker);
        expect(lastPlayedAudio, mundariWord);
      }

      // Verify Hindi items do NOT have speaker buttons
      for (final hindiWord in ['दरवाजा', 'पति', 'कपड़ा', 'बर्तन', 'पत्नी']) {
        final itemSpeaker = find.byWidgetPredicate(
          (w) => w is MundariAudioButton && w.text == hindiWord,
        );
        expect(itemSpeaker, findsNothing);
      }
    });
  });
}
