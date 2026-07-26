enum CurriculumType {
  kurikulumMerdeka,
  kurikulum2013,
  kurikulumTingkatSatuanPendidikan,
  international,
  islamic,
  other,
}

enum CompetencyLevel {
  dasar, // SD/MI
  menengahPertama, // SMP/MTs
  menengahAtas, // SMA/MA/SMK
}

class LearningOutcome {
  final String id;
  final String code; // CP code
  final String description;
  final CompetencyLevel level;
  final String subjectArea;
  final String phase; // Fase A-J in Kurikulum Merdeka
  final DateTime? createdAt;

  LearningOutcome({
    required this.id,
    required this.code,
    required this.description,
    required this.level,
    required this.subjectArea,
    required this.phase,
    this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'description': description,
        'level': level.toString(),
        'subjectArea': subjectArea,
        'phase': phase,
        'createdAt': createdAt?.toIso8601String(),
      };

  factory LearningOutcome.fromJson(Map<String, dynamic> json) => LearningOutcome(
        id: json['id'],
        code: json['code'],
        description: json['description'],
        level: CompetencyLevel.values.firstWhere(
          (e) => e.toString() == json['level'],
        ),
        subjectArea: json['subjectArea'],
        phase: json['phase'],
        createdAt: json['createdAt'] != null 
            ? DateTime.parse(json['createdAt']) 
            : null,
      );
}

class SubjectCompetency {
  final String id;
  final String learningOutcomeId;
  final String subjectId;
  final String description;
  final List<String> indicators; // Indikator pencapaian

  SubjectCompetency({
    required this.id,
    required this.learningOutcomeId,
    required this.subjectId,
    required this.description,
    required this.indicators,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'learningOutcomeId': learningOutcomeId,
        'subjectId': subjectId,
        'description': description,
        'indicators': indicators,
      };

  factory SubjectCompetency.fromJson(Map<String, dynamic> json) => SubjectCompetency(
        id: json['id'],
        learningOutcomeId: json['learningOutcomeId'],
        subjectId: json['subjectId'],
        description: json['description'],
        indicators: List<String>.from(json['indicators']),
      );
}

class CurriculumMap {
  final String id;
  final String name;
  final CurriculumType type;
  final String academicYear;
  final String educationLevel;
  final String semester;
  final List<SubjectMapping> subjectMappings;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CurriculumMap({
    required this.id,
    required this.name,
    required this.type,
    required this.academicYear,
    required this.educationLevel,
    required this.semester,
    required this.subjectMappings,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.toString(),
        'academicYear': academicYear,
        'educationLevel': educationLevel,
        'semester': semester,
        'subjectMappings': subjectMappings.map((e) => e.toJson()).toList(),
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory CurriculumMap.fromJson(Map<String, dynamic> json) => CurriculumMap(
        id: json['id'],
        name: json['name'],
        type: CurriculumType.values.firstWhere((e) => e.toString() == json['type']),
        academicYear: json['academicYear'],
        educationLevel: json['educationLevel'],
        semester: json['semester'],
        subjectMappings: (json['subjectMappings'] as List)
            .map((e) => SubjectMapping.fromJson(e))
            .toList(),
        createdAt: json['createdAt'] != null 
            ? DateTime.parse(json['createdAt']) 
            : null,
        updatedAt: json['updatedAt'] != null 
            ? DateTime.parse(json['updatedAt']) 
            : null,
      );
}

class SubjectMapping {
  final String subjectId;
  final String subjectName;
  final int credits; // JP (Jam Pelajaran) per week
  final List<String> learningOutcomes; // CP IDs
  final List<String> topics; // Materi pokok
  final List<String> activities; // Kegiatan pembelajaran
  final List<String> assessments; // Asesmen

  SubjectMapping({
    required this.subjectId,
    required this.subjectName,
    required this.credits,
    required this.learningOutcomes,
    required this.topics,
    required this.activities,
    required this.assessments,
  });

  Map<String, dynamic> toJson() => {
        'subjectId': subjectId,
        'subjectName': subjectName,
        'credits': credits,
        'learningOutcomes': learningOutcomes,
        'topics': topics,
        'activities': activities,
        'assessments': assessments,
      };

  factory SubjectMapping.fromJson(Map<String, dynamic> json) => SubjectMapping(
        subjectId: json['subjectId'],
        subjectName: json['subjectName'],
        credits: json['credits'] ?? 0,
        learningOutcomes: List<String>.from(json['learningOutcomes']),
        topics: List<String>.from(json['topics']),
        activities: List<String>.from(json['activities']),
        assessments: List<String>.from(json['assessments']),
      );
}
