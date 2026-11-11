class TeacherAttendanceRecord {
  final dynamic teacherId;
  final String teacherName;
  final String status; // 'present' (حاضرة), 'absent' (غائبة), 'late' (متأخرة), 'excused' (إجازة / معذورة)
  final String note;
  final String time;

  TeacherAttendanceRecord({
    required this.teacherId,
    required this.teacherName,
    required this.status,
    this.note = '',
    this.time = '',
  });

  bool get isPresent => status == 'present';
  bool get isAbsent => status == 'absent';
  bool get isLate => status == 'late';
  bool get isExcused => status == 'excused';

  String get statusArabic {
    switch (status) {
      case 'present':
        return 'حاضرة';
      case 'absent':
        return 'غائبة';
      case 'late':
        return 'متأخرة';
      case 'excused':
        return 'إجازة / معذورة';
      default:
        return 'غير محدد';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'teacher_id': teacherId,
      'teacher_name': teacherName,
      'status': status,
      'note': note,
      'time': time,
    };
  }

  factory TeacherAttendanceRecord.fromMap(Map<String, dynamic> map) {
    return TeacherAttendanceRecord(
      teacherId: map['teacher_id'],
      teacherName: map['teacher_name'] as String? ?? '',
      status: map['status'] as String? ?? 'present',
      note: map['note'] as String? ?? '',
      time: map['time'] as String? ?? '',
    );
  }

  TeacherAttendanceRecord copyWith({
    dynamic teacherId,
    String? teacherName,
    String? status,
    String? note,
    String? time,
  }) {
    return TeacherAttendanceRecord(
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      status: status ?? this.status,
      note: note ?? this.note,
      time: time ?? this.time,
    );
  }
}

class TeacherAttendance {
  final String id;
  final String date; // YYYY-MM-DD
  final String dayName; // السبت، الأحد...
  final dynamic courseId;
  final String courseName;
  final Map<String, TeacherAttendanceRecord> records; // key is teacherId.toString()
  final String notes;
  final String updatedAt;

  TeacherAttendance({
    required this.id,
    required this.date,
    required this.dayName,
    required this.courseId,
    this.courseName = '',
    required this.records,
    this.notes = '',
    this.updatedAt = '',
  });

  int get presentCount => records.values.where((r) => r.isPresent).length;
  int get absentCount => records.values.where((r) => r.isAbsent).length;
  int get lateCount => records.values.where((r) => r.isLate).length;
  int get excusedCount => records.values.where((r) => r.isExcused).length;
  int get totalTeachers => records.length;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'day_name': dayName,
      'course_id': courseId,
      'course_name': courseName,
      'records': records.map((key, val) => MapEntry(key, val.toMap())),
      'present_count': presentCount,
      'absent_count': absentCount,
      'late_count': lateCount,
      'excused_count': excusedCount,
      'total_teachers': totalTeachers,
      'notes': notes,
      'updated_at': updatedAt,
    };
  }

  factory TeacherAttendance.fromMap(Map<String, dynamic> map, [String? docId]) {
    final rawRecords = map['records'];
    final recordsMap = <String, TeacherAttendanceRecord>{};

    if (rawRecords is Map) {
      rawRecords.forEach((key, val) {
        if (val is Map) {
          recordsMap[key.toString()] = TeacherAttendanceRecord.fromMap(
            Map<String, dynamic>.from(val),
          );
        }
      });
    }

    return TeacherAttendance(
      id: docId ?? map['id']?.toString() ?? '',
      date: map['date']?.toString() ?? '',
      dayName: map['day_name']?.toString() ?? '',
      courseId: map['course_id'],
      courseName: map['course_name']?.toString() ?? '',
      records: recordsMap,
      notes: map['notes']?.toString() ?? '',
      updatedAt: map['updated_at']?.toString() ?? '',
    );
  }

  TeacherAttendance copyWith({
    String? id,
    String? date,
    String? dayName,
    dynamic courseId,
    String? courseName,
    Map<String, TeacherAttendanceRecord>? records,
    String? notes,
    String? updatedAt,
  }) {
    return TeacherAttendance(
      id: id ?? this.id,
      date: date ?? this.date,
      dayName: dayName ?? this.dayName,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      records: records ?? this.records,
      notes: notes ?? this.notes,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
