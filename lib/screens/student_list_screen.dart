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
        title: const Text('Danh sách sinh viên'),
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

                final width = MediaQuery.of(context).size.width;
                final crossAxisCount = width > 800 ? 2 : 1;

                if (crossAxisCount == 1) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    child: ListView.builder(
                      itemCount: filteredStudents.length,
                      itemBuilder: (context, index) {
                        return StudentCard(student: filteredStudents[index]);
                      },
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      mainAxisExtent: 140,
                    ),
                    itemCount: filteredStudents.length,
                    itemBuilder: (context, index) {
                      return StudentCard(student: filteredStudents[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
