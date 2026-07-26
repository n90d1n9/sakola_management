import 'enums.dart';

class StudentExamResult {
  final String id;
  final String examScheduleId;
  final String studentId;
  final String studentName;
  final String classGroupId;
  final double score;
  final double maxScore;
  final String? grade;
  final String? remarks; // Lulus, Tidak Lulus, Perlu Remedial
  final bool isRemedial;
  final int? rank;
  final DateTime? submittedAt;
  final String? teacherNotes;
  final Map<String, dynamic>? answerDetails; // Store detailed answers per question
  final DateTime? createdAt;
  final DateTime? updatedAt;

  StudentExamResult({
    required this.id,
    required this.examScheduleId,
    required this.studentId,
    required this.studentName,
    required this.classGroupId,
    required this.score,
    required this.maxScore,
    this.grade,
    this.remarks,
    this.isRemedial = false,
    this.rank,
    this.submittedAt,
    this.teacherNotes,
    this.answerDetails,
    this.createdAt,
    this.updatedAt,
  });

  double get percentage => maxScore > 0 ? (score / maxScore) * 100 : 0;

  StudentExamResult copyWith({
    String? id,
    String? examScheduleId,
    String? studentId,
    String? studentName,
    String? classGroupId,
    double? score,
    double? maxScore,
    String? grade,
    String? remarks,
    bool? isRemedial,
    int? rank,
    DateTime? submittedAt,
    String? teacherNotes,
    Map<String, dynamic>? answerDetails,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudentExamResult(
      id: id ?? this.id,
      examScheduleId: examScheduleId ?? this.examScheduleId,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      classGroupId: classGroupId ?? this.classGroupId,
      score: score ?? this.score,
      maxScore: maxScore ?? this.maxScore,
      grade: grade ?? this.grade,
      remarks: remarks ?? this.remarks,
      isRemedial: isRemedial ?? this.isRemedial,
      rank: rank ?? this.rank,
      submittedAt: submittedAt ?? this.submittedAt,
      teacherNotes: teacherNotes ?? this.teacherNotes,
      answerDetails: answerDetails ?? this.answerDetails,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'examScheduleId': examScheduleId,
        'studentId': studentId,
        'studentName': studentName,
        'classGroupId': classGroupId,
        'score': score,
        'maxScore': maxScore,
        'grade': grade,
        'remarks': remarks,
        'isRemedial': isRemedial,
        'rank': rank,
        'submittedAt': submittedAt?.toIso8601String(),
        'teacherNotes': teacherNotes,
        'answerDetails': answerDetails,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory StudentExamResult.fromJson(Map<String, dynamic> json) => StudentExamResult(
        id: json['id'],
        examScheduleId: json['examScheduleId'],
        studentId: json['studentId'],
        studentName: json['studentName'],
        classGroupId: json['classGroupId'],
        score: json['score']?.toDouble() ?? 0.0,
        maxScore: json['maxScore']?.toDouble() ?? 0.0,
        grade: json['grade'],
        remarks: json['remarks'],
        isRemedial: json['isRemedial'] ?? false,
        rank: json['rank'],
        submittedAt: json['submittedAt'] != null 
            ? DateTime.parse(json['submittedAt']) 
            : null,
        teacherNotes: json['teacherNotes'],
        answerDetails: json['answerDetails'] != null 
            ? Map<String, dynamic>.from(json['answerDetails']) 
            : null,
        createdAt: json['createdAt'] != null 
            ? DateTime.parse(json['createdAt']) 
            : null,
        updatedAt: json['updatedAt'] != null 
            ? DateTime.parse(json['updatedAt']) 
            : null,
      );

  @override
  String toString() => 'StudentExamResult(student: $studentName, score: $score/$maxScore (${percentage.toStringAsFixed(1)}%), grade: $grade)';
}

class ClassExamStatistics {
  final String examScheduleId;
  final String classGroupId;
  final int totalStudents;
  final int presentStudents;
  final double averageScore;
  final double highestScore;
  final double lowestScore;
  final double standardDeviation;
  final int studentsPassed;
  final int studentsFailed;
  final int studentsRemedial;
  final Map<String, int> gradeDistribution;

  ClassExamStatistics({
    required this.examScheduleId,
    required this.classGroupId,
    required this.totalStudents,
    required this.presentStudents,
    required this.averageScore,
    required this.highestScore,
    required this.lowestScore,
    required this.standardDeviation,
    required this.studentsPassed,
    required this.studentsFailed,
    required this.studentsRemedial,
    required this.gradeDistribution,
  });

  double get passRate => totalStudents > 0 ? (studentsPassed / totalStudents) * 100 : 0;
  double get failureRate => totalStudents > 0 ? (studentsFailed / totalStudents) * 100 : 0;

  Map<String, dynamic> toJson() => {
        'examScheduleId': examScheduleId,
        'classGroupId': classGroupId,
        'totalStudents': totalStudents,
        'presentStudents': presentStudents,
        'averageScore': averageScore,
        'highestScore': highestScore,
        'lowestScore': lowestScore,
        'standardDeviation': standardDeviation,
        'studentsPassed': studentsPassed,
        'studentsFailed': studentsFailed,
        'studentsRemedial': studentsRemedial,
        'gradeDistribution': gradeDistribution,
        'passRate': passRate,
        'failureRate': failureRate,
      };

  factory ClassExamStatistics.fromJson(Map<String, dynamic> json) => ClassExamStatistics(
        examScheduleId: json['examScheduleId'],
        classGroupId: json['classGroupId'],
        totalStudents: json['totalStudents'],
        presentStudents: json['presentStudents'],
        averageScore: json['averageScore']?.toDouble() ?? 0.0,
        highestScore: json['highestScore']?.toDouble() ?? 0.0,
        lowestScore: json['lowestScore']?.toDouble() ?? 0.0,
        standardDeviation: json['standardDeviation']?.toDouble() ?? 0.0,
        studentsPassed: json['studentsPassed'] ?? 0,
        studentsFailed: json['studentsFailed'] ?? 0,
        studentsRemedial: json['studentsRemedial'] ?? 0,
        gradeDistribution: json['gradeDistribution'] != null 
            ? Map<String, int>.from(json['gradeDistribution']) 
            : {},
      );
}
