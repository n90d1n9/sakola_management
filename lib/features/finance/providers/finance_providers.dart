import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_helper.dart';
import '../services/finance_service.dart';
import '../models/fee_structure.dart';
import '../models/invoice.dart';

// ==================== PROVIDERS ====================

/// Provider for FinanceService
final financeServiceProvider = Provider<FinanceService>((ref) {
  final db = ref.watch(databaseProvider);
  return FinanceService(db);
});

/// Provider for FeeStructureNotifier
final feeStructureNotifierProvider = StateNotifierProvider<FeeStructureNotifier, List<FeeStructure>>((ref) {
  return FeeStructureNotifier(ref.watch(financeServiceProvider));
});

/// Provider for InvoiceNotifier
final invoiceNotifierProvider = StateNotifierProvider<InvoiceNotifier, List<Invoice>>((ref) {
  return InvoiceNotifier(ref.watch(financeServiceProvider));
});

/// Provider for PaymentNotifier
final paymentNotifierProvider = StateNotifierProvider<PaymentNotifier, List<Payment>>((ref) {
  return PaymentNotifier(ref.watch(financeServiceProvider));
});

/// Provider for Finance Statistics
final financeStatisticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(financeServiceProvider);
  final currentYear = DateTime.now().year.toString();
  return await service.getInvoiceStatistics(academicYear: currentYear);
});

// ==================== NOTIFIERS ====================

/// State notifier for managing Fee Structures
class FeeStructureNotifier extends StateNotifier<List<FeeStructure>> {
  final FinanceService _service;

  FeeStructureNotifier(this._service) : super([]);

  /// Load all fee structures with optional filters
  Future<void> loadFeeStructures({
    String? academicYear,
    FeeType? type,
    bool? isActive,
  }) async {
    state = []; // Clear current state
    final fees = await _service.getAllFeeStructures(
      academicYear: academicYear,
      type: type,
      isActive: isActive,
    );
    state = fees;
  }

  /// Add new fee structure
  Future<bool> addFeeStructure(FeeStructure fee) async {
    try {
      final newFee = await _service.createFeeStructure(fee);
      state = [...state, newFee];
      return true;
    } catch (e) {
      print('Error adding fee structure: $e');
      return false;
    }
  }

  /// Update existing fee structure
  Future<bool> updateFeeStructure(FeeStructure fee) async {
    if (fee.id == null) return false;
    
    try {
      final updated = await _service.updateFeeStructure(fee);
      if (updated != null) {
        state = state.map((f) => f.id == fee.id ? updated : f).toList();
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating fee structure: $e');
      return false;
    }
  }

  /// Delete fee structure
  Future<bool> deleteFeeStructure(String id) async {
    try {
      await _service.deleteFeeStructure(id);
      state = state.where((f) => f.id != id).toList();
      return true;
    } catch (e) {
      print('Error deleting fee structure: $e');
      return false;
    }
  }

  /// Get active fees for a specific grade
  Future<List<FeeStructure>> getActiveFeesForGrade(String gradeLevel) async {
    return await _service.getActiveFeesForGrade(gradeLevel);
  }
}

/// State notifier for managing Invoices
class InvoiceNotifier extends StateNotifier<List<Invoice>> {
  final FinanceService _service;

  InvoiceNotifier(this._service) : super([]);

  /// Load all invoices with optional filters
  Future<void> loadInvoices({
    String? studentId,
    InvoiceStatus? status,
    String? academicYear,
    DateTime? dueDateFrom,
    DateTime? dueDateTo,
  }) async {
    state = []; // Clear current state
    final invoices = await _service.getAllInvoices(
      studentId: studentId,
      status: status,
      academicYear: academicYear,
      dueDateFrom: dueDateFrom,
      dueDateTo: dueDateTo,
    );
    state = invoices;
  }

  /// Generate new invoice
  Future<Invoice?> generateInvoice(Invoice invoice) async {
    try {
      final newInvoice = await _service.generateInvoice(invoice);
      state = [...state, newInvoice];
      return newInvoice;
    } catch (e) {
      print('Error generating invoice: $e');
      return null;
    }
  }

  /// Update invoice status
  Future<bool> updateInvoiceStatus(String id, InvoiceStatus status) async {
    try {
      final updated = await _service.updateInvoiceStatus(id, status);
      if (updated != null) {
        state = state.map((i) => i.id == id ? updated : i).toList();
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating invoice status: $e');
      return false;
    }
  }

  /// Add payment to invoice
  Future<Invoice?> addPayment(String invoiceId, Payment payment) async {
    try {
      final updated = await _service.addPaymentToInvoice(invoiceId, payment);
      if (updated != null) {
        state = state.map((i) => i.id == invoiceId ? updated : i).toList();
        return updated;
      }
      return null;
    } catch (e) {
      print('Error adding payment: $e');
      return null;
    }
  }

  /// Delete invoice
  Future<bool> deleteInvoice(String id) async {
    try {
      await _service.deleteInvoice(id);
      state = state.where((i) => i.id != id).toList();
      return true;
    } catch (e) {
      print('Error deleting invoice: $e');
      return false;
    }
  }

  /// Get invoices for a specific student
  List<Invoice> getInvoicesByStudent(String studentId) {
    return state.where((i) => i.studentId == studentId).toList();
  }

  /// Get overdue invoices
  List<Invoice> getOverdueInvoices() {
    final now = DateTime.now();
    return state.where((i) => 
      i.status != InvoiceStatus.paid && 
      i.dueDate.isBefore(now)
    ).toList();
  }
}

/// State notifier for managing Payments
class PaymentNotifier extends StateNotifier<List<Payment>> {
  final FinanceService _service;

  PaymentNotifier(this._service) : super([]);

  /// Load all payments with optional filters
  Future<void> loadPayments({
    String? invoiceId,
    String? studentId,
    PaymentMethod? method,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    state = []; // Clear current state
    final payments = await _service.getAllPayments(
      invoiceId: invoiceId,
      studentId: studentId,
      method: method,
      dateFrom: dateFrom,
      dateTo: dateTo,
    );
    state = payments;
  }

  /// Record new payment
  Future<bool> recordPayment(Payment payment) async {
    try {
      final newPayment = await _service.recordPayment(payment);
      state = [...state, newPayment];
      return true;
    } catch (e) {
      print('Error recording payment: $e');
      return false;
    }
  }

  /// Get payments by student
  List<Payment> getPaymentsByStudent(String studentId) {
    return state.where((p) => p.studentId == studentId).toList();
  }

  /// Get total payments for current month
  double getCurrentMonthTotal() {
    final now = DateTime.now();
    final currentMonthPayments = state.where((p) => 
      p.paymentDate.year == now.year && 
      p.paymentDate.month == now.month
    );
    
    return currentMonthPayments.fold<double>(
      0, 
      (sum, p) => sum + p.amount
    );
  }

  /// Get payment statistics
  Map<String, dynamic> getPaymentStatistics() {
    final totalAmount = state.fold<double>(0, (sum, p) => sum + p.amount);
    
    final byMethod = <String, double>{};
    for (var payment in state) {
      byMethod[payment.method.name] = (byMethod[payment.method.name] ?? 0) + payment.amount;
    }

    return {
      'totalPayments': state.length,
      'totalAmount': totalAmount,
      'byMethod': byMethod,
    };
  }
}
