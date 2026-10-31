class Student {
  final dynamic id;
  final String name;
  final String surname;
  final String fatherName;
  final String motherName;
  final String fatherJob;
  final String motherJob;
  final String socialStatus;
  final String address;
  final String mobile;
  final String parentMobile;
  final dynamic teacherId;
  final String teacherName;
  final String grade;
  final String joinDate;
  final String notes;

  // Payment Fields
  final double requiredFee;
  final double paidAmount;
  final String paymentStatus; // 'paid', 'partial', 'unpaid', 'exempt'
  final String paymentDate;
  final String paymentNotes;

  Student({
    this.id,
    required this.name,
    this.surname = '',
    this.fatherName = '',
    this.motherName = '',
    this.fatherJob = '',
    this.motherJob = '',
    this.socialStatus = '',
    this.address = '',
    required this.mobile,
    this.parentMobile = '',
    required this.teacherId,
    this.teacherName = '',
    required this.grade,
    this.joinDate = '01-09-2023',
    this.notes = '',
    this.requiredFee = 0.0,
    this.paidAmount = 0.0,
    this.paymentStatus = 'unpaid',
    this.paymentDate = '',
    this.paymentNotes = '',
  });

  double get remainingFee => (requiredFee - paidAmount) > 0 ? (requiredFee - paidAmount) : 0.0;

  String get paymentStatusArabic {
    switch (paymentStatus) {
      case 'paid':
        return 'مسدد بالكامل';
      case 'partial':
        return 'مسدد جزئياً';
      case 'exempt':
        return 'معفى / منحة';
      case 'unpaid':
      default:
        return requiredFee > 0 ? 'غير مسدد' : 'لم يحدد';
    }
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'surname': surname,
      'father_name': fatherName,
      'mother_name': motherName,
      'father_job': fatherJob,
      'mother_job': motherJob,
      'social_status': socialStatus,
      'address': address,
      'phone': mobile,
      'parent_mobile': parentMobile,
      'teacher_id': teacherId,
      'teacher_name': teacherName,
      'grade': grade,
      'join_date': joinDate,
      'notes': notes,
      'required_fee': requiredFee,
      'paid_amount': paidAmount,
      'payment_status': paymentStatus,
      'payment_date': paymentDate,
      'payment_notes': paymentNotes,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory Student.fromMap(Map<String, dynamic> map, [String? docId]) {
    return Student(
      id: docId ?? map['id'],
      name: map['name'] as String? ?? '',
      surname: map['surname'] as String? ?? '',
      fatherName: map['father_name'] as String? ?? '',
      motherName: map['mother_name'] as String? ?? '',
      fatherJob: map['father_job'] as String? ?? '',
      motherJob: map['mother_job'] as String? ?? '',
      socialStatus: map['social_status'] as String? ?? '',
      address: map['address'] as String? ?? '',
      mobile: map['phone'] as String? ?? '',
      parentMobile: map['parent_mobile'] as String? ?? '',
      teacherId: map['teacher_id'],
      teacherName: map['teacher_name'] as String? ?? '',
      grade: map['grade'] as String? ?? '',
      joinDate: map['join_date'] as String? ?? '01-09-2023',
      notes: map['notes'] as String? ?? '',
      requiredFee: (map['required_fee'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (map['paid_amount'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: map['payment_status'] as String? ?? 'unpaid',
      paymentDate: map['payment_date'] as String? ?? '',
      paymentNotes: map['payment_notes'] as String? ?? '',
    );
  }

  Student copyWith({
    dynamic id,
    String? name,
    String? surname,
    String? fatherName,
    String? motherName,
    String? fatherJob,
    String? motherJob,
    String? socialStatus,
    String? address,
    String? mobile,
    String? parentMobile,
    dynamic teacherId,
    String? teacherName,
    String? grade,
    String? joinDate,
    String? notes,
    double? requiredFee,
    double? paidAmount,
    String? paymentStatus,
    String? paymentDate,
    String? paymentNotes,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      fatherName: fatherName ?? this.fatherName,
      motherName: motherName ?? this.motherName,
      fatherJob: fatherJob ?? this.fatherJob,
      motherJob: motherJob ?? this.motherJob,
      socialStatus: socialStatus ?? this.socialStatus,
      address: address ?? this.address,
      mobile: mobile ?? this.mobile,
      parentMobile: parentMobile ?? this.parentMobile,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      grade: grade ?? this.grade,
      joinDate: joinDate ?? this.joinDate,
      notes: notes ?? this.notes,
      requiredFee: requiredFee ?? this.requiredFee,
      paidAmount: paidAmount ?? this.paidAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentNotes: paymentNotes ?? this.paymentNotes,
    );
  }
}
