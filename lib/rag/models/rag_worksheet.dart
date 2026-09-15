import 'dart:convert';

class RagFillInTheBlankItem {
  final String id;
  final String promptHindi;
  final String promptMundari;
  final String answerHindi;
  final String answerMundari;
  final List<String> wordBankHindi;
  final List<String> wordBankMundari;

  RagFillInTheBlankItem({
    required this.id,
    required this.promptHindi,
    required this.promptMundari,
    required this.answerHindi,
    required this.answerMundari,
    required this.wordBankHindi,
    required this.wordBankMundari,
  });

  factory RagFillInTheBlankItem.fromJson(Map<String, dynamic> json) =>
      RagFillInTheBlankItem(
        id: json['id'] as String? ?? '',
        promptHindi: json['promptWithBlank'] as String? ?? '',
        promptMundari: json['promptWithBlank_mundari'] as String? ?? json['promptWithBlank'] as String? ?? '',
        answerHindi: json['answer'] as String? ?? '',
        answerMundari: json['answer_mundari'] as String? ?? json['answer'] as String? ?? '',
        wordBankHindi: (json['wordBank'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        wordBankMundari: (json['wordBank_mundari'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
            (json['wordBank'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'promptWithBlank': promptHindi,
        'promptWithBlank_mundari': promptMundari,
        'answer': answerHindi,
        'answer_mundari': answerMundari,
        'wordBank': wordBankHindi,
        'wordBank_mundari': wordBankMundari,
      };
}

class RagMatchPairItem {
  final String id;
  final String columnAHindi;
  final String columnAMundari;
  final String columnBHindi;
  final String columnBMundari;

  RagMatchPairItem({
    required this.id,
    required this.columnAHindi,
    required this.columnAMundari,
    required this.columnBHindi,
    required this.columnBMundari,
  });

  factory RagMatchPairItem.fromJson(Map<String, dynamic> json) =>
      RagMatchPairItem(
        id: json['id'] as String? ?? '',
        columnAHindi: json['columnA'] as String? ?? '',
        columnAMundari: json['columnA_mundari'] as String? ?? json['columnA'] as String? ?? '',
        columnBHindi: json['columnB'] as String? ?? '',
        columnBMundari: json['columnB_mundari'] as String? ?? json['columnB'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'columnA': columnAHindi,
        'columnA_mundari': columnAMundari,
        'columnB': columnBHindi,
        'columnB_mundari': columnBMundari,
      };
}

class RagShortAnswerItem {
  final String id;
  final String questionHindi;
  final String questionMundari;
  final String sampleAnswerHindi;
  final String sampleAnswerMundari;
  final int maxMarks;

  RagShortAnswerItem({
    required this.id,
    required this.questionHindi,
    required this.questionMundari,
    required this.sampleAnswerHindi,
    required this.sampleAnswerMundari,
    this.maxMarks = 2,
  });

  factory RagShortAnswerItem.fromJson(Map<String, dynamic> json) =>
      RagShortAnswerItem(
        id: json['id'] as String? ?? '',
        questionHindi: json['question'] as String? ?? '',
        questionMundari: json['question_mundari'] as String? ?? json['question'] as String? ?? '',
        sampleAnswerHindi: json['sampleAnswer'] as String? ?? '',
        sampleAnswerMundari: json['sampleAnswer_mundari'] as String? ?? json['sampleAnswer'] as String? ?? '',
        maxMarks: json['maxMarks'] as int? ?? 2,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'question': questionHindi,
        'question_mundari': questionMundari,
        'sampleAnswer': sampleAnswerHindi,
        'sampleAnswer_mundari': sampleAnswerMundari,
        'maxMarks': maxMarks,
      };
}

class RagWorksheet {
  final String id;
  final String title;
  final String chapterName;
  final List<RagFillInTheBlankItem> fillInTheBlanks;
  final List<RagMatchPairItem> matchPairs;
  final List<RagShortAnswerItem> shortAnswers;

  RagWorksheet({
    required this.id,
    required this.title,
    required this.chapterName,
    required this.fillInTheBlanks,
    required this.matchPairs,
    required this.shortAnswers,
  });

  factory RagWorksheet.fromJson(Map<String, dynamic> json) => RagWorksheet(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        chapterName: json['chapterName'] as String? ?? '',
        fillInTheBlanks: (json['fillInTheBlanks'] as List<dynamic>?)
                ?.map((e) => RagFillInTheBlankItem.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        matchPairs: (json['matchPairs'] as List<dynamic>?)
                ?.map((e) => RagMatchPairItem.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        shortAnswers: (json['shortAnswers'] as List<dynamic>?)
                ?.map((e) => RagShortAnswerItem.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'chapterName': chapterName,
        'fillInTheBlanks': fillInTheBlanks.map((e) => e.toJson()).toList(),
        'matchPairs': matchPairs.map((e) => e.toJson()).toList(),
        'shortAnswers': shortAnswers.map((e) => e.toJson()).toList(),
      };

  String toFormattedJson() => const JsonEncoder.withIndent('  ').convert(toJson());
}
