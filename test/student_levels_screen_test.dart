import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ayo_vani/screens/learn/student_levels_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestWidget({Size size = const Size(393, 851)}) {
    return MediaQuery(
      data: MediaQueryData(size: size),
      child: const MaterialApp(
        home: StudentLevelsScreen(),
      ),
    );
  }

  group('StudentLevelsScreen - Initial Scroll Position', () {
    testWidgets('opens at bottom so Level 1 is immediately visible on mobile', (tester) async {
      tester.view.physicalSize = const Size(393, 851);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Level 1 node and text should be immediately visible without manual scrolling
      final level1Finder = find.text('Level 1');
      expect(level1Finder, findsOneWidget);

      // Verify Level 1 is within the visible viewport bounds
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
      expect(level10Rect.bottom, lessThan(0)); // Scrolled above viewport
    });

    testWidgets('allows scrolling upward to reach higher levels up to Level 10', (tester) async {
      tester.view.physicalSize = const Size(393, 851);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Scroll up towards Level 10
      await tester.scrollUntilVisible(
        find.text('Level 10'),
        -200.0,
        scrollable: find.byType(Scrollable),
      );
      await tester.pumpAndSettle();

      // Level 10 is now visible
      final level10Finder = find.text('Level 10');
      final level10Rect = tester.getRect(level10Finder);
      expect(level10Rect.top, greaterThanOrEqualTo(0));
      expect(level10Rect.bottom, lessThanOrEqualTo(851));

      // Scroll controller does not force back down to Level 1 after user scrolls
      final scrollable = tester.widget<Scrollable>(find.byType(Scrollable));
      final scrollPosition = scrollable.controller!.position;
      expect(scrollPosition.pixels, lessThan(scrollPosition.maxScrollExtent));
    });

    testWidgets('opens at bottom so Level 1 is immediately visible on tablet', (tester) async {
      tester.view.physicalSize = const Size(800, 1280);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestWidget(size: const Size(800, 1280)));
      await tester.pumpAndSettle();

      // Level 1 node is visible on tablet
      final level1Finder = find.text('Level 1');
      expect(level1Finder, findsOneWidget);
      final level1Rect = tester.getRect(level1Finder);
      expect(level1Rect.top, greaterThanOrEqualTo(0));
      expect(level1Rect.bottom, lessThanOrEqualTo(1280));

      final scrollable = tester.widget<Scrollable>(find.byType(Scrollable));
      final scrollPosition = scrollable.controller!.position;
      expect(scrollPosition.pixels, equals(scrollPosition.maxScrollExtent));
      expect(scrollPosition.pixels, greaterThan(0));
    });
  });
}
