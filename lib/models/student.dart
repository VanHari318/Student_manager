import 'course.dart';

class Student {
  final String id;
  String name;
  String studentId;
  String major;
  String email;
  String phone;
  String avatarUrl;
  String notes;
  double gpa;
  DateTime enrollmentDate;
  List<Course> courses;

  Student({
    required this.id,
    required this.name,
    required this.studentId,
    required this.major,
    required this.email,
    required this.phone,
    this.avatarUrl = '',
    required this.notes,
    required this.gpa,
    required this.enrollmentDate,
    required this.courses,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'studentId': studentId,
      'major': major,
      'email': email,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'notes': notes,
      'gpa': gpa,
      'enrollmentDate': enrollmentDate.toIso8601String(),
      'courses': courses.map((c) => c.toJson()).toList(),
    };
  }

  factory Student.fromJson(Map<String, dynamic> json) {
    var courseList = json['courses'] as List<dynamic>? ?? [];
    List<Course> parsedCourses = courseList
        .map(
          (courseJson) => Course.fromJson(courseJson as Map<String, dynamic>),
        )
        .toList();

    return Student(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      studentId: json['studentId'] ?? '',
      major: json['major'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      notes: json['notes'] ?? '',
      gpa: (json['gpa'] ?? 0.0).toDouble(),
      enrollmentDate: json['enrollmentDate'] != null
          ? DateTime.tryParse(json['enrollmentDate']) ?? DateTime.now()
          : DateTime.now(),
      courses: parsedCourses,
    );
  }

  factory Student.fromFirestore(Map<String, dynamic> data, String docId) {
    Student student = Student.fromJson(data);
    return Student(
      id: docId,
      name: student.name,
      studentId: student.studentId,
      major: student.major,
      email: student.email,
      phone: student.phone,
      avatarUrl: student.avatarUrl,
      notes: student.notes,
      gpa: student.gpa,
      enrollmentDate: student.enrollmentDate,
      courses: student.courses,
    );
  }
}
