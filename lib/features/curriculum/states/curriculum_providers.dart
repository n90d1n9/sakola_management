import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/curriculum_map.dart';
import '../models/lesson_plan.dart';
import '../services/curriculum_service.dart';

// ==================== STATE CLASSES ====================

/// State for Curriculum management
class CurriculumState {
  final List<CurriculumMap> curriculumMaps;
  final List<LessonPlan> lessonPlans;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? statistics;

  CurriculumState({
    this.curriculumMaps = const [],
    this.lessonPlans = const [],
    this.isLoading = false,
    this.error,
    this.statistics,
  });

  CurriculumState copyWith({
    List<CurriculumMap>? curriculumMaps,
    List<LessonPlan>? lessonPlans,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? statistics,
  }) {
    return CurriculumState(
      curriculumMaps: curriculumMaps ?? this.curriculumMaps,
      lessonPlans: lessonPlans ?? this.lessonPlans,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      statistics: statistics ?? this.statistics,
    );
  }
}

// ==================== NOTIFIER ====================

/// Notifier for Curriculum state management
class CurriculumNotifier extends StateNotifier<CurriculumState> {
  final CurriculumService _service = CurriculumService();

  CurriculumNotifier() : super(CurriculumState());

  /// Initialize and load all data
  Future<void> init() async {
    state = state.copyWith(isLoading: true);
    try {
      await _service.init();
      await loadAllData();
      await loadStatistics();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Load all curriculum maps and lesson plans
  Future<void> loadAllData() async {
    try {
      final maps = await _service.getAllCurriculumMaps();
      final plans = await _service.getAllLessonPlans();
      state = state.copyWith(
        curriculumMaps: maps,
        lessonPlans: plans,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Load statistics
  Future<void> loadStatistics() async {
    try {
      final stats = await _service.getCurriculumStats();
      state = state.copyWith(statistics: stats);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // ==================== CURRICULUM MAP OPERATIONS ====================

  /// Create new curriculum map
  Future<void> createCurriculumMap(CurriculumMap map) async {
    state = state.copyWith(isLoading: true);
    try {
      await _service.createCurriculumMap(map);
      await loadAllData();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Update curriculum map
  Future<void> updateCurriculumMap(CurriculumMap map) async {
    state = state.copyWith(isLoading: true);
    try {
      await _service.updateCurriculumMap(map);
      await loadAllData();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Delete curriculum map
  Future<void> deleteCurriculumMap(String id) async {
    state = state.copyWith(isLoading: true);
    try {
      await _service.deleteCurriculumMap(id);
      await loadAllData();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Search curriculum maps
  Future<void> searchCurriculumMaps(String query) async {
    state = state.copyWith(isLoading: true);
    try {
      final results = await _service.searchCurriculumMaps(query);
      state = state.copyWith(
        curriculumMaps: results,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Get curriculum maps by academic year
  Future<void> getCurriculumMapsByYear(String academicYear) async {
    state = state.copyWith(isLoading: true);
    try {
      final results = await _service.getCurriculumMapsByYear(academicYear);
      state = state.copyWith(
        curriculumMaps: results,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Get active curriculum
  Future<CurriculumMap?> getActiveCurriculum() async {
    return await _service.getActiveCurriculum();
  }

  // ==================== LESSON PLAN OPERATIONS ====================

  /// Create new lesson plan
  Future<void> createLessonPlan(LessonPlan plan) async {
    state = state.copyWith(isLoading: true);
    try {
      await _service.createLessonPlan(plan);
      await loadAllData();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Update lesson plan
  Future<void> updateLessonPlan(LessonPlan plan) async {
    state = state.copyWith(isLoading: true);
    try {
      await _service.updateLessonPlan(plan);
      await loadAllData();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Delete lesson plan
  Future<void> deleteLessonPlan(String id) async {
    state = state.copyWith(isLoading: true);
    try {
      await _service.deleteLessonPlan(id);
      await loadAllData();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Get lesson plans by teacher
  Future<void> getLessonPlansByTeacher(String teacherId) async {
    state = state.copyWith(isLoading: true);
    try {
      final results = await _service.getLessonPlansByTeacher(teacherId);
      state = state.copyWith(
        lessonPlans: results,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Get lesson plans by subject
  Future<void> getLessonPlansBySubject(String subjectId) async {
    state = state.copyWith(isLoading: true);
    try {
      final results = await _service.getLessonPlansBySubject(subjectId);
      state = state.copyWith(
        lessonPlans: results,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Search lesson plans
  Future<void> searchLessonPlans(String query) async {
    state = state.copyWith(isLoading: true);
    try {
      final results = await _service.searchLessonPlans(query);
      state = state.copyWith(
        lessonPlans: results,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// ==================== PROVIDERS ====================

/// Provider for CurriculumNotifier
final curriculumProvider = StateNotifierProvider<CurriculumNotifier, CurriculumState>(
  (ref) => CurriculumNotifier(),
);

/// Provider for filtered curriculum maps
final filteredCurriculumMapsProvider = Provider<List<CurriculumMap>>((ref) {
  final state = ref.watch(curriculumProvider);
  return state.curriculumMaps;
});

/// Provider for filtered lesson plans
final filteredLessonPlansProvider = Provider<List<LessonPlan>>((ref) {
  final state = ref.watch(curriculumProvider);
  return state.lessonPlans;
});

/// Provider for curriculum statistics
final curriculumStatsProvider = Provider<Map<String, dynamic>?>((ref) {
  final state = ref.watch(curriculumProvider);
  return state.statistics;
});

/// Provider for active curriculum
final activeCurriculumProvider = FutureProvider<CurriculumMap?>((ref) async {
  final notifier = ref.read(curriculumProvider.notifier);
  return await notifier.getActiveCurriculum();
});
