import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_getx_app/models/student.dart';
import 'package:flutter_getx_app/models/create_student_request.dart';
import 'package:flutter_getx_app/controllers/student_controller.dart';
import 'package:flutter_getx_app/controllers/home_controller.dart';
import 'package:flutter_getx_app/utils/storage_service.dart';
import 'package:get/get.dart';
import 'dart:typed_data';

class StudentFormScreen extends StatefulWidget {
  final Student? student;
  final bool isEditing;
  final VoidCallback? onSave;
  final VoidCallback? onCancel;

  const StudentFormScreen({
    Key? key,
    this.student,
    this.isEditing = false,
    this.onSave,
    this.onCancel,
  }) : super(key: key);

  @override
  State<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Controllers
  final StudentController _studentController = Get.find<StudentController>();
  final HomeController _homeController = Get.find<HomeController>();
  final StorageService _storageService = Get.find<StorageService>();

  // Image picker state
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  bool _isImageLoading = false;

  // Controllers for form fields
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _passportController = TextEditingController();

  // Guardian 1 controllers
  final _guardian1FirstNameController = TextEditingController();
  final _guardian1LastNameController = TextEditingController();
  final _guardian1EmailController = TextEditingController();
  final _guardian1PhoneController = TextEditingController();

  // Guardian 2 controllers
  final _guardian2FirstNameController = TextEditingController();
  final _guardian2LastNameController = TextEditingController();
  final _guardian2EmailController = TextEditingController();
  final _guardian2PhoneController = TextEditingController();

  // Dropdown values
  String? _selectedCountry = 'Egypt';
  String? _selectedGender = 'male';
  String? _selectedGrade;
  String? _selectedClass;
  String? _guardian1Relationship = 'mother';
  String? _guardian2Relationship = 'father';

  DateTime? _dateOfBirth;

