import 'package:sembast/sembast.dart';
import '../models/curriculum_map.dart';
import '../models/lesson_plan.dart';
import '../../../core/database/database_helper.dart';

/// Service layer for Curriculum Management
/// Handles Kurikulum Merdeka mapping, lesson plans (RPP/Modul Ajar)
class CurriculumService {
  static final CurriculumService _instance = CurriculumService._internal();
  factory CurriculumService() => _instance;
  CurriculumService._internal();

  late DatabaseHelper _dbHelper;
  static const String _curriculumMapStore = 'curriculum_maps';
  static const String _lessonPlanStore = 'lesson_plans';

  /// Initialize database stores
  Future<void> init() async {
    _dbHelper = await DatabaseHelper().database;
  }

  // ==================== CURRICULUM MAP CRUD ====================

  /// Create new curriculum map
  Future<CurriculumMap> createCurriculumMap(CurriculumMap map) async {
    await init();
    final store = StoreRef.main().store(_curriculumMapStore);
    final data = map.toJson();
    data['createdAt'] = DateTime.now().toIso8601String();
    data['updatedAt'] = DateTime.now().toIso8601String();
    await store.record(map.id).put(data);
    return map;
  }

  /// Get all curriculum maps
  Future<List<CurriculumMap>> getAllCurriculumMaps() async {
    await init();
    final store = StoreRef.main().store(_curriculumMapStore);
    final records = await store.find();
    return records
        .map((record) => CurriculumMap.fromJson(record.value as Map<String, dynamic>))
        .toList();
  }

  /// Get curriculum map by ID
  Future<CurriculumMap?> getCurriculumMapById(String id) async {
    await init();
    final store = StoreRef.main().store(_curriculumMapStore);
    final record = await store.record(id).get();
    if (record == null) return null;
    return CurriculumMap.fromJson(record as Map<String, dynamic>);
  }

  /// Update curriculum map
  Future<CurriculumMap> updateCurriculumMap(CurriculumMap map) async {
    await init();
    final store = StoreRef.main().store(_curriculumMapStore);
    final data = map.toJson();
    data['updatedAt'] = DateTime.now().toIso8601String();
    await store.record(map.id).update(data);
    return map;
  }

  /// Delete curriculum map
  Future<void> deleteCurriculumMap(String id) async {
    await init();
    final store = StoreRef.main().store(_curriculumMapStore);
    await store.record(id).delete();
  }

  /// Search curriculum maps by name or subject
  Future<List<CurriculumMap>> searchCurriculumMaps(String query) async {
    await init();
    final store = StoreRef.main().store(_curriculumMapStore);
    final records = await store.find();
    
    final lowercaseQuery = query.toLowerCase();
    return records
        .where((record) {
          final data = record.value as Map<String, dynamic>;
          final name = (data['name'] ?? '').toString().toLowerCase();
          final academicYear = (data['academicYear'] ?? '').toString().toLowerCase();
          return name.contains(lowercaseQuery) || 
                 academicYear.contains(lowercaseQuery);
        })
        .map((record) => CurriculumMap.fromJson(record.value as Map<String, dynamic>))
        .toList();
  }

  /// Get curriculum maps by academic year
  Future<List<CurriculumMap>> getCurriculumMapsByYear(String academicYear) async {
    await init();
    final store = StoreRef.main().store(_curriculumMapStore);
    final records = await store.find();
    return records
        .where((record) {
          final data = record.value as Map<String, dynamic>;
          return data['academicYear'] == academicYear;
        })
        .map((record) => CurriculumMap.fromJson(record.value as Map<String, dynamic>))
        .toList();
  }

  /// Get active curriculum (current academic year)
  Future<CurriculumMap?> getActiveCurriculum() async {
    final currentYear = '${DateTime.now().year}/${DateTime.now().year + 1}';
    final maps = await getCurriculumMapsByYear(currentYear);
    return maps.isNotEmpty ? maps.first : null;
  }

  // ==================== LESSON PLAN CRUD ====================

  /// Create new lesson plan (RPP/Modul Ajar)
  Future<LessonPlan> createLessonPlan(LessonPlan plan) async {
    await init();
    final store = StoreRef.main().store(_lessonPlanStore);
    final data = plan.toJson();
    data['createdAt'] = DateTime.now().toIso8601String();
    data['updatedAt'] = DateTime.now().toIso8601String();
    await store.record(plan.id).put(data);
    return plan;
  }

