import 'dart:convert';

class RagQuizQuestion {
  final String id;
  final String questionHindi;
  final String questionMundari;
  final List<String> optionsHindi;
  final List<String> optionsMundari;
  final int answerIndex;
  final String explanationHindi;
  final String explanationMundari;
  final String difficulty;
  final int points;

  RagQuizQuestion({
    required this.id,
    required this.questionHindi,
    required this.questionMundari,
    required this.optionsHindi,
    required this.optionsMundari,
    required this.answerIndex,
    required this.explanationHindi,
    required this.explanationMundari,
    this.difficulty = 'medium',
    this.points = 1,
  });

  factory RagQuizQuestion.fromJson(Map<String, dynamic> json) => RagQuizQuestion(
        id: json['id'] as String? ?? '',
        questionHindi: json['question'] as String? ?? '',
        questionMundari: json['question_mundari'] as String? ?? json['question'] as String? ?? '',
        optionsHindi: (json['options'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        optionsMundari: (json['options_mundari'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
            (json['options'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        answerIndex: json['answerIndex'] as int? ?? 0,
        explanationHindi: json['explanation'] as String? ?? '',
        explanationMundari: json['explanation_mundari'] as String? ?? json['explanation'] as String? ?? '',
        difficulty: json['difficulty'] as String? ?? 'medium',
        points: json['points'] as int? ?? 1,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'question': questionHindi,
        'question_mundari': questionMundari,
        'options': optionsHindi,
        'options_mundari': optionsMundari,
        'answerIndex': answerIndex,
        'explanation': explanationHindi,
        'explanation_mundari': explanationMundari,
        'difficulty': difficulty,
        'points': points,
      };
}

class RagQuiz {
  final String id;
  final String title;
  final String chapterName;
  final int durationMinutes;
  final int totalPoints;
  final List<RagQuizQuestion> questions;

  RagQuiz({
    required this.id,
    required this.title,
    required this.chapterName,
    this.durationMinutes = 15,
    required this.totalPoints,
    required this.questions,
  });

  factory RagQuiz.fromJson(Map<String, dynamic> json) => RagQuiz(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        chapterName: json['chapterName'] as String? ?? '',
        durationMinutes: json['durationMinutes'] as int? ?? 15,
        totalPoints: json['totalPoints'] as int? ?? 10,
        questions: (json['questions'] as List<dynamic>?)
                ?.map((e) => RagQuizQuestion.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'chapterName': chapterName,
        'durationMinutes': durationMinutes,
        'totalPoints': totalPoints,
        'questions': questions.map((q) => q.toJson()).toList(),
      };

  String toFormattedJson() => const JsonEncoder.withIndent('  ').convert(toJson());
}
