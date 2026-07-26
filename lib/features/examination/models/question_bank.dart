import 'enums.dart';

class ExamQuestion {
  final String id;
  final String examScheduleId;
  final int questionNumber;
  final String questionText;
  final String? questionImage;
  final QuestionType type;
  final double points;
  final List<String>? options; // For multiple choice
  final int? correctOptionIndex; // For multiple choice
  final String? answerKey; // For essay/short answer
  final String? explanation;
  final String? topic;
  final int difficultyLevel; // 1-5, 1=easiest, 5=hardest
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ExamQuestion({
    required this.id,
    required this.examScheduleId,
    required this.questionNumber,
    required this.questionText,
    this.questionImage,
    required this.type,
    required this.points,
    this.options,
    this.correctOptionIndex,
    this.answerKey,
    this.explanation,
    this.topic,
    this.difficultyLevel = 3,
    this.createdAt,
    this.updatedAt,
  });

  ExamQuestion copyWith({
    String? id,
    String? examScheduleId,
    int? questionNumber,
    String? questionText,
    String? questionImage,
    QuestionType? type,
    double? points,
    List<String>? options,
    int? correctOptionIndex,
    String? answerKey,
    String? explanation,
    String? topic,
    int? difficultyLevel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExamQuestion(
      id: id ?? this.id,
      examScheduleId: examScheduleId ?? this.examScheduleId,
      questionNumber: questionNumber ?? this.questionNumber,
      questionText: questionText ?? this.questionText,
      questionImage: questionImage ?? this.questionImage,
      type: type ?? this.type,
      points: points ?? this.points,
      options: options ?? this.options,
      correctOptionIndex: correctOptionIndex ?? this.correctOptionIndex,
      answerKey: answerKey ?? this.answerKey,
      explanation: explanation ?? this.explanation,
      topic: topic ?? this.topic,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'examScheduleId': examScheduleId,
        'questionNumber': questionNumber,
        'questionText': questionText,
        'questionImage': questionImage,
        'type': type.toString(),
        'points': points,
        'options': options,
        'correctOptionIndex': correctOptionIndex,
        'answerKey': answerKey,
        'explanation': explanation,
        'topic': topic,
        'difficultyLevel': difficultyLevel,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory ExamQuestion.fromJson(Map<String, dynamic> json) => ExamQuestion(
        id: json['id'],
        examScheduleId: json['examScheduleId'],
        questionNumber: json['questionNumber'],
        questionText: json['questionText'],
        questionImage: json['questionImage'],
        type: QuestionType.values.firstWhere((e) => e.toString() == json['type']),
        points: json['points'],
        options: json['options'] != null ? List<String>.from(json['options']) : null,
        correctOptionIndex: json['correctOptionIndex'],
        answerKey: json['answerKey'],
        explanation: json['explanation'],
        topic: json['topic'],
        difficultyLevel: json['difficultyLevel'] ?? 3,
        createdAt: json['createdAt'] != null 
            ? DateTime.parse(json['createdAt']) 
            : null,
        updatedAt: json['updatedAt'] != null 
            ? DateTime.parse(json['updatedAt']) 
            : null,
      );

  @override
  String toString() => 'ExamQuestion(id: $id, number: $questionNumber, type: $type, points: $points)';
}

enum QuestionType {
  multipleChoice,
  trueFalse,
  essay,
  shortAnswer,
  matching,
  fillInTheBlank,
  calculation,
}