  /// Get all lesson plans
  Future<List<LessonPlan>> getAllLessonPlans() async {
    await init();
    final store = StoreRef.main().store(_lessonPlanStore);
    final records = await store.find();
    return records
        .map((record) => LessonPlan.fromJson(record.value as Map<String, dynamic>))
        .toList();
  }

  /// Get lesson plan by ID
  Future<LessonPlan?> getLessonPlanById(String id) async {
    await init();
    final store = StoreRef.main().store(_lessonPlanStore);
    final record = await store.record(id).get();
    if (record == null) return null;
    return LessonPlan.fromJson(record as Map<String, dynamic>);
  }

  /// Update lesson plan
  Future<LessonPlan> updateLessonPlan(LessonPlan plan) async {
    await init();
    final store = StoreRef.main().store(_lessonPlanStore);
    final data = plan.toJson();
    data['updatedAt'] = DateTime.now().toIso8601String();
    await store.record(plan.id).update(data);
    return plan;
  }

  /// Delete lesson plan
  Future<void> deleteLessonPlan(String id) async {
    await init();
    final store = StoreRef.main().store(_lessonPlanStore);
    await store.record(id).delete();
  }

  /// Get lesson plans by teacher
  Future<List<LessonPlan>> getLessonPlansByTeacher(String teacherId) async {
    await init();
    final store = StoreRef.main().store(_lessonPlanStore);
    final records = await store.find();
    return records
        .where((record) {
          final data = record.value as Map<String, dynamic>;
          return data['teacherId'] == teacherId;
        })
        .map((record) => LessonPlan.fromJson(record.value as Map<String, dynamic>))
        .toList();
  }

  /// Get lesson plans by subject
  Future<List<LessonPlan>> getLessonPlansBySubject(String subjectId) async {
    await init();
    final store = StoreRef.main().store(_lessonPlanStore);
    final records = await store.find();
    return records
        .where((record) {
          final data = record.value as Map<String, dynamic>;
          return data['subjectId'] == subjectId;
        })
        .map((record) => LessonPlan.fromJson(record.value as Map<String, dynamic>))
        .toList();
  }

  /// Get lesson plans by curriculum map
  Future<List<LessonPlan>> getLessonPlansByCurriculum(String curriculumId) async {
    await init();
    final store = StoreRef.main().store(_lessonPlanStore);
    final records = await store.find();
    return records
        .where((record) {
          final data = record.value as Map<String, dynamic>;
          return data['curriculumMapId'] == curriculumId;
        })
        .map((record) => LessonPlan.fromJson(record.value as Map<String, dynamic>))
        .toList();
  }

  /// Search lesson plans
  Future<List<LessonPlan>> searchLessonPlans(String query) async {
    await init();
    final store = StoreRef.main().store(_lessonPlanStore);
    final records = await store.find();
    
    final lowercaseQuery = query.toLowerCase();
    return records
        .where((record) {
          final data = record.value as Map<String, dynamic>;
          final title = (data['title'] ?? '').toString().toLowerCase();
          return title.contains(lowercaseQuery);
        })
        .map((record) => LessonPlan.fromJson(record.value as Map<String, dynamic>))
        .toList();
  }

  /// Get lesson plans for specific week
  Future<List<LessonPlan>> getLessonPlansByWeek(int weekNumber, String semester) async {
    await init();
    final store = StoreRef.main().store(_lessonPlanStore);
    final records = await store.find();
    return records
        .where((record) {
          final data = record.value as Map<String, dynamic>;
          return data['weekNumber'] == weekNumber && data['semester'] == semester;
        })
        .map((record) => LessonPlan.fromJson(record.value as Map<String, dynamic>))
        .toList();
  }

  // ==================== STATISTICS ====================

  /// Get curriculum statistics
  Future<Map<String, dynamic>> getCurriculumStats() async {
    final maps = await getAllCurriculumMaps();
    final plans = await getAllLessonPlans();
    
    return {
      'totalCurriculumMaps': maps.length,
      'totalLessonPlans': plans.length,
      'mapsByType': _groupByType(maps),
      'plansBySubject': _groupBySubject(plans),
    };
  }

  Map<String, int> _groupByType(List<CurriculumMap> maps) {
    final Map<String, int> result = {};
    for (var map in maps) {
      final type = map.type.toString().split('.').last;
      result[type] = (result[type] ?? 0) + 1;
    }
    return result;
  }

  Map<String, int> _groupBySubject(List<LessonPlan> plans) {
    final Map<String, int> result = {};
    for (var plan in plans) {
      final subject = plan.subjectName;
      result[subject] = (result[subject] ?? 0) + 1;
    }
    return result;
  }
}
