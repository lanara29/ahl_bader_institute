import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/teacher.dart';
import '../models/student.dart';
import '../models/course.dart';
import '../models/teacher_attendance.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _teachersCol =>
      _firestore.collection('teachers');

  CollectionReference<Map<String, dynamic>> get _studentsCol =>
      _firestore.collection('students');

  CollectionReference<Map<String, dynamic>> get _coursesCol =>
      _firestore.collection('courses');

  CollectionReference<Map<String, dynamic>> get _attendanceCol =>
      _firestore.collection('teacher_attendance');

  // --- Teacher Operations (Firebase Firestore - 100% Dynamic) ---

  Future<dynamic> insertTeacher(Teacher teacher) async {
    final map = teacher.toMap();
    map.remove('id');
    map['created_at'] = FieldValue.serverTimestamp();

    if (teacher.id != null && teacher.id.toString().isNotEmpty) {
      await _teachersCol.doc(teacher.id.toString()).set(map);
      return teacher.id;
    } else {
      final docRef = await _teachersCol.add(map);
      return docRef.id;
    }
  }

  Future<List<Teacher>> getTeachers() async {
    final snapshot = await _teachersCol.get();
    return snapshot.docs.map((doc) {
      return Teacher.fromMap(doc.data(), doc.id);
    }).toList();
  }

  Stream<List<Teacher>> streamTeachers() {
    return _teachersCol.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Teacher.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<void> updateTeacher(Teacher teacher) async {
    if (teacher.id == null) return;
    final map = teacher.toMap();
    map.remove('id');
    map['updated_at'] = FieldValue.serverTimestamp();
    await _teachersCol.doc(teacher.id.toString()).update(map);
  }

  Future<void> deleteTeacher(dynamic id) async {
    if (id == null) return;
    await _teachersCol.doc(id.toString()).delete();
  }

  // --- Student Operations (Firebase Firestore - 100% Dynamic) ---

  Future<dynamic> insertStudent(Student student) async {
    final map = student.toMap();
    map.remove('id');
    map['created_at'] = FieldValue.serverTimestamp();

    if (student.id != null && student.id.toString().isNotEmpty) {
      await _studentsCol.doc(student.id.toString()).set(map);
      return student.id;
    } else {
      final docRef = await _studentsCol.add(map);
      return docRef.id;
    }
  }

  Future<List<Student>> getAllStudents() async {
    final snapshot = await _studentsCol.get();
    return snapshot.docs.map((doc) {
      return Student.fromMap(doc.data(), doc.id);
    }).toList();
  }

  Stream<List<Student>> streamStudents() {
    return _studentsCol.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Student.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<List<Student>> getStudentsByTeacher(dynamic teacherId) async {
    final snapshot = await _studentsCol.get();
    final allStudents = snapshot.docs.map((doc) {
      return Student.fromMap(doc.data(), doc.id);
    }).toList();

    return allStudents.where((s) {
      return s.teacherId.toString() == teacherId.toString();
    }).toList();
  }

  Future<void> updateStudent(Student student) async {
    if (student.id == null) return;
    final map = student.toMap();
    map.remove('id');
    map['updated_at'] = FieldValue.serverTimestamp();
    await _studentsCol.doc(student.id.toString()).update(map);
  }

  Future<void> deleteStudent(dynamic id) async {
    if (id == null) return;
    await _studentsCol.doc(id.toString()).delete();
  }

  Future<int> getStudentCountForTeacher(dynamic teacherId) async {
    final students = await getStudentsByTeacher(teacherId);
    return students.length;
  }

  Future<void> updateStudentTeacher({
    required dynamic studentId,
    required dynamic teacherId,
    required String teacherName,
  }) async {
    if (studentId == null) return;
    await _studentsCol.doc(studentId.toString()).update({
      'teacher_id': teacherId,
      'teacher_name': teacherName,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  // --- Course Operations (Firebase Firestore - 100% Dynamic) ---

  Future<dynamic> insertCourse(Course course) async {
    final map = course.toMap();
    map.remove('id');
    map['created_at'] = FieldValue.serverTimestamp();

    // If this course is marked active, make sure other courses are marked inactive
    if (course.isActive) {
      await _deactivateAllCourses();
    }

    if (course.id != null && course.id.toString().isNotEmpty) {
      await _coursesCol.doc(course.id.toString()).set(map);
      return course.id;
    } else {
      final docRef = await _coursesCol.add(map);
      return docRef.id;
    }
  }

  Future<List<Course>> getCourses() async {
    final snapshot = await _coursesCol.orderBy('year', descending: true).get();
    return snapshot.docs.map((doc) {
      return Course.fromMap(doc.data(), doc.id);
    }).toList();
  }

  Stream<List<Course>> streamCourses() {
    return _coursesCol.orderBy('year', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Course.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<Course?> getActiveCourse() async {
    final snapshot = await _coursesCol.where('is_active', isEqualTo: true).limit(1).get();
    if (snapshot.docs.isNotEmpty) {
      return Course.fromMap(snapshot.docs.first.data(), snapshot.docs.first.id);
    }
    // If no course explicitly marked active, return the newest one if exists
    final all = await getCourses();
    if (all.isNotEmpty) return all.first;
    return null;
  }

  Future<void> setActiveCourse(dynamic courseId) async {
    if (courseId == null) return;
    final batch = _firestore.batch();
    final allSnapshot = await _coursesCol.get();

    for (final doc in allSnapshot.docs) {
      final isTarget = doc.id == courseId.toString();
      batch.update(doc.reference, {
        'is_active': isTarget,
        'updated_at': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  Future<void> _deactivateAllCourses() async {
    final activeSnapshot = await _coursesCol.where('is_active', isEqualTo: true).get();
    final batch = _firestore.batch();
    for (final doc in activeSnapshot.docs) {
      batch.update(doc.reference, {'is_active': false});
    }
    await batch.commit();
  }

  Future<void> updateCourse(Course course) async {
    if (course.id == null) return;
    if (course.isActive) {
      await _deactivateAllCourses();
    }
    final map = course.toMap();
    map.remove('id');
    map['updated_at'] = FieldValue.serverTimestamp();
    await _coursesCol.doc(course.id.toString()).update(map);
  }

  Future<void> deleteCourse(dynamic id) async {
    if (id == null) return;
    await _coursesCol.doc(id.toString()).delete();
  }

  Future<List<Student>> getStudentsByCourse(dynamic courseId) async {
    final all = await getAllStudents();
    return all.where((s) => s.courseId.toString() == courseId.toString()).toList();
  }

  Future<int> getStudentCountForCourse(dynamic courseId) async {
    final list = await getStudentsByCourse(courseId);
    return list.length;
  }

  // --- Teacher Attendance Operations (Firebase Firestore) ---

  /// معرّف الوثيقة الثابت لكل يوم ودورة: YYYY-MM-DD_courseId
  String getAttendanceDocId(String date, dynamic courseId) => '${date}_$courseId';

  Future<void> saveTeacherAttendance(TeacherAttendance attendance) async {
    final docId = attendance.id.isNotEmpty
        ? attendance.id
        : getAttendanceDocId(attendance.date, attendance.courseId);

    final map = attendance.toMap();
    map['updated_at'] = FieldValue.serverTimestamp();

    await _attendanceCol.doc(docId).set(map, SetOptions(merge: true));
  }

  Future<TeacherAttendance?> getTeacherAttendance(String date, dynamic courseId) async {
    final docId = getAttendanceDocId(date, courseId);
    final doc = await _attendanceCol.doc(docId).get();
    if (!doc.exists || doc.data() == null) return null;
    return TeacherAttendance.fromMap(doc.data()!, doc.id);
  }

  Stream<TeacherAttendance?> streamTeacherAttendance(String date, dynamic courseId) {
    final docId = getAttendanceDocId(date, courseId);
    return _attendanceCol.doc(docId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return TeacherAttendance.fromMap(doc.data()!, doc.id);
    });
  }

  Future<List<TeacherAttendance>> getAttendanceForCourse(dynamic courseId) async {
    final snapshot = await _attendanceCol
        .where('course_id', isEqualTo: courseId)
        .get();

    final list = snapshot.docs
        .map((doc) => TeacherAttendance.fromMap(doc.data(), doc.id))
        .toList();
    list.sort((a, b) => b.date.compareTo(a.date)); // الأحدث أولاً
    return list;
  }

  Future<List<TeacherAttendance>> getAttendanceForMonth({
    required dynamic courseId,
    required int year,
    required int month,
  }) async {
    final monthStr = month.toString().padLeft(2, '0');
    final startPrefix = '$year-$monthStr-01';
    final endPrefix = '$year-$monthStr-31';

    final snapshot = await _attendanceCol
        .where('course_id', isEqualTo: courseId)
        .where('date', isGreaterThanOrEqualTo: startPrefix)
        .where('date', isLessThanOrEqualTo: endPrefix)
        .get();

    final list = snapshot.docs
        .map((doc) => TeacherAttendance.fromMap(doc.data(), doc.id))
        .toList();
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  Future<void> deleteTeacherAttendance(String id) async {
    await _attendanceCol.doc(id).delete();
  }
}
