import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';
import '../widgets/student_card.dart';
import '../widgets/search_filter_bar.dart';

class StudentListScreen extends StatelessWidget {
  const StudentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TH5 - Nhóm 11'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SearchFilterBar(),
          Expanded(
            child: Consumer<StudentProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filteredStudents = provider.filteredStudents;

                if (filteredStudents.isEmpty) {
                  return const Center(
                    child: Text('Không tìm thấy sinh viên nào.'),
                  );
                }

                return ListView.builder(
                  itemCount: filteredStudents.length,
                  itemBuilder: (context, index) {
                    return StudentCard(student: filteredStudents[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
