import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/student_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('TH5 - Nhóm 11'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
      body: Consumer<StudentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   const Icon(Icons.error_outline, size: 48, color: Colors.red),
                   const SizedBox(height: 16),
                   Text('Lỗi: ${provider.error}', textAlign: TextAlign.center),
                   const SizedBox(height: 16),
                   ElevatedButton(
                     onPressed: () => provider.fetchSampleFromApi(),
                     child: const Text('Thử lại'),
                   )
                ],
              ),
            );
          }

          final topStudents = provider.filteredStudents.take(5).toList();

          return RefreshIndicator(
            onRefresh: () async {
              // Usually we don't need to refresh manually with stream
              // but we can add a small delay
              await Future.delayed(const Duration(seconds: 1));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dashboard Stats
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: 'Tổng Sinh Viên',
                            value: provider.totalStudents.toString(),
                            icon: Icons.people_alt,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: StatCard(
                            title: 'Điểm TB',
                            value: provider.averageGpa.toStringAsFixed(2),
                            icon: Icons.analytics,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Quick Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionBtn(
                          context,
                          icon: Icons.add,
                          label: 'Thêm Mới',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Navigation to Add Screen pending...'))
                            );
                          },
                        ),
                        _buildActionBtn(
                          context,
                          icon: Icons.list,
                          label: 'Tất Cả',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Navigation to List Screen pending...'))
                            );
                          },
                        ),
                        _buildActionBtn(
                          context,
                          icon: Icons.pie_chart,
                          label: 'Thống Kê',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Navigation to Stats Screen pending...'))
                            );
                          },
                        ),
                        _buildActionBtn(
                          context, 
                          icon: Icons.download,
                          label: 'Tải Mẫu',
                          onTap: () async {
                            await provider.fetchSampleFromApi();
                            if(context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Đã tải DL mẫu'))
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Recent students
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Mới cập nhật',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to all students
                          },
                          child: const Text('Xem tất cả'),
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    if (topStudents.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text('Chưa có sinh viên nào. Vui lòng tải mẫu hoặc thêm mới.'),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: topStudents.length,
                        itemBuilder: (context, index) {
                          return StudentCard(student: topStudents[index]);
                        },
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionBtn(
      BuildContext context, {
      required IconData icon,
      required String label,
      required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Theme.of(context).primaryColor),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
