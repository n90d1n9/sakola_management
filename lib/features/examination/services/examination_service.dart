import 'package:flutter/foundation.dart';
import '../models/exam_period.dart';
import '../models/exam_schedule.dart';
import '../models/exam_result.dart';
import '../models/report_card.dart';
import '../models/question_bank.dart';
import 'exam_export_service.dart';

/// Service layer for examination management
/// Handles business logic, validation, and coordination between models
class ExaminationService {
  static final ExaminationService _instance = ExaminationService._internal();
  factory ExaminationService() => _instance;
  ExaminationService._internal();

  // Export service for generating reports
  final ExamExportService exportService = ExamExportService();

  /// Validate exam period dates
  bool validateExamPeriod(DateTime start, DateTime end) {
    if (start.isAfter(end)) {
      debugPrint('Error: Start date must be before end date');
      return false;
    }
    
    if (start.isBefore(DateTime.now().subtract(const Duration(days: 30)))) {
      debugPrint('Warning: Exam period starts in the past');
    }
    
    return true;
  }

  /// Check for overlapping exam periods
  bool hasOverlap(List<ExamPeriod> periods, ExamPeriod newPeriod) {
    for (var period in periods) {
      if (period.id == newPeriod.id) continue; // Skip self when updating
      
      if (newPeriod.startDate.isBefore(period.endDate) &&
          newPeriod.endDate.isAfter(period.startDate)) {
        debugPrint('Error: Overlapping exam period detected with ${period.name}');
        return true;
      }
    }
    return false;
  }

  /// Generate exam schedule conflicts check
  List<ExamSchedule> findConflicts(
    List<ExamSchedule> existingSchedules,
    ExamSchedule newSchedule,
  ) {
    final conflicts = <ExamSchedule>[];
    
    for (var schedule in existingSchedules) {
      if (schedule.id == newSchedule.id) continue;
      
      // Same class, same time
      if (schedule.classGroupId == newSchedule.classGroupId &&
          schedule.date == newSchedule.date &&
          schedule.startTime.isBefore(newSchedule.endTime) &&
          schedule.endTime.isAfter(newSchedule.startTime)) {
        conflicts.add(schedule);
      }
      
      // Same teacher, same time
      if (schedule.teacherId == newSchedule.teacherId &&
          schedule.date == newSchedule.date &&
          schedule.startTime.isBefore(newSchedule.endTime) &&
          schedule.endTime.isAfter(newSchedule.startTime)) {
        conflicts.add(schedule);
      }
      
      // Same room, same time
      if (schedule.room != null &&
          newSchedule.room != null &&
          schedule.room == newSchedule.room &&
          schedule.date == newSchedule.date &&
          schedule.startTime.isBefore(newSchedule.endTime) &&
          schedule.endTime.isAfter(newSchedule.startTime)) {
        conflicts.add(schedule);
      }
    }
    
    return conflicts;
  }

  /// Calculate final grade based on Indonesian grading system
  String calculateGrade(double percentage) {
    if (percentage >= 90) return 'A (Sangat Baik)';
    if (percentage >= 80) return 'B (Baik)';
    if (percentage >= 70) return 'C (Cukup)';
    if (percentage >= 60) return 'D (Kurang)';
    return 'E (Sangat Kurang)';
  }

  /// Determine if student needs remedial
  bool needsRemedial(double percentage, {double threshold = 75.0}) {
    return percentage < threshold;
  }

