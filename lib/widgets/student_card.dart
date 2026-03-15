import 'package:flutter/material.dart';
import 'dart:io';
import '../models/student.dart';
import '../screens/student_detail_screen.dart';

class StudentCard extends StatelessWidget {
  final Student student;

  const StudentCard({super.key, required this.student});

  Widget _buildAvatar(BuildContext context) {
    final url = student.avatarUrl.trim();
    final isUrl = url.startsWith('http');
    final isPath =
        url.isNotEmpty &&
        !isUrl &&
        (url.startsWith('/') || url.contains(':\\'));

    final placeholder = Container(
      width: 50,
      height: 50,
      color: Colors.grey.shade200,
      child: const Icon(Icons.person, color: Colors.blue),
    );

    if (url.isEmpty) return placeholder;

    if (isUrl) {
      return Image.network(
        url,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => placeholder,
      );
    }

    if (isPath) {
      return Image.file(
        File(url),
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => placeholder,
      );
    }

    return placeholder;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Hero(
          tag: 'avatar_${student.id}',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildAvatar(context),
          ),
        ),
        title: Text(
          student.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${student.studentId} • ${student.major}'),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.grade, size: 16, color: Colors.orange),
                const SizedBox(width: 4),
                Text(
                  student.gpa.toStringAsFixed(2),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StudentDetailScreen(student: student),
            ),
          );
        },
      ),
    );
  }
}
