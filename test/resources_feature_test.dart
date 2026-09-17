import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ayo_vani/screens/chapter_options/chapter_options_screen.dart';
import 'package:ayo_vani/screens/chapter_options/widgets/learning_option_card.dart';
import 'package:ayo_vani/screens/activities/resources/resources_screen.dart';
import 'package:ayo_vani/screens/activities/resources/chapter_video_player_screen.dart';
import 'package:ayo_vani/screens/activities/resources/chapter_pdf_viewer_screen.dart';
import 'package:ayo_vani/screens/activities/resources/chapter_dictionary_screen.dart';
import 'package:ayo_vani/data/chapter_dictionary_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('First Standard English Resources Feature Tests', () {
    testWidgets(
      'Chapter 1 (Two Little Hands) displays 5 cards in order and opens ResourcesScreen with exactly 3 options',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(393 * 2.75, 851 * 2.75);
        tester.view.devicePixelRatio = 2.75;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          const MaterialApp(
            home: ChapterOptionsScreen(
              className: 'First',
              chapterNumber: 1,
              chapterName: 'Two Little Hands',
              subject: 'English',
            ),
          ),
        );
        await tester.pumpAndSettle();

        final cards = tester.widgetList<LearningOptionCard>(
          find.byType(LearningOptionCard),
        ).toList();

        expect(cards.length, 5);
        expect(cards[0].title, 'Flashcards');
        expect(cards[1].title, 'Worksheets');
        expect(cards[2].title, 'Games');
        expect(cards[3].title, 'Quizzes');
        expect(cards[4].title, 'Resources');
        expect(cards[4].subtitle, 'Additional learning materials');

        await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -500));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Resources'));
        await tester.pumpAndSettle();

        expect(find.byType(ResourcesScreen), findsOneWidget);
        expect(find.text('Two Little Hands'), findsWidgets);
        expect(find.text('Video'), findsOneWidget);
        expect(find.text('Reading Material'), findsOneWidget);
        expect(find.text('Dictionary'), findsOneWidget);
      },
    );

    testWidgets(
      'Chapter 1 Resources: Tapping Video opens ChapterVideoPlayerScreen',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(393 * 2.75, 851 * 2.75);
        tester.view.devicePixelRatio = 2.75;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          const MaterialApp(
            home: ResourcesScreen(
              className: 'First',
              chapterNumber: 1,
              chapterName: 'Two Little Hands',
              subject: 'English',
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Video'), findsOneWidget);
        await tester.tap(find.text('Video'));
        await tester.pumpAndSettle();

        expect(find.byType(ChapterVideoPlayerScreen), findsOneWidget);
        expect(find.text('Two Little Hands - Video'), findsOneWidget);
      },
    );

    testWidgets(
      'Chapter 1 Resources: Tapping Reading Material opens ChapterPdfViewerScreen',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(393 * 2.75, 851 * 2.75);
        tester.view.devicePixelRatio = 2.75;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          const MaterialApp(
            home: ResourcesScreen(
              className: 'First',
              chapterNumber: 1,
              chapterName: 'Two Little Hands',
              subject: 'English',
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Reading Material'), findsOneWidget);
        await tester.tap(find.text('Reading Material'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(ChapterPdfViewerScreen), findsOneWidget);
        expect(find.text('Two Little Hands - Reading Material'), findsOneWidget);
      },
    );

    testWidgets(
      'Chapter 1 Dictionary: Contains exactly 30 words, MT translations, categories, and search',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(412 * 2.75, 915 * 2.75);
        tester.view.devicePixelRatio = 2.75;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        // 1. Verify Data Model has exactly 30 words (15 Actions, 15 Body Parts)
        final entries = ChapterDictionaryData.chapter1Entries;
        expect(entries.length, 30);

        final actionEntries = entries.where((e) => e.category == DictionaryCategory.actions).toList();
        final bodyPartEntries = entries.where((e) => e.category == DictionaryCategory.bodyParts).toList();
        expect(actionEntries.length, 15);
        expect(bodyPartEntries.length, 15);

        const expectedActions = [
          'Clap', 'Tap', 'Walk', 'Look', 'Hear', 'Smell', 'Eat', 'Talk',
          'Move', 'See', 'Feel', 'Wash', 'Open', 'Rub', 'Rinse'
        ];
        const expectedBodyParts = [
          'Hand', 'Leg', 'Head', 'Eye', 'Ear', 'Nose', 'Mouth', 'Shoulder',
          'Knee', 'Toe', 'Tongue', 'Arm', 'Foot', 'Cheek', 'Skin'
        ];

        for (final word in expectedActions) {
          expect(actionEntries.any((e) => e.english == word), isTrue, reason: 'Missing action $word');
        }
        for (final word in expectedBodyParts) {
          expect(bodyPartEntries.any((e) => e.english == word), isTrue, reason: 'Missing body part $word');
        }

        // 2. Pump Dictionary screen
        await tester.pumpWidget(
          const MaterialApp(
            home: ChapterDictionaryScreen(
              className: 'First',
              chapterNumber: 1,
              chapterName: 'Two Little Hands',
              subject: 'English',
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify headers
        expect(find.text('Dictionary'), findsOneWidget);
        expect(find.text('English → Mundari'), findsOneWidget);
        expect(find.text('30 of 30 words'), findsOneWidget);

        // Verify Category Filter Chips
        expect(find.widgetWithText(FilterChip, 'All'), findsOneWidget);
        expect(find.widgetWithText(FilterChip, 'Actions'), findsOneWidget);
        expect(find.widgetWithText(FilterChip, 'Body Parts'), findsOneWidget);

        // Tap "Actions" chip
        await tester.tap(find.widgetWithText(FilterChip, 'Actions'));
        await tester.pumpAndSettle();
        expect(find.text('15 of 30 words'), findsOneWidget);
        expect(find.text('Clap'), findsOneWidget);
        expect(find.text('Mundari: '), findsWidgets);

        // Tap "Body Parts" chip
        await tester.tap(find.widgetWithText(FilterChip, 'Body Parts'));
        await tester.pumpAndSettle();
        expect(find.text('15 of 30 words'), findsOneWidget);
        expect(find.text('Hand'), findsOneWidget);

        // Tap "All" chip
        await tester.tap(find.widgetWithText(FilterChip, 'All'));
        await tester.pumpAndSettle();
        expect(find.text('30 of 30 words'), findsOneWidget);

        // 3. Verify Search functionality
        final searchField = find.byType(TextField);
        expect(searchField, findsOneWidget);

        await tester.enterText(searchField, 'hand');
        await tester.pumpAndSettle();
        expect(find.text('Hand'), findsOneWidget);
        expect(find.text('तिः'), findsOneWidget);
        expect(find.text('1 of 30 words'), findsOneWidget);

        // Search "clap"
        await tester.enterText(searchField, 'clap');
        await tester.pumpAndSettle();
        expect(find.text('Clap'), findsOneWidget);
        expect(find.text('रापुड़'), findsOneWidget);

        // Clear search
        await tester.tap(find.byIcon(Icons.close_rounded));
        await tester.pumpAndSettle();
        expect(find.text('30 of 30 words'), findsOneWidget);

        // 4. Test speaker button tap
        final speakerButton = find.byIcon(Icons.volume_up_outlined).first;
        await tester.tap(speakerButton);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
      },
    );

    testWidgets(
      'Chapter 2 (Life Around Us) displays 5 cards and preserves Chapter 2 resources',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(393 * 2.75, 851 * 2.75);
        tester.view.devicePixelRatio = 2.75;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          const MaterialApp(
            home: ChapterOptionsScreen(
              className: 'First',
              chapterNumber: 2,
              chapterName: 'Life Around Us',
              subject: 'English',
            ),
          ),
        );
        await tester.pumpAndSettle();

        final cards = tester.widgetList<LearningOptionCard>(
          find.byType(LearningOptionCard),
        ).toList();

        expect(cards.length, 5);
        expect(cards[4].title, 'Resources');

        await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -500));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Resources'));
        await tester.pumpAndSettle();

        expect(find.byType(ResourcesScreen), findsOneWidget);
        expect(find.text('Life Around Us'), findsWidgets);
        expect(find.text('Teacher Nature Walk Observation Guide'), findsOneWidget);
        expect(find.text('Animal Sounds & Audio Flash Guide'), findsOneWidget);
      },
    );

    testWidgets(
      'Chapter 3 (The Food We Eat) displays 5 cards and preserves Chapter 3 resources',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(393 * 2.75, 851 * 2.75);
        tester.view.devicePixelRatio = 2.75;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          const MaterialApp(
            home: ChapterOptionsScreen(
              className: 'First',
              chapterNumber: 3,
              chapterName: 'The Food We Eat',
              subject: 'English',
            ),
          ),
        );
        await tester.pumpAndSettle();

        final cards = tester.widgetList<LearningOptionCard>(
          find.byType(LearningOptionCard),
        ).toList();

        expect(cards.length, 5);
        expect(cards[4].title, 'Resources');

        await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -500));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Resources'));
        await tester.pumpAndSettle();

        expect(find.byType(ResourcesScreen), findsOneWidget);
        expect(find.text('The Food We Eat'), findsWidgets);
        expect(find.text('Teacher Nutrition & Food Discussion Manual'), findsOneWidget);
      },
    );

    testWidgets('Tablet layout renders Chapter 1 Dictionary without overflow', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: ChapterDictionaryScreen(
            className: 'First',
            chapterNumber: 1,
            chapterName: 'Two Little Hands',
            subject: 'English',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Dictionary'), findsOneWidget);
      expect(find.text('English → Mundari'), findsOneWidget);
      expect(find.text('30 of 30 words'), findsOneWidget);
    });

    testWidgets(
      'Resources card is NOT shown for other standards or subjects',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: ChapterOptionsScreen(
              className: 'Second',
              chapterNumber: 1,
              chapterName: 'Welcome to School',
              subject: 'English',
            ),
          ),
        );
        await tester.pumpAndSettle();

        final cards = tester.widgetList<LearningOptionCard>(
          find.byType(LearningOptionCard),
        ).toList();

        expect(cards.length, 4);
        expect(find.text('Resources'), findsNothing);
      },
    );
  });
}
