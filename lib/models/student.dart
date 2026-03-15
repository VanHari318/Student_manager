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
    // Safely serialize courses with fallback
    List<dynamic> coursesList = [];
    try {
      if (courses.isNotEmpty) {
        coursesList = courses
            .map((c) {
              try {
                return c.toJson();
              } catch (e) {
                print('Error converting course to JSON: $e');
                return null;
              }
            })
            .whereType<Map<String, dynamic>>()
            .toList();
      }
    } catch (e) {
      print('Error processing courses for toJson: $e');
      coursesList = [];
    }

    return {
      'id': id,
      'name': name,
      'studentId': studentId,
      'major': major,
      'email': email,
      'phone': phone,
      'avatarUrl': avatarUrl.toString().trim(),
      'notes': notes,
      'gpa': gpa,
      'enrollmentDate': enrollmentDate.toIso8601String(),
      'courses': coursesList,
    };
  }

  factory Student.fromJson(Map<String, dynamic> json) {
    // Safely get courses list with multi-layer protection
    List<Course> parsedCourses = [];
    try {
      final courseListRaw = json['courses'];

      if (courseListRaw != null &&
          courseListRaw is List &&
          courseListRaw.isNotEmpty) {
        for (var item in courseListRaw) {
          if (item == null) continue;

          try {
            // Convert to map if needed (handle web JS objects)
            Map<String, dynamic> courseMap;
            if (item is Map<String, dynamic>) {
              courseMap = item;
            } else if (item is Map) {
              // Deep convert map to ensure all keys are strings
              courseMap = {};
              for (var entry in item.entries) {
                courseMap[entry.key.toString()] = entry.value;
              }
            } else {
              continue;
            }

            // Ensure courseMap is not empty before parsing
            if (courseMap.isNotEmpty) {
              final course = Course.fromJson(courseMap);
              parsedCourses.add(course);
            }
          } catch (e) {
            print('Error parsing individual course: $e');
            continue;
          }
        }
      }
    } catch (e) {
      print('Error parsing courses list: $e');
      parsedCourses = [];
    }

    return Student(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      studentId: json['studentId']?.toString() ?? '',
      major: json['major']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      avatarUrl: (json['avatarUrl']?.toString() ?? '').trim(),
      notes: json['notes']?.toString() ?? '',
      gpa: _safeParseDouble(json['gpa']),
      enrollmentDate: _safeParseDatetime(json['enrollmentDate']),
      courses: parsedCourses,
    );
  }

  // Helper to safely parse double
  static double _safeParseDouble(dynamic value) {
    try {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    } catch (e) {
      print('Error parsing double: $e');
      return 0.0;
    }
  }

  // Helper to safely parse datetime
  static DateTime _safeParseDatetime(dynamic value) {
    try {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }
      return DateTime.now();
    } catch (e) {
      print('Error parsing datetime: $e');
      return DateTime.now();
    }
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
