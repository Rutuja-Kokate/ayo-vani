import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ayo_vani/app/app.dart';
import 'package:ayo_vani/screens/splash/splash_screen.dart';
import 'package:ayo_vani/screens/welcome/welcome_screen.dart';
import 'package:ayo_vani/widgets/ayo_bottom_nav_bar.dart';
import 'package:ayo_vani/widgets/ayo_coming_soon.dart';
import 'package:ayo_vani/widgets/ayo_logo.dart';
import 'package:ayo_vani/widgets/ayo_screen_background.dart';
import 'package:ayo_vani/widgets/ayo_subject_card.dart';
import 'package:ayo_vani/widgets/ayo_warli_art.dart';
import 'package:ayo_vani/widgets/ayo_warli_village_art.dart';

void main() {
  testWidgets('AYOVAANI Screen 01 (Splash) & Screen 02 (Welcome) complete flow', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(393 * 2.75, 851 * 2.75);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const AyoVaaniApp());
    await tester.pump();

    // 1. Verify Screen 01: Splash Screen
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(AyoLogo), findsWidgets);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(AyoWarliBottomArt), findsOneWidget);

    // 2. Allow splash timer to complete -> transition to Screen 02: Welcome Screen
    await tester.pump(const Duration(milliseconds: 3000));
    await tester.pumpAndSettle();

    // 3. Verify Screen 02: Welcome Screen
    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.text('Welcome, Teacher'), findsOneWidget);
    expect(find.text('This app works best offline.'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.byType(AyoWarliVillageArt), findsOneWidget);

    // 4. Tap "Continue" -> transition to Screen 03: Home Dashboard / MainShell
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // 5. Verify Screen 03: Home (Dashboard)
    expect(find.text('Hello, Teacher'), findsOneWidget);
    expect(find.text('Ready to inspire today?'), findsOneWidget);
    expect(find.text('Offline Ready'), findsOneWidget);
    expect(find.text("Let's Start"), findsOneWidget);
    expect(find.text('Mathematics'), findsOneWidget);
    expect(find.text('Translate'), findsWidgets);
    expect(find.text('Classes'), findsOneWidget);
    expect(find.text('Balvatika'), findsOneWidget);
    expect(find.text('First'), findsOneWidget);
    expect(find.text('Second'), findsOneWidget);
    expect(find.text('Third'), findsOneWidget);
    expect(find.byType(AyoBottomNavBar), findsOneWidget);
  });

  testWidgets('AYOVAANI navigation switches between tabs cleanly', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(393 * 2.75, 851 * 2.75);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const AyoVaaniApp());
    await tester.pump(const Duration(milliseconds: 3000));
    await tester.pumpAndSettle();

    // On Welcome Screen, tap Continue
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Tap Learn tab
    await tester.tap(find.text('Learn').first);
    await tester.pumpAndSettle();
    expect(find.text('Learning'), findsOneWidget);
    expect(
      find.text('Choose how you want to learn today'),
      findsOneWidget,
    );
    expect(find.text('For Teachers'), findsOneWidget);
    expect(find.text('For Students'), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('Start Learning'), findsOneWidget);

    // Tap Translate tab
    await tester.tap(find.text('Translate').first);
    await tester.pumpAndSettle();
    expect(find.text('Live Translation'), findsWidgets);
    expect(find.text('Hindi to Mundari Translation'), findsOneWidget);
    expect(find.text('हिंदी  →  मुंडारी'), findsOneWidget);

    // Tap Profile tab
    await tester.tap(find.text('Profile').first);
    await tester.pumpAndSettle();
    expect(find.text('Teacher Profile'), findsOneWidget);
    expect(find.text('Classroom Educator'), findsOneWidget);
    expect(find.text('My Classroom'), findsOneWidget);
  });

  testWidgets('AYOVAANI adapts to tablet layout with bottom navigation', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280 * 1.5, 800 * 1.5);
    tester.view.devicePixelRatio = 1.5;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const AyoVaaniApp());
    await tester.pump(const Duration(milliseconds: 3000));
    await tester.pumpAndSettle();

    // On Welcome Screen, tap Continue
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.byType(AyoBottomNavBar), findsOneWidget);
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Learn'), findsWidgets);
    expect(find.text('Translate'), findsWidgets);
    expect(find.text('Profile'), findsWidgets);
    expect(find.text('Hello, Teacher'), findsOneWidget);
  });

  testWidgets(
    'AyoScreenBackground provides parchment radial vignette on phone and tablet',
    (WidgetTester tester) async {
      // 1. Verify on Pixel 4 Mobile dimensions
      tester.view.physicalSize = const Size(393 * 2.75, 851 * 2.75);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const AyoVaaniApp());
      await tester.pump();

      // Verify AyoScreenBackground is present on Splash screen
      expect(find.byType(AyoScreenBackground), findsWidgets);
      expect(find.byType(AyoWarliBottomArt), findsOneWidget);

      // Transition to Welcome screen
      await tester.pump(const Duration(milliseconds: 3000));
      await tester.pumpAndSettle();
      expect(find.byType(AyoScreenBackground), findsWidgets);
      expect(find.byType(AyoWarliVillageArt), findsOneWidget);

      // Continue to Home Dashboard
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.byType(AyoScreenBackground), findsWidgets);

      // 2. Switch to Pixel Tablet dimensions
      tester.view.physicalSize = const Size(1280 * 1.5, 800 * 1.5);
      tester.view.devicePixelRatio = 1.5;
      await tester.pumpAndSettle();

      expect(find.byType(AyoScreenBackground), findsWidgets);
    },
  );

  testWidgets(
    'Live Translation screen opens from Home and supports classroom interactions',
    (WidgetTester tester) async {
      // 1. Mobile view test
      tester.view.physicalSize = const Size(393 * 2.75, 851 * 2.75);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const AyoVaaniApp());
      await tester.pump(const Duration(milliseconds: 3000));
      await tester.pumpAndSettle();

      // From Welcome, tap Continue to Home
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // On Home screen, tap "Translate"
      final translateButton = find.widgetWithText(ElevatedButton, 'Translate');
      expect(translateButton, findsOneWidget);
      await tester.tap(translateButton);
      await tester.pumpAndSettle();

      // Verify Live Translation screen elements in State 1 (Input)
      expect(find.text('Live Translation'), findsWidgets);
      expect(find.text('Hindi to Mundari Translation'), findsOneWidget);
      expect(find.text('हिंदी  →  मुंडारी'), findsOneWidget);
      expect(find.text('Hindi → Mundari'), findsOneWidget);
      expect(find.text('हिंदी (Hindi)'), findsOneWidget);
      expect(find.text('बोलें'), findsOneWidget);
      expect(find.text('Transcribe'), findsOneWidget);
      expect(find.text('कैसे उपयोग करें?'), findsOneWidget);
      expect(find.text('उदाहरण वाक्य'), findsOneWidget);
      expect(find.text('आप कैसे हैं?'), findsOneWidget);

      // Scroll until example chip is visible then tap it
      final chipFinder = find.text('आप कैसे हैं?');
      await tester.ensureVisible(chipFinder);
      await tester.tap(chipFinder);
      await tester.pumpAndSettle();

      // Check that text is now populated in input and Mundari translation is revealed in the same card
      expect(find.text('मुंडारी (Mundari)'), findsOneWidget);
      expect(find.text('चेतना मेना?'), findsWidgets);
      expect(find.text('✓ Translation Ready'), findsOneWidget);
      expect(find.text('Play Mundari pronunciation'), findsOneWidget);

      // Tap back button (ensure visible at top)
      final backIcon = find.byIcon(Icons.chevron_left_rounded);
      await tester.ensureVisible(backIcon);
      expect(backIcon, findsOneWidget);
      await tester.tap(backIcon);
      await tester.pumpAndSettle();

      // Should return to Home
      expect(find.text('Hello, Teacher'), findsOneWidget);

      // 2. Tablet view test
      tester.view.physicalSize = const Size(1280 * 1.5, 800 * 1.5);
      tester.view.devicePixelRatio = 1.5;
      await tester.pumpAndSettle();

      // Tap Translate again on tablet
      await tester.tap(find.widgetWithText(ElevatedButton, 'Translate'));
      await tester.pumpAndSettle();

      expect(find.text('Live Translation'), findsWidgets);
      expect(find.text('हिंदी (Hindi)'), findsOneWidget);
      expect(find.text('Transcribe'), findsOneWidget);
      expect(find.byType(AyoBottomNavBar), findsOneWidget);

      // Tap Transcribe on tablet -> reveals Mundari output in the same card
      await tester.tap(find.text('Transcribe'));
      await tester.pumpAndSettle();
      expect(find.text('मुंडारी (Mundari)'), findsOneWidget);
      expect(find.text('✓ Translation Ready'), findsOneWidget);
    },
  );

  testWidgets(
    'Balvatika screen opens from Home and displays Coming Soon state with no functional chapters',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(393 * 2.75, 851 * 2.75);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const AyoVaaniApp());
      await tester.pump(const Duration(milliseconds: 3000));
      await tester.pumpAndSettle();

      // From Welcome, tap Continue to Home
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // On Home screen, scroll until Balvatika card is visible then tap it
      final balvatikaCard = find.text('Balvatika');
      expect(balvatikaCard, findsOneWidget);
      await tester.ensureVisible(balvatikaCard);
      await tester.tap(balvatikaCard);
      await tester.pumpAndSettle();

      // Verify Balvatika screen header elements
      expect(find.text('Balvatika'), findsWidgets);
      expect(
        find.text('Foundation Stage | Learn, Listen, Speak'),
        findsOneWidget,
      );
      expect(find.byType(AyoComingSoonCard), findsWidgets);
      expect(
        find.textContaining('Learning content is coming soon.'),
        findsWidgets,
      );

      // Verify that no functional chapter is openable
      expect(find.text('Flashcards'), findsNothing);

      // Tap back button on Balvatika screen -> returns to Home
      final backIcon = find.byIcon(Icons.chevron_left_rounded);
      await tester.ensureVisible(backIcon);
      await tester.tap(backIcon);
      await tester.pumpAndSettle();

      // Verify back on Home
      expect(find.text('Hello, Teacher'), findsOneWidget);
    },
  );

  testWidgets(
    'Class 1 (First) Subject Selection: English is Available, other subjects are Coming Soon',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(393 * 2.75, 851 * 2.75);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const AyoVaaniApp());
      await tester.pump(const Duration(milliseconds: 3000));
      await tester.pumpAndSettle();

      // From Welcome, tap Continue to Home
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // On Home screen, scroll until First card is visible then tap it
      final firstCard = find.text('First');
      expect(firstCard, findsOneWidget);
      await tester.ensureVisible(firstCard);
      await tester.tap(firstCard);
      await tester.pumpAndSettle();

      // Verify First screen header elements
      expect(find.text('First'), findsWidgets);
      expect(find.text('Grade 1 | Learn, Listen, Speak'), findsOneWidget);
      expect(find.text('Subjects'), findsOneWidget);

      // Verify English is Available
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Available'), findsWidgets);

      // Verify other subjects are Coming Soon
      expect(find.text('Hindi'), findsOneWidget);
      expect(find.text('Mathematics'), findsOneWidget);
      expect(find.text('Environmental Studies'), findsOneWidget);
      expect(find.text('Coming Soon'), findsWidgets);

      // Verify AyoSubjectCard widgets
      expect(find.byType(AyoSubjectCard), findsNWidgets(4));

      // Tap an unavailable subject (e.g. Hindi) -> should NOT navigate anywhere
      final hindiCard = find.text('Hindi');
      await tester.tap(hindiCard);
      await tester.pumpAndSettle();
      // Still on First screen
      expect(find.text('Grade 1 | Learn, Listen, Speak'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
    },
  );

  testWidgets(
    'Full MVP Flow: Home -> First -> English -> Chapters -> Chapter Options -> Flashcards/Worksheets/Games/Quizzes',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280 * 1.5, 800 * 1.5);
      tester.view.devicePixelRatio = 1.5;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const AyoVaaniApp());
      await tester.pump(const Duration(milliseconds: 3000));
      await tester.pumpAndSettle();

      // From Welcome, tap Continue
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // 1. Home -> First
      await tester.tap(find.text('First'));
      await tester.pumpAndSettle();
      expect(find.text('Grade 1 | Learn, Listen, Speak'), findsOneWidget);

      // 2. First -> English (Tap Available English subject)
      final englishCard = find.text('English');
      expect(englishCard, findsOneWidget);
      await tester.ensureVisible(englishCard);
      await tester.tap(englishCard);
      await tester.pumpAndSettle();

      // 3. English Chapters listing screen
      expect(find.text('English'), findsWidgets);
      expect(find.text('Grade 1 | Learn, Listen, Speak'), findsOneWidget);
      expect(find.text('Chapters'), findsOneWidget);
      expect(find.text('Search chapters...'), findsOneWidget);
      expect(find.text('Two Little Hands'), findsOneWidget);
      expect(find.text('Life Around Us'), findsOneWidget);
      expect(find.text('The Food We Eat'), findsOneWidget);

      // 4. Select Chapter (Tap "Two Little Hands") -> opens Chapter Options Screen
      await tester.tap(find.text('Two Little Hands'));
      await tester.pumpAndSettle();

      // 5. Chapter Options Screen
      expect(find.text('Two Little Hands'), findsWidgets);
      expect(find.text('Flashcards'), findsOneWidget);
      expect(find.text('Worksheets'), findsOneWidget);
      expect(find.text('Games'), findsOneWidget);
      expect(find.text('Quizes'), findsOneWidget);

      // 6. Test Flashcards
      await tester.tap(find.text('Flashcards'));
      await tester.pumpAndSettle();
      expect(find.text('Listen'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      // 7. Test Worksheets
      await tester.tap(find.text('Worksheets'));
      await tester.pumpAndSettle();
      expect(find.text('Download PDF'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      // 8. Test Games
      await tester.tap(find.text('Games'));
      await tester.pumpAndSettle();
      expect(find.text('⭐ 0'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      // 9. Test Quizzes
      await tester.tap(find.text('Quizes'));
      await tester.pumpAndSettle();
      expect(find.text('First • Ch 1'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      // 10. Back to English Chapters
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Search chapters...'), findsOneWidget);

      // 11. Back to Subject Selection
      await tester.tap(find.byIcon(Icons.chevron_left_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Subjects'), findsOneWidget);

      // 12. Back to Home
      final homeBack = find.byIcon(Icons.chevron_left_rounded);
      await tester.ensureVisible(homeBack);
      await tester.tap(homeBack);
      await tester.pumpAndSettle();
      expect(find.text('Hello, Teacher'), findsOneWidget);
    },
  );

  testWidgets(
    'Class 2 (Second) and Class 3 (Third) show Coming Soon with no functional chapters',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(393 * 2.75, 851 * 2.75);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const AyoVaaniApp());
      await tester.pump(const Duration(milliseconds: 3000));
      await tester.pumpAndSettle();

      // From Welcome, tap Continue
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // 1. Test Second (Class 2)
      final secondCard = find.text('Second');
      await tester.ensureVisible(secondCard);
      await tester.tap(secondCard);
      await tester.pumpAndSettle();

      expect(find.text('Second'), findsWidgets);
      expect(find.text('Grade 2 | Learn, Listen, Speak'), findsOneWidget);
      expect(find.byType(AyoComingSoonCard), findsWidgets);
      expect(find.text('Flashcards'), findsNothing);

      // Return to Home
      final backIcon = find.byIcon(Icons.chevron_left_rounded);
      await tester.tap(backIcon);
      await tester.pumpAndSettle();

      // 2. Test Third (Class 3)
      final thirdCard = find.text('Third');
      await tester.ensureVisible(thirdCard);
      await tester.tap(thirdCard);
      await tester.pumpAndSettle();

      expect(find.text('Third'), findsWidgets);
      expect(find.text('Grade 3 | Learn, Listen, Speak'), findsOneWidget);
      expect(find.byType(AyoComingSoonCard), findsWidgets);
      expect(find.text('Flashcards'), findsNothing);

      // Return to Home
      await tester.tap(find.byIcon(Icons.chevron_left_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Hello, Teacher'), findsOneWidget);
    },
  );

  testWidgets(
    'Teacher Profile screen displays all required sections and adapts to tablet',
    (WidgetTester tester) async {
      // 1. Mobile screen test
      tester.view.physicalSize = const Size(393 * 2.75, 851 * 2.75);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const AyoVaaniApp());
      await tester.pump(const Duration(milliseconds: 3000));
      await tester.pumpAndSettle();

      // On Welcome, tap Continue
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Tap Profile in bottom navigation
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      // 1. Teacher Profile Header
      expect(find.text('Teacher Profile'), findsOneWidget);
      expect(find.text('Teacher'), findsOneWidget);
      expect(find.text('Classroom Educator'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);

      // 2. Offline Status Card
      expect(find.text('Offline Ready'), findsOneWidget);
      expect(find.text('Content synced today.'), findsOneWidget);
      expect(find.text('24 lessons available offline'), findsWidgets);

      // 3. My Classroom
      expect(find.text('My Classroom'), findsOneWidget);
      expect(find.text('Class 1'), findsOneWidget);
      expect(find.text('Hindi → Mundari'), findsWidgets);
      expect(find.text('32 students'), findsOneWidget);

      // 4. Language Settings
      expect(find.text('Language Settings'), findsOneWidget);
      expect(find.text('Teaching Language'), findsOneWidget);

      // 5. Downloaded Content
      expect(find.text('Downloaded Content'), findsOneWidget);
      expect(find.text('128 MB'), findsOneWidget);

      // 6. Settings
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Offline Sync'), findsOneWidget);
      expect(find.text('Help & Support'), findsOneWidget);
      expect(find.text('About AYOVAANI'), findsOneWidget);

      // 7. Log Out
      expect(find.text('Log Out'), findsOneWidget);

      // 2. Tablet layout test
      tester.view.physicalSize = const Size(1280 * 1.5, 800 * 1.5);
      tester.view.devicePixelRatio = 1.5;
      await tester.pumpAndSettle();

      expect(find.text('Teacher Profile'), findsOneWidget);
      expect(find.text('My Classroom'), findsOneWidget);
      expect(find.text('Language Settings'), findsOneWidget);
      expect(find.text('Downloaded Content'), findsOneWidget);
      expect(find.text('Log Out'), findsOneWidget);
      expect(find.byType(AyoBottomNavBar), findsOneWidget);
    },
  );

  testWidgets(
    'Learn Tab Flow: Bottom Nav Learn -> Student Levels Screen -> Phase Selection Popup',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(393 * 2.75, 851 * 2.75);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const AyoVaaniApp());
      await tester.pump(const Duration(milliseconds: 3000));
      await tester.pumpAndSettle();

      // From Welcome, tap Continue
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // 1. Tap Learn in Bottom Navigation
      await tester.tap(find.text('Learn').first);
      await tester.pumpAndSettle();

      // Verify Learning screen is shown
      expect(find.text('Learning'), findsOneWidget);
      expect(
        find.text('Choose how you want to learn today'),
        findsOneWidget,
      );
      expect(find.text('For Students'), findsOneWidget);

      // 2. Tap Start Learning on Students card -> goes to StudentLevelsScreen
      await tester.tap(find.text('Start Learning'));
      await tester.pumpAndSettle();

      // Verify StudentLevelsScreen is shown (English – First Standard)
      expect(find.text('English – First Standard'), findsOneWidget);
      expect(find.text('Learn, practice & grow'), findsOneWidget);

      // 3. Level 1 is at the bottom of the scrollable path; scroll down to reveal it.
      await tester.scrollUntilVisible(
        find.text('1'),
        200.0,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();

      // Tap Level 1 circle -> Phase selection popup should appear
      await tester.tap(find.text('1'));
      await tester.pump(const Duration(milliseconds: 300));

      // Verify PhaseSelectionDialog content
      expect(find.text('Choose a Phase'), findsOneWidget);
      expect(find.text('Phase 1'), findsOneWidget);
      expect(find.text('Phase 2'), findsOneWidget);
      expect(find.text('Phase 3'), findsOneWidget);
      expect(find.text('5 Questions'), findsWidgets);

      // 4. Close the popup via X button
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      // Verify back to level map
      expect(find.text('English – First Standard'), findsOneWidget);
      expect(find.text('Choose a Phase'), findsNothing);

      // 5. Back from StudentLevelsScreen -> returns to LearnScreen
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Learning'), findsOneWidget);
    },
  );
}
