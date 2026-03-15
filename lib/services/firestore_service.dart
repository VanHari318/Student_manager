import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../models/student.dart';
import '../models/course.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Reference to the 'students' collection
  CollectionReference get _studentsRef => _db.collection('students');
  CollectionReference get _coursesRef => _db.collection('courses');

  // Helper to safely convert Firestore doc data to Map with deep conversion
  Map<String, dynamic> _toMap(DocumentSnapshot doc) {
    try {
      final data = doc.data();
      if (data == null) return {};

      // Recursively convert to safe Map structure
      return _deepConvertToMap(data);
    } catch (e) {
      print('Error converting doc data: $e');
      return {};
    }
  }

  // Deep conversion to handle LegacyJavaScriptObject on web
  Map<String, dynamic> _deepConvertToMap(dynamic value) {
    try {
      if (value is Map<String, dynamic>) {
        // Already correct type, but convert values recursively
        return Map<String, dynamic>.from(
          value.map((k, v) => MapEntry(k, _convertValue(v))),
        );
      } else if (value is Map) {
        // Generic Map - need to convert both keys and values
        final result = <String, dynamic>{};
        for (final entry in value.entries) {
          final key = entry.key.toString();
          result[key] = _convertValue(entry.value);
        }
        return result;
      }
      return {};
    } catch (e) {
      print('Error in deep map conversion: $e');
      return {};
    }
  }

  // Convert individual values to safe types
  dynamic _convertValue(dynamic value) {
    try {
      if (value == null) return null;
      if (value is String || value is int || value is double || value is bool) {
        return value;
      }
      if (value is List) {
        return value.map((item) => _convertValue(item)).toList();
      }
      if (value is Map) {
        return _deepConvertToMap(value);
      }
      // For any unknown type (like LegacyJavaScriptObject), try string conversion
      return value.toString();
    } catch (e) {
      print('Error converting value: $e');
      return null;
    }
  }

  // Stream of students for real-time updates
  Stream<List<Student>> streamStudents() {
    return _studentsRef.snapshots().map((snapshot) {
      return snapshot.docs
          .where((doc) => doc.exists)
          .map((doc) {
            try {
              return Student.fromFirestore(_toMap(doc), doc.id);
            } catch (e) {
              print('Error parsing student $e');
              return null;
            }
          })
          .whereType<Student>()
          .toList();
    });
  }

  // Stream of courses for a specific student
  Stream<List<Course>> streamCourses(String studentId) {
    return _coursesRef.where('studentId', isEqualTo: studentId).snapshots().map(
      (snapshot) {
        return snapshot.docs
            .where((doc) => doc.exists)
            .map((doc) {
              try {
                return Course.fromJson(_toMap(doc));
              } catch (e) {
                print('Error parsing course: $e');
                return null;
              }
            })
            .whereType<Course>()
            .toList();
      },
    );
  }

  // Add a new student along with their courses
  Future<void> addStudent(Student student) async {
    try {
      // Write student with safe JSON conversion
      await _studentsRef.doc(student.id).set(student.toJson());

      // Write assigned courses with error handling per-course
      if (student.courses.isNotEmpty) {
        for (var course in student.courses) {
          try {
            await _coursesRef.doc(course.id).set(course.toJson());
          } catch (e) {
            print('Error writing course ${course.id}: $e');
            // Continue with next course instead of failing
          }
        }
      }
    } catch (e) {
      print('Error in addStudent: $e');
      rethrow;
    }
  }

  // Update an existing student (only info, don't touch courses)
  Future<void> updateStudent(Student student) async {
    try {
      // Update only student info, preserve existing courses
      await _studentsRef.doc(student.id).update({
        'name': student.name,
        'studentId': student.studentId,
        'major': student.major,
        'email': student.email,
        'phone': student.phone,
        'avatarUrl': student.avatarUrl.toString().trim(),
        'notes': student.notes,
        'gpa': student.gpa,
        'enrollmentDate': student.enrollmentDate.toIso8601String(),
      });
    } catch (e) {
      print('Error in updateStudent: $e');
      rethrow;
    }
  }

  // Delete a student
  Future<void> deleteStudent(String id) async {
    try {
      // Delete student from Firestore (avatarUrl Base64 string deletes automatically)
      await _studentsRef.doc(id).delete();

      // Delete all courses assigned to this student
      var courseDocs = await _coursesRef
          .where('studentId', isEqualTo: id)
          .get();
      for (var doc in courseDocs.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error deleting student: $e');
      rethrow;
    }
  }

  // Get student with all courses loaded (for edit screen)
  Future<Student?> getStudentWithCourses(String studentId) async {
    try {
      final studentDoc = await _studentsRef.doc(studentId).get();
      if (!studentDoc.exists) return null;

      final studentData = _toMap(studentDoc);
      final courseDocs = await _coursesRef
          .where('studentId', isEqualTo: studentId)
          .get();

      final courses = courseDocs.docs
          .where((doc) => doc.exists)
          .map((doc) {
            try {
              return Course.fromJson(_toMap(doc));
            } catch (e) {
              print('Error parsing course: $e');
              return null;
            }
          })
          .whereType<Course>()
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
      print('Error fetching student with courses: $e');
      return null;
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
          .where((doc) => doc.exists)
          .map((doc) {
            try {
              return Course.fromJson(_toMap(doc));
            } catch (e) {
              print('Error parsing course for GPA: $e');
              return null;
            }
          })
          .whereType<Course>()
          .toList();

      if (courses.isEmpty) {
        await _studentsRef.doc(studentId).update({'gpa': 0.0});
        return;
      }

      // Calculate weighted GPA: sum(grade * credits) / sum(credits)
      double totalWeightedGrade = 0;
      int totalCredits = 0;
      for (var course in courses) {
        totalWeightedGrade += course.grade * course.credits;
        totalCredits += course.credits;
      }

      double gpa = totalCredits > 0
          ? (totalWeightedGrade / totalCredits) * (4.0 / 10.0)
          : 0.0;

      // Round to 2 decimal places
      gpa = double.parse(gpa.toStringAsFixed(2));

      await _studentsRef.doc(studentId).update({'gpa': gpa});
    } catch (e) {
      print('Error updating GPA: $e');
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
