class Teacher {
  final dynamic id;
  final String name;
  final String ageRange;
  final String phone;
  final String joinDate;
  final String notes;

  Teacher({
    this.id,
    required this.name,
    required this.ageRange,
    required this.phone,
    required this.joinDate,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'age_range': ageRange,
      'subject': ageRange,
      'phone': phone,
      'join_date': joinDate,
      'notes': notes,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory Teacher.fromMap(Map<String, dynamic> map, [String? docId]) {
    return Teacher(
      id: docId ?? map['id'],
      name: map['name'] as String? ?? '',
      ageRange: (map['age_range'] ?? map['subject']) as String? ?? '',
      phone: map['phone'] as String? ?? '',
      joinDate: map['join_date'] as String? ?? '01-09-2022',
      notes: map['notes'] as String? ?? '',
    );
  }

  Teacher copyWith({
    dynamic id,
    String? name,
    String? ageRange,
    String? phone,
    String? joinDate,
    String? notes,
  }) {
    return Teacher(
      id: id ?? this.id,
      name: name ?? this.name,
      ageRange: ageRange ?? this.ageRange,
      phone: phone ?? this.phone,
      joinDate: joinDate ?? this.joinDate,
      notes: notes ?? this.notes,
    );
  }
}
