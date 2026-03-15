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
    return Course(
      id: json['id'] ?? '',
      studentId: json['studentId'] ?? '',
      name: json['name'] ?? '',
      semester: json['semester'] ?? '',
      credits: json['credits'] ?? 0,
      grade: (json['grade'] ?? 0.0).toDouble(),
    );
  }
}
