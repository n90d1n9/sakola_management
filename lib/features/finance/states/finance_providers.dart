import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sembast/sembast.dart';
import '../../../services/local_database/local_storage_service.dart';
import '../models/fee_structure.dart';
import '../models/invoice.dart';

/// Fee Structure Provider
class FeeStructureNotifier extends StateNotifier<List<FeeStructure>> {
  static const String storeName = 'fee_structures';
  
  FeeStructureNotifier() : super([]);

  Future<void> loadFeeStructures({String? academicYear}) async {
    try {
      final db = await LocalDBService.instance.getDatabase();
      final store = intMapStoreFactory.store(storeName);
      var records = await store.find(db);
      
      if (academicYear != null) {
        records = records.where((e) => e['academicYear'] == academicYear).toList();
      }
      
      state = records
          .map((e) => FeeStructure.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading fee structures: $e');
    }
  }

  Future<void> addFeeStructure(FeeStructure fee) async {
    try {
      final db = await LocalDBService.instance.getDatabase();
      final store = intMapStoreFactory.store(storeName);
      await store.record(fee.id).put(db, fee.toJson());
      await loadFeeStructures();
    } catch (e) {
      print('Error adding fee structure: $e');
      rethrow;
    }
  }

  Future<void> updateFeeStructure(FeeStructure fee) async {
    try {
      final db = await LocalDBService.instance.getDatabase();
      final store = intMapStoreFactory.store(storeName);
      await store.record(fee.id).put(db, fee.toJson());
      await loadFeeStructures();
    } catch (e) {
      print('Error updating fee structure: $e');
      rethrow;
    }
  }

  Future<void> deleteFeeStructure(String id) async {
    try {
      final db = await LocalDBService.instance.getDatabase();
      final store = intMapStoreFactory.store(storeName);
      await store.record(id).delete(db);
      await loadFeeStructures();
    } catch (e) {
      print('Error deleting fee structure: $e');
      rethrow;
    }
  }

  List<FeeStructure> getByType(FeeType type) {
    return state.where((f) => f.feeType == type).toList();
  }

  List<FeeStructure> getRecurring() {
    return state.where((f) => f.isRecurring).toList();
  }

  double calculateTotalForGrade(String gradeLevel) {
    return state
        .where((f) => f.applicableGrades.contains(gradeLevel))
        .fold(0, (sum, f) => sum + f.amount);
  }
}

/// Invoice Provider
class InvoiceNotifier extends StateNotifier<List<Invoice>> {
  static const String storeName = 'invoices';
  
  InvoiceNotifier() : super([]);

  Future<void> loadInvoices({String? studentId, String? status}) async {
    try {
      final db = await LocalDBService.instance.getDatabase();
      final store = intMapStoreFactory.store(storeName);
      var records = await store.find(db);
      
      if (studentId != null) {
        records = records.where((e) => e['studentId'] == studentId).toList();
      }
      
      if (status != null) {
        records = records.where((e) => e['status'] == status).toList();
      }
      
      state = records
          .map((e) => Invoice.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading invoices: $e');
    }
  }

  Future<void> addInvoice(Invoice invoice) async {
    try {
      final db = await LocalDBService.instance.getDatabase();
      final store = intMapStoreFactory.store(storeName);
      await store.record(invoice.id).put(db, invoice.toJson());
      await loadInvoices();
    } catch (e) {
      print('Error adding invoice: $e');
      rethrow;
    }
  }

  Future<void> updateInvoice(Invoice invoice) async {
    try {
      final db = await LocalDBService.instance.getDatabase();
      final store = intMapStoreFactory.store(storeName);
      await store.record(invoice.id).put(db, invoice.toJson());
      await loadInvoices();
    } catch (e) {
      print('Error updating invoice: $e');
      rethrow;
    }
  }

  Future<void> deleteInvoice(String id) async {
    try {
      final db = await LocalDBService.instance.getDatabase();
      final store = intMapStoreFactory.store(storeName);
      await store.record(id).delete(db);
      await loadInvoices();
    } catch (e) {
      print('Error deleting invoice: $e');
      rethrow;
    }
  }

  List<Invoice> getByStudent(String studentId) {
    return state.where((i) => i.studentId == studentId).toList();
  }

  List<Invoice> getOverdue() {
    final now = DateTime.now();
    return state
        .where((i) => i.dueDate.isBefore(now) && i.status == InvoiceStatus.pending)
        .toList();
  }

  List<Invoice> getPending() {
    return state.where((i) => i.status == InvoiceStatus.pending).toList();
  }

  List<Invoice> getPaid() {
    return state.where((i) => i.status == InvoiceStatus.paid).toList();
  }

  double getTotalRevenue() {
    return getPaid().fold(0, (sum, i) => sum + i.totalAmount);
  }

  double getTotalPending() {
    return getPending().fold(0, (sum, i) => sum + i.totalAmount);
  }
}

/// Payment Provider
class PaymentNotifier extends StateNotifier<List<Payment>> {
  static const String storeName = 'payments';
  
  PaymentNotifier() : super([]);

  Future<void> loadPayments({String? invoiceId, String? studentId}) async {
    try {
      final db = await LocalDBService.instance.getDatabase();
      final store = intMapStoreFactory.store(storeName);
      var records = await store.find(db);
      
      if (invoiceId != null) {
        records = records.where((e) => e['invoiceId'] == invoiceId).toList();
      }
      
      if (studentId != null) {
        records = records.where((e) => e['studentId'] == studentId).toList();
      }
      
      state = records
          .map((e) => Payment.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading payments: $e');
    }
  }

  Future<void> addPayment(Payment payment) async {
    try {
      final db = await LocalDBService.instance.getDatabase();
      final store = intMapStoreFactory.store(storeName);
      await store.record(payment.id).put(db, payment.toJson());
      await loadPayments();
      
      // Update invoice status
      // This would be handled by a service layer in production
    } catch (e) {
      print('Error adding payment: $e');
      rethrow;
    }
  }

  Future<void> updatePayment(Payment payment) async {
    try {
      final db = await LocalDBService.instance.getDatabase();
      final store = intMapStoreFactory.store(storeName);
      await store.record(payment.id).put(db, payment.toJson());
      await loadPayments();
    } catch (e) {
      print('Error updating payment: $e');
      rethrow;
    }
  }

  List<Payment> getByInvoice(String invoiceId) {
    return state.where((p) => p.invoiceId == invoiceId).toList();
  }

  double getTotalPaidToday() {
    final today = DateTime.now();
    return state
        .where((p) => 
          p.paymentDate.year == today.year &&
          p.paymentDate.month == today.month &&
          p.paymentDate.day == today.day
        )
        .fold(0, (sum, p) => sum + p.amount);
  }
}

// Provider definitions
final feeStructureProvider = StateNotifierProvider<FeeStructureNotifier, List<FeeStructure>>((ref) {
  return FeeStructureNotifier();
});

final invoiceProvider = StateNotifierProvider<InvoiceNotifier, List<Invoice>>((ref) {
  return InvoiceNotifier();
});

final paymentProvider = StateNotifierProvider<PaymentNotifier, List<Payment>>((ref) {
  return PaymentNotifier();
});
