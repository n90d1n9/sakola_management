enum PaymentType {
  tuition, // SPP
  registration, // Pendaftaran
  building, // Gedung
  activity, // Kegiatan
  exam, // Ujian
  book, // Buku
  uniform, // Seragam
  transportation, // Transport
  dormitory, // Asrama
  lateFee, // Denda
  other, // Lainnya
}

enum PaymentStatus {
  pending,
  paid,
  overdue,
  cancelled,
  partial,
  waived,
}

enum PaymentMethod {
  cash,
  bankTransfer,
  creditCard,
  debitCard,
  eWallet,
  virtualAccount,
  qris,
}

class FeeItem {
  final String id;
  final String name;
  final PaymentType type;
  final double amount;
  final String? description;
  final bool isRecurring;
  final int frequencyMonths; // 0 = one-time, 1 = monthly, etc.
  final DateTime? startDate;
  final DateTime? endDate;

  FeeItem({
    required this.id,
    required this.name,
    required this.type,
    required this.amount,
    this.description,
    this.isRecurring = false,
    this.frequencyMonths = 0,
    this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.toString(),
        'amount': amount,
        'description': description,
        'isRecurring': isRecurring,
        'frequencyMonths': frequencyMonths,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
      };

  factory FeeItem.fromJson(Map<String, dynamic> json) => FeeItem(
        id: json['id'],
        name: json['name'],
        type: PaymentType.values.firstWhere((e) => e.toString() == json['type']),
        amount: json['amount']?.toDouble() ?? 0.0,
        description: json['description'],
        isRecurring: json['isRecurring'] ?? false,
        frequencyMonths: json['frequencyMonths'] ?? 0,
        startDate: json['startDate'] != null 
            ? DateTime.parse(json['startDate']) 
            : null,
        endDate: json['endDate'] != null 
            ? DateTime.parse(json['endDate']) 
            : null,
      );
}

class FeeStructure {
  final String id;
  final String name; // e.g., "SMP Kelas 7", "SMA IPA"
  final String educationLevel;
  final String academicYear;
  final List<FeeItem> feeItems;
  final double totalAmount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FeeStructure({
    required this.id,
    required this.name,
    required this.educationLevel,
    required this.academicYear,
    required this.feeItems,
    required this.totalAmount,
    this.createdAt,
    this.updatedAt,
  });

  FeeStructure copyWith({
    String? id,
    String? name,
    String? educationLevel,
    String? academicYear,
    List<FeeItem>? feeItems,
    double? totalAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FeeStructure(
      id: id ?? this.id,
      name: name ?? this.name,
      educationLevel: educationLevel ?? this.educationLevel,
      academicYear: academicYear ?? this.academicYear,
      feeItems: feeItems ?? this.feeItems,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'educationLevel': educationLevel,
        'academicYear': academicYear,
        'feeItems': feeItems.map((e) => e.toJson()).toList(),
        'totalAmount': totalAmount,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory FeeStructure.fromJson(Map<String, dynamic> json) => FeeStructure(
        id: json['id'],
        name: json['name'],
        educationLevel: json['educationLevel'],
        academicYear: json['academicYear'],
        feeItems: (json['feeItems'] as List)
            .map((e) => FeeItem.fromJson(e))
            .toList(),
        totalAmount: json['totalAmount']?.toDouble() ?? 0.0,
        createdAt: json['createdAt'] != null 
            ? DateTime.parse(json['createdAt']) 
            : null,
        updatedAt: json['updatedAt'] != null 
            ? DateTime.parse(json['updatedAt']) 
            : null,
      );
}
