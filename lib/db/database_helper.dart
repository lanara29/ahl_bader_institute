import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/teacher.dart';
import '../models/student.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _teachersCol =>
      _firestore.collection('teachers');

  CollectionReference<Map<String, dynamic>> get _studentsCol =>
      _firestore.collection('students');

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
}
