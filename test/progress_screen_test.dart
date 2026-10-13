import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:ayo_vani/screens/progress/progress_screen.dart';
import 'package:ayo_vani/services/activity_database_service.dart';

Widget createTestWidget() {
  return const MaterialApp(
    home: ProgressScreen(),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProgressScreen Tests', () {
    late ActivityDatabaseService dbService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      dbService = ActivityDatabaseService.instance;
      final inMemDb = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      await inMemDb.execute('''
        CREATE TABLE activity_events (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          chapter TEXT NOT NULL,
          activity_type TEXT NOT NULL,
          correct INTEGER NOT NULL,
          total INTEGER NOT NULL,
          timestamp INTEGER NOT NULL
        )
      ''');
      dbService.dbForTesting = inMemDb;
    });

    tearDown(() async {
      await dbService.clearAll();
      await dbService.close();
    });

    testWidgets('Renders clean empty state when no activity recorded', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Classroom Progress'), findsOneWidget);
      expect(find.text('No Classroom Activity Yet'), findsOneWidget);
      expect(
        find.textContaining('Complete quizzes, flashcard reviews, worksheets'),
        findsOneWidget,
      );

      // Verify NO static Gondi cards exist
      expect(find.textContaining('Gondi'), findsNothing);
      expect(find.text('6 students struggled with complex numeral sounds in Gondi.'), findsNothing);
    });

    testWidgets('Renders dynamic mastery and learning gap insights when events exist', (tester) async {
      await tester.runAsync(() async {
        await dbService.recordEvent(
          chapter: 'Two Little Hands',
          activityType: 'quiz',
          correct: 2,
          total: 10,
        );
        await dbService.recordEvent(
          chapter: 'The Food We Eat',
          activityType: 'game',
          correct: 9,
          total: 10,
        );
      });

      await tester.pumpWidget(createTestWidget());
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Empty state should be gone
      expect(find.text('No Classroom Activity Yet'), findsNothing);

      // Overall Mastery Card
      expect(find.text('Overall Language Mastery'), findsOneWidget);
      expect(find.textContaining('11 / 20 items correct across 2 activities'), findsOneWidget);

      // Insights Header
      expect(find.text('Learning Gap Insights'), findsOneWidget);

      // Weak Area Card
      expect(find.text('Two Little Hands (quiz)'), findsOneWidget);
      expect(find.text('Needs Practice'), findsOneWidget);
      expect(find.textContaining('2 / 10 correct. Targeted review recommended in Mundari.'), findsOneWidget);

      // Strong Area Card
      expect(find.text('The Food We Eat (game)'), findsOneWidget);
      expect(find.text('High Mastery'), findsOneWidget);
      expect(find.textContaining('9 / 10 completed successfully.'), findsOneWidget);

      // Verify zero hardcoded static text
      expect(find.textContaining('Gondi'), findsNothing);
    });
  });
}
