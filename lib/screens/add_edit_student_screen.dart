import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
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
  late TextEditingController _avatarUrlController;
  late TextEditingController _notesController;
  late String _selectedMajor;
  late DateTime _enrollmentDate;
  
  final List<String> _majors = [
    'Công nghệ thông tin',
    'Kế toán',
    'Ngôn ngữ Anh',
    'Kinh doanh quốc tế',
    'Marketing',
    'Kỹ thuật phần mềm'
  ];

  @override
  void initState() {
    super.initState();
    final s = widget.student;
    _nameController = TextEditingController(text: s?.name ?? '');
    _studentIdController = TextEditingController(text: s?.studentId ?? '');
    _emailController = TextEditingController(text: s?.email ?? '');
    _phoneController = TextEditingController(text: s?.phone ?? '');
    _avatarUrlController = TextEditingController(text: s?.avatarUrl ?? 'https://i.pravatar.cc/300');
    _notesController = TextEditingController(text: s?.notes ?? '');
    _selectedMajor = s?.major ?? _majors.first;
    _enrollmentDate = s?.enrollmentDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _avatarUrlController.dispose();
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

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<StudentProvider>(context, listen: false);
      
      final student = Student(
        id: widget.student?.id ?? const Uuid().v4(),
        name: _nameController.text,
        studentId: _studentIdController.text,
        major: _selectedMajor,
        email: _emailController.text,
        phone: _phoneController.text,
        avatarUrl: _avatarUrlController.text,
        notes: _notesController.text,
        gpa: widget.student?.gpa ?? 0.0,
        enrollmentDate: _enrollmentDate,
        courses: widget.student?.courses ?? [], // We don't edit courses here for brevity
      );

      if (widget.student == null) {
        await provider.addStudent(student);
      } else {
        await provider.updateStudent(student);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.student != null;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('TH5 - Nhóm 11'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEditing ? 'Cập nhật thông tin' : 'Thêm sinh viên mới',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildTextField(_nameController, 'Họ và tên', Icons.person),
              _buildTextField(_studentIdController, 'Mã số sinh viên', Icons.badge),
              _buildDropdown(),
              _buildTextField(_emailController, 'Email', Icons.email, keyboardType: TextInputType.emailAddress),
              _buildTextField(_phoneController, 'Số điện thoại', Icons.phone, keyboardType: TextInputType.phone),
              _buildTextField(_avatarUrlController, 'Link Avatar', Icons.image),
              _buildDatePicker(),
              _buildTextField(_notesController, 'Ghi chú', Icons.note, maxLines: 3),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(isEditing ? 'Cập nhật' : 'Lưu thông tin'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, 
      {TextInputType? keyboardType, int maxLines = 1}) {
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
          if (value == null || value.isEmpty) {
            return 'Vui lòng nhập $label';
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
        items: _majors.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
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
