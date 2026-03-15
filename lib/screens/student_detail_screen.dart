import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/student.dart';
import '../models/course.dart';
import '../providers/student_provider.dart';
import 'package:intl/intl.dart';
import 'add_edit_student_screen.dart';

class StudentDetailScreen extends StatelessWidget {
  final Student student;

  const StudentDetailScreen({super.key, required this.student});

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
                  builder: (context) => AddEditStudentScreen(student: student),
                ),
              );
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
          children: [
            _buildHeader(context),
            _buildInfoTabs(context),
          ],
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
            tag: 'avatar_${student.id}',
            child: CircleAvatar(
              radius: 50,
              backgroundImage: CachedNetworkImageProvider(student.avatarUrl),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  student.studentId,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    student.major,
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
              children: [
                _buildInfoList(),
                _buildCourseList(context),
              ],
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
        _buildInfoItem(Icons.email, 'Email', student.email),
        _buildInfoItem(Icons.phone, 'Số điện thoại', student.phone),
        _buildInfoItem(Icons.calendar_today, 'Ngày nhập học', DateFormat('dd/MM/yyyy').format(student.enrollmentDate)),
        _buildInfoItem(Icons.grade, 'GPA hiện tại', student.gpa.toStringAsFixed(2)),
        _buildInfoItem(Icons.note, 'Ghi chú', student.notes),
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
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
      stream: provider.getStudentCourses(student.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final courses = snapshot.data ?? [];
        
        if (courses.isEmpty) {
          return const Center(child: Text('Chưa có thông tin môn học.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: courses.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final course = courses[index];
            return ListTile(
              title: Text(course.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${course.semester} • ${course.credits} tín chỉ'),
              trailing: Container(
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
            );
          },
        );
      },
    );
  }

  Color _getGradeColor(double grade) {
    if (grade >= 8.5) return Colors.green;
    if (grade >= 7.0) return Colors.blue;
    if (grade >= 5.0) return Colors.orange;
    return Colors.red;
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa sinh viên ${student.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              await Provider.of<StudentProvider>(context, listen: false)
                  .deleteStudent(student.id);
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
}
