import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';

class SearchFilterBar extends StatelessWidget {
  const SearchFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            onChanged: (value) {
              Provider.of<StudentProvider>(context, listen: false)
                  .setSearchQuery(value);
            },
            decoration: InputDecoration(
              hintText: 'Tìm kiếm tên hoặc MSSV...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(context).cardColor,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(context, 'Tất cả', null),
                const SizedBox(width: 8),
                _buildFilterChip(context, 'Công nghệ thông tin', 'Công nghệ thông tin'),
                const SizedBox(width: 8),
                _buildFilterChip(context, 'Kế toán', 'Kế toán'),
                const SizedBox(width: 8),
                _buildFilterChip(context, 'Kỹ thuật phần mềm', 'Kỹ thuật phần mềm'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Consumer<StudentProvider>(
            builder: (context, provider, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Sắp xếp theo:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  DropdownButton<String>(
                    value: 'name_asc', // Default for now
                    onChanged: (value) {
                      if (value != null) {
                        provider.setSortBy(value);
                      }
                    },
                    items: const [
                      DropdownMenuItem(value: 'name_asc', child: Text('Tên (A-Z)')),
                      DropdownMenuItem(value: 'name_desc', child: Text('Tên (Z-A)')),
                      DropdownMenuItem(value: 'gpa_desc', child: Text('GPA Cao nhất')),
                      DropdownMenuItem(value: 'gpa_asc', child: Text('GPA Thấp nhất')),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, String? major) {
    return Consumer<StudentProvider>(
      builder: (context, provider, child) {
        return FilterChip(
          label: Text(label),
          selected: false, 
          onSelected: (selected) {
            provider.setSelectedMajor(major);
          },
        );
      },
    );
  }
}
