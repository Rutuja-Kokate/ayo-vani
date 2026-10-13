import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Single classroom learning activity event.
class ActivityEvent {
  final int? id;
  final String chapter;
  final String activityType; // 'quiz', 'flashcard', 'worksheet', 'game', 'practice'
  final int correct;
  final int total;
  final DateTime timestamp;

  const ActivityEvent({
    this.id,
    required this.chapter,
    required this.activityType,
    required this.correct,
    required this.total,
    required this.timestamp,
  });

  double get accuracy => total > 0 ? (correct / total).clamp(0.0, 1.0) : 0.0;

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'chapter': chapter,
        'activity_type': activityType,
        'correct': correct,
        'total': total,
        'timestamp': timestamp.millisecondsSinceEpoch,
      };

  factory ActivityEvent.fromMap(Map<String, dynamic> map) => ActivityEvent(
        id: map['id'] as int?,
        chapter: map['chapter'] as String? ?? 'General',
        activityType: map['activity_type'] as String? ?? 'quiz',
        correct: map['correct'] as int? ?? 0,
        total: map['total'] as int? ?? 0,
        timestamp: DateTime.fromMillisecondsSinceEpoch(
          map['timestamp'] as int? ?? 0,
        ),
      );
}

/// Aggregated classroom progress metrics computed from real activity events.
class ClassroomProgressStats {
  final int totalEvents;
  final int totalCorrect;
  final int totalQuestions;
  final double overallAccuracy;
  final double retentionRate;
  final List<TopicAccuracy> weakAreas;
  final List<TopicAccuracy> strongAreas;

  const ClassroomProgressStats({
    required this.totalEvents,
    required this.totalCorrect,
    required this.totalQuestions,
    required this.overallAccuracy,
    required this.retentionRate,
    required this.weakAreas,
    required this.strongAreas,
  });

  bool get isEmpty => totalEvents == 0;

  factory ClassroomProgressStats.empty() => const ClassroomProgressStats(
        totalEvents: 0,
        totalCorrect: 0,
        totalQuestions: 0,
        overallAccuracy: 0.0,
        retentionRate: 0.0,
        weakAreas: [],
        strongAreas: [],
      );
}

/// Topic accuracy breakdown item.
class TopicAccuracy {
  final String topic;
  final String activityType;
  final int correct;
  final int total;
  final double accuracy;

  const TopicAccuracy({
    required this.topic,
    required this.activityType,
    required this.correct,
    required this.total,
    required this.accuracy,
  });
}

/// Lightweight local store using SQLite for tracking real student activity events.
class ActivityDatabaseService {
  static final ActivityDatabaseService instance =
      ActivityDatabaseService._internal();
  factory ActivityDatabaseService() => instance;
  ActivityDatabaseService._internal();

  Database? _db;

  @visibleForTesting
  set dbForTesting(Database? database) => _db = database;

  Future<Database> get database async {
    if (_db != null && _db!.isOpen) return _db!;
    _db = await init();
    return _db!;
  }

  /// Initializes the SQLite database.
  Future<Database> init({String? customPath}) async {
    if (_db != null && _db!.isOpen) return _db!;

    // Initialize FFI for desktop and Flutter test environments
    if (Platform.environment.containsKey('FLUTTER_TEST') ||
        Platform.isMacOS ||
        Platform.isLinux ||
        Platform.isWindows) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String dbPath;
    if (customPath != null) {
      dbPath = customPath;
    } else if (Platform.environment.containsKey('FLUTTER_TEST')) {
      dbPath = inMemoryDatabasePath;
    } else {
      final docDir = await getApplicationDocumentsDirectory();
      dbPath = p.join(docDir.path, 'ayo_activity_events.db');
    }

    _db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE activity_events (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            chapter TEXT NOT NULL,
            activity_type TEXT NOT NULL,
            correct INTEGER NOT NULL,
            total INTEGER NOT NULL,
            timestamp INTEGER NOT NULL
          )
        ''');
      },
    );

    return _db!;
  }

  /// Records a completed or submitted student activity event.
  Future<int> recordEvent({
    required String chapter,
    required String activityType,
    required int correct,
    required int total,
    DateTime? timestamp,
  }) async {
    final db = await database;
    final event = ActivityEvent(
      chapter: chapter,
      activityType: activityType,
      correct: correct,
      total: total,
      timestamp: timestamp ?? DateTime.now(),
    );
    return await db.insert('activity_events', event.toMap());
  }

  /// Retrieves all recorded activity events, ordered newest first.
  Future<List<ActivityEvent>> getAllEvents() async {
    final db = await database;
    final rows = await db.query('activity_events', orderBy: 'timestamp DESC');
    return rows.map(ActivityEvent.fromMap).toList();
  }

  /// Computes classroom progress metrics dynamically from real activity records.
  Future<ClassroomProgressStats> getProgressStats() async {
    final events = await getAllEvents();
    if (events.isEmpty) {
      return ClassroomProgressStats.empty();
    }

    int sumCorrect = 0;
    int sumTotal = 0;
    int retentionCorrect = 0;
    int retentionTotal = 0;

    final topicMap = <String, _TopicAccumulator>{};

    for (final e in events) {
      sumCorrect += e.correct;
      sumTotal += e.total;

      // Retention is tracked via repeated review activities (flashcards & quizzes)
      if (e.activityType == 'flashcard' || e.activityType == 'quiz') {
        retentionCorrect += e.correct;
        retentionTotal += e.total;
      }

      final key = '${e.chapter}::${e.activityType}';
      final acc = topicMap.putIfAbsent(
        key,
        () => _TopicAccumulator(e.chapter, e.activityType),
      );
      acc.correct += e.correct;
      acc.total += e.total;
    }

    final overallAccuracy = sumTotal > 0 ? (sumCorrect / sumTotal).clamp(0.0, 1.0) : 0.0;
    final retentionRate = retentionTotal > 0
        ? (retentionCorrect / retentionTotal).clamp(0.0, 1.0)
        : overallAccuracy;

    final weak = <TopicAccuracy>[];
    final strong = <TopicAccuracy>[];

    for (final item in topicMap.values) {
      final acc = item.total > 0 ? (item.correct / item.total).clamp(0.0, 1.0) : 0.0;
      final topicAcc = TopicAccuracy(
        topic: item.chapter,
        activityType: item.activityType,
        correct: item.correct,
        total: item.total,
        accuracy: acc,
      );

      if (acc < 0.70) {
        weak.add(topicAcc);
      } else {
        strong.add(topicAcc);
      }
    }

    // Sort weak areas lowest accuracy first
    weak.sort((a, b) => a.accuracy.compareTo(b.accuracy));
    // Sort strong areas highest accuracy first
    strong.sort((a, b) => b.accuracy.compareTo(a.accuracy));

    return ClassroomProgressStats(
      totalEvents: events.length,
      totalCorrect: sumCorrect,
      totalQuestions: sumTotal,
      overallAccuracy: overallAccuracy,
      retentionRate: retentionRate,
      weakAreas: weak,
      strongAreas: strong,
    );
  }

  /// Clears all events (for testing or profile reset).
  Future<void> clearAll() async {
    final db = await database;
    await db.delete('activity_events');
  }

  /// Closes database connection.
  Future<void> close() async {
    if (_db != null && _db!.isOpen) {
      await _db!.close();
      _db = null;
    }
  }
}

class _TopicAccumulator {
  final String chapter;
  final String activityType;
  int correct = 0;
  int total = 0;

  _TopicAccumulator(this.chapter, this.activityType);
}
