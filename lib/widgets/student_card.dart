import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../models/student.dart';

class StudentCard extends StatelessWidget {
  final Student student;

  const StudentCard({Key? key, required this.student}) : super(key: key);

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
            child: CachedNetworkImage(
              imageUrl: student.avatarUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(color: Colors.white, width: 50, height: 50),
              ),
              errorWidget: (context, url, error) => Container(
                width: 50,
                height: 50,
                color: Theme.of(context).primaryColor.withOpacity(0.2),
                child: const Icon(Icons.person, color: Colors.blue),
              ),
            ),
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
                  style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.orange),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // TODO: Navigate to Detail Screen
        },
      ),
    );
  }
}
