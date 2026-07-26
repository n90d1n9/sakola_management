import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_helper.dart';
import '../services/admission_service.dart';
import '../models/admission.dart';

// ==================== PROVIDERS ====================

/// Provider for AdmissionService
final admissionServiceProvider = Provider<AdmissionService>((ref) {
  final db = ref.watch(databaseProvider);
  return AdmissionService(db);
});

/// Provider for AdmissionNotifier
final admissionNotifierProvider = StateNotifierProvider<AdmissionNotifier, List<Admission>>((ref) {
  return AdmissionNotifier(ref.watch(admissionServiceProvider));
});

/// Provider for Admission Statistics
final admissionStatisticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(admissionServiceProvider);
  final currentYear = DateTime.now().year.toString();
  return await service.getAdmissionStatistics(academicYear: currentYear);
});

// ==================== NOTIFIER ====================

/// State notifier for managing Admissions
class AdmissionNotifier extends StateNotifier<List<Admission>> {
  final AdmissionService _service;

  AdmissionNotifier(this._service) : super([]);

  /// Load all admissions with optional filters
  Future<void> loadAdmissions({
    String? academicYear,
    AdmissionStatus? status,
    String? applyingForGrade,
  }) async {
    state = []; // Clear current state
    final admissions = await _service.getAllAdmissions(
      academicYear: academicYear,
      status: status,
      applyingForGrade: applyingForGrade,
    );
    state = admissions;
  }

  /// Create new admission application
  Future<Admission?> createAdmission(Admission admission) async {
    try {
      final newAdmission = await _service.createAdmission(admission);
      state = [...state, newAdmission];
      return newAdmission;
    } catch (e) {
      print('Error creating admission: $e');
      return null;
    }
  }

  /// Update admission
  Future<bool> updateAdmission(Admission admission) async {
    if (admission.id == null) return false;
    
    try {
      final updated = await _service.updateAdmission(admission);
      if (updated != null) {
        state = state.map((a) => a.id == admission.id ? updated : a).toList();
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating admission: $e');
      return false;
    }
  }

  /// Update admission status
  Future<bool> updateAdmissionStatus(
    String id, 
    AdmissionStatus status, {
    String? notes,
    String? assignedClass,
    double? selectionScore,
    String? selectionNotes,
  }) async {
    try {
      final updated = await _service.updateAdmissionStatus(
        id, 
        status,
        notes: notes,
        assignedClass: assignedClass,
        selectionScore: selectionScore,
        selectionNotes: selectionNotes,
      );
      if (updated != null) {
        state = state.map((a) => a.id == id ? updated : a).toList();
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating admission status: $e');
      return false;
    }
  }

  /// Delete admission
  Future<bool> deleteAdmission(String id) async {
    try {
      await _service.deleteAdmission(id);
      state = state.where((a) => a.id != id).toList();
      return true;
    } catch (e) {
      print('Error deleting admission: $e');
      return false;
    }
  }

  /// Get pending admissions count
  int getPendingCount() {
    return state.where((a) => 
      a.status == AdmissionStatus.registered || 
      a.status == AdmissionStatus.verified
    ).length;
  }

  /// Get accepted admissions
  List<Admission> getAcceptedAdmissions() {
    return state.where((a) => a.status == AdmissionStatus.accepted).toList();
  }

  /// Get enrolled admissions
  List<Admission> getEnrolledAdmissions() {
    return state.where((a) => a.status == AdmissionStatus.enrolled).toList();
  }

  /// Search admissions
  Future<List<Admission>> searchAdmissions(String query) async {
    if (query.isEmpty) {
      return state;
    }
    return await _service.searchAdmissions(query);
  }

  /// Get admission by ID
  Admission? getAdmissionById(String id) {
    return state.firstWhere((a) => a.id == id, orElse: () => throw Exception('Admission not found'));
  }
}
