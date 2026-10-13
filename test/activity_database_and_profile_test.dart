import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:ayo_vani/services/activity_database_service.dart';
import 'package:ayo_vani/services/teacher_profile_service.dart';
import 'package:ayo_vani/services/app_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ActivityDatabaseService Tests', () {
    late ActivityDatabaseService dbService;

    setUp(() async {
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

    test('Initial database produces empty stats', () async {
      final stats = await dbService.getProgressStats();
      expect(stats.isEmpty, isTrue);
      expect(stats.totalEvents, 0);
      expect(stats.totalCorrect, 0);
      expect(stats.totalQuestions, 0);
      expect(stats.overallAccuracy, 0.0);
      expect(stats.retentionRate, 0.0);
      expect(stats.weakAreas, isEmpty);
      expect(stats.strongAreas, isEmpty);
    });

    test('Records activities and aggregates accuracy, retention, and weak/strong areas', () async {
      // 1. High-accuracy quiz in Chapter 1
      await dbService.recordEvent(
        chapter: 'Two Little Hands',
        activityType: 'quiz',
        correct: 5,
        total: 5,
      );

      // 2. Low-accuracy quiz in Chapter 2 (struggling)
      await dbService.recordEvent(
        chapter: 'Greetings',
        activityType: 'quiz',
        correct: 1,
        total: 5,
      );

      // 3. High-accuracy flashcards in Chapter 1
      await dbService.recordEvent(
        chapter: 'Two Little Hands',
        activityType: 'flashcard',
        correct: 10,
        total: 10,
      );

      // 4. Completed worksheet in Chapter 1
      await dbService.recordEvent(
        chapter: 'Two Little Hands',
        activityType: 'worksheet',
        correct: 6,
        total: 6,
      );

      // 5. Game completed in Chapter 5
      await dbService.recordEvent(
        chapter: 'The Food We Eat',
        activityType: 'game',
        correct: 6,
        total: 6,
      );

      final stats = await dbService.getProgressStats();

      expect(stats.isEmpty, isFalse);
      expect(stats.totalEvents, 5);
      expect(stats.totalCorrect, 5 + 1 + 10 + 6 + 6); // 28
      expect(stats.totalQuestions, 5 + 5 + 10 + 6 + 6); // 32
      expect(stats.overallAccuracy, closeTo(28 / 32, 0.01));

      // Retention (flashcard 10/10 + quiz 6/10 = 16/20 = 0.8)
      expect(stats.retentionRate, closeTo(16 / 20, 0.01));

      // Weak areas: Greetings::quiz has 1/5 = 20% (< 70%)
      expect(stats.weakAreas.length, 1);
      expect(stats.weakAreas.first.topic, 'Greetings');
      expect(stats.weakAreas.first.activityType, 'quiz');
      expect(stats.weakAreas.first.accuracy, 0.2);

      // Strong areas: >= 70%
      expect(stats.strongAreas.length, greaterThanOrEqualTo(3));
      final topics = stats.strongAreas.map((a) => a.topic).toSet();
      expect(topics.contains('Two Little Hands'), isTrue);
      expect(topics.contains('The Food We Eat'), isTrue);
    });

    test('clearAll clears all recorded activities', () async {
      await dbService.recordEvent(
        chapter: 'Two Little Hands',
        activityType: 'quiz',
        correct: 3,
        total: 5,
      );
      var stats = await dbService.getProgressStats();
      expect(stats.totalEvents, 1);

      await dbService.clearAll();
      stats = await dbService.getProgressStats();
      expect(stats.isEmpty, isTrue);
    });
  });

  group('TeacherProfileService Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Loads default teacher profile when fresh', () async {
      final profile = await TeacherProfileService.instance.getProfile();
      expect(profile.name, 'Teacher');
      expect(profile.role, 'Classroom Educator');
      expect(profile.className, 'Class 1');
      expect(profile.studentsCount, 32);
    });

    test('Saves and persists edited teacher profile', () async {
      final updated = const TeacherProfile(
        teacherId: 'teacher_custom_99',
        name: 'Sunita Hembrom',
        role: 'Senior Primary Teacher',
        className: 'Class 2',
        focus: 'Mundari Immersion Section',
        schoolId: 'ranchi_gov_school_03',
        studentsCount: 28,
      );

      await TeacherProfileService.instance.saveProfile(updated);
      final retrieved = await TeacherProfileService.instance.getProfile();

      expect(retrieved.name, 'Sunita Hembrom');
      expect(retrieved.role, 'Senior Primary Teacher');
      expect(retrieved.className, 'Class 2');
      expect(retrieved.focus, 'Mundari Immersion Section');
      expect(retrieved.studentsCount, 28);
    });
  });

  group('AppStorageService Tests', () {
    test('Computes storage stats with 24 base offline lessons and baseline formatted storage', () async {
      final stats = await AppStorageService.instance.computeStats();
      expect(stats.offlineLessonCount, greaterThanOrEqualTo(24));
      expect(stats.storageUsedBytes, greaterThan(0));
      expect(stats.formattedStorage.contains('MB') || stats.formattedStorage.contains('KB'), isTrue);
    });
  });

  group('Curated Content JSON Tests', () {
    test('Curated JSON files exist and declare source: curated', () {
      final dictionaryFile = File('assets/content/curated_chapter_dictionary.json');
      expect(dictionaryFile.existsSync(), isTrue);
      final dictJson = jsonDecode(dictionaryFile.readAsStringSync()) as Map<String, dynamic>;
      expect(dictJson['source'], 'curated');
      expect(dictJson['language'], contains('Mundari'));
      expect(dictJson['entries'], isNotEmpty);

      final activitiesFile = File('assets/content/curated_english_activities.json');
      expect(activitiesFile.existsSync(), isTrue);
      final actJson = jsonDecode(activitiesFile.readAsStringSync()) as Map<String, dynamic>;
      expect(actJson['source'], 'curated');
      expect(actJson['precedenceRule'], contains('Curated Content'));

      final balvatikaFile = File('assets/content/curated_balvatika.json');
      expect(balvatikaFile.existsSync(), isTrue);
      final balJson = jsonDecode(balvatikaFile.readAsStringSync()) as Map<String, dynamic>;
      expect(balJson['source'], 'curated');

      final teacherPracticeFile = File('assets/content/curated_teacher_practice.json');
      expect(teacherPracticeFile.existsSync(), isTrue);
      final tpJson = jsonDecode(teacherPracticeFile.readAsStringSync()) as Map<String, dynamic>;
      expect(tpJson['source'], 'curated');
      expect(tpJson['matchingQuestion'], isNotNull);
      expect(tpJson['multipleChoiceQuestions'], isNotEmpty);
    });
  });
}
