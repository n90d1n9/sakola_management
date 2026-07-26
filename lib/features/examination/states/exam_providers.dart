import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sembast/sembast.dart';
import '../../../services/local_database/local_storage_service.dart';
import '../models/exam_period.dart';
import '../models/exam_schedule.dart';
import '../models/exam_result.dart';
import '../models/report_card.dart';

class ExamPeriodNotifier extends StateNotifier<List<ExamPeriod>> {
  static const String storeName = 'exam_periods';

  ExamPeriodNotifier() : super([]);

  Future<void> loadExamPeriods() async {
    try {
      final db = await LocalDBService.instance.getDatabase();
      final store = intMapStoreFactory.store(storeName);
      final records = await store.find(db);
      state = records
          .map((e) => ExamPeriod.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading exam periods: $e');
    }
  }

  Future<void> addExamPeriod(ExamPeriod period) async {
    try {
      final db = await LocalDBService.instance.getDatabase();
      final store = intMapStoreFactory.store(storeName);
      await store.record(period.id).put(db, period.toJson());
      await loadExamPeriods();
    } catch (e) {
      print('Error adding exam period: $e');
      rethrow;
    }
  }

  Future<void> updateExamPeriod(ExamPeriod period) async {
    try {
      final db = await LocalDBService.instance.getDatabase();
      final store = intMapStoreFactory.store(storeName);
      await store.record(period.id).put(db, period.toJson());
      await loadExamPeriods();
    } catch (e) {
      print('Error updating exam period: $e');
      rethrow;
    }
  }

  Future<void> deleteExamPeriod(String id) async {
    try {
      final db = await LocalDBService.instance.getDatabase();
      final store = intMapStoreFactory.store(storeName);
      await store.record(id).delete(db);
      await loadExamPeriods();
    } catch (e) {
      print('Error deleting exam period: $e');
      rethrow;
    }
  }

  List<ExamPeriod> getActivePeriods() {
    return state.where((p) => p.isActive).toList();
  }

  ExamPeriod? getCurrentPeriod() {
    final now = DateTime.now();
    if (state.isEmpty) return null;
    return state.firstWhere(
      (p) => p.isActive && now.isAfter(p.startDate) && now.isBefore(p.endDate),
      orElse: () => state.firstWhere((p) => p.isActive, orElse: () => state[0]),
    );
  }
}

class ExamScheduleNotifier extends StateNotifier<List<ExamSchedule>> {
  static const String storeName = 'exam_schedules';

  ExamScheduleNotifier() : super([]);

  Future<void> loadExamSchedules({String? examPeriodId}) async {
    try {
      final db = await LocalDBService.instance.getDatabase();
      final store = intMapStoreFactory.store(storeName);
      var records = await store.find(db);
      
      if (examPeriodId != null) {
        records = records.where((e) => e['examPeriodId'] == examPeriodId).toList();
      }
      
      state = records
          .map((e) => ExamSchedule.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading exam schedules: $e');
    }
  }

  Future<void> addExamSchedule(ExamSchedule schedule) async {
    try {
      final db = await LocalDBService.instance.getDatabase();
      final store = intMapStoreFactory.store(storeName);
      await store.record(schedule.id).put(db, schedule.toJson());
      await loadExamSchedules();
    } catch (e) {
      print('Error adding exam schedule: $e');
      rethrow;
    }
  }

  Future<void> updateExamSchedule(ExamSchedule schedule) async {
    try {
      final db = await LocalDBService.instance.getDatabase();
      final store = intMapStoreFactory.store(storeName);
      await store.record(schedule.id).put(db, schedule.toJson());
      await loadExamSchedules();
    } catch (e) {
      print('Error updating exam schedule: $e');
      rethrow;
    }
  }

  Future<void> deleteExamSchedule(String id) async {
    try {
      final db = await LocalDBService.instance.getDatabase();
      final store = intMapStoreFactory.store(storeName);
      await store.record(id).delete(db);
      await loadExamSchedules();
    } catch (e) {
      print('Error deleting exam schedule: $e');
      rethrow;
    }
  }

  List<ExamSchedule> getByClassGroup(String classGroupId) {
    return state.where((s) => s.classGroupId == classGroupId).toList();
  }

  List<ExamSchedule> getByTeacher(String teacherId) {
    return state.where((s) => s.teacherId == teacherId).toList();
  }

  List<ExamSchedule> getUpcomingExams() {
    final now = DateTime.now();
    return state
        .where((s) => s.date.isAfter(now))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }
}

class ExamResultNotifier extends StateNotifier<List<StudentExamResult>> {
  static const String storeName = 'exam_results';

