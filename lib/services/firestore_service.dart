import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Reference to the 'students' collection
  CollectionReference get _studentsRef => _db.collection('students');

  // Stream of students for real-time updates
  Stream<List<Student>> streamStudents() {
    return _studentsRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Student.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Add a new student
  Future<void> addStudent(Student student) async {
    await _studentsRef.doc(student.id).set(student.toJson());
  }

  // Update an existing student
  Future<void> updateStudent(Student student) async {
    await _studentsRef.doc(student.id).update(student.toJson());
  }

  // Delete a student
  Future<void> deleteStudent(String id) async {
    await _studentsRef.doc(id).delete();
  }
}