  /// Generate report card for a student
  Future<ReportCard> generateReportCard({
    required String studentId,
    required String studentName,
    required String classGroupId,
    required String className,
    required String semester,
    required String academicYear,
    required List<StudentExamResult> results,
    Map<String, String>? teacherComments,
    String? principalName,
    String? homeroomTeacherName,
  }) async {
    // Group results by subject
    final subjectResults = <String, List<StudentExamResult>>{};
    for (var result in results) {
      if (!subjectResults.containsKey(result.subjectName)) {
        subjectResults[result.subjectName] = [];
      }
      subjectResults[result.subjectName]!.add(result);
    }

    // Calculate subject averages
    final reportSubjects = <ReportCardSubject>[];
    double totalScore = 0;
    int subjectCount = 0;

    for (var entry in subjectResults.entries) {
      final scores = entry.value.map((r) => r.score).toList();
      final avgScore = scores.reduce((a, b) => a + b) / scores.length;
      
      reportSubjects.add(ReportCardSubject(
        subjectName: entry.key,
        score: avgScore,
        grade: calculateGrade(avgScore),
        predicate: _getPredicate(avgScore),
        teacherComment: teacherComments?[entry.key] ?? '',
      ));
      
      totalScore += avgScore;
      subjectCount++;
    }

    final overallAverage = totalScore / subjectCount;
    
    return ReportCard(
      id: 'rc_${studentId}_$semester_$academicYear',
      studentId: studentId,
      studentName: studentName,
      classGroupId: classGroupId,
      className: className,
      semester: semester,
      academicYear: academicYear,
      subjects: reportSubjects,
      overallAverage: overallAverage,
      overallGrade: calculateGrade(overallAverage),
      overallPredicate: _getPredicate(overallAverage),
      attendance: AttendanceSummary(
        present: 0, // To be filled from attendance module
        sick: 0,
        permission: 0,
        withoutInfo: 0,
      ),
      behavior: BehaviorAssessment(
        spiritual: '', // To be filled from assessment module
        social: '',
      ),
      extracurriculars: [], // To be filled from extracurricular module
      homeroomTeacherNote: '',
      principalNote: '',
      issueDate: DateTime.now(),
      parentSignature: null,
      teacherSignature: null,
    );
  }

  /// Get predicate from score (Kurikulum Merdeka)
  String _getPredicate(double score) {
    if (score >= 90) return 'Sangat Baik';
    if (score >= 80) return 'Baik';
    if (score >= 70) return 'Cukup';
    if (score >= 60) return 'Kurang';
    return 'Sangat Kurang';
  }

  /// Prepare bulk result entry for a class
  List<StudentExamResult> prepareBulkEntry({
    required String examScheduleId,
    required String classGroupId,
    required List<Map<String, dynamic>> students,
    double maxScore = 100,
  }) {
    return students.map((student) {
      return StudentExamResult(
        id: 'result_${examScheduleId}_${student['studentId']}',
        examScheduleId: examScheduleId,
        studentId: student['studentId'] as String,
        studentName: student['studentName'] as String,
        classGroupId: classGroupId,
        subjectId: student['subjectId'] as String? ?? '',
        subjectName: student['subjectName'] as String,
        score: 0, // Initialize with 0, to be filled by teacher
        maxScore: maxScore,
        percentage: 0,
        grade: 'E',
        isPresent: true,
        isRemedial: false,
        notes: '',
        submittedAt: null,
        gradedAt: null,
        gradedBy: null,
      );
    }).toList();
  }

  /// Validate question bank data
  bool validateQuestion(QuestionBank question) {
    if (question.questionText.trim().isEmpty) {
      debugPrint('Error: Question text cannot be empty');
      return false;
    }
    
    if (question.options.isEmpty && question.questionType == QuestionType.multipleChoice) {
      debugPrint('Error: Multiple choice questions must have options');
      return false;
    }
    
    if (question.correctAnswer == null || question.correctAnswer!.trim().isEmpty) {
      debugPrint('Error: Correct answer must be provided');
      return false;
    }
    
    return true;
  }

  /// Import exam results from CSV/Excel
  Future<List<StudentExamResult>> importResultsFromFile(
    String filePath,
    String examScheduleId,
  ) async {
    // This would integrate with a file picker and CSV parser
    // Placeholder for implementation
    debugPrint('Import results from: $filePath');
    return [];
  }

  /// Export exam results to various formats
  Future<void> exportResults({
    required List<StudentExamResult> results,
    required ExportFormat format,
    required String outputPath,
  }) async {
    await exportService.exportResults(
      results: results,
      format: format,
      outputPath: outputPath,
    );
  }

  /// Export report card to PDF
  Future<void> exportReportCard({
    required ReportCard reportCard,
    required String outputPath,
    Map<String, dynamic>? schoolInfo,
  }) async {
    await exportService.generateReportCardPDF(
      reportCard: reportCard,
      outputPath: outputPath,
      schoolInfo: schoolInfo,
    );
  }
}
