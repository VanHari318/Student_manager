import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/student.dart';
import '../models/course.dart';
import '../providers/student_provider.dart';
import 'package:intl/intl.dart';
import 'add_edit_student_screen.dart';
import 'add_edit_course_screen.dart';

class StudentDetailScreen extends StatefulWidget {
  final Student student;

  const StudentDetailScreen({super.key, required this.student});

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  late Student _currentStudent;

  @override
  void initState() {
    super.initState();
    _currentStudent = widget.student;
  }

  Future<void> _refreshStudentData() async {
    final provider = Provider.of<StudentProvider>(context, listen: false);
    final updatedStudent = await provider.getStudentWithCourses(
      _currentStudent.id,
    );
    if (mounted && updatedStudent != null) {
      setState(() {
        _currentStudent = updatedStudent;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TH5 - Nhóm 11'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddEditStudentScreen(student: _currentStudent),
                ),
              ).then((_) => _refreshStudentData());
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [_buildHeader(context), _buildInfoTabs(context)],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
      ),
      child: Row(
        children: [
          Hero(
            tag: 'avatar_${_currentStudent.id}',
            child: _currentStudent.avatarUrl.isEmpty
                ? CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.2),
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.blue,
                    ),
                  )
                : CircleAvatar(
                    radius: 50,
                    backgroundImage: CachedNetworkImageProvider(
                      _currentStudent.avatarUrl,
                    ),
                    onBackgroundImageError: (exception, stackTrace) {
                      // Fallback icon if image fails to load
                    },
                  ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentStudent.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _currentStudent.studentId,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _currentStudent.major,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTabs(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Thông tin'),
              Tab(text: 'Môn học'),
            ],
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
          ),
          SizedBox(
            height: 400, // Fixed height for simplicity in this example
            child: TabBarView(
              children: [_buildInfoList(), _buildCourseList(context)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoItem(Icons.email, 'Email', _currentStudent.email),
        _buildInfoItem(Icons.phone, 'Số điện thoại', _currentStudent.phone),
        _buildInfoItem(
          Icons.calendar_today,
          'Ngày nhập học',
          DateFormat('dd/MM/yyyy').format(_currentStudent.enrollmentDate),
        ),
        _buildInfoItem(
          Icons.grade,
          'GPA hiện tại',
          _currentStudent.gpa.toStringAsFixed(2),
        ),
        _buildInfoItem(Icons.note, 'Ghi chú', _currentStudent.notes),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCourseList(BuildContext context) {
    final provider = Provider.of<StudentProvider>(context, listen: false);

    return StreamBuilder<List<Course>>(
      stream: provider.getStudentCourses(_currentStudent.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final courses = snapshot.data ?? [];

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddEditCourseScreen(studentId: _currentStudent.id),
                      ),
                    ).then((_) => _refreshStudentData());
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm môn học'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            Expanded(
              child: courses.isEmpty
                  ? const Center(child: Text('Chưa có thông tin môn học.'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: courses.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final course = courses[index];
                        return _buildCourseCard(context, course);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCourseCard(BuildContext context, Course course) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(
          course.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${course.semester} • ${course.credits} tín chỉ'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getGradeColor(course.grade).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                course.grade.toStringAsFixed(1),
                style: TextStyle(
                  color: _getGradeColor(course.grade),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditCourseScreen(
                      studentId: _currentStudent.id,
                      course: course,
                    ),
                  ),
                ).then((_) => _refreshStudentData());
              },
              tooltip: 'Sửa môn học',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: () => _showDeleteCourseDialog(context, course),
              tooltip: 'Xóa môn học',
            ),
          ],
        ),
        onLongPress: () {
          _showCourseOptions(context, course);
        },
      ),
    );
  }

  void _showCourseOptions(BuildContext context, Course course) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              course.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Sửa môn học'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditCourseScreen(
                      studentId: _currentStudent.id,
                      course: course,
                    ),
                  ),
                ).then((_) => _refreshStudentData());
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Xóa môn học'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteCourseDialog(context, course);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteCourseDialog(BuildContext context, Course course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa môn học "${course.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              final provider = Provider.of<StudentProvider>(
                context,
                listen: false,
              );
              await provider.deleteCourse(course.id);

              // Recalculate GPA after deleting course
              await provider.updateStudentGPA(_currentStudent.id);

              // Refresh student data to show updated GPA
              await _refreshStudentData();

              if (context.mounted) {
                Navigator.pop(context); // Close dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Xóa môn học thành công')),
                );
              }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc chắn muốn xóa sinh viên ${_currentStudent.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              await Provider.of<StudentProvider>(
                context,
                listen: false,
              ).deleteStudent(_currentStudent.id);
              if (context.mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to list
              }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Color _getGradeColor(double grade) {
    if (grade >= 8.5) return Colors.green;
    if (grade >= 7.0) return Colors.blue;
    if (grade >= 5.0) return Colors.orange;
    return Colors.red;
  }
}
