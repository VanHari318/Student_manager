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

          final sId = _uuid.v4();
          return Student(
            id: sId,
            name: _getRandomVietnameseName(),
            studentId: 'SV${user['login']['salt'].toString().substring(0, 6).toUpperCase()}',
            major: _getRandomMajor(),
            email: user['email'],
            phone: user['phone'],
            avatarUrl: user['picture']['large'],
            notes: 'Sample generated data',
            gpa: _getRandomGpa(),
            enrollmentDate: enrollDate,
            courses: _generateSampleCourses(sId),
          );
        }).toList();
      } else {
        throw Exception('Failed to load sample data');
      }
    } catch (e) {
      throw Exception('Error fetching sample data: $e');
    }
  }

  String _getRandomVietnameseName() {
    final lastNames = ['Nguyễn', 'Trần', 'Lê', 'Phạm', 'Hoàng', 'Huỳnh', 'Phan', 'Vũ', 'Võ', 'Đặng', 'Bùi', 'Đỗ', 'Hồ', 'Ngô', 'Dương', 'Lý'];
    final middleNames = ['Văn', 'Thị', 'Hoàng', 'Minh', 'Ngọc', 'Quốc', 'Tuấn', 'Phương', 'Hồng', 'Thanh', 'Đức', 'Gia'];
    final firstNames = ['Anh', 'Bình', 'Châu', 'Dương', 'Dũng', 'Hải', 'Hiếu', 'Hoà', 'Huy', 'Hùng', 'Hương', 'Hà', 'Khang', 'Khánh', 'Kiên', 'Lâm', 'Linh', 'Long', 'Minh', 'Nam', 'Nghĩa', 'Nhung', 'Phúc', 'Phương', 'Quang', 'Quân', 'Sơn', 'Tài', 'Tân', 'Thái', 'Thành', 'Thảo', 'Thắng', 'Thu', 'Trang', 'Trí', 'Trung', 'Tuấn', 'Tùng', 'Việt', 'Vinh', 'Xuân', 'Yến'];

    lastNames.shuffle();
    middleNames.shuffle();
    firstNames.shuffle();

    return '${lastNames.first} ${middleNames.first} ${firstNames.first}';
  }

  String _getRandomMajor() {
    return 'Công nghệ thông tin';
  }

  double _getRandomGpa() {
    final list = [2.5, 3.0, 3.2, 3.5, 3.8, 4.0, 2.0, 2.8, 3.6];
    list.shuffle();
    return list.first;
  }

  List<Course> _generateSampleCourses(String studentId) {
    final titles = [
      'Lập trình Flutter',
      'Cơ sở dữ liệu',
      'Cấu trúc dữ liệu và giải thuật',
      'Mạng máy tính',
      'Hệ điều hành',
      'Trí tuệ nhân tạo',
      'Kiến trúc máy tính',
      'Thiết kế phần mềm'
    ];
    
    return titles.map((title) {
      final grades = [7.0, 7.5, 8.0, 8.5, 9.0, 9.5, 6.5, 10.0];
      grades.shuffle();
      return Course(
        id: _uuid.v4(),
        studentId: studentId,
        name: title,
        semester: 'Kỳ 1',
        credits: 3,
        grade: grades.first,
      );
    }).toList();
  }
}
