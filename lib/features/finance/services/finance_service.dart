import 'package:sembast/sembast.dart';
import '../models/fee_structure.dart';
import '../models/invoice.dart';

/// Service layer for Finance module
/// Handles all database operations for fees, invoices, and payments
class FinanceService {
  final Database _db;
  final StoreRef<String, Map<String, dynamic>> _feeStore = 
      stringMapStoreFactory.store('fees');
  final StoreRef<String, Map<String, dynamic>> _invoiceStore = 
      stringMapStoreFactory.store('invoices');
  final StoreRef<String, Map<String, dynamic>> _paymentStore = 
      stringMapStoreFactory.store('payments');

  FinanceService(this._db);

  // ==================== FEE STRUCTURE OPERATIONS ====================

  /// Get all fee structures
  Future<List<FeeStructure>> getAllFeeStructures({
    String? academicYear,
    FeeType? type,
    bool? isActive,
  }) async {
    var finder = Finder(
      sortOrders: [SortOrder(FeeStructureFields.createdAt, descending: true)],
    );

    if (academicYear != null || type != null || isActive != null) {
      final filters = <Filter>[];
      if (academicYear != null) {
        filters.add(Filter.equals(FeeStructureFields.academicYear, academicYear));
      }
      if (type != null) {
        filters.add(Filter.equals(FeeStructureFields.type, type.name));
      }
      if (isActive != null) {
        filters.add(Filter.equals(FeeStructureFields.isActive, isActive));
      }
      finder = finder.copyWith(filter: Filter.and(filters));
    }

    final records = await _feeStore.find(_db, finder: finder);
    return records.map((rec) => FeeStructure.fromMap(rec.value)).toList();
  }

  /// Get fee structure by ID
  Future<FeeStructure?> getFeeStructureById(String id) async {
    final record = await _feeStore.record(id).get(_db);
    return record != null ? FeeStructure.fromMap(record) : null;
  }

