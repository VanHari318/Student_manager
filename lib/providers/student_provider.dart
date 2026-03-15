import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/student.dart';
import '../models/course.dart';
import '../services/firestore_service.dart';
import '../services/api_service.dart';

class StudentProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final ApiService _apiService = ApiService();

  Stream<List<Course>> getStudentCourses(String studentId) {
    return _firestoreService.streamCourses(studentId);
  }

  // Get student with courses loaded (for edit screen)
  Future<Student?> getStudentWithCourses(String studentId) async {
    return _firestoreService.getStudentWithCourses(studentId);
  }

  List<Student> _students = [];
  bool _isLoading = false;
  String _error = '';

  late StreamSubscription<List<Student>> _studentsSubscription;

  // Filters
  String _searchQuery = '';
  String? _selectedMajor;
  String _sortBy = 'recent_first'; // Show newly added students first

  StudentProvider() {
    _initStream();
  }

  void _initStream() {
    _isLoading = true;
    notifyListeners();

    _studentsSubscription = _firestoreService.streamStudents().listen(
      (studentList) {
        _students = studentList;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _studentsSubscription.cancel();
    super.dispose();
  }

  List<Student> get students => _students;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Filtered and Sorted Students
  List<Student> get filteredStudents {
    List<Student> filtered = _students.where((student) {
      bool matchesSearch =
          student.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          student.studentId.toLowerCase().contains(_searchQuery.toLowerCase());
      bool matchesMajor =
          _selectedMajor == null ||
          _selectedMajor!.isEmpty ||
          student.major == _selectedMajor;
      return matchesSearch && matchesMajor;
    }).toList();

    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'gpa_desc':
          return b.gpa.compareTo(a.gpa);
        case 'gpa_asc':
          return a.gpa.compareTo(b.gpa);
        case 'name_desc':
          return b.name.compareTo(a.name);
        case 'recent_first':
          return b.enrollmentDate.compareTo(a.enrollmentDate);
        case 'name_asc':
        default:
          return a.name.compareTo(b.name);
      }
    });

    return filtered;
  }

  // Dashboard stats
  int get totalStudents => _students.length;
  double get averageGpa => _students.isEmpty
      ? 0
      : _students.map((e) => e.gpa).reduce((a, b) => a + b) / _students.length;
  int get totalMajors => _students.map((e) => e.major).toSet().length;

  // Actions
  Future<void> addStudent(Student student) =>
      _firestoreService.addStudent(student);
  Future<void> updateStudent(Student student) =>
      _firestoreService.updateStudent(student);
  Future<void> deleteStudent(String id) => _firestoreService.deleteStudent(id);

  // Course Actions
  Future<void> addCourse(Course course) => _firestoreService.addCourse(course);
  Future<void> updateCourse(Course course) =>
      _firestoreService.updateCourse(course);
  Future<void> deleteCourse(String courseId) =>
      _firestoreService.deleteCourse(courseId);
  Future<void> updateStudentGPA(String studentId) =>
      _firestoreService.updateStudentGPA(studentId);
  Future<bool> checkDuplicateCourseName(
    String studentId,
    String courseName, {
    String? excludeCourseId,
  }) => _firestoreService.checkDuplicateCourseName(
    studentId,
    courseName,
    excludeCourseId: excludeCourseId,
  );

  // Clear all data from Firestore (for fixing CORS issues or fresh start)
  Future<void> clearAllFirestoreData() async {
    try {
      _isLoading = true;
      notifyListeners();
      await _firestoreService.deleteAllData();
      _error = '';
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSampleFromApi() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Clear old data first to avoid mix with English names & CORS issues
      await _firestoreService.deleteAllData();

      final newStudents = await _apiService.fetchSampleStudents(30);
      for (var student in newStudents) {
        await _firestoreService.addStudent(student);
      }

      _error = '';
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Set Filters
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedMajor(String? major) {
    _selectedMajor = major;
    notifyListeners();
  }

  void setSortBy(String sortBy) {
    _sortBy = sortBy;
    notifyListeners();
  }
}
