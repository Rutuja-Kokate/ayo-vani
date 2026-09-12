import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ayo_vani/screens/learn/learn_screen.dart';
import 'package:ayo_vani/widgets/ayo_bottom_nav_bar.dart';
import 'package:ayo_vani/widgets/ayo_logo.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LearnScreen Tests', () {
    testWidgets('renders all visual elements on mobile screen matching reference', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(393 * 2.75, 851 * 2.75);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      bool backPressed = false;
      bool teacherPressed = false;
      bool studentPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: LearnScreen(
            onBack: () => backPressed = true,
            onNavigateToTeacher: () => teacherPressed = true,
            onNavigateToStudent: () => studentPressed = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Top bar & Logo
      expect(find.byType(AyoLogo), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

      // Title & Subtitle
      expect(find.text('Learning'), findsOneWidget);
      expect(find.text('Choose how you want to learn today'), findsOneWidget);

      // Teacher card
      expect(find.text('For Teachers'), findsOneWidget);
      expect(find.text('Plan, prepare & teach'), findsOneWidget);
      expect(find.text('Lessons • Worksheets • Quizzes • Translation'), findsOneWidget);
      expect(find.text('Explore'), findsOneWidget);

      // Student card
      expect(find.text('For Students'), findsOneWidget);
      expect(find.text('Learn, practice & play'), findsOneWidget);
      expect(find.text('Lessons • Flashcards • Games • Activities'), findsOneWidget);
      expect(find.text('Start Learning'), findsOneWidget);

      // Bottom Navigation
      expect(find.byType(AyoBottomNavBar), findsOneWidget);
      expect(find.text('Learn'), findsOneWidget);

      // Back button tap
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();
      expect(backPressed, isTrue);

      // Teacher card explore tap
      await tester.tap(find.text('Explore'));
      await tester.pumpAndSettle();
      expect(teacherPressed, isTrue);

      // Student card start learning tap
      await tester.tap(find.text('Start Learning'));
      await tester.pumpAndSettle();
      expect(studentPressed, isTrue);
    });

    testWidgets('renders cleanly on tablet without overflow', (
      WidgetTester tester,
    ) async {
      // Tablet portrait (e.g. 800 x 1280)
      tester.view.physicalSize = const Size(800 * 1.5, 1280 * 1.5);
      tester.view.devicePixelRatio = 1.5;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: LearnScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Learning'), findsOneWidget);
      expect(find.text('For Teachers'), findsOneWidget);
      expect(find.text('For Students'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
