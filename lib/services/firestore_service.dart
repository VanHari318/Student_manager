import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';
import '../models/course.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Reference to the 'students' collection
  CollectionReference get _studentsRef => _db.collection('students');
  CollectionReference get _coursesRef => _db.collection('courses');

  // Stream of students for real-time updates
  Stream<List<Student>> streamStudents() {
    return _studentsRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Student.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Stream of courses for a specific student
  Stream<List<Course>> streamCourses(String studentId) {
    return _coursesRef.where('studentId', isEqualTo: studentId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Course.fromJson(doc.data() as Map<String, dynamic>)).toList();
    });
  }

  // Add a new student along with their courses
  Future<void> addStudent(Student student) async {
    // Write student
    await _studentsRef.doc(student.id).set(student.toJson());
    // Write assigned courses
    for (var course in student.courses) {
      await _coursesRef.doc(course.id).set(course.toJson());
    }
  }

  // Update an existing student
  Future<void> updateStudent(Student student) async {
    await _studentsRef.doc(student.id).update(student.toJson());
  }

  // Delete a student
  Future<void> deleteStudent(String id) async {
    await _studentsRef.doc(id).delete();
    // Delete all courses assigned to this student
    var courseDocs = await _coursesRef.where('studentId', isEqualTo: id).get();
    for (var doc in courseDocs.docs) {
      await doc.reference.delete();
    }
  }

  // Clear all data for testing
  Future<void> deleteAllData() async {
    final students = await _studentsRef.get();
    for (var doc in students.docs) {
      await doc.reference.delete();
    }
    final courses = await _coursesRef.get();
    for (var doc in courses.docs) {
      await doc.reference.delete();
    }
  }
}

