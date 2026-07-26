import 'enums.dart';

class ReportCard {
  final String id;
  final String studentId;
  final String studentName;
  final String classGroupId;
  final String classGroupName;
  final String academicYear;
  final String semester; // Ganjil/Genap
  final ExamPeriod examPeriod;
  final List<SubjectGrade> subjectGrades;
  final double averageScore;
  final double gpa;
  final int classRank;
  final int gradeLevelRank;
  final String? homeroomTeacherNotes;
  final String? principalNotes;
  final bool isPassed;
  final DateTime issuedDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ReportCard({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.classGroupId,
    required this.classGroupName,
    required this.academicYear,
    required this.semester,
    required this.examPeriod,
    required this.subjectGrades,
    required this.averageScore,
    required this.gpa,
    required this.classRank,
    required this.gradeLevelRank,
    this.homeroomTeacherNotes,
    this.principalNotes,
    required this.isPassed,
    required this.issuedDate,
    this.createdAt,
    this.updatedAt,
  });

  ReportCard copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? classGroupId,
    String? classGroupName,
    String? academicYear,
    String? semester,
    ExamPeriod? examPeriod,
    List<SubjectGrade>? subjectGrades,
    double? averageScore,
    double? gpa,
    int? classRank,
    int? gradeLevelRank,
    String? homeroomTeacherNotes,
    String? principalNotes,
    bool? isPassed,
    DateTime? issuedDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReportCard(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      classGroupId: classGroupId ?? this.classGroupId,
      classGroupName: classGroupName ?? this.classGroupName,
      academicYear: academicYear ?? this.academicYear,
      semester: semester ?? this.semester,
      examPeriod: examPeriod ?? this.examPeriod,
      subjectGrades: subjectGrades ?? this.subjectGrades,
      averageScore: averageScore ?? this.averageScore,
      gpa: gpa ?? this.gpa,
      classRank: classRank ?? this.classRank,
      gradeLevelRank: gradeLevelRank ?? this.gradeLevelRank,
      homeroomTeacherNotes: homeroomTeacherNotes ?? this.homeroomTeacherNotes,
      principalNotes: principalNotes ?? this.principalNotes,
      isPassed: isPassed ?? this.isPassed,
      issuedDate: issuedDate ?? this.issuedDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'studentId': studentId,
        'studentName': studentName,
        'classGroupId': classGroupId,
        'classGroupName': classGroupName,
        'academicYear': academicYear,
        'semester': semester,
        'examPeriod': examPeriod.toJson(),
        'subjectGrades': subjectGrades.map((e) => e.toJson()).toList(),
        'averageScore': averageScore,
        'gpa': gpa,
        'classRank': classRank,
        'gradeLevelRank': gradeLevelRank,
        'homeroomTeacherNotes': homeroomTeacherNotes,
        'principalNotes': principalNotes,
        'isPassed': isPassed,
        'issuedDate': issuedDate.toIso8601String(),
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory ReportCard.fromJson(Map<String, dynamic> json) => ReportCard(
        id: json['id'],
        studentId: json['studentId'],
        studentName: json['studentName'],
        classGroupId: json['classGroupId'],
        classGroupName: json['classGroupName'],
        academicYear: json['academicYear'],
        semester: json['semester'],
        examPeriod: ExamPeriod.fromJson(json['examPeriod']),
        subjectGrades: (json['subjectGrades'] as List)
            .map((e) => SubjectGrade.fromJson(e))
            .toList(),
        averageScore: json['averageScore']?.toDouble() ?? 0.0,
        gpa: json['gpa']?.toDouble() ?? 0.0,
        classRank: json['classRank'] ?? 0,
        gradeLevelRank: json['gradeLevelRank'] ?? 0,
        homeroomTeacherNotes: json['homeroomTeacherNotes'],
        principalNotes: json['principalNotes'],
        isPassed: json['isPassed'] ?? true,
        issuedDate: DateTime.parse(json['issuedDate']),
        createdAt: json['createdAt'] != null 
            ? DateTime.parse(json['createdAt']) 
            : null,
        updatedAt: json['updatedAt'] != null 
            ? DateTime.parse(json['updatedAt']) 
            : null,
      );

  @override
  String toString() => 'ReportCard(student: $studentName, semester: $semester, average: $averageScore, rank: $classRank)';
}

class SubjectGrade {
  final String subjectId;
  final String subjectName;
  final double knowledgeScore; // Nilai Pengetahuan
  final double skillsScore; // Nilai Keterampilan
  final double attitudeScore; // Nilai Sikap
  final double finalScore;
  final String? grade;
  final String? description; // Deskripsi kompetensi
  final int credits; // SKS if applicable
  final String? teacherName;
  final String? remedialStatus;

  SubjectGrade({
    required this.subjectId,
    required this.subjectName,
    required this.knowledgeScore,
    required this.skillsScore,
    required this.attitudeScore,
    required this.finalScore,
    this.grade,
    this.description,
    this.credits = 0,
    this.teacherName,
    this.remedialStatus,
  });

  SubjectGrade copyWith({
    String? subjectId,
    String? subjectName,
    double? knowledgeScore,
    double? skillsScore,
    double? attitudeScore,
    double? finalScore,
    String? grade,
    String? description,
    int? credits,
    String? teacherName,
    String? remedialStatus,
  }) {
    return SubjectGrade(
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      knowledgeScore: knowledgeScore ?? this.knowledgeScore,
      skillsScore: skillsScore ?? this.skillsScore,
      attitudeScore: attitudeScore ?? this.attitudeScore,
      finalScore: finalScore ?? this.finalScore,
      grade: grade ?? this.grade,
      description: description ?? this.description,
      credits: credits ?? this.credits,
      teacherName: teacherName ?? this.teacherName,
      remedialStatus: remedialStatus ?? this.remedialStatus,
    );
  }

  Map<String, dynamic> toJson() => {
        'subjectId': subjectId,
        'subjectName': subjectName,
        'knowledgeScore': knowledgeScore,
        'skillsScore': skillsScore,
        'attitudeScore': attitudeScore,
        'finalScore': finalScore,
        'grade': grade,
        'description': description,
        'credits': credits,
        'teacherName': teacherName,
        'remedialStatus': remedialStatus,
      };

  factory SubjectGrade.fromJson(Map<String, dynamic> json) => SubjectGrade(
        subjectId: json['subjectId'],
        subjectName: json['subjectName'],
        knowledgeScore: json['knowledgeScore']?.toDouble() ?? 0.0,
        skillsScore: json['skillsScore']?.toDouble() ?? 0.0,
        attitudeScore: json['attitudeScore']?.toDouble() ?? 0.0,
        finalScore: json['finalScore']?.toDouble() ?? 0.0,
        grade: json['grade'],
        description: json['description'],
        credits: json['credits'] ?? 0,
        teacherName: json['teacherName'],
        remedialStatus: json['remedialStatus'],
      );
}
