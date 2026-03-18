import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import '../models/student.dart';
import '../providers/student_provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../services/cloudinary_service.dart';

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
  late TextEditingController _avatarUrlController;
  Student? _loadedStudent;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

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
    _avatarUrlController = TextEditingController(text: s?.avatarUrl ?? '');

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
    _avatarUrlController.dispose();
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

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final provider = Provider.of<StudentProvider>(context, listen: false);

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
          avatarUrl: _avatarUrlController.text.trim(),
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

        await provider.updateStudentGPA(student.id);

        if (mounted) {
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
                onPressed: _saveForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(isEditing ? 'Cập nhật' : 'Lưu thông tin'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() {
        _isUploading = true;
      });

      final File imageFile = File(pickedFile.path);
      final String? imageUrl = await CloudinaryService.uploadImage(imageFile);

      if (mounted) {
        if (imageUrl != null) {
          setState(() {
            _avatarUrlController.text = imageUrl;
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Tải ảnh lên thành công!')));
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Tải ảnh lên thất bại.')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Widget _buildAvatarPicker() {
    final currentUrl = _avatarUrlController.text.trim();
    final isUrl = currentUrl.startsWith('http');

    return Column(
      children: [
        // Preview Container
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200,
                border: Border.all(
                  color: currentUrl.isNotEmpty ? Colors.blue : Colors.grey,
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: currentUrl.isEmpty
                    ? const Icon(Icons.person, size: 60)
                    : isUrl
                    ? Image.network(
                        currentUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.image_not_supported, size: 60),
                      )
                    : const Icon(Icons.image_not_supported, size: 60),
              ),
            ),
            if (_isUploading)
              const SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Upload Button
        ElevatedButton.icon(
          onPressed: _isUploading ? null : _pickAndUploadImage,
          icon: const Icon(Icons.cloud_upload),
          label: Text(_isUploading ? 'Đang tải lên...' : 'Tải ảnh lên'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
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
