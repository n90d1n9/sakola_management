import 'package:sembast/sembast.dart';
import '../models/admission.dart';

/// Service layer for Admission module
/// Handles all database operations for student admissions
class AdmissionService {
  final Database _db;
  final StoreRef<String, Map<String, dynamic>> _admissionStore = 
      stringMapStoreFactory.store('admissions');

  AdmissionService(this._db);

  // ==================== ADMISSION OPERATIONS ====================

  /// Get all admissions with optional filters
  Future<List<Admission>> getAllAdmissions({
    String? academicYear,
    AdmissionStatus? status,
    String? applyingForGrade,
  }) async {
    var finder = Finder(
      sortOrders: [SortOrder(AdmissionFields.applicationDate, descending: true)],
    );

    final filters = <Filter>[];
    if (academicYear != null) {
      filters.add(Filter.equals(AdmissionFields.academicYear, academicYear));
    }
    if (status != null) {
      filters.add(Filter.equals(AdmissionFields.status, status.name));
    }
    if (applyingForGrade != null) {
      filters.add(Filter.equals(AdmissionFields.applyingForGrade, applyingForGrade));
    }

    if (filters.isNotEmpty) {
      finder = finder.copyWith(filter: Filter.and(filters));
    }

    final records = await _admissionStore.find(_db, finder: finder);
    return records.map((rec) => Admission.fromMap(rec.value)).toList();
  }

  /// Get admission by ID
  Future<Admission?> getAdmissionById(String id) async {
    final record = await _admissionStore.record(id).get(_db);
    return record != null ? Admission.fromMap(record) : null;
  }

  /// Get admission by application number
  Future<Admission?> getAdmissionByApplicationNumber(String appNumber) async {
    final finder = Finder(
      filter: Filter.equals(AdmissionFields.applicationNumber, appNumber),
    );
    final records = await _admissionStore.find(_db, finder: finder);
    return records.isNotEmpty ? Admission.fromMap(records.first.value) : null;
  }

  /// Create new admission application
  Future<Admission> createAdmission(Admission admission) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final newAdmission = admission.copyWith(
      id: id,
      applicationNumber: _generateApplicationNumber(admission.academicYear),
    );
    await _admissionStore.record(id).put(_db, newAdmission.toMap());
    return newAdmission;
  }

  /// Generate application number format: PPDB/YYYY/XXXX
  String _generateApplicationNumber(String academicYear) {
    final now = DateTime.now();
    final sequence = now.millisecondsSinceEpoch.toString().substring(8);
    return 'PPDB/$academicYear/$sequence';
  }

  /// Update admission application
  Future<Admission?> updateAdmission(Admission admission) async {
    if (admission.id == null) return null;
    
    final updated = admission.copyWith(
      statusUpdatedDate: DateTime.now(),
    );
    
    await _admissionStore.record(admission.id!).put(_db, updated.toMap());
    return updated;
  }

  /// Update admission status
  Future<Admission?> updateAdmissionStatus(String id, AdmissionStatus status, {
    String? notes,
    String? assignedClass,
    double? selectionScore,
    String? selectionNotes,
  }) async {
    final admission = await getAdmissionById(id);
    if (admission == null) return null;

    final updated = admission.copyWith(
      status: status,
      notes: notes ?? admission.notes,
      assignedClass: assignedClass ?? admission.assignedClass,
      selectionScore: selectionScore ?? admission.selectionScore,
      selectionNotes: selectionNotes ?? admission.selectionNotes,
      selectionDate: status == AdmissionStatus.tested ? DateTime.now() : admission.selectionDate,
      statusUpdatedDate: DateTime.now(),
    );

    await _admissionStore.record(id).put(_db, updated.toMap());
    return updated;
  }

  /// Delete admission
  Future<void> deleteAdmission(String id) async {
    await _admissionStore.record(id).delete(_db);
  }

  /// Get admission statistics
  Future<Map<String, dynamic>> getAdmissionStatistics({
    required String academicYear,
  }) async {
    final admissions = await getAllAdmissions(academicYear: academicYear);
    
    final totalApplications = admissions.length;
    final registeredCount = admissions.where((a) => a.status == AdmissionStatus.registered).length;
    final verifiedCount = admissions.where((a) => a.status == AdmissionStatus.verified).length;
    final testedCount = admissions.where((a) => a.status == AdmissionStatus.tested).length;
    final acceptedCount = admissions.where((a) => a.status == AdmissionStatus.accepted).length;
    final rejectedCount = admissions.where((a) => a.status == AdmissionStatus.rejected).length;
    final waitlistedCount = admissions.where((a) => a.status == AdmissionStatus.waitlisted).length;
    final enrolledCount = admissions.where((a) => a.status == AdmissionStatus.enrolled).length;

    // Calculate acceptance rate
    final acceptanceRate = totalApplications > 0 
        ? (acceptedCount / totalApplications * 100) 
        : 0.0;

    // Group by grade level
    final byGrade = <String, int>{};
    for (var admission in admissions) {
      byGrade[admission.applyingForGrade] = (byGrade[admission.applyingForGrade] ?? 0) + 1;
    }

    // Group by status
    final byStatus = <String, int>{};
    for (var admission in admissions) {
      byStatus[admission.status.label] = (byStatus[admission.status.label] ?? 0) + 1;
    }

    return {
      'totalApplications': totalApplications,
      'registeredCount': registeredCount,
      'verifiedCount': verifiedCount,
      'testedCount': testedCount,
      'acceptedCount': acceptedCount,
      'rejectedCount': rejectedCount,
      'waitlistedCount': waitlistedCount,
      'enrolledCount': enrolledCount,
      'acceptanceRate': acceptanceRate,
      'byGrade': byGrade,
      'byStatus': byStatus,
    };
  }

  /// Get pending admissions (not yet processed)
  Future<List<Admission>> getPendingAdmissions() async {
    final finder = Finder(
      filter: Filter.or([
        Filter.equals(AdmissionFields.status, AdmissionStatus.registered.name),
        Filter.equals(AdmissionFields.status, AdmissionStatus.verified.name),
      ]),
      sortOrders: [SortOrder(AdmissionFields.applicationDate)],
    );
    
    final records = await _admissionStore.find(_db, finder: finder);
    return records.map((rec) => Admission.fromMap(rec.value)).toList();
  }

  /// Get accepted admissions ready for enrollment
  Future<List<Admission>> getAcceptedForEnrollment() async {
    final finder = Finder(
      filter: Filter.equals(AdmissionFields.status, AdmissionStatus.accepted.name),
      sortOrders: [SortOrder(AdmissionFields.applicationDate)],
    );
    
    final records = await _admissionStore.find(_db, finder: finder);
    return records.map((rec) => Admission.fromMap(rec.value)).toList();
  }

  /// Search admissions by student name or application number
  Future<List<Admission>> searchAdmissions(String query) async {
    final allAdmissions = await getAllAdmissions();
    final queryLower = query.toLowerCase();
    
    return allAdmissions.where((a) => 
      a.studentName.toLowerCase().contains(queryLower) ||
      a.applicationNumber.toLowerCase().contains(queryLower)
    ).toList();
  }
}
