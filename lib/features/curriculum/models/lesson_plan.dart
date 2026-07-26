import 'package:flutter/material.dart';

class LessonPlan {
  final String id;
  final String teacherId;
  final String teacherName;
  final String subjectId;
  final String subjectName;
  final String classGroupId;
  final String classGroupName;
  final String topic;
  final String learningObjectives;
  final List<String> competencies; // CP/TP/ATP references
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final int durationMinutes;
  final List<LearningActivity> activities;
  final List<String> materials;
  final List<String> media;
  final String assessmentMethod;
  final String? notes;
  final String moduleAjarId; // Referensi Modul Ajar
  final DateTime? createdAt;
  final DateTime? updatedAt;

  LessonPlan({
    required this.id,
    required this.teacherId,
    required this.teacherName,
    required this.subjectId,
    required this.subjectName,
    required this.classGroupId,
    required this.classGroupName,
    required this.topic,
    required this.learningObjectives,
    required this.competencies,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.activities,
    required this.materials,
    required this.media,
    required this.assessmentMethod,
    this.notes,
    this.moduleAjarId,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'teacherId': teacherId,
        'teacherName': teacherName,
        'subjectId': subjectId,
        'subjectName': subjectName,
        'classGroupId': classGroupId,
        'classGroupName': classGroupName,
        'topic': topic,
        'learningObjectives': learningObjectives,
        'competencies': competencies,
        'date': date.toIso8601String(),
        'startTime': '${startTime.hour}:${startTime.minute}',
        'endTime': '${endTime.hour}:${endTime.minute}',
        'durationMinutes': durationMinutes,
        'activities': activities.map((e) => e.toJson()).toList(),
        'materials': materials,
        'media': media,
        'assessmentMethod': assessmentMethod,
        'notes': notes,
        'moduleAjarId': moduleAjarId,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory LessonPlan.fromJson(Map<String, dynamic> json) => LessonPlan(
        id: json['id'],
        teacherId: json['teacherId'],
        teacherName: json['teacherName'],
        subjectId: json['subjectId'],
        subjectName: json['subjectName'],
        classGroupId: json['classGroupId'],
        classGroupName: json['classGroupName'],
        topic: json['topic'],
        learningObjectives: json['learningObjectives'],
        competencies: List<String>.from(json['competencies']),
        date: DateTime.parse(json['date']),
        startTime: _parseTimeOfDay(json['startTime']),
        endTime: _parseTimeOfDay(json['endTime']),
        durationMinutes: json['durationMinutes'],
        activities: (json['activities'] as List)
            .map((e) => LearningActivity.fromJson(e))
            .toList(),
        materials: List<String>.from(json['materials']),
        media: List<String>.from(json['media']),
        assessmentMethod: json['assessmentMethod'],
        notes: json['notes'],
        moduleAjarId: json['moduleAjarId'],
        createdAt: json['createdAt'] != null 
            ? DateTime.parse(json['createdAt']) 
            : null,
        updatedAt: json['updatedAt'] != null 
            ? DateTime.parse(json['updatedAt']) 
            : null,
      );

  static TimeOfDay _parseTimeOfDay(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}

class LearningActivity {
  final String id;
  final ActivityPhase phase; // Pendahuluan, Inti, Penutup
  final String description;
  final int durationMinutes;
  final String? teacherAction;
  final String? studentAction;
  final List<String> resources;

  LearningActivity({
    required this.id,
    required this.phase,
    required this.description,
    required this.durationMinutes,
    this.teacherAction,
    this.studentAction,
    this.resources = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'phase': phase.toString(),
        'description': description,
        'durationMinutes': durationMinutes,
        'teacherAction': teacherAction,
        'studentAction': studentAction,
        'resources': resources,
      };

  factory LearningActivity.fromJson(Map<String, dynamic> json) => LearningActivity(
        id: json['id'],
        phase: ActivityPhase.values.firstWhere((e) => e.toString() == json['phase']),
        description: json['description'],
        durationMinutes: json['durationMinutes'],
        teacherAction: json['teacherAction'],
        studentAction: json['studentAction'],
        resources: json['resources'] != null 
            ? List<String>.from(json['resources']) 
            : [],
      );
}

enum ActivityPhase {
  pendahuluan, // Introduction
  inti, // Core activity
  penutup, // Closing
  refleksi, // Reflection
}

class TeachingModule {
  final String id;
  final String name; // Nama Modul Ajar
  final String subjectId;
  final String subjectName;
  final String educationLevel;
  final String phase; // Fase in Kurikulum Merdeka
  final String semester;
  final int allocatedHours; // Alokasi JP
  final String learningOutcomes; // Capaian Pembelajaran
  final String objectives; // Tujuan Pembelajaran
  final String understandingQuestions; // Pertanyaan Pemantik
  final List<String> activities; // Kegiatan Pembelajaran
  final String assessment; // Asesmen
  final List<String> attachments; // Lampiran
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TeachingModule({
    required this.id,
    required this.name,
    required this.subjectId,
    required this.subjectName,
    required this.educationLevel,
    required this.phase,
    required this.semester,
    required this.allocatedHours,
    required this.learningOutcomes,
    required this.objectives,
    required this.understandingQuestions,
    required this.activities,
    required this.assessment,
    required this.attachments,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'subjectId': subjectId,
        'subjectName': subjectName,
        'educationLevel': educationLevel,
        'phase': phase,
        'semester': semester,
        'allocatedHours': allocatedHours,
        'learningOutcomes': learningOutcomes,
        'objectives': objectives,
        'understandingQuestions': understandingQuestions,
        'activities': activities,
        'assessment': assessment,
        'attachments': attachments,
        'createdBy': createdBy,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory TeachingModule.fromJson(Map<String, dynamic> json) => TeachingModule(
        id: json['id'],
        name: json['name'],
        subjectId: json['subjectId'],
        subjectName: json['subjectName'],
        educationLevel: json['educationLevel'],
        phase: json['phase'],
        semester: json['semester'],
        allocatedHours: json['allocatedHours'],
        learningOutcomes: json['learningOutcomes'],
        objectives: json['objectives'],
        understandingQuestions: json['understandingQuestions'],
        activities: List<String>.from(json['activities']),
        assessment: json['assessment'],
        attachments: List<String>.from(json['attachments']),
        createdBy: json['createdBy'],
        createdAt: json['createdAt'] != null 
            ? DateTime.parse(json['createdAt']) 
            : null,
        updatedAt: json['updatedAt'] != null 
            ? DateTime.parse(json['updatedAt']) 
            : null,
      );
}
