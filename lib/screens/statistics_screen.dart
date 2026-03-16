import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/student_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TH5 - Nhóm 11'),
        centerTitle: true,
      ),
      body: Consumer<StudentProvider>(
        builder: (context, provider, child) {
          if (provider.students.isEmpty) {
            return const Center(child: Text('Không có dữ liệu thống kê.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thống kê học tập',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                _buildGpaDistribution(context, provider),
                const SizedBox(height: 24),
                _buildMajorTabs(context, provider),
                const SizedBox(height: 16),
                _buildMajorDistribution(context, provider),
                const SizedBox(height: 24),
                _buildCohortDistribution(context, provider),
                const SizedBox(height: 24),
                _buildCourseDistribution(context, provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCohortDistribution(BuildContext context, StudentProvider provider) {
    // Group students by enrollment year (khóa)
    final cohortCounts = <int, int>{};
    for (var s in provider.students) {
      final year = s.enrollmentDate.year;
      cohortCounts[year] = (cohortCounts[year] ?? 0) + 1;
    }

    final sortedCohorts = cohortCounts.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Số lượng theo Khóa', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...sortedCohorts.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Khóa ${entry.key}', style: const TextStyle(fontWeight: FontWeight.w500)),
                      Text('${entry.value} SV'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: entry.value / (provider.students.isEmpty ? 1 : provider.students.length),
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.teal),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseDistribution(BuildContext context, StudentProvider provider) {
    // Count distinct students per course name across all students
    final courseCounts = <String, int>{};
    for (var s in provider.students) {
      final seen = <String>{};
      for (var c in s.courses) {
        final name = c.name.trim();
        if (name.isEmpty) continue;
        if (seen.contains(name)) continue;
        seen.add(name);
        courseCounts[name] = (courseCounts[name] ?? 0) + 1;
      }
    }

    final sortedCourses = courseCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Số lượng theo Môn học', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (sortedCourses.isEmpty) const Text('Không có dữ liệu môn học.'),
            ...sortedCourses.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w500))),
                      Text('${entry.value} SV'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: entry.value / (provider.students.isEmpty ? 1 : provider.students.length),
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.indigo),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildGpaDistribution(BuildContext context, StudentProvider provider) {
    // Group students by GPA ranges
    final ranges = {
      'Xuất sắc (>=3.6)': provider.students.where((s) => s.gpa >= 3.6).length,
      'Giỏi (3.2-3.59)': provider.students.where((s) => s.gpa >= 3.2 && s.gpa < 3.6).length,
      'Khá (2.5-3.19)': provider.students.where((s) => s.gpa >= 2.5 && s.gpa < 3.2).length,
      'Trung bình (<2.5)': provider.students.where((s) => s.gpa < 2.5).length,
    };

    final total = provider.students.length;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Phân loại theo GPA', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    _pieSection(ranges['Xuất sắc (>=3.6)']!, total, 'XS', Colors.green),
                    _pieSection(ranges['Giỏi (3.2-3.59)']!, total, 'G', Colors.blue),
                    _pieSection(ranges['Khá (2.5-3.19)']!, total, 'K', Colors.orange),
                    _pieSection(ranges['Trung bình (<2.5)']!, total, 'TB', Colors.red),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildLegend(ranges),
          ],
        ),
      ),
    );
  }

  PieChartSectionData _pieSection(int count, int total, String label, Color color) {
    final percentage = total == 0 ? 0.0 : (count / total) * 100;
    return PieChartSectionData(
      color: color,
      value: count.toDouble(),
      title: '${percentage.toStringAsFixed(0)}%',
      radius: 50,
      titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  Widget _buildLegend(Map<String, int> ranges) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _legendItem('Xuất sắc', Colors.green),
        _legendItem('Giỏi', Colors.blue),
        _legendItem('Khá', Colors.orange),
        _legendItem('Trung bình', Colors.red),
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildMajorDistribution(BuildContext context, StudentProvider provider) {
    // Count per major
    final majorCounts = <String, int>{};
    for (var s in provider.students) {
      majorCounts[s.major] = (majorCounts[s.major] ?? 0) + 1;
    }

    final sortedMajors = majorCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Số lượng theo Ngành học', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...sortedMajors.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w500)),
                      Text('${entry.value} SV'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: entry.value / provider.students.length,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                    borderRadius: BorderRadius.circular(10),
                    minHeight: 8,
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  // Builds a TabBar of majors where each tab shows GPA pie chart for that major.
  Widget _buildMajorTabs(BuildContext context, StudentProvider provider) {
    final majors = provider.availableMajors;
    if (majors.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DefaultTabController(
          length: majors.length,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: Text('Phân tích theo Ngành', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              TabBar(
                isScrollable: true,
                tabs: majors.map((m) => Tab(text: m)).toList(),
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Theme.of(context).primaryColor,
              ),
              SizedBox(
                height: 260,
                child: TabBarView(
                  children: majors.map((major) {
                    return Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: _buildGpaPieForMajor(context, provider, major),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable chart for a specific major - uses provider.getGPAStatisticsByMajor
  Widget _buildGpaPieForMajor(BuildContext context, StudentProvider provider, String major) {
    final ranges = provider.getGPAStatisticsByMajor(major);
    final total = ranges.values.fold<int>(0, (p, e) => p + e);

    return Column(
      children: [
        Text(major, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: total == 0
              ? const Center(child: Text('Không có sinh viên trong ngành này.'))
              : PieChart(
                  PieChartData(
                    sections: [
                      _pieSection(ranges['Xuất sắc'] ?? 0, total, 'XS', Colors.green),
                      _pieSection(ranges['Giỏi'] ?? 0, total, 'G', Colors.blue),
                      _pieSection(ranges['Khá'] ?? 0, total, 'K', Colors.orange),
                      _pieSection(ranges['Trung bình'] ?? 0, total, 'TB', Colors.red),
                    ],
                    sectionsSpace: 2,
                    centerSpaceRadius: 36,
                  ),
                ),
        ),
        const SizedBox(height: 8),
        _buildLegend({
          'Xuất sắc (>=3.6)': ranges['Xuất sắc'] ?? 0,
          'Giỏi (3.2-3.59)': ranges['Giỏi'] ?? 0,
          'Khá (2.5-3.19)': ranges['Khá'] ?? 0,
          'Trung bình (<2.5)': ranges['Trung bình'] ?? 0,
        }),
      ],
    );
  }
}
