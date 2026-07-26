/// Model for Student Admission/Application
class Admission {
  final String? id;
  final String applicationNumber;
  final String studentName;
  final DateTime birthDate;
  final String birthPlace;
  final String gender;
  final String religion;
  final String address;
  final String postalCode;
  final String phone;
  final String email;
  
  // Parent/Guardian Information
  final String fatherName;
  final String fatherOccupation;
  final String fatherPhone;
  final String motherName;
  final String motherOccupation;
  final String motherPhone;
  
  // Academic Information
  final String previousSchool;
  final String applyingForGrade;
  final String academicYear;
  final DateTime applicationDate;
  
  // Admission Status
  final AdmissionStatus status;
  final String? assignedClass;
  final DateTime? statusUpdatedDate;
  final String? notes;
  
  // Documents
  final List<String> uploadedDocuments; // Document URLs/paths
  
  // Selection Process
  final double? selectionScore;
  final String? selectionNotes;
  final DateTime? selectionDate;

  Admission({
    this.id,
    required this.applicationNumber,
    required this.studentName,
    required this.birthDate,
    required this.birthPlace,
    required this.gender,
    required this.religion,
    required this.address,
    required this.postalCode,
    required this.phone,
    required this.email,
    required this.fatherName,
    required this.fatherOccupation,
    required this.fatherPhone,
    required this.motherName,
    required this.motherOccupation,
    required this.motherPhone,
    required this.previousSchool,
    required this.applyingForGrade,
    required this.academicYear,
    required this.applicationDate,
    this.status = AdmissionStatus.registered,
    this.assignedClass,
    this.statusUpdatedDate,
    this.notes,
    this.uploadedDocuments = const [],
    this.selectionScore,
    this.selectionNotes,
    this.selectionDate,
  });

  /// Create from JSON map
  factory Admission.fromMap(Map<String, dynamic> map) {
    return Admission(
      id: map['id'] as String?,
      applicationNumber: map['applicationNumber'] as String,
      studentName: map['studentName'] as String,
      birthDate: DateTime.parse(map['birthDate'] as String),
      birthPlace: map['birthPlace'] as String,
      gender: map['gender'] as String,
      religion: map['religion'] as String,
      address: map['address'] as String,
      postalCode: map['postalCode'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String,
      fatherName: map['fatherName'] as String,
      fatherOccupation: map['fatherOccupation'] as String,
      fatherPhone: map['fatherPhone'] as String,
      motherName: map['motherName'] as String,
      motherOccupation: map['motherOccupation'] as String,
      motherPhone: map['motherPhone'] as String,
      previousSchool: map['previousSchool'] as String,
      applyingForGrade: map['applyingForGrade'] as String,
      academicYear: map['academicYear'] as String,
      applicationDate: DateTime.parse(map['applicationDate'] as String),
      status: AdmissionStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => AdmissionStatus.registered,
      ),
      assignedClass: map['assignedClass'] as String?,
      statusUpdatedDate: map['statusUpdatedDate'] != null 
          ? DateTime.parse(map['statusUpdatedDate'] as String) 
          : null,
      notes: map['notes'] as String?,
      uploadedDocuments: List<String>.from(map['uploadedDocuments'] ?? []),
      selectionScore: map['selectionScore'] as double?,
      selectionNotes: map['selectionNotes'] as String?,
      selectionDate: map['selectionDate'] != null 
          ? DateTime.parse(map['selectionDate'] as String) 
          : null,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'applicationNumber': applicationNumber,
      'studentName': studentName,
      'birthDate': birthDate.toIso8601String(),
      'birthPlace': birthPlace,
      'gender': gender,
      'religion': religion,
      'address': address,
      'postalCode': postalCode,
      'phone': phone,
      'email': email,
      'fatherName': fatherName,
      'fatherOccupation': fatherOccupation,
      'fatherPhone': fatherPhone,
      'motherName': motherName,
      'motherOccupation': motherOccupation,
      'motherPhone': motherPhone,
      'previousSchool': previousSchool,
      'applyingForGrade': applyingForGrade,
      'academicYear': academicYear,
      'applicationDate': applicationDate.toIso8601String(),
      'status': status.name,
      'assignedClass': assignedClass,
      'statusUpdatedDate': statusUpdatedDate?.toIso8601String(),
      'notes': notes,
      'uploadedDocuments': uploadedDocuments,
      'selectionScore': selectionScore,
      'selectionNotes': selectionNotes,
      'selectionDate': selectionDate?.toIso8601String(),
    };
  }

