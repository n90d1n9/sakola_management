enum ExamType {
  dailyQuiz,
  midterm,
  finalExam,
  nationalExam,
  schoolExam,
  practicalExam,
  oralExam,
  remedial,
  enrichment,
}

enum ExamStatus {
  scheduled,
  ongoing,
  completed,
  cancelled,
  postponed,
}

enum GradingScale {
  scale0to100,
  scale0to10,
  scaleAToF,
  scalePassFail,
  custom,
}

class GradePoint {
  final String grade;
  final double minScore;
  final double maxScore;
  final double gpa;
  final String description;

  GradePoint({
    required this.grade,
    required this.minScore,
    required this.maxScore,
    required this.gpa,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
        'grade': grade,
        'minScore': minScore,
        'maxScore': maxScore,
        'gpa': gpa,
        'description': description,
      };

  factory GradePoint.fromJson(Map<String, dynamic> json) => GradePoint(
        grade: json['grade'],
        minScore: json['minScore'],
        maxScore: json['maxScore'],
        gpa: json['gpa'],
        description: json['description'],
      );
}
