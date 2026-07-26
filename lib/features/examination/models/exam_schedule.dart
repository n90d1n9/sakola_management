import 'enums.dart';
import 'package:flutter/material.dart';

class ExamSchedule {
  final String id;
  final String examPeriodId;
  final String subjectId;
  final String subjectName;
  final String classGroupId;
  final String classGroupName;
  final String teacherId;
  final String teacherName;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String? roomName;
  final ExamType type;
  final ExamStatus status;
  final int durationMinutes;
  final String? instructions;
  final int totalStudents;
  final int presentStudents;
  final int absentStudents;

  ExamSchedule({
    required this.id,
    required this.examPeriodId,
    required this.subjectId,
    required this.subjectName,
    required this.classGroupId,
    required this.classGroupName,
    required this.teacherId,
    required this.teacherName,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.roomName,
    required this.type,
    this.status = ExamStatus.scheduled,
    required this.durationMinutes,
    this.instructions,
    this.totalStudents = 0,
    this.presentStudents = 0,
    this.absentStudents = 0,
  });

  ExamSchedule copyWith({
    String? id,
    String? examPeriodId,
    String? subjectId,
    String? subjectName,
    String? classGroupId,
    String? classGroupName,
    String? teacherId,
    String? teacherName,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? roomName,
    ExamType? type,
    ExamStatus? status,
    int? durationMinutes,
    String? instructions,
    int? totalStudents,
    int? presentStudents,
    int? absentStudents,
  }) {
    return ExamSchedule(
      id: id ?? this.id,
      examPeriodId: examPeriodId ?? this.examPeriodId,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      classGroupId: classGroupId ?? this.classGroupId,
      classGroupName: classGroupName ?? this.classGroupName,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      roomName: roomName ?? this.roomName,
      type: type ?? this.type,
      status: status ?? this.status,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      instructions: instructions ?? this.instructions,
      totalStudents: totalStudents ?? this.totalStudents,
      presentStudents: presentStudents ?? this.presentStudents,
      absentStudents: absentStudents ?? this.absentStudents,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'examPeriodId': examPeriodId,
        'subjectId': subjectId,
        'subjectName': subjectName,
        'classGroupId': classGroupId,
        'classGroupName': classGroupName,
        'teacherId': teacherId,
        'teacherName': teacherName,
        'date': date.toIso8601String(),
        'startTime': '${startTime.hour}:${startTime.minute}',
        'endTime': '${endTime.hour}:${endTime.minute}',
        'roomName': roomName,
        'type': type.toString(),
        'status': status.toString(),
        'durationMinutes': durationMinutes,
        'instructions': instructions,
        'totalStudents': totalStudents,
        'presentStudents': presentStudents,
        'absentStudents': absentStudents,
      };

  factory ExamSchedule.fromJson(Map<String, dynamic> json) => ExamSchedule(
        id: json['id'],
        examPeriodId: json['examPeriodId'],
        subjectId: json['subjectId'],
        subjectName: json['subjectName'],
        classGroupId: json['classGroupId'],
        classGroupName: json['classGroupName'],
        teacherId: json['teacherId'],
        teacherName: json['teacherName'],
        date: DateTime.parse(json['date']),
        startTime: _parseTimeOfDay(json['startTime']),
        endTime: _parseTimeOfDay(json['endTime']),
        roomName: json['roomName'],
        type: ExamType.values.firstWhere((e) => e.toString() == json['type']),
        status: ExamStatus.values.firstWhere((e) => e.toString() == json['status']),
        durationMinutes: json['durationMinutes'],
        instructions: json['instructions'],
        totalStudents: json['totalStudents'] ?? 0,
        presentStudents: json['presentStudents'] ?? 0,
        absentStudents: json['absentStudents'] ?? 0,
      );

  static TimeOfDay _parseTimeOfDay(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  @override
  String toString() => 'ExamSchedule(id: $id, subject: $subjectName, class: $classGroupName, date: $date)';
}