  /// Copy with new values
  Admission copyWith({
    String? id,
    String? applicationNumber,
    String? studentName,
    DateTime? birthDate,
    String? birthPlace,
    String? gender,
    String? religion,
    String? address,
    String? postalCode,
    String? phone,
    String? email,
    String? fatherName,
    String? fatherOccupation,
    String? fatherPhone,
    String? motherName,
    String? motherOccupation,
    String? motherPhone,
    String? previousSchool,
    String? applyingForGrade,
    String? academicYear,
    DateTime? applicationDate,
    AdmissionStatus? status,
    String? assignedClass,
    DateTime? statusUpdatedDate,
    String? notes,
    List<String>? uploadedDocuments,
    double? selectionScore,
    String? selectionNotes,
    DateTime? selectionDate,
  }) {
    return Admission(
      id: id ?? this.id,
      applicationNumber: applicationNumber ?? this.applicationNumber,
      studentName: studentName ?? this.studentName,
      birthDate: birthDate ?? this.birthDate,
      birthPlace: birthPlace ?? this.birthPlace,
      gender: gender ?? this.gender,
      religion: religion ?? this.religion,
      address: address ?? this.address,
      postalCode: postalCode ?? this.postalCode,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      fatherName: fatherName ?? this.fatherName,
      fatherOccupation: fatherOccupation ?? this.fatherOccupation,
      fatherPhone: fatherPhone ?? this.fatherPhone,
      motherName: motherName ?? this.motherName,
      motherOccupation: motherOccupation ?? this.motherOccupation,
      motherPhone: motherPhone ?? this.motherPhone,
      previousSchool: previousSchool ?? this.previousSchool,
      applyingForGrade: applyingForGrade ?? this.applyingForGrade,
      academicYear: academicYear ?? this.academicYear,
      applicationDate: applicationDate ?? this.applicationDate,
      status: status ?? this.status,
      assignedClass: assignedClass ?? this.assignedClass,
      statusUpdatedDate: statusUpdatedDate ?? this.statusUpdatedDate,
      notes: notes ?? this.notes,
      uploadedDocuments: uploadedDocuments ?? this.uploadedDocuments,
      selectionScore: selectionScore ?? this.selectionScore,
      selectionNotes: selectionNotes ?? this.selectionNotes,
      selectionDate: selectionDate ?? this.selectionDate,
    );
  }
}

/// Admission Status Enum
enum AdmissionStatus {
  registered,      // Baru terdaftar
  verified,        // Dokumen diverifikasi
  tested,          // Sudah mengikuti tes seleksi
  accepted,        // Diterima
  rejected,        // Ditolak
  waitlisted,      // Daftar tunggu
  enrolled,        // Sudah daftar ulang
}

/// Extension for Indonesian labels
extension AdmissionStatusExtension on AdmissionStatus {
  String get label {
    switch (this) {
      case AdmissionStatus.registered:
        return 'Terdaftar';
      case AdmissionStatus.verified:
        return 'Terverifikasi';
      case AdmissionStatus.tested:
        return 'Sudah Tes';
      case AdmissionStatus.accepted:
        return 'Diterima';
      case AdmissionStatus.rejected:
        return 'Ditolak';
      case AdmissionStatus.waitlisted:
        return 'Daftar Tunggu';
      case AdmissionStatus.enrolled:
        return 'Daftar Ulang';
    }
  }
}

/// Fields constant for database queries
class AdmissionFields {
  static const String id = 'id';
  static const String applicationNumber = 'applicationNumber';
  static const String studentName = 'studentName';
  static const String status = 'status';
  static const String academicYear = 'academicYear';
  static const String applyingForGrade = 'applyingForGrade';
  static const String applicationDate = 'applicationDate';
  static const String selectionScore = 'selectionScore';
}
