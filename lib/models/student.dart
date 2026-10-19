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
  });

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
    );
  }
}
