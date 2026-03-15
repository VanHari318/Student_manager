import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/student.dart';
import '../models/course.dart';

class ApiService {
  final String _baseUrl = 'https://randomuser.me/api/';
  final _uuid = const Uuid();

  Future<List<Student>> fetchSampleStudents(int count) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl?results=$count'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        return results.map((user) {
          final dob = DateTime.parse(user['dob']['date']);
          // Generate a sample enrollment date
          final enrollDate = dob.add(const Duration(days: 18 * 365));

          return Student(
            id: _uuid.v4(),
            name: '${user['name']['first']} ${user['name']['last']}',
            studentId: 'SV${user['login']['salt'].toString().substring(0, 6).toUpperCase()}',
            major: _getRandomMajor(),
            email: user['email'],
            phone: user['phone'],
            avatarUrl: user['picture']['large'],
            notes: 'Sample generated data',
            gpa: _getRandomGpa(),
            enrollmentDate: enrollDate,
            courses: _generateSampleCourses(),
          );
        }).toList();
      } else {
        throw Exception('Failed to load sample data');
      }
    } catch (e) {
      throw Exception('Error fetching sample data: $e');
    }
  }

  String _getRandomMajor() {
    const majors = [
      'Công nghệ thông tin',
      'Kế toán',
      'Ngôn ngữ Anh',
      'Kinh doanh quốc tế',
      'Marketing',
      'Kỹ thuật phần mềm'
    ];
    majors.shuffle();
    return majors.first;
  }

  double _getRandomGpa() {
    final list = [2.5, 3.0, 3.2, 3.5, 3.8, 4.0, 2.0];
    list.shuffle();
    return list.first;
  }

  List<Course> _generateSampleCourses() {
    return [
      Course(
        id: _uuid.v4(),
        name: 'Lập trình Flutter',
        semester: 'Kỳ 1',
        credits: 3,
        grade: 8.5,
      ),
      Course(
        id: _uuid.v4(),
        name: 'Cơ sở dữ liệu',
        semester: 'Kỳ 1',
        credits: 3,
        grade: 7.0,
      )
    ];
  }
}
