import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ayo_vani/screens/learn/learn_screen.dart';
import 'package:ayo_vani/screens/learn/teacher_levels_screen.dart';
import 'package:ayo_vani/screens/learn/teacher_phase_screen.dart';
import 'package:ayo_vani/screens/learn/teacher_practice_screen.dart';
import 'package:ayo_vani/screens/learn/teacher_application_screen.dart';
import 'package:ayo_vani/widgets/mundari_audio_text.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildLevelsWidget({Size size = const Size(393, 851)}) {
    return MediaQuery(
      data: MediaQueryData(size: size),
      child: const MaterialApp(
        home: TeacherLevelsScreen(),
      ),
    );
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  group('TeacherLevelsScreen - Initial Scroll Position', () {
    testWidgets('opens at bottom so Level 1 is immediately visible on mobile', (tester) async {
      tester.view.physicalSize = const Size(393, 851);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildLevelsWidget());
      await tester.pumpAndSettle();

      // Header should show "For Teachers" and "Plan, prepare & teach"
      expect(find.text('For Teachers'), findsOneWidget);
      expect(find.text('Plan, prepare & teach'), findsOneWidget);
      expect(find.text('English – First Standard'), findsOneWidget);

      // Level 1 node and text should be immediately visible without manual scrolling
      final level1Finder = find.text('Level 1');
      expect(level1Finder, findsOneWidget);

      final level1Rect = tester.getRect(level1Finder);
      expect(level1Rect.top, greaterThanOrEqualTo(0));
      expect(level1Rect.bottom, lessThanOrEqualTo(851));

      // Scrollable must be at its maximum scroll extent (bottom)
      final scrollable = tester.widget<Scrollable>(find.byType(Scrollable));
      final scrollPosition = scrollable.controller!.position;
      expect(scrollPosition.pixels, equals(scrollPosition.maxScrollExtent));
      expect(scrollPosition.pixels, greaterThan(0));

      // Level 10 should NOT be in the visible viewport initially
      final level10Finder = find.text('Level 10');
      expect(level10Finder, findsOneWidget);
      final level10Rect = tester.getRect(level10Finder);
      expect(level10Rect.bottom, lessThan(0));
    });

    testWidgets('renders cleanly on tablet with Level 1 visible', (tester) async {
      tester.view.physicalSize = const Size(800, 1280);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildLevelsWidget(size: const Size(800, 1280)));
      await tester.pumpAndSettle();

      expect(find.text('For Teachers'), findsOneWidget);
      expect(find.text('Level 1'), findsOneWidget);

      final scrollable = tester.widget<Scrollable>(find.byType(Scrollable));
      final scrollPosition = scrollable.controller!.position;
      expect(scrollPosition.pixels, equals(scrollPosition.maxScrollExtent));
      expect(tester.takeException(), isNull);
    });
  });

  group('Teacher Learning Phase - 3-Page Flow', () {
    testWidgets('Page 1 -> Page 2 -> Page 3 -> FINISH returns to Phase Popup', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(393, 851);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: LearnScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Verify on Learn screen with For Teachers card
      expect(find.text('Learning'), findsOneWidget);
      expect(find.text('For Teachers'), findsOneWidget);
      expect(find.text('Explore'), findsOneWidget);

      // 2. Click "Explore" on For Teachers card -> opens TeacherLevelsScreen
      await tester.tap(find.text('Explore'));
      await tester.pumpAndSettle();

      expect(find.byType(TeacherLevelsScreen), findsOneWidget);
      expect(find.text('For Teachers'), findsOneWidget);

      // 3. Tap Level 1 circle -> Teacher phase selection popup should appear
      await tester.tap(find.text('1'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Choose a Phase'), findsOneWidget);
      expect(find.text('Learning Phase'), findsOneWidget);
      expect(find.text('Practice Phase'), findsOneWidget);
      expect(find.text('Application Phase'), findsOneWidget);
      // Learning Phase card has NO "5 Questions", Practice and Application DO
      expect(find.text('5 Questions'), findsNWidgets(2));

      // 4. Tap "Learning Phase" -> Navigates to TeacherPhaseScreen (Page 1)
      await tester.tap(find.text('Learning Phase'));
      await tester.pumpAndSettle();

      expect(find.byType(TeacherPhaseScreen), findsOneWidget);
      expect(find.text('Learning Phase'), findsOneWidget);
      expect(find.text('Level 1 • Plan, prepare & teach'), findsOneWidget);

      // ==========================================
      // PAGE 1: Common Classroom Words
      // ==========================================
      expect(find.text('कक्षा में बार-बार बोले जाने वाले शब्द:'), findsOneWidget);
      expect(find.text('हिन्दी'), findsOneWidget);
      expect(find.text('मुंडारी (Mundari)'), findsOneWidget);

      // Verify word pairs
      expect(find.text('बच्चा'), findsOneWidget);
      expect(find.text('होन'), findsOneWidget);
      expect(find.text('किताब'), findsWidgets); // Hindi and Mundari
      expect(find.text('पानी'), findsOneWidget);
      expect(find.text('दअः'), findsOneWidget);
      expect(find.text('खाना'), findsOneWidget);
      expect(find.text('जोम-नू'), findsOneWidget);
      expect(find.text('घर'), findsOneWidget);
      expect(find.text('ओड़अः'), findsOneWidget);
      expect(find.text('स्कूल'), findsOneWidget);
      expect(find.text('इसकुल'), findsOneWidget);
      expect(find.text('बैठना'), findsOneWidget);
      expect(find.text('दुब'), findsOneWidget);
      expect(find.text('उठना'), findsOneWidget);
      expect(find.text('बिरिद्'), findsOneWidget);
      expect(find.text('आना'), findsOneWidget);
      expect(find.text('हिजुःमे'), findsOneWidget);
      expect(find.text('जाना'), findsOneWidget);
      expect(find.text('सेनोः'), findsOneWidget);

      // Verify speaker buttons exist and are tappable
      final audioButtons = find.byType(MundariAudioButton);
      expect(audioButtons, findsNWidgets(10));
      await tester.tap(audioButtons.first);
      await tester.pump();

      // Page 1 bottom button is "Next"
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('FINISH'), findsNothing);

      // 5. Tap "Next" -> transitions to PAGE 2
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // ==========================================
      // PAGE 2: Classroom Instructions
      // ==========================================
      expect(find.text('कक्षा में छात्रों को दिए जाने वाले निर्देश:'), findsOneWidget);
      expect(find.text('इधर आओ।'), findsOneWidget);
      expect(find.text('हिजुःमे।'), findsOneWidget);
      expect(find.text('बैठो।'), findsOneWidget);
      expect(find.text('दुब मे।'), findsOneWidget);
      expect(find.text('खड़े हो जाओ।'), findsOneWidget);
      expect(find.text('तिंगु कोःमे'), findsOneWidget);
      expect(find.text('ध्यान से सुनो।'), findsOneWidget);
      expect(find.text('धेआन ते अयुमेपे।'), findsOneWidget);
      expect(find.text('बोलो।'), findsOneWidget);
      expect(find.text('कजिलेम'), findsOneWidget);
      expect(find.text('देखो।'), findsOneWidget);
      expect(find.text('लेलेमे'), findsOneWidget);
      expect(find.text('किताब खोलो।'), findsOneWidget);
      expect(find.text('किताब निइपे'), findsOneWidget);
      expect(find.text('यहाँ लिखो।'), findsOneWidget);
      expect(find.text('नेरे ओलेमे।'), findsOneWidget);
      expect(find.text('दोहराओ।'), findsOneWidget);
      expect(find.text('दोहरवएपे'), findsOneWidget);
      expect(find.text('समझ आया?'), findsOneWidget);
      expect(find.text('बुजव जनम?'), findsOneWidget);

      expect(find.text('Next'), findsOneWidget);

      // 6. Tap "Next" -> transitions to PAGE 3
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // ==========================================
      // PAGE 3: Daily Classroom Conversations
      // ==========================================
      expect(
        find.text('छात्रों से संवाद करने के लिए कक्षा में उपयोग किए जाने वाले दैनिक वार्तालाप वाक्य:'),
        findsOneWidget,
      );
      expect(find.text('आपका नाम क्या है?'), findsOneWidget);
      expect(find.text('अमगअ लुतुम चेकनअः?'), findsOneWidget);
      expect(find.text('आप कैसे हैं?'), findsOneWidget);
      expect(find.text('अम चिलका मेनाःमा?'), findsOneWidget);
      expect(find.text('पानी चाहिए?'), findsOneWidget);
      expect(find.text('दअः लगतिङअ?'), findsOneWidget);
      expect(find.text('खाना खाया?'), findsOneWidget);
      expect(find.text('मंडी जोम केदा?'), findsOneWidget);
      expect(find.text('कहाँ जा रहे हो?'), findsOneWidget);
      expect(find.text('कोतेमतना?'), findsOneWidget);
      expect(find.text('क्या कर रहे हो?'), findsOneWidget);
      expect(find.text('चेनअःम चेकातना?'), findsOneWidget);
      expect(find.text('यह क्या है?'), findsOneWidget);
      expect(find.text('नेअ चेकनअः?'), findsOneWidget);
      expect(find.text('मेरा नाम ___ है।'), findsOneWidget);
      expect(find.text('अइञअः नुतुम..... तनअः।'), findsOneWidget);
      expect(find.text('हाँ / नहीं।'), findsOneWidget);
      expect(find.text('हे/का।'), findsOneWidget);
      expect(find.text('धन्यवाद।'), findsWidgets);

      // On Page 3, button is "FINISH", NOT "Next"
      expect(find.text('FINISH'), findsOneWidget);
      expect(find.text('Next'), findsNothing);

      // 7. Test Back Navigation: Page 3 -> Page 2 -> Page 1
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();
      expect(find.text('कक्षा में छात्रों को दिए जाने वाले निर्देश:'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();
      expect(find.text('कक्षा में बार-बार बोले जाने वाले शब्द:'), findsOneWidget);

      // Forward back to Page 3
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('FINISH'), findsOneWidget);

      // 8. Tap "FINISH" -> completes and returns to Teacher Phase Popup
      await tester.tap(find.text('FINISH'));
      await tester.pumpAndSettle();

      // Verify back at Teacher Phase Popup
      expect(find.text('Choose a Phase'), findsOneWidget);
      expect(find.text('Learning Phase'), findsOneWidget);
      expect(find.text('Practice Phase'), findsOneWidget);
      expect(find.text('Application Phase'), findsOneWidget);
      expect(find.text('5 Questions'), findsNWidgets(2));

      // 9. Close the popup via X button -> back to Teacher Level Path
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(TeacherLevelsScreen), findsOneWidget);
      expect(find.text('Choose a Phase'), findsNothing);

      // 10. Back from TeacherLevelsScreen -> Returns to LearnScreen
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(LearnScreen), findsOneWidget);
      expect(find.byType(TeacherLevelsScreen), findsNothing);
    });

    testWidgets('Teacher Phase 1 renders cleanly on tablet without overflow', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1280);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: TeacherPhaseScreen(
            phaseName: 'Learning Phase',
            phaseNumber: 1,
            levelNumber: 1,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('कक्षा में बार-बार बोले जाने वाले शब्द:'), findsOneWidget);
      expect(find.text('बच्चा'), findsOneWidget);
      expect(find.text('होन'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Teacher Practice Phase - 5-Question Interactive Flow (Q1 -> Q5 -> FINISH)', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(393, 851);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: TeacherLevelsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Open Level 1 popup
      await tester.tap(find.text('1'));
      await tester.pump(const Duration(milliseconds: 300));

      // 2. Tap "Practice Phase" -> Navigates to TeacherPracticeScreen
      await tester.tap(find.text('Practice Phase'));
      await tester.pumpAndSettle();

      expect(find.byType(TeacherPracticeScreen), findsOneWidget);

      // =======================================================================
      // QUESTION 1: Match the Words
      // =======================================================================
      expect(find.text('Q 1/5'), findsOneWidget);
      expect(find.text('20%'), findsOneWidget);
      expect(find.text('First • Ch 1'), findsOneWidget);
      expect(find.text('Level 1'), findsOneWidget);
      expect(find.text('सही अर्थ से मिलाएँ'), findsOneWidget);
      expect(find.text('(Match the correct meanings)'), findsOneWidget);
      expect(find.text('मुंडारी शब्द'), findsOneWidget);
      expect(find.text('हिंदी अर्थ'), findsOneWidget);

      // Verify all 5 pairs are present
      expect(find.text('होन'), findsOneWidget);
      expect(find.text('दअः'), findsOneWidget);
      expect(find.text('जोम-नू'), findsOneWidget);
      expect(find.text('ओड़अः'), findsOneWidget);
      expect(find.text('दुब'), findsOneWidget);

      expect(find.text('बच्चा'), findsOneWidget);
      expect(find.text('पानी'), findsOneWidget);
      expect(find.text('खाना'), findsOneWidget);
      expect(find.text('घर'), findsOneWidget);
      expect(find.text('बैठना'), findsOneWidget);

      // Verify clickable audio buttons exist on Mundari words
      final audioButtons = find.byType(MundariAudioButton);
      expect(audioButtons, findsNWidgets(5));
      await tester.tap(audioButtons.first);
      await tester.pump();

      // Initial button is "CHECK"
      expect(find.text('CHECK'), findsOneWidget);

      // Match all 5 pairs
      await tapVisible(tester, find.text('होन'));
      await tapVisible(tester, find.text('बच्चा'));

      await tapVisible(tester, find.text('दअः'));
      await tapVisible(tester, find.text('पानी'));

      await tapVisible(tester, find.text('जोम-नू'));
      await tapVisible(tester, find.text('खाना'));

      await tapVisible(tester, find.text('ओड़अः'));
      await tapVisible(tester, find.text('घर'));

      await tapVisible(tester, find.text('दुब'));
      await tapVisible(tester, find.text('बैठना'));

      // Tap CHECK -> Correct feedback appears
      await tapVisible(tester, find.text('CHECK'));
      expect(find.textContaining('शानदार! सही उत्तर'), findsOneWidget);
      expect(find.text('CONTINUE'), findsOneWidget);

      // Tap CONTINUE -> Advances to Question 2
      await tapVisible(tester, find.text('CONTINUE'));

      // =======================================================================
      // QUESTION 2: MCQ (बैठो। -> दुब मे।)
      // =======================================================================
      expect(find.text('Q 2/5'), findsOneWidget);
      expect(find.text('40%'), findsOneWidget);
      expect(find.text('सही मुंडारी वाक्य चुनें'), findsOneWidget);
      expect(find.text('(Choose the correct Mundari sentence)'), findsOneWidget);
      expect(find.text('बैठो।'), findsOneWidget);
      expect(find.text('दुब मे।'), findsOneWidget);

      // Verify audio button on options
      expect(find.byType(MundariAudioButton), findsNWidgets(4));

      // Select correct answer and CHECK
      await tapVisible(tester, find.text('दुब मे।'));
      await tapVisible(tester, find.text('CHECK'));
      expect(find.textContaining('शानदार! सही उत्तर'), findsOneWidget);
      expect(find.text('CONTINUE'), findsOneWidget);

      // Tap CONTINUE -> Advances to Question 3
      await tapVisible(tester, find.text('CONTINUE'));

      // =======================================================================
      // QUESTION 3: MCQ (किताब खोलो। -> किताब निइपे)
      // =======================================================================
      expect(find.text('Q 3/5'), findsOneWidget);
      expect(find.text('60%'), findsOneWidget);
      expect(find.text('किताब खोलो।'), findsOneWidget);
      expect(find.text('किताब निइपे'), findsOneWidget);

      await tapVisible(tester, find.text('किताब निइपे'));
      await tapVisible(tester, find.text('CHECK'));
      expect(find.text('CONTINUE'), findsOneWidget);

      // Tap CONTINUE -> Advances to Question 4
      await tapVisible(tester, find.text('CONTINUE'));

      // =======================================================================
      // QUESTION 4: MCQ (आपका नाम क्या है? -> अमगअ लुतुम चेकनअः?)
      // =======================================================================
      expect(find.text('Q 4/5'), findsOneWidget);
      expect(find.text('80%'), findsOneWidget);
      expect(find.text('आपका नाम क्या है?'), findsOneWidget);
      expect(find.text('अमगअ लुतुम चेकनअः?'), findsOneWidget);

      await tapVisible(tester, find.text('अमगअ लुतुम चेकनअः?'));
      await tapVisible(tester, find.text('CHECK'));
      expect(find.text('CONTINUE'), findsOneWidget);

      // Tap CONTINUE -> Advances to Question 5
      await tapVisible(tester, find.text('CONTINUE'));

      // =======================================================================
      // QUESTION 5: MCQ (पानी चाहिए? -> दअः लगतिङअ?)
      // =======================================================================
      expect(find.text('Q 5/5'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
      expect(find.text('पानी चाहिए?'), findsOneWidget);
      expect(find.text('दअः लगतिङअ?'), findsOneWidget);

      await tapVisible(tester, find.text('दअः लगतिङअ?'));
      await tapVisible(tester, find.text('CHECK'));

      // Question 5 shows "FINISH"
      expect(find.text('FINISH'), findsOneWidget);
      expect(find.text('CONTINUE'), findsNothing);

      // Tap FINISH -> Redirects back to existing Phase Popup
      await tapVisible(tester, find.text('FINISH'));
      await tester.pumpAndSettle();

      // Verify back at Phase Popup
      expect(find.text('Choose a Phase'), findsOneWidget);
      expect(find.text('Learning Phase'), findsOneWidget);
      expect(find.text('Practice Phase'), findsOneWidget);
      expect(find.text('Application Phase'), findsOneWidget);
    });

    testWidgets('Teacher Practice Phase renders cleanly on tablet without overflow', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1280);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: TeacherPracticeScreen(
            levelNumber: 1,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Q 1/5'), findsOneWidget);
      expect(find.text('मुंडारी शब्द'), findsOneWidget);
      expect(find.text('हिंदी अर्थ'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Teacher Application Phase - 5-Question Situational Flow (Q1 -> Q5 -> FINISH)', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(393, 851);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: TeacherLevelsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Level 1 -> Open popup
      await tester.tap(find.text('1'));
      await tester.pump(const Duration(milliseconds: 300));

      // Tap Application Phase -> Navigates to TeacherApplicationScreen
      await tester.tap(find.text('Application Phase'));
      await tester.pumpAndSettle();

      expect(find.byType(TeacherApplicationScreen), findsOneWidget);

      // =======================================================================
      // QUESTION 1:
      // स्थिति: आप पढ़ा रहे हैं, लेकिन एक छात्र ध्यान नहीं दे रहा है।
      // प्रश्न: आप छात्र से क्या कहेंगे?
      // विकल्प: धेआन ते अयुमेपे।
      // =======================================================================
      expect(find.text('Q 1/5'), findsOneWidget);
      expect(find.text('20%'), findsOneWidget);
      expect(find.text('First • Ch 1'), findsOneWidget);
      expect(find.text('Level 1'), findsOneWidget);

      // Check Hindi headings
      expect(find.text('स्थिति'), findsOneWidget);
      expect(find.text('प्रश्न'), findsOneWidget);

      // Verify NO English labels inside question card
      expect(find.text('Situation'), findsNothing);
      expect(find.text('Question'), findsNothing);

      // Check situation and question text
      expect(find.text('आप पढ़ा रहे हैं, लेकिन एक छात्र ध्यान नहीं दे रहा है।'), findsOneWidget);
      expect(find.text('आप छात्र से क्या कहेंगे?'), findsOneWidget);

      // Exactly 3 options
      expect(find.text('कजिलेम।'), findsOneWidget);
      expect(find.text('धेआन ते अयुमेपे।'), findsOneWidget);
      expect(find.text('लेलेमे।'), findsOneWidget);

      // Verify 3 speaker buttons exist on options
      final audioButtons = find.byType(MundariAudioButton);
      expect(audioButtons, findsNWidgets(3));

      // Tap speaker button
      await tester.tap(audioButtons.first);
      await tester.pump();

      // Tap correct answer: "धेआन ते अयुमेपे।"
      await tapVisible(tester, find.text('धेआन ते अयुमेपे।'));
      await tapVisible(tester, find.text('CHECK'));

      // Verify feedback
      expect(find.textContaining('शानदार! सही उत्तर'), findsOneWidget);
      expect(
        find.text('"धेआन ते अयुमेपे।" का सही अर्थ "ध्यान से सुनो।" है।'),
        findsOneWidget,
      );
      expect(find.text('CONTINUE'), findsOneWidget);

      // Tap CONTINUE -> Advances to Question 2
      await tapVisible(tester, find.text('CONTINUE'));

      // =======================================================================
      // QUESTION 2:
      // स्थिति: आप देखते हैं कि एक छात्र कोई काम कर रहा है।
      // प्रश्न: आप उससे क्या पूछेंगे?
      // विकल्प: चेनअःम चेकातना?
      // =======================================================================
      expect(find.text('Q 2/5'), findsOneWidget);
      expect(find.text('40%'), findsOneWidget);
      expect(find.text('आप देखते हैं कि एक छात्र कोई काम कर रहा है।'), findsOneWidget);
      expect(find.text('आप उससे क्या पूछेंगे?'), findsOneWidget);
      expect(find.text('चेनअःम चेकातना?'), findsOneWidget);
      expect(find.text('अम चिलका मेनाःमा?'), findsOneWidget);
      expect(find.text('नेअ चेकनअः?'), findsOneWidget);

      await tapVisible(tester, find.text('चेनअःम चेकातना?'));
      await tapVisible(tester, find.text('CHECK'));
      expect(find.textContaining('शानदार! सही उत्तर'), findsOneWidget);
      expect(
        find.text('"चेनअःम चेकातना?" का सही अर्थ "क्या कर रहे हो?" है।'),
        findsOneWidget,
      );
      expect(find.text('CONTINUE'), findsOneWidget);

      // Tap CONTINUE -> Advances to Question 3
      await tapVisible(tester, find.text('CONTINUE'));

      // =======================================================================
      // QUESTION 3:
      // स्थिति: आपने एक छात्र को कुछ समझाया है और अब जानना चाहते हैं कि उसे समझ आया या नहीं।
      // प्रश्न: आप छात्र से क्या पूछेंगे?
      // विकल्प: बुजव जनम?
      // =======================================================================
      expect(find.text('Q 3/5'), findsOneWidget);
      expect(find.text('60%'), findsOneWidget);
      expect(
        find.text('आपने एक छात्र को कुछ समझाया है और अब जानना चाहते हैं कि उसे समझ आया या नहीं।'),
        findsOneWidget,
      );
      expect(find.text('आप छात्र से क्या पूछेंगे?'), findsOneWidget);
      expect(find.text('बुजव जनम?'), findsOneWidget);

      await tapVisible(tester, find.text('बुजव जनम?'));
      await tapVisible(tester, find.text('CHECK'));
      expect(find.textContaining('शानदार! सही उत्तर'), findsOneWidget);
      expect(
        find.text('"बुजव जनम?" का सही अर्थ "समझ आया?" है।'),
        findsOneWidget,
      );
      expect(find.text('CONTINUE'), findsOneWidget);

      // Tap CONTINUE -> Advances to Question 4
      await tapVisible(tester, find.text('CONTINUE'));

      // =======================================================================
      // QUESTION 4:
      // स्थिति: आप छात्रों को अपनी किताब खोलने के लिए कहते हैं।
      // प्रश्न: आप क्या कहेंगे?
      // विकल्प: किताब निइपे।
      // =======================================================================
      expect(find.text('Q 4/5'), findsOneWidget);
      expect(find.text('80%'), findsOneWidget);
      expect(find.text('आप छात्रों को अपनी किताब खोलने के लिए कहते हैं।'), findsOneWidget);
      expect(find.text('आप क्या कहेंगे?'), findsOneWidget);
      expect(find.text('किताब निइपे।'), findsOneWidget);

      await tapVisible(tester, find.text('किताब निइपे।'));
      await tapVisible(tester, find.text('CHECK'));
      expect(find.textContaining('शानदार! सही उत्तर'), findsOneWidget);
      expect(
        find.text('"किताब निइपे।" का सही अर्थ "किताब खोलो।" है।'),
        findsOneWidget,
      );
      expect(find.text('CONTINUE'), findsOneWidget);

      // Tap CONTINUE -> Advances to Question 5
      await tapVisible(tester, find.text('CONTINUE'));

      // =======================================================================
      // QUESTION 5:
      // स्थिति: आपने एक वाक्य बोला है और चाहते हैं कि छात्र उसे फिर से बोलें।
      // प्रश्न: आप छात्रों से क्या कहेंगे?
      // विकल्प: दोहरवएपे।
      // =======================================================================
      expect(find.text('Q 5/5'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
      expect(find.text('आपने एक वाक्य बोला है और चाहते हैं कि छात्र उसे फिर से बोलें।'), findsOneWidget);
      expect(find.text('आप छात्रों से क्या कहेंगे?'), findsOneWidget);
      expect(find.text('दोहरवएपे।'), findsOneWidget);

      await tapVisible(tester, find.text('दोहरवएपे।'));
      await tapVisible(tester, find.text('CHECK'));
      expect(find.textContaining('शानदार! सही उत्तर'), findsOneWidget);
      expect(
        find.text('"दोहरवएपे।" का सही अर्थ "दोहराओ।" है।'),
        findsOneWidget,
      );

      // On Question 5, button is "FINISH"
      expect(find.text('FINISH'), findsOneWidget);
      expect(find.text('CONTINUE'), findsNothing);

      // Tap FINISH -> Redirects back to Phase Popup
      await tapVisible(tester, find.text('FINISH'));

      expect(find.text('Choose a Phase'), findsOneWidget);
      expect(find.text('Learning Phase'), findsOneWidget);
      expect(find.text('Practice Phase'), findsOneWidget);
      expect(find.text('Application Phase'), findsOneWidget);
    });

    testWidgets('Teacher Application Phase renders cleanly on tablet without overflow', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1280);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: TeacherApplicationScreen(
            levelNumber: 1,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Q 1/5'), findsOneWidget);
      expect(find.text('स्थिति'), findsOneWidget);
      expect(find.text('प्रश्न'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Teacher Phase Popup removes 5 Questions ONLY for Learning Phase', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(393, 851);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: TeacherLevelsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Open Teacher Phase Popup
      await tester.tap(find.text('1'));
      await tester.pump(const Duration(milliseconds: 300));

      // Dialog opens
      expect(find.text('Choose a Phase'), findsOneWidget);
      expect(find.text('Learning Phase'), findsOneWidget);
      expect(find.text('Practice Phase'), findsOneWidget);
      expect(find.text('Application Phase'), findsOneWidget);

      // Verify "5 Questions" appears exactly twice: once for Practice, once for Application
      expect(find.text('5 Questions'), findsNWidgets(2));
    });
  });
}