  /// Create new fee structure
  Future<FeeStructure> createFeeStructure(FeeStructure fee) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final newFee = fee.copyWith(id: id);
    await _feeStore.record(id).put(_db, newFee.toMap());
    return newFee;
  }

  /// Update fee structure
  Future<FeeStructure?> updateFeeStructure(FeeStructure fee) async {
    if (fee.id == null) return null;
    await _feeStore.record(fee.id!).put(_db, fee.toMap());
    return fee;
  }

  /// Delete fee structure
  Future<void> deleteFeeStructure(String id) async {
    await _feeStore.record(id).delete(_db);
  }

  /// Get active fee structures for a grade level
  Future<List<FeeStructure>> getActiveFeesForGrade(String gradeLevel) async {
    final finder = Finder(
      filter: Filter.and([
        Filter.equals(FeeStructureFields.gradeLevel, gradeLevel),
        Filter.equals(FeeStructureFields.isActive, true),
      ]),
      sortOrders: [SortOrder(FeeStructureFields.createdAt)],
    );
    
    final records = await _feeStore.find(_db, finder: finder);
    return records.map((rec) => FeeStructure.fromMap(rec.value)).toList();
  }

  // ==================== INVOICE OPERATIONS ====================

  /// Get all invoices with optional filters
  Future<List<Invoice>> getAllInvoices({
    String? studentId,
    InvoiceStatus? status,
    String? academicYear,
    DateTime? dueDateFrom,
    DateTime? dueDateTo,
  }) async {
    var finder = Finder(
      sortOrders: [SortOrder(InvoiceFields.createdAt, descending: true)],
    );

    final filters = <Filter>[];
    if (studentId != null) {
      filters.add(Filter.equals(InvoiceFields.studentId, studentId));
    }
    if (status != null) {
      filters.add(Filter.equals(InvoiceFields.status, status.name));
    }
    if (academicYear != null) {
      filters.add(Filter.equals(InvoiceFields.academicYear, academicYear));
    }
    if (dueDateFrom != null) {
      filters.add(Filter.greaterThanOrEquals(InvoiceFields.dueDate, dueDateFrom.toIso8601String().substring(0, 10)));
    }
    if (dueDateTo != null) {
      filters.add(Filter.lessThanOrEquals(InvoiceFields.dueDate, dueDateTo.toIso8601String().substring(0, 10)));
    }

    if (filters.isNotEmpty) {
      finder = finder.copyWith(filter: Filter.and(filters));
    }

    final records = await _invoiceStore.find(_db, finder: finder);
    return records.map((rec) => Invoice.fromMap(rec.value)).toList();
  }

  /// Get invoice by ID
  Future<Invoice?> getInvoiceById(String id) async {
    final record = await _invoiceStore.record(id).get(_db);
    return record != null ? Invoice.fromMap(record) : null;
  }

  /// Generate new invoice for student
  Future<Invoice> generateInvoice(Invoice invoice) async {
    final id = 'INV-${DateTime.now().millisecondsSinceEpoch}';
    final newInvoice = invoice.copyWith(
      id: id,
      invoiceNumber: _generateInvoiceNumber(),
      status: InvoiceStatus.pending,
      createdAt: DateTime.now(),
    );
    
    await _invoiceStore.record(id).put(_db, newInvoice.toMap());
    
    // Also store payment records if any
    for (var payment in invoice.payments) {
      await _paymentStore.record(payment.id).put(_db, payment.toMap());
    }
    
    return newInvoice;
  }

  /// Generate invoice number format: INV/YYYYMM/XXXX
  String _generateInvoiceNumber() {
    final now = DateTime.now();
    final yearMonth = '${now.year}${now.month.toString().padLeft(2, '0')}';
    return 'INV/$yearMonth/${now.millisecondsSinceEpoch.toString().substring(8)}';
  }

  /// Update invoice status
  Future<Invoice?> updateInvoiceStatus(String id, InvoiceStatus status) async {
    final invoice = await getInvoiceById(id);
    if (invoice == null) return null;

    final updated = invoice.copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );
    
    await _invoiceStore.record(id).put(_db, updated.toMap());
    return updated;
  }

  /// Add payment to invoice
  Future<Invoice?> addPaymentToInvoice(String invoiceId, Payment payment) async {
    final invoice = await getInvoiceById(invoiceId);
    if (invoice == null) return null;

    final updatedPayments = [...invoice.payments, payment];
    final totalPaid = updatedPayments.fold<double>(
      0, 
      (sum, p) => sum + p.amount
    );

    InvoiceStatus newStatus;
    if (totalPaid >= invoice.totalAmount) {
      newStatus = InvoiceStatus.paid;
    } else if (totalPaid > 0) {
      newStatus = InvoiceStatus.partiallyPaid;
    } else {
      newStatus = InvoiceStatus.pending;
    }

    final updated = invoice.copyWith(
      payments: updatedPayments,
      totalPaid: totalPaid,
      balance: invoice.totalAmount - totalPaid,
      status: newStatus,
      updatedAt: DateTime.now(),
    );

    await _invoiceStore.record(invoiceId).put(_db, updated.toMap());
    await _paymentStore.record(payment.id).put(_db, payment.toMap());
    
    return updated;
  }

  /// Get invoice statistics
  Future<Map<String, dynamic>> getInvoiceStatistics({
    required String academicYear,
  }) async {
    final invoices = await getAllInvoices(academicYear: academicYear);
    
    final totalInvoices = invoices.length;
    final paidInvoices = invoices.where((i) => i.status == InvoiceStatus.paid).length;
    final pendingInvoices = invoices.where((i) => i.status == InvoiceStatus.pending).length;
    final partiallyPaidInvoices = invoices.where((i) => i.status == InvoiceStatus.partiallyPaid).length;
    final overdueInvoices = invoices.where((i) => 
      i.status != InvoiceStatus.paid && 
      i.dueDate.isBefore(DateTime.now())
    ).length;

    final totalRevenue = invoices.fold<double>(
      0, 
      (sum, i) => sum + i.totalPaid
    );
    
    final expectedRevenue = invoices.fold<double>(
      0, 
      (sum, i) => sum + i.totalAmount
    );

    return {
      'totalInvoices': totalInvoices,
      'paidInvoices': paidInvoices,
      'pendingInvoices': pendingInvoices,
      'partiallyPaidInvoices': partiallyPaidInvoices,
      'overdueInvoices': overdueInvoices,
      'totalRevenue': totalRevenue,
      'expectedRevenue': expectedRevenue,
      'collectionRate': expectedRevenue > 0 ? (totalRevenue / expectedRevenue * 100) : 0,
    };
  }

  /// Delete invoice
  Future<void> deleteInvoice(String id) async {
    final invoice = await getInvoiceById(id);
    if (invoice != null) {
      // Delete associated payments
      for (var payment in invoice.payments) {
        await _paymentStore.record(payment.id).delete(_db);
      }
      await _invoiceStore.record(id).delete(_db);
    }
  }

  // ==================== PAYMENT OPERATIONS ====================

  /// Get all payments
  Future<List<Payment>> getAllPayments({
    String? invoiceId,
    String? studentId,
    PaymentMethod? method,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    var finder = Finder(
      sortOrders: [SortOrder(PaymentFields.paymentDate, descending: true)],
    );

    final filters = <Filter>[];
    if (invoiceId != null) {
      filters.add(Filter.equals(PaymentFields.invoiceId, invoiceId));
    }
    if (studentId != null) {
      filters.add(Filter.equals(PaymentFields.studentId, studentId));
    }
    if (method != null) {
      filters.add(Filter.equals(PaymentFields.method, method.name));
    }
    if (dateFrom != null) {
      filters.add(Filter.greaterThanOrEquals(
        PaymentFields.paymentDate, 
        dateFrom.toIso8601String().substring(0, 10)
      ));
    }
    if (dateTo != null) {
      filters.add(Filter.lessThanOrEquals(
        PaymentFields.paymentDate, 
        dateTo.toIso8601String().substring(0, 10)
      ));
    }

    if (filters.isNotEmpty) {
      finder = finder.copyWith(filter: Filter.and(filters));
    }

    final records = await _paymentStore.find(_db, finder: finder);
    return records.map((rec) => Payment.fromMap(rec.value)).toList();
  }

  /// Get payment by ID
  Future<Payment?> getPaymentById(String id) async {
    final record = await _paymentStore.record(id).get(_db);
    return record != null ? Payment.fromMap(record) : null;
  }

  /// Record a new payment
  Future<Payment> recordPayment(Payment payment) async {
    await _paymentStore.record(payment.id).put(_db, payment.toMap());
    return payment;
  }

  /// Get daily collection summary
  Future<Map<String, dynamic>> getDailyCollectionSummary(DateTime date) async {
    final payments = await getAllPayments(
      dateFrom: date,
      dateTo: date,
    );

    final totalCollected = payments.fold<double>(
      0, 
      (sum, p) => sum + p.amount
    );

    final byMethod = <String, double>{};
    for (var payment in payments) {
      byMethod[payment.method.name] = (byMethod[payment.method.name] ?? 0) + payment.amount;
    }

    return {
      'date': date.toIso8601String().substring(0, 10),
      'totalCollected': totalCollected,
      'transactionCount': payments.length,
      'byMethod': byMethod,
    };
  }
}
