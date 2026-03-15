class Course {
  String id;
  String studentId;
  String name;
  String semester;
  int credits;
  double grade;

  Course({
    required this.id,
    required this.studentId,
    required this.name,
    required this.semester,
    required this.credits,
    required this.grade,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'name': name,
      'semester': semester,
      'credits': credits,
      'grade': grade,
    };
  }

  factory Course.fromJson(Map<String, dynamic> json) {
    try {
      return Course(
        id: _safeString(json['id']),
        studentId: _safeString(json['studentId']),
        name: _safeString(json['name']),
        semester: _safeString(json['semester']),
        credits: _safeInt(json['credits']),
        grade: _safeDouble(json['grade']),
      );
    } catch (e) {
      print('Error parsing course: $e');
      // Return default course on parse error
      return Course(
        id: '',
        studentId: '',
        name: '',
        semester: '',
        credits: 0,
        grade: 0.0,
      );
    }
  }

  static String _safeString(dynamic value) {
    try {
      if (value == null) return '';
      if (value is String) return value;
      return value.toString();
    } catch (e) {
      return '';
    }
  }

  static int _safeInt(dynamic value) {
    try {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is num) return value.toInt();
      return 0;
    } catch (e) {
      return 0;
    }
  }

  static double _safeDouble(dynamic value) {
    try {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }
}
