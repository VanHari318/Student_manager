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
        return Student.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  // Stream of courses for a specific student
  Stream<List<Course>> streamCourses(String studentId) {
    return _coursesRef.where('studentId', isEqualTo: studentId).snapshots().map(
      (snapshot) {
        return snapshot.docs
            .map((doc) => Course.fromJson(doc.data() as Map<String, dynamic>))
            .toList();
      },
    );
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

  // Update an existing student (only info, don't touch courses)
  Future<void> updateStudent(Student student) async {
    // Update only student info, preserve existing courses
    await _studentsRef.doc(student.id).update({
      'name': student.name,
      'studentId': student.studentId,
      'major': student.major,
      'email': student.email,
      'phone': student.phone,
      'avatarUrl': student.avatarUrl,
      'notes': student.notes,
      'gpa': student.gpa,
      'enrollmentDate': student.enrollmentDate.toIso8601String(),
    });
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

  // Get student with all courses loaded (for edit screen)
  Future<Student?> getStudentWithCourses(String studentId) async {
    try {
      final studentDoc = await _studentsRef.doc(studentId).get();
      if (!studentDoc.exists) return null;

      final studentData = studentDoc.data() as Map<String, dynamic>;
      final courseDocs = await _coursesRef
          .where('studentId', isEqualTo: studentId)
          .get();

      final courses = courseDocs.docs
          .map((doc) => Course.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      final student = Student.fromJson(studentData);
      return Student(
        id: student.id,
        name: student.name,
        studentId: student.studentId,
        major: student.major,
        email: student.email,
        phone: student.phone,
        avatarUrl: student.avatarUrl,
        notes: student.notes,
        gpa: student.gpa,
        enrollmentDate: student.enrollmentDate,
        courses: courses,
      );
    } catch (e) {
      throw Exception('Error fetching student with courses: $e');
    }
  }

  // Add a single course for a student
  Future<void> addCourse(Course course) async {
    await _coursesRef.doc(course.id).set(course.toJson());
  }

  // Update a single course
  Future<void> updateCourse(Course course) async {
    await _coursesRef.doc(course.id).update(course.toJson());
  }

  // Delete a single course
  Future<void> deleteCourse(String courseId) async {
    await _coursesRef.doc(courseId).delete();
  }

  // Check if a course with same name already exists for this student
  // Exclude current course ID from the check (for editing)
  Future<bool> checkDuplicateCourseName(
    String studentId,
    String courseName, {
    String? excludeCourseId,
  }) async {
    try {
      final courseDocs = await _coursesRef
          .where('studentId', isEqualTo: studentId)
          .where('name', isEqualTo: courseName)
          .get();

      if (courseDocs.docs.isEmpty) {
        return false; // No duplicate
      }

      // If excluding a specific course, check if it's only that course
      if (excludeCourseId != null) {
        return courseDocs.docs.any((doc) => doc.id != excludeCourseId);
      }

      return true; // Duplicate found
    } catch (e) {
      throw Exception('Error checking duplicate course: $e');
    }
  }

  // Update student's GPA based on courses (weighted average, converted to 4.0 scale)
  Future<void> updateStudentGPA(String studentId) async {
    try {
      final courseDocs = await _coursesRef
          .where('studentId', isEqualTo: studentId)
          .get();

      if (courseDocs.docs.isEmpty) {
        await _studentsRef.doc(studentId).update({'gpa': 0.0});
        return;
      }

      final courses = courseDocs.docs
          .map((doc) => Course.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      // Calculate weighted GPA: sum(grade * credits) / sum(credits)
      double totalWeightedGrade = 0;
      int totalCredits = 0;
      for (var course in courses) {
        totalWeightedGrade += course.grade * course.credits;
        totalCredits += course.credits;
      }

      // Convert from 10-point scale to 4-point scale
      double gpa = (totalWeightedGrade / totalCredits) * (4.0 / 10.0);

      // Round to 2 decimal places
      gpa = double.parse(gpa.toStringAsFixed(2));

      await _studentsRef.doc(studentId).update({'gpa': gpa});
    } catch (e) {
      throw Exception('Error updating GPA: $e');
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
