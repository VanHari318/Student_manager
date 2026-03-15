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
                _buildMajorDistribution(context, provider),
              ],
            ),
          );
        },
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
}
