import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/course.dart';
import '../providers/student_provider.dart';

class AddEditCourseScreen extends StatefulWidget {
  final String studentId;
  final Course? course;

  const AddEditCourseScreen({super.key, required this.studentId, this.course});

  @override
  State<AddEditCourseScreen> createState() => _AddEditCourseScreenState();
}

class _AddEditCourseScreenState extends State<AddEditCourseScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _courseNameController;
  late TextEditingController _semesterController;
  late TextEditingController _creditsController;
  late TextEditingController _gradeController;

  bool _isLoading = false;

  final List<String> _semesters = ['Kỳ 1', 'Kỳ 2', 'Kỳ Hè'];

  @override
  void initState() {
    super.initState();
    final c = widget.course;
    _courseNameController = TextEditingController(text: c?.name ?? '');
    _semesterController = TextEditingController(
      text: c?.semester ?? _semesters.first,
    );
    _creditsController = TextEditingController(
      text: c?.credits.toString() ?? '3',
    );
    _gradeController = TextEditingController(text: c?.grade.toString() ?? '');
  }

  @override
  void dispose() {
    _courseNameController.dispose();
    _semesterController.dispose();
    _creditsController.dispose();
    _gradeController.dispose();
    super.dispose();
  }

  void _saveCourse() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() => _isLoading = true);

        final provider = Provider.of<StudentProvider>(context, listen: false);
        final courseName = _courseNameController.text.trim();

        // Check for duplicate course names for this student
        final isDuplicate = await provider.checkDuplicateCourseName(
          widget.studentId,
          courseName,
          excludeCourseId: widget.course?.id,
        );

        if (isDuplicate) {
          if (mounted) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Môn học "$courseName" đã tồn tại cho sinh viên này',
                ),
              ),
            );
          }
          return;
        }

        final course = Course(
          id: widget.course?.id ?? const Uuid().v4(),
          studentId: widget.studentId,
          name: courseName,
          semester: _semesterController.text.trim(),
          credits: int.parse(_creditsController.text.trim()),
          grade: double.parse(_gradeController.text.trim()),
        );

        if (widget.course == null) {
          await provider.addCourse(course);
        } else {
          await provider.updateCourse(course);
        }

        // Update student GPA after adding/updating course
        await provider.updateStudentGPA(widget.studentId);

        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.course == null
                    ? 'Thêm môn học thành công'
                    : 'Cập nhật môn học thành công',
              ),
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.course != null;

    return Scaffold(
      appBar: AppBar(title: const Text('TH5 - Nhóm 11'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEditing ? 'Cập nhật môn học' : 'Thêm môn học mới',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildTextField(_courseNameController, 'Tên môn học', Icons.book),
              _buildSemesterDropdown(),
              _buildTextField(
                _creditsController,
                'Số tín chỉ',
                Icons.numbers,
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                _gradeController,
                'Điểm số (0-10)',
                Icons.grade,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveCourse,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(isEditing ? 'Cập nhật' : 'Thêm môn học'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Vui lòng nhập $label';
          }

          if (label == 'Số tín chỉ') {
            final credits = int.tryParse(value);
            if (credits == null || credits < 1) {
              return 'Số tín chỉ phải là số dương';
            }
          }

          if (label == 'Điểm số (0-10)') {
            final grade = double.tryParse(value);
            if (grade == null || grade < 0 || grade > 10) {
              return 'Điểm phải nằm trong khoảng 0-10';
            }
          }

          return null;
        },
      ),
    );
  }

  Widget _buildSemesterDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: _semesterController.text.isNotEmpty
            ? _semesterController.text
            : _semesters.first,
        decoration: InputDecoration(
          labelText: 'Học kỳ',
          prefixIcon: const Icon(Icons.calendar_month),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: _semesters
            .map((s) => DropdownMenuItem(value: s, child: Text(s)))
            .toList(),
        onChanged: (value) {
          if (value != null) {
            _semesterController.text = value;
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Vui lòng chọn học kỳ';
          }
          return null;
        },
      ),
    );
  }
}