  final List<String> _grades = [
    'G1',
    'G2',
    'G3',
    'G4',
    'G5',
    'G6',
    'G7',
    'G8',
    'G9',
    'G10',
    'G11',
    'G12'
  ];
  final List<String> _classes = [
    'Lions',
    'Tigers',
    'Eagles',
    'Bears',
    'Wolves',
    'Panthers'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.student != null) {
      _populateFieldsForEditing();
    }
  }

  void _populateFieldsForEditing() {
    final student = widget.student!;
    final nameParts = student.name.split(' ');
    _firstNameController.text = nameParts.isNotEmpty ? nameParts.first : '';
    _lastNameController.text =
        nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    _emailController.text = student.email ?? '';
    _phoneController.text = student.phoneNumber ?? '';
    _nationalIdController.text = student.nationalId ?? '';
    _passportController.text = student.passportIdNumber ?? '';
    _dateOfBirth = student.dateOfBirth;
    _selectedCountry = student.nationality ?? 'Egypt';
    _selectedGrade = student.grade;
    _selectedClass = student.className;

    if (student.firstGuardianName != null) {
      final guardian1Parts = student.firstGuardianName!.split(' ');
      _guardian1FirstNameController.text =
          guardian1Parts.isNotEmpty ? guardian1Parts.first : '';
      _guardian1LastNameController.text =
          guardian1Parts.length > 1 ? guardian1Parts.sublist(1).join(' ') : '';
    }
    _guardian1EmailController.text = student.firstGuardianEmail ?? '';
    _guardian1PhoneController.text = student.firstGuardianPhone ?? '';

    if (student.secondGuardianName != null) {
      final guardian2Parts = student.secondGuardianName!.split(' ');
      _guardian2FirstNameController.text =
          guardian2Parts.isNotEmpty ? guardian2Parts.first : '';
      _guardian2LastNameController.text =
          guardian2Parts.length > 1 ? guardian2Parts.sublist(1).join(' ') : '';
    }
    _guardian2EmailController.text = student.secondGuardianEmail ?? '';
    _guardian2PhoneController.text = student.secondGuardianPhone ?? '';
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> _pickImage() async {
    setState(() => _isImageLoading = true);
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.size > 5 * 1024 * 1024) {
          _showErrorSnackbar('Image size must be less than 5MB');
          return;
        }

        setState(() {
          _selectedImageBytes = file.bytes;
          _selectedImageName = file.name;
        });
      }
    } catch (e) {
      _showErrorSnackbar('Error selecting image: ${e.toString()}');
    } finally {
      setState(() => _isImageLoading = false);
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImageBytes = null;
      _selectedImageName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSaving = _studentController.isSaving.value;

      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: _buildAppBar(isSaving),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileSidebar(),
            Expanded(child: _buildMainContent()),
          ],
        ),
      );
    });
  }

  PreferredSizeWidget _buildAppBar(bool isSaving) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: isSaving ? null : () => _handleCancel(),
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
      ),
      title: Row(
        children: [
          const Text(
            'Back',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'View student profile',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: isSaving ? null : () => _handleCancel(),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: isSaving ? Colors.grey : Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: isSaving ? null : _saveStudent,
          style: ElevatedButton.styleFrom(
            backgroundColor: isSaving ? Colors.grey : Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Save details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  void _handleCancel() {
    if (widget.onCancel != null) {
      widget.onCancel!();
    } else {
      _homeController.exitStudentForm();
    }
  }

  // Simplified save method - just validation and calling controller
  Future<void> _saveStudent() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      _showErrorSnackbar('Please fill in all required fields');
      return;
    }

    // Get branch and organization IDs
    final branchData = _storageService.getSelectedBranchData();
    if (branchData == null) {
      _showErrorSnackbar('No branch selected');
      return;
    }

    final branchId = branchData['id'];
    final organizationId =
        branchData['organizationId'] ?? branchData['parentId'];

    if (branchId == null || organizationId == null) {
      _showErrorSnackbar('Branch or organization ID not found');
      return;
    }

    // Validate required fields
    if (_firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty) {
      _showErrorSnackbar('First name and last name are required');
      return;
    }

    if (_dateOfBirth == null) {
      _showErrorSnackbar('Date of birth is required');
      return;
    }

    if (_selectedGrade == null) {
      _showErrorSnackbar('Grade is required');
      return;
    }

    // Create request object
    final request = CreateStudentRequest.fromFormData(
      branchId: branchId,
      organizationId: organizationId,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      dateOfBirth: _dateOfBirth!,
      gender: _selectedGender ?? 'male',
      grade: _selectedGrade!,
      email: _emailController.text.trim().isNotEmpty
          ? _emailController.text.trim()
          : null,
      phone: _phoneController.text.trim().isNotEmpty
          ? _phoneController.text.trim()
          : null,
      nationalId: _nationalIdController.text.trim().isNotEmpty
          ? _nationalIdController.text.trim()
          : null,
      passportNumber: _passportController.text.trim().isNotEmpty
          ? _passportController.text.trim()
          : null,
      country: _selectedCountry,
      guardian1FirstName: _guardian1FirstNameController.text.trim().isNotEmpty
          ? _guardian1FirstNameController.text.trim()
          : null,
      guardian1LastName: _guardian1LastNameController.text.trim().isNotEmpty
          ? _guardian1LastNameController.text.trim()
          : null,
      guardian1Email: _guardian1EmailController.text.trim().isNotEmpty
          ? _guardian1EmailController.text.trim()
          : null,
      guardian1Phone: _guardian1PhoneController.text.trim().isNotEmpty
          ? _guardian1PhoneController.text.trim()
          : null,
      guardian1Relationship: _guardian1Relationship,
      guardian2FirstName: _guardian2FirstNameController.text.trim().isNotEmpty
          ? _guardian2FirstNameController.text.trim()
          : null,
      guardian2LastName: _guardian2LastNameController.text.trim().isNotEmpty
          ? _guardian2LastNameController.text.trim()
          : null,
      guardian2Email: _guardian2EmailController.text.trim().isNotEmpty
          ? _guardian2EmailController.text.trim()
          : null,
      guardian2Phone: _guardian2PhoneController.text.trim().isNotEmpty
          ? _guardian2PhoneController.text.trim()
          : null,
      guardian2Relationship: _guardian2Relationship,
    );

    // Call controller method
    final success = await _studentController.createStudent(request);

    if (success) {
      // Navigate back
      if (widget.onSave != null) {
        widget.onSave!();
      } else {
        _homeController.exitStudentForm();
      }
    }
  }

  Widget _buildProfileSidebar() {
    return Container(
      width: 320,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildProfileAvatar(),
            const SizedBox(height: 32),
            _buildProfileQuickInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Column(
      children: [
        ImagePickerWidget(
          selectedImageBytes: _selectedImageBytes,
          selectedImageName: _selectedImageName,
          isLoading: _isImageLoading,
          onPickImage: _pickImage,
          onRemoveImage: _removeImage,
          studentName:
              '${_firstNameController.text} ${_lastNameController.text}',
        ),
        const SizedBox(height: 16),
        Text(
          '${_firstNameController.text} ${_lastNameController.text}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          widget.isEditing
              ? (widget.student!.studentId ?? 'No ID')
              : 'ID will be generated',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProfileQuickInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Info',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildQuickInfoItem(
            icon: Icons.school_outlined,
            label: 'Grade & Class',
            value:
                '${_selectedGrade ?? 'Not set'} ${_selectedClass != null ? '- $_selectedClass' : ''}',
          ),
          const SizedBox(height: 12),
          _buildQuickInfoItem(
            icon: Icons.cake_outlined,
            label: 'Age',
            value: _dateOfBirth != null
                ? '${DateTime.now().year - _dateOfBirth!.year} years'
                : 'Not set',
          ),
          const SizedBox(height: 12),
          _buildQuickInfoItem(
            icon: Icons.flag_outlined,
            label: 'Country',
            value: _selectedCountry ?? 'Not selected',
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBasicInfoSection(),
            const SizedBox(height: 32),
            _buildGradeClassSection(),
            const SizedBox(height: 32),
            _buildFirstGuardianSection(),
            const SizedBox(height: 32),
            _buildSecondGuardianSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return FormSection(
      title: 'Basic info',
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'First name',
                controller: _firstNameController,
                isRequired: true,
                onChanged: (value) => setState(() {}),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                label: 'Last name',
                controller: _lastNameController,
                isRequired: true,
                onChanged: (value) => setState(() {}),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomDateField(
                label: 'Date of birth',
                selectedDate: _dateOfBirth,
                onDateSelected: (date) => setState(() => _dateOfBirth = date),
                isRequired: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: CustomDropdownField(
                label: 'Country of citizenship',
                value: _selectedCountry,
                items: const [
                  'Egypt',
                  'Tunisia',
                  'Morocco',
                  'Algeria',
                  'Saudi Arabia',
                  'UAE'
                ],
                onChanged: (value) => setState(() => _selectedCountry = value),
                isRequired: true,
                icon: Icons.flag,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                label: 'National ID number',
                controller: _nationalIdController,
                isRequired: true,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }

  Widget _buildGradeClassSection() {
    return FormSection(
      title: 'Grade & Class',
      children: [
        Row(
          children: [
            Expanded(
              child: CustomDropdownField(
                label: 'Grade',
                value: _selectedGrade,
                items: _grades,
                onChanged: (value) => setState(() => _selectedGrade = value),
                isRequired: true,
                icon: Icons.school,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomDropdownField(
                label: 'Class',
                value: _selectedClass,
                items: _classes,
                onChanged: (value) => setState(() => _selectedClass = value),
                isRequired: false,
                icon: Icons.class_,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }

  Widget _buildFirstGuardianSection() {
    return FormSection(
      title: 'First guardian details',
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'Full name',
                controller: _guardian1FirstNameController,
                isRequired: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomDropdownField(
                label: 'Relationship with student',
                value: _guardian1Relationship,
                items: const [
                  'mother',
                  'father',
                  'guardian',
                  'relative',
                  'other'
                ],
                onChanged: (value) =>
                    setState(() => _guardian1Relationship = value),
                isRequired: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'Email',
                controller: _guardian1EmailController,
                isRequired: true,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                label: 'Phone number',
                controller: _guardian1PhoneController,
                isRequired: true,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSecondGuardianSection() {
    return FormSection(
      title: 'Second guardian details',
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'Full name',
                controller: _guardian2FirstNameController,
                isRequired: false,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomDropdownField(
                label: 'Relationship with student',
                value: _guardian2Relationship,
                items: const [
                  'mother',
                  'father',
                  'guardian',
                  'relative',
                  'other'
                ],
                onChanged: (value) =>
                    setState(() => _guardian2Relationship = value),
                isRequired: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'Email',
                controller: _guardian2EmailController,
                isRequired: false,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                label: 'Phone number',
                controller: _guardian2PhoneController,
                isRequired: false,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nationalIdController.dispose();
    _passportController.dispose();
    _guardian1FirstNameController.dispose();
    _guardian1LastNameController.dispose();
    _guardian1EmailController.dispose();
    _guardian1PhoneController.dispose();
    _guardian2FirstNameController.dispose();
    _guardian2LastNameController.dispose();
    _guardian2EmailController.dispose();
    _guardian2PhoneController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

// CUSTOM WIDGETS

class FormSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const FormSection({
    Key? key,
    required this.title,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isRequired;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final Function(String)? onChanged;

  const CustomTextField({
    Key? key,
    required this.label,
    required this.controller,
    this.isRequired = false,
    this.keyboardType,
    this.prefixIcon,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
            children: [
              if (isRequired)
                const TextSpan(
                  text: '*',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: label,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20) : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: Colors.white,
          ),
          validator: isRequired
              ? (value) {
                  if (value?.isEmpty ?? true) {
                    return '$label is required';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }
}

class CustomDropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final Function(String?) onChanged;
  final bool isRequired;
  final IconData? icon;

  const CustomDropdownField({
    Key? key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.isRequired = false,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
            children: [
              if (isRequired)
                const TextSpan(
                  text: '*',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          decoration: InputDecoration(
            prefixIcon: icon != null ? Icon(icon, size: 20) : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: Colors.white,
          ),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
          validator: isRequired
              ? (value) {
                  if (value?.isEmpty ?? true) {
                    return '$label is required';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }
}

class CustomDateField extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;
  final bool isRequired;

  const CustomDateField({
    Key? key,
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
    this.isRequired = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
            children: [
              if (isRequired)
                const TextSpan(
                  text: '*',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              onDateSelected(date);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 20, color: Colors.grey.shade600),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedDate != null
                        ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                        : label,
                    style: TextStyle(
                      color: selectedDate != null
                          ? Colors.black87
                          : Colors.grey.shade400,
                      fontSize: 16,
                    ),
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ImagePickerWidget extends StatelessWidget {
  final Uint8List? selectedImageBytes;
  final String? selectedImageName;
  final bool isLoading;
  final VoidCallback onPickImage;
  final VoidCallback onRemoveImage;
  final String studentName;

  const ImagePickerWidget({
    Key? key,
    required this.selectedImageBytes,
    required this.selectedImageName,
    required this.isLoading,
    required this.onPickImage,
    required this.onRemoveImage,
    required this.studentName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildAvatarDisplay(),
        const SizedBox(height: 20),
        if (selectedImageName != null) _buildImageInfo(),
      ],
    );
  }

  Widget _buildAvatarDisplay() {
    return Stack(
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade300, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipOval(
            child: selectedImageBytes != null
                ? Image.memory(selectedImageBytes!, fit: BoxFit.cover)
                : Container(
                    color: Colors.grey.shade200,
                    child:
                        const Icon(Icons.person, size: 60, color: Colors.grey),
                  ),
          ),
        ),
        if (isLoading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.3),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          ),
        Positioned(
          bottom: 5,
          right: 5,
          child: GestureDetector(
            onTap: isLoading ? null : onPickImage,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child:
                  const Icon(Icons.camera_alt, size: 18, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageInfo() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.green.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              selectedImageName!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.green.shade700,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: onRemoveImage,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
