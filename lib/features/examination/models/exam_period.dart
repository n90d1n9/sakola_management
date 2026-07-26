import 'enums.dart';

class ExamPeriod {
  final String id;
  final String name; // e.g., "Semester Ganjil 2024/2025", "Ujian Tengah Semester"
  final String academicYear;
  final DateTime startDate;
  final DateTime endDate;
  final ExamType type;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ExamPeriod({
    required this.id,
    required this.name,
    required this.academicYear,
    required this.startDate,
    required this.endDate,
    required this.type,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  ExamPeriod copyWith({
    String? id,
    String? name,
    String? academicYear,
    DateTime? startDate,
    DateTime? endDate,
    ExamType? type,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExamPeriod(
      id: id ?? this.id,
      name: name ?? this.name,
      academicYear: academicYear ?? this.academicYear,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      type: type ?? this.type,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'academicYear': academicYear,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'type': type.toString(),
        'isActive': isActive,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory ExamPeriod.fromJson(Map<String, dynamic> json) => ExamPeriod(
        id: json['id'],
        name: json['name'],
        academicYear: json['academicYear'],
        startDate: DateTime.parse(json['startDate']),
        endDate: DateTime.parse(json['endDate']),
        type: ExamType.values.firstWhere((e) => e.toString() == json['type']),
        isActive: json['isActive'] ?? true,
        createdAt: json['createdAt'] != null 
            ? DateTime.parse(json['createdAt']) 
            : null,
        updatedAt: json['updatedAt'] != null 
            ? DateTime.parse(json['updatedAt']) 
            : null,
      );

  @override
  String toString() => 'ExamPeriod(id: $id, name: $name, academicYear: $academicYear, startDate: $startDate, endDate: $endDate, type: $type, isActive: $isActive)';
}
