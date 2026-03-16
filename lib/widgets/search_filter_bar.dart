import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';

class SearchFilterBar extends StatefulWidget {
  const SearchFilterBar({super.key});

  @override
  State<SearchFilterBar> createState() => _SearchFilterBarState();
}

class _SearchFilterBarState extends State<SearchFilterBar> {
  late TextEditingController _controller;
  StudentProvider? _provider;

  void _onProviderChanged() {
    if (!mounted) return;
    final newQuery = _provider?.searchQuery ?? '';
    if (_controller.text != newQuery) {
      _controller.text = newQuery;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final prov = Provider.of<StudentProvider>(context);
    if (_provider != prov) {
      _provider?.removeListener(_onProviderChanged);
      _provider = prov;
      _controller.text = _provider?.searchQuery ?? '';
      _provider?.addListener(_onProviderChanged);
    }
  }

  @override
  void dispose() {
    _provider?.removeListener(_onProviderChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            onChanged: (value) {
              Provider.of<StudentProvider>(
                context,
                listen: false,
              ).setSearchQuery(value);
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
          Consumer<StudentProvider>(
            builder: (context, provider, child) {
              final majors = provider.availableMajors;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(context, 'Tất cả', null),
                    const SizedBox(width: 8),
                    ...majors.map(
                      (m) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: _buildFilterChip(context, m, m),
                      ),
                    ),
                  ],
                ),
              );
            },
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
                    value: provider.sortBy,
                    onChanged: (value) {
                      if (value != null) {
                        provider.setSortBy(value);
                      }
                    },
                    items: const [
                      DropdownMenuItem(
                        value: 'name_asc',
                        child: Text('Tên (A-Z)'),
                      ),
                      DropdownMenuItem(
                        value: 'name_desc',
                        child: Text('Tên (Z-A)'),
                      ),
                      DropdownMenuItem(
                        value: 'gpa_desc',
                        child: Text('GPA Cao nhất'),
                      ),
                      DropdownMenuItem(
                        value: 'gpa_asc',
                        child: Text('GPA Thấp nhất'),
                      ),
                      DropdownMenuItem(
                        value: 'recent_first',
                        child: Text('Mới thêm trước'),
                      ),
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
        final selected = (provider.selectedMajor ?? '') == (major ?? '');
        return FilterChip(
          label: Text(label),
          selected: selected,
          onSelected: (selected) {
            provider.setSelectedMajor(selected ? major : null);
          },
        );
      },
    );
  }
}
