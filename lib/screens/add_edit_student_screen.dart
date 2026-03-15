import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/student.dart';
import '../providers/student_provider.dart';
import 'package:intl/intl.dart';

class AddEditStudentScreen extends StatefulWidget {
  final Student? student;

  const AddEditStudentScreen({super.key, this.student});

  @override
  State<AddEditStudentScreen> createState() => _AddEditStudentScreenState();
}

class _AddEditStudentScreenState extends State<AddEditStudentScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _studentIdController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _notesController;

  final List<String> _majors = [
    'Công nghệ thông tin',
    'Kế toán',
    'Ngôn ngữ Anh',
    'Kinh doanh quốc tế',
    'Marketing',
    'Kỹ thuật phần mềm',
  ];

  late String _selectedMajor = _majors.first;
  late DateTime _enrollmentDate = DateTime.now();
  File? _selectedImageFile;
  bool _isUploadingImage = false;
  Student? _loadedStudent; // Track full student data with courses

  @override
  void initState() {
    super.initState();
    final s = widget.student;

    // Initialize controllers immediately (synchronously)
    _nameController = TextEditingController(text: s?.name ?? '');
    _studentIdController = TextEditingController(text: s?.studentId ?? '');
    _emailController = TextEditingController(text: s?.email ?? '');
    _phoneController = TextEditingController(text: s?.phone ?? '');
    _notesController = TextEditingController(text: s?.notes ?? '');

    _selectedMajor = s?.major ?? _majors.first;
    _enrollmentDate = s?.enrollmentDate ?? DateTime.now();

    // Load full student data with courses asynchronously
    if (s != null) {
      _loadStudentWithCourses(s.id);
    }
  }

  Future<void> _loadStudentWithCourses(String studentId) async {
    try {
      final provider = Provider.of<StudentProvider>(context, listen: false);
      final fullStudent = await provider.getStudentWithCourses(studentId);
      if (mounted && fullStudent != null) {
        setState(() {
          _loadedStudent = fullStudent;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi tải dữ liệu: $e')));
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _enrollmentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _enrollmentDate) {
      setState(() {
        _enrollmentDate = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImageFile = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi chọn ảnh: $e')));
      }
    }
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() => _isUploadingImage = true);

        // Use image path if selected, otherwise use existing or empty
        String finalAvatarUrl = (widget.student?.avatarUrl ?? '').toString();
        if (_selectedImageFile != null) {
          final path = _selectedImageFile!.path;
          // Only set path if it's not empty (web might return empty)
          if (path.isNotEmpty) {
            finalAvatarUrl = path.toString();
          }
        }

        final provider = Provider.of<StudentProvider>(context, listen: false);

        // Get existing GPA if editing
        double gpa = 0.0;
        if (widget.student != null) {
          gpa = widget.student!.gpa;
        }

        final student = Student(
          id: widget.student?.id ?? const Uuid().v4(),
          name: _nameController.text.trim(),
          studentId: _studentIdController.text.trim(),
          major: _selectedMajor,
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          avatarUrl: finalAvatarUrl,
          notes: _notesController.text.trim(),
          gpa: gpa,
          enrollmentDate: _enrollmentDate,
          courses:
              _loadedStudent?.courses ?? widget.student?.courses ?? const [],
        );

        if (widget.student == null) {
          await provider.addStudent(student);
        } else {
          await provider.updateStudent(student);
        }

        // Update GPA after saving student
        await provider.updateStudentGPA(student.id);

        if (mounted) {
          setState(() => _isUploadingImage = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.student == null
                    ? 'Thêm sinh viên thành công'
                    : 'Cập nhật thành công',
              ),
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isUploadingImage = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.student != null;

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
                isEditing ? 'Cập nhật thông tin' : 'Thêm sinh viên mới',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildAvatarPicker(),
              const SizedBox(height: 24),
              _buildTextField(_nameController, 'Họ và tên', Icons.person),
              _buildTextField(
                _studentIdController,
                'Mã số sinh viên',
                Icons.badge,
              ),
              _buildDropdown(),
              _buildTextField(
                _emailController,
                'Email',
                Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              _buildTextField(
                _phoneController,
                'Số điện thoại',
                Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              _buildDatePicker(),
              _buildTextField(
                _notesController,
                'Ghi chú',
                Icons.note,
                maxLines: 3,
                isRequired: false,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isUploadingImage ? null : _saveForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isUploadingImage
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
                    : Text(isEditing ? 'Cập nhật' : 'Lưu thông tin'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarPicker() {
    final hasNewImage = _selectedImageFile != null;
    final hasOldImage =
        widget.student != null &&
        widget.student!.avatarUrl.isNotEmpty &&
        !kIsWeb;

    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade200,
            border: Border.all(
              color: hasNewImage ? Colors.green : Colors.grey,
              width: 2,
            ),
          ),
          child: hasNewImage
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: Image.file(_selectedImageFile!, fit: BoxFit.cover),
                )
              : hasOldImage
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: Image.file(
                    File(widget.student!.avatarUrl),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.person, size: 60),
                  ),
                )
              : const Icon(Icons.person, size: 60),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.photo_library),
          label: const Text('Tải ảnh đại diện (tùy chọn)'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
    int maxLines = 1,
    bool isRequired = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return 'Vui lòng nhập $label';
          }
          if (label == 'Email' &&
              value != null &&
              value.isNotEmpty &&
              !value.contains('@')) {
            return 'Email không hợp lệ';
          }

          if (label == 'Số điện thoại' &&
              value != null &&
              value.isNotEmpty &&
              value.length < 10) {
            return 'Số điện thoại phải ít nhất 10 chữ số';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: _selectedMajor,
        decoration: InputDecoration(
          labelText: 'Ngành học',
          prefixIcon: const Icon(Icons.school),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: _majors
            .map((m) => DropdownMenuItem(value: m, child: Text(m)))
            .toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedMajor = value;
            });
          }
        },
      ),
    );
  }

  Widget _buildDatePicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () => _selectDate(context),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Ngày nhập học',
            prefixIcon: const Icon(Icons.calendar_today),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(DateFormat('dd/MM/yyyy').format(_enrollmentDate)),
        ),
      ),
    );
  }
}
