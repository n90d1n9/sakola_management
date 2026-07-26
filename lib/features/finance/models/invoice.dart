import 'fee_structure.dart';

class Invoice {
  final String id;
  final String invoiceNumber;
  final String studentId;
  final String studentName;
  final String feeStructureId;
  final String academicYear;
  final String period; // e.g., "Januari 2025", "Semester Ganjil"
  final List<InvoiceItem> items;
  final double subtotal;
  final double discount;
  final double tax;
  final double totalAmount;
  final double paidAmount;
  final double remainingAmount;
  final PaymentStatus status;
  final DateTime dueDate;
  final DateTime? paidDate;
  final PaymentMethod? paymentMethod;
  final String? paymentReference;
  final String? notes;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.studentId,
    required this.studentName,
    required this.feeStructureId,
    required this.academicYear,
    required this.period,
    required this.items,
    required this.subtotal,
    this.discount = 0,
    this.tax = 0,
    required this.totalAmount,
    this.paidAmount = 0,
    required this.remainingAmount,
    this.status = PaymentStatus.pending,
    required this.dueDate,
    this.paidDate,
    this.paymentMethod,
    this.paymentReference,
    this.notes,
    this.createdBy,
    required this.createdAt,
    this.updatedAt,
  });

  Invoice copyWith({
    String? id,
    String? invoiceNumber,
    String? studentId,
    String? studentName,
    String? feeStructureId,
    String? academicYear,
    String? period,
    List<InvoiceItem>? items,
    double? subtotal,
    double? discount,
    double? tax,
    double? totalAmount,
    double? paidAmount,
    double? remainingAmount,
    PaymentStatus? status,
    DateTime? dueDate,
    DateTime? paidDate,
    PaymentMethod? paymentMethod,
    String? paymentReference,
    String? notes,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Invoice(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      feeStructureId: feeStructureId ?? this.feeStructureId,
      academicYear: academicYear ?? this.academicYear,
      period: period ?? this.period,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      paidDate: paidDate ?? this.paidDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentReference: paymentReference ?? this.paymentReference,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'invoiceNumber': invoiceNumber,
        'studentId': studentId,
        'studentName': studentName,
        'feeStructureId': feeStructureId,
        'academicYear': academicYear,
        'period': period,
        'items': items.map((e) => e.toJson()).toList(),
        'subtotal': subtotal,
        'discount': discount,
        'tax': tax,
        'totalAmount': totalAmount,
        'paidAmount': paidAmount,
        'remainingAmount': remainingAmount,
        'status': status.toString(),
        'dueDate': dueDate.toIso8601String(),
        'paidDate': paidDate?.toIso8601String(),
        'paymentMethod': paymentMethod?.toString(),
        'paymentReference': paymentReference,
        'notes': notes,
        'createdBy': createdBy,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
        id: json['id'],
        invoiceNumber: json['invoiceNumber'],
        studentId: json['studentId'],
        studentName: json['studentName'],
        feeStructureId: json['feeStructureId'],
        academicYear: json['academicYear'],
        period: json['period'],
        items: (json['items'] as List)
            .map((e) => InvoiceItem.fromJson(e))
            .toList(),
        subtotal: json['subtotal']?.toDouble() ?? 0.0,
        discount: json['discount']?.toDouble() ?? 0.0,
        tax: json['tax']?.toDouble() ?? 0.0,
        totalAmount: json['totalAmount']?.toDouble() ?? 0.0,
        paidAmount: json['paidAmount']?.toDouble() ?? 0.0,
        remainingAmount: json['remainingAmount']?.toDouble() ?? 0.0,
        status: PaymentStatus.values.firstWhere(
          (e) => e.toString() == json['status'],
        ),
        dueDate: DateTime.parse(json['dueDate']),
        paidDate: json['paidDate'] != null 
            ? DateTime.parse(json['paidDate']) 
            : null,
        paymentMethod: json['paymentMethod'] != null
            ? PaymentMethod.values.firstWhere(
                (e) => e.toString() == json['paymentMethod'],
              )
            : null,
        paymentReference: json['paymentReference'],
        notes: json['notes'],
        createdBy: json['createdBy'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: json['updatedAt'] != null 
            ? DateTime.parse(json['updatedAt']) 
            : null,
      );

  @override
  String toString() => 'Invoice($invoiceNumber, student: $studentName, total: $totalAmount, status: $status)';
}

class InvoiceItem {
  final String feeItemId;
  final String name;
  final PaymentType type;
  final double amount;
  final int quantity;
  final double total;
  final String? description;

  InvoiceItem({
    required this.feeItemId,
    required this.name,
    required this.type,
    required this.amount,
    this.quantity = 1,
    required this.total,
    this.description,
  });

  Map<String, dynamic> toJson() => {
        'feeItemId': feeItemId,
        'name': name,
        'type': type.toString(),
        'amount': amount,
        'quantity': quantity,
        'total': total,
        'description': description,
      };

  factory InvoiceItem.fromJson(Map<String, dynamic> json) => InvoiceItem(
        feeItemId: json['feeItemId'],
        name: json['name'],
        type: PaymentType.values.firstWhere((e) => e.toString() == json['type']),
        amount: json['amount']?.toDouble() ?? 0.0,
        quantity: json['quantity'] ?? 1,
        total: json['total']?.toDouble() ?? 0.0,
        description: json['description'],
      );
}

class PaymentTransaction {
  final String id;
  final String invoiceId;
  final String invoiceNumber;
  final String studentId;
  final String studentName;
  final double amount;
  final PaymentMethod method;
  final String? transactionReference;
  final String? bankName;
  final String? accountNumber;
  final String? qrCodeData;
  final PaymentStatus status;
  final DateTime transactionDate;
  final String? processedBy;
  final String? notes;
  final DateTime createdAt;

  PaymentTransaction({
    required this.id,
    required this.invoiceId,
    required this.invoiceNumber,
    required this.studentId,
    required this.studentName,
    required this.amount,
    required this.method,
    this.transactionReference,
    this.bankName,
    this.accountNumber,
    this.qrCodeData,
    this.status = PaymentStatus.pending,
    required this.transactionDate,
    this.processedBy,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'invoiceId': invoiceId,
        'invoiceNumber': invoiceNumber,
        'studentId': studentId,
        'studentName': studentName,
        'amount': amount,
        'method': method.toString(),
        'transactionReference': transactionReference,
        'bankName': bankName,
        'accountNumber': accountNumber,
        'qrCodeData': qrCodeData,
        'status': status.toString(),
        'transactionDate': transactionDate.toIso8601String(),
        'processedBy': processedBy,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
      };

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) => PaymentTransaction(
        id: json['id'],
        invoiceId: json['invoiceId'],
        invoiceNumber: json['invoiceNumber'],
        studentId: json['studentId'],
        studentName: json['studentName'],
        amount: json['amount']?.toDouble() ?? 0.0,
        method: PaymentMethod.values.firstWhere(
          (e) => e.toString() == json['method'],
        ),
        transactionReference: json['transactionReference'],
        bankName: json['bankName'],
        accountNumber: json['accountNumber'],
        qrCodeData: json['qrCodeData'],
        status: PaymentStatus.values.firstWhere(
          (e) => e.toString() == json['status'],
        ),
        transactionDate: DateTime.parse(json['transactionDate']),
        processedBy: json['processedBy'],
        notes: json['notes'],
        createdAt: DateTime.parse(json['createdAt']),
      );
}