  ExamResultNotifier() : super([]);

  Future<void> loadResults({String? examScheduleId, String? studentId}) async {
    try {
      final db = await LocalDBService.instance.getDatabase();
      final store = intMapStoreFactory.store(storeName);
      var records = await store.find(db);
      
      if (examScheduleId != null) {
        records = records.where((e) => e['examScheduleId'] == examScheduleId).toList();
      }
      
      if (studentId != null) {
        records = records.where((e) => e['studentId'] == studentId).toList();
      }
      
      state = records
          .map((e) => StudentExamResult.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading exam results: $e');
    }
  }

  Future<void> saveResult(StudentExamResult result) async {
    try {
      final db = await LocalDBService.instance.getDatabase();
      final store = intMapStoreFactory.store(storeName);
      await store.record(result.id).put(db, result.toJson());
      await loadResults();
    } catch (e) {
      print('Error saving exam result: $e');
      rethrow;
    }
  }

  Future<void> bulkSaveResults(List<StudentExamResult> results) async {
    try {
      final db = await LocalDBService.instance.getDatabase();
      final store = intMapStoreFactory.store(storeName);
      final batch = store.batch();
      
      for (var result in results) {
        batch.put(result.id, result.toJson());
      }
      
      await batch.commit(db);
      await loadResults();
    } catch (e) {
      print('Error bulk saving exam results: $e');
      rethrow;
    }
  }

  List<StudentExamResult> getByStudent(String studentId) {
    return state.where((r) => r.studentId == studentId).toList();
  }

  List<StudentExamResult> getByExam(String examScheduleId) {
    return state.where((r) => r.examScheduleId == examScheduleId).toList();
  }

  ClassExamStatistics calculateStatistics(String examScheduleId) {
    final results = getByExam(examScheduleId);
    
    if (results.isEmpty) {
      return ClassExamStatistics(
        examScheduleId: examScheduleId,
        classGroupId: '',
        totalStudents: 0,
        presentStudents: 0,
        averageScore: 0,
        highestScore: 0,
        lowestScore: 0,
        standardDeviation: 0,
        studentsPassed: 0,
        studentsFailed: 0,
        studentsRemedial: 0,
        gradeDistribution: {},
      );
    }

    final scores = results.map((r) => r.score).toList();
    final avg = scores.reduce((a, b) => a + b) / scores.length;
    final max = scores.reduce((a, b) => a > b ? a : b);
    final min = scores.reduce((a, b) => a < b ? a : b);
    
    final variance = scores.map((s) => (s - avg) * (s - avg)).reduce((a, b) => a + b) / scores.length;
    final stdDev = _sqrt(variance);

    final passed = results.where((r) => r.percentage >= 75).length;
    final failed = results.where((r) => r.percentage < 75 && !r.isRemedial).length;
    final remedial = results.where((r) => r.isRemedial).length;

    final gradeDist = <String, int>{};
    for (var r in results) {
      final grade = r.grade ?? 'Unknown';
      gradeDist[grade] = (gradeDist[grade] ?? 0) + 1;
    }

    return ClassExamStatistics(
      examScheduleId: examScheduleId,
      classGroupId: results.first.classGroupId,
      totalStudents: results.length,
      presentStudents: results.length,
      averageScore: avg,
      highestScore: max,
      lowestScore: min,
      standardDeviation: stdDev,
      studentsPassed: passed,
      studentsFailed: failed,
      studentsRemedial: remedial,
      gradeDistribution: gradeDist,
    );
  }

  double _sqrt(double value) {
    if (value < 0) return double.nan;
    if (value == 0) return 0;
    
    double guess = value / 2;
    for (int i = 0; i < 10; i++) {
      guess = (guess + value / guess) / 2;
    }
    return guess;
  }
}

// Provider definitions
final examPeriodProvider = StateNotifierProvider<ExamPeriodNotifier, List<ExamPeriod>>((ref) {
  return ExamPeriodNotifier();
});

final examScheduleProvider = StateNotifierProvider<ExamScheduleNotifier, List<ExamSchedule>>((ref) {
  return ExamScheduleNotifier();
});

final examResultProvider = StateNotifierProvider<ExamResultNotifier, List<StudentExamResult>>((ref) {
  return ExamResultNotifier();
});
