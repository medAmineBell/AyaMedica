// Updated StudentFormScreen with complete save functionality
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_getx_app/models/student.dart';
import 'package:flutter_getx_app/controllers/student_controller.dart';
import 'package:flutter_getx_app/controllers/home_controller.dart';
import 'package:get/get.dart';
import 'dart:typed_data';
import 'dart:math';
import 'dart:convert';

class StudentFormScreen extends StatefulWidget {
  final Student? student; // null for add, populated for edit
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
  
  // Image picker state
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  bool _isImageLoading = false;
  bool _isSaving = false;

  // Controllers for form fields
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _guardian1FirstNameController = TextEditingController();
  final _guardian1LastNameController = TextEditingController();
  final _guardian1EmailController = TextEditingController();
  final _guardian1PhoneController = TextEditingController();
  final _guardian1NationalIdController = TextEditingController();
  final _guardian2FirstNameController = TextEditingController();
  final _guardian2LastNameController = TextEditingController();
  final _guardian2EmailController = TextEditingController();
  final _guardian2PhoneController = TextEditingController();
  final _guardian2NationalIdController = TextEditingController();

  // Dropdown values
  String? _selectedCountry = 'Egypt';
  String? _selectedGrade = 'G4';
  String? _selectedClass = 'Lions';
  String? _guardian1Gender = 'Female';
  String? _guardian1Country = 'Egypt';
  String? _guardian1Relationship = 'Parent';
  String? _guardian2Gender = 'Female';
  String? _guardian2Country = 'Egypt';
  String? _guardian2Relationship = 'Parent';
  DateTime? _dateOfBirth;
  DateTime? _guardian1DateOfBirth;
  DateTime? _guardian2DateOfBirth;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.student != null) {
      _populateFieldsForEditing();
    }
  }

  void _populateFieldsForEditing() {
    final student = widget.student!;
    
    // Split name into first and last name
    final nameParts = student.name.split(' ');
    _firstNameController.text = nameParts.isNotEmpty ? nameParts.first : '';
    _lastNameController.text = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
    
    // Basic info
    _nationalIdController.text = student.nationalId ?? '';
    _dateOfBirth = student.dateOfBirth;
    _selectedCountry = student.nationality ?? 'Egypt';
    
    // Grade and class
    _selectedGrade = student.grade ?? 'G4';
    _selectedClass = student.className ?? 'Lions';
    
    // Guardian 1 info - parse from existing data
    if (student.firstGuardianName != null) {
      final guardian1Parts = student.firstGuardianName!.split(' ');
      _guardian1FirstNameController.text = guardian1Parts.isNotEmpty ? guardian1Parts.first : '';
      _guardian1LastNameController.text = guardian1Parts.length > 1 ? guardian1Parts.sublist(1).join(' ') : '';
    }
    _guardian1EmailController.text = student.firstGuardianEmail ?? '';
    _guardian1PhoneController.text = student.firstGuardianPhone ?? '';
    _guardian1Country = student.nationality ?? 'Egypt';
    
    // Guardian 2 info
    if (student.secondGuardianName != null) {
      final guardian2Parts = student.secondGuardianName!.split(' ');
      _guardian2FirstNameController.text = guardian2Parts.isNotEmpty ? guardian2Parts.first : '';
      _guardian2LastNameController.text = guardian2Parts.length > 1 ? guardian2Parts.sublist(1).join(' ') : '';
    }
    _guardian2EmailController.text = student.secondGuardianEmail ?? '';
    _guardian2PhoneController.text = student.secondGuardianPhone ?? '';
    _guardian2Country = student.nationality ?? 'Egypt';
  }

  // Image picker methods
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: Duration(seconds: 3),
    );
  }

  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }

  void _removeImage() {
    setState(() {
      _selectedImageBytes = null;
      _selectedImageName = null;
    });
    _showSuccessSnackbar('Image removed');
  }

  Future<void> _pickImage() async {
    setState(() => _isImageLoading = true);

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'bmp'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        
        // Validate file size (max 5MB)
        if (file.size > 5 * 1024 * 1024) {
          _showErrorSnackbar('Image size must be less than 5MB');
          return;
        }

        // Validate file type
        final allowedTypes = ['jpg', 'jpeg', 'png', 'gif', 'bmp'];
        final extension = file.extension?.toLowerCase();
        if (extension == null || !allowedTypes.contains(extension)) {
          _showErrorSnackbar('Please select a valid image file (JPG, PNG, GIF, BMP)');
          return;
        }

        setState(() {
          _selectedImageBytes = file.bytes;
          _selectedImageName = file.name;
        });

        _showSuccessSnackbar('Image selected successfully');
      }
    } catch (e) {
      _showErrorSnackbar('Error selecting image: ${e.toString()}');
    } finally {
      setState(() => _isImageLoading = false);
    }
  }

  // Generate unique IDs for new students
  String _generateStudentId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '29${timestamp.toString().substring(timestamp.toString().length - 9)}';
  }

  String _generateUniqueId() {
    final random = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(10, (index) => chars[random.nextInt(chars.length)]).join();
  }

  String _generateAid() {
    final random = Random();
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const numbers = '0123456789';
    return '4EG${numbers[random.nextInt(numbers.length)]}${numbers[random.nextInt(numbers.length)]}${numbers[random.nextInt(numbers.length)]}${numbers[random.nextInt(numbers.length)]}Q${numbers[random.nextInt(numbers.length)]}S${letters[random.nextInt(letters.length)]}';
  }

  // Generate random avatar color
  Color _generateAvatarColor() {
    final colors = [
      Color(4279450111), // Blue
      Color(4279286145), // Purple
      Color(4293870660), // Orange
      Color(4285315327), // Green
      Color(4294924066), // Red
      Color(4291611852), // Teal
      Color(4294945263), // Pink
    ];
    return colors[Random().nextInt(colors.length)];
  }

  // Convert image bytes to base64 string for storage
  String? _convertImageToBase64() {
    if (_selectedImageBytes != null) {
      return base64Encode(_selectedImageBytes!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Sidebar - Profile Section
          _buildProfileSidebar(),
          // Main Content Area
          Expanded(
            child: _buildMainContent(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: _isSaving ? null : () => _handleCancel(),
        icon: Icon(Icons.arrow_back, color: Colors.black87),
      ),
      title: Row(
        children: [
          Text(
            'Back',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 8),
          Text(
            widget.isEditing ? 'Edit student profile' : 'Add new student',
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
          onPressed: _isSaving ? null : () => _handleCancel(),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: _isSaving ? Colors.grey : Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
        ),
        SizedBox(width: 8),
        ElevatedButton(
          onPressed: _isSaving ? null : _saveStudent,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isSaving ? Colors.grey : Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: _isSaving
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  'Save details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
        SizedBox(width: 16),
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

  // MAIN SAVE STUDENT METHOD
  Future<void> _saveStudent() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      _showErrorSnackbar('Please fill in all required fields');
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Collect form data
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      final fullName = '$firstName $lastName';
      
      if (firstName.isEmpty || lastName.isEmpty) {
        _showErrorSnackbar('First name and last name are required');
        return;
      }

      if (_dateOfBirth == null) {
        _showErrorSnackbar('Date of birth is required');
        return;
      }

      // Create guardian names
      final guardian1Name = '${_guardian1FirstNameController.text.trim()} ${_guardian1LastNameController.text.trim()}';
      final guardian2Name = '${_guardian2FirstNameController.text.trim()} ${_guardian2LastNameController.text.trim()}';

      // Create Student object
      final Student newStudent = Student(
        id: widget.isEditing ? widget.student!.id : _generateUniqueId(),
        name: fullName,
        imageUrl: _convertImageToBase64(), // Store image as base64
        avatarColor: widget.isEditing ? widget.student!.avatarColor : _generateAvatarColor(),
        
        // Basic info
        dateOfBirth: _dateOfBirth,
        nationality: _selectedCountry,
        nationalId: _nationalIdController.text.trim(),
        gender: 'Not specified', // You can add gender field to form if needed
        
        // Academic info
        studentId: widget.isEditing ? widget.student!.studentId : _generateStudentId(),
        aid: widget.isEditing ? widget.student!.aid : _generateAid(),
        grade: _selectedGrade,
        className: _selectedClass,
        
        // Guardian 1 info
        firstGuardianName: guardian1Name.trim().isNotEmpty ? guardian1Name : null,
        firstGuardianEmail: _guardian1EmailController.text.trim().isNotEmpty ? _guardian1EmailController.text.trim() : null,
        firstGuardianPhone: _guardian1PhoneController.text.trim().isNotEmpty ? _guardian1PhoneController.text.trim() : null,
        firstGuardianStatus: 'Offline', // Default status
        
        // Guardian 2 info
        secondGuardianName: guardian2Name.trim().isNotEmpty ? guardian2Name : null,
        secondGuardianEmail: _guardian2EmailController.text.trim().isNotEmpty ? _guardian2EmailController.text.trim() : null,
        secondGuardianPhone: _guardian2PhoneController.text.trim().isNotEmpty ? _guardian2PhoneController.text.trim() : null,
        secondGuardianStatus: 'Offline', // Default status
        
        // Default values for fields not in form
        bloodType: widget.isEditing ? widget.student!.bloodType : null,
        weightKg: widget.isEditing ? widget.student!.weightKg : null,
        heightCm: widget.isEditing ? widget.student!.heightCm : null,
        goToHospital: widget.isEditing ? widget.student!.goToHospital : null,
        city: widget.isEditing ? widget.student!.city : null,
        street: widget.isEditing ? widget.student!.street : null,
        zipCode: widget.isEditing ? widget.student!.zipCode : null,
        province: widget.isEditing ? widget.student!.province : null,
        insuranceCompany: widget.isEditing ? widget.student!.insuranceCompany : null,
        policyNumber: widget.isEditing ? widget.student!.policyNumber : null,
        passportIdNumber: widget.isEditing ? widget.student!.passportIdNumber : null,
        phoneNumber: widget.isEditing ? widget.student!.phoneNumber : null,
        email: widget.isEditing ? widget.student!.email : null,
        lastAppointmentDate: widget.isEditing ? widget.student!.lastAppointmentDate : null,
        lastAppointmentType: widget.isEditing ? widget.student!.lastAppointmentType : null,
        emrNumber: widget.isEditing ? widget.student!.emrNumber : Random().nextInt(100) + 1, // Generate random EMR for new students
      );

      // Save via controller
      if (widget.isEditing) {
        await _updateStudent(newStudent);
      } else {
        _studentController.addStudent(newStudent);
      }

      // Show success message
      _showSuccessSnackbar(
        widget.isEditing 
            ? 'Student updated successfully' 
            : 'Student added successfully'
      );

      // Wait a moment for the user to see the success message
      await Future.delayed(Duration(milliseconds: 500));

      // Navigate back
      if (widget.onSave != null) {
        widget.onSave!();
      } else {
        _homeController.exitStudentForm();
      }

    } catch (e) {
      _showErrorSnackbar('Error saving student: ${e.toString()}');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  // Method to update existing student
  Future<void> _updateStudent(Student updatedStudent) async {
    // Remove old student and add updated one
    _studentController.removeStudent(widget.student!.id);
    _studentController.addStudent(updatedStudent);
  }

  // Rest of the UI building methods remain the same...
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
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile Avatar Section
            _buildProfileAvatar(),
            SizedBox(height: 32),
            
            // Profile Quick Info
            _buildProfileQuickInfo(),
            SizedBox(height: 32),
            
            // Profile Actions
            _buildProfileActions(),
            SizedBox(height: 32),
            
            // Profile Stats (if editing)
            if (widget.isEditing) _buildProfileStats(),
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
          student: widget.student,
          isEditing: widget.isEditing,
        ),
        SizedBox(height: 16),
        Text(
          widget.isEditing ? widget.student!.name : 
          '${_firstNameController.text} ${_lastNameController.text}',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 4),
        Text(
          widget.isEditing 
              ? (widget.student!.studentId ?? 'No ID') 
              : 'Student ID will be generated',
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
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Info',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          _buildQuickInfoItem(
            icon: Icons.school_outlined,
            label: 'Grade & Class',
            value: '${_selectedGrade ?? ''} - ${_selectedClass ?? ''}',
          ),
          SizedBox(height: 12),
          _buildQuickInfoItem(
            icon: Icons.cake_outlined,
            label: 'Age',
            value: _dateOfBirth != null 
                ? '${DateTime.now().year - _dateOfBirth!.year} years'
                : 'Not set',
          ),
          SizedBox(height: 12),
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
        SizedBox(width: 8),
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
                style: TextStyle(
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

  Widget _buildProfileActions() {
    return Column(
      children: [
        _buildActionButton(
          icon: Icons.qr_code_outlined,
          label: 'Generate QR Code',
          onTap: () {
            _showSuccessSnackbar('QR Code generation coming soon');
          },
        ),
        if (widget.isEditing) ...[
          SizedBox(height: 12),
          _buildActionButton(
            icon: Icons.print_outlined,
            label: 'Print Profile',
            onTap: () {
              _showSuccessSnackbar('Print functionality coming soon');
            },
          ),
        ],
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey.shade600),
            SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStats() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Medical Records',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  value: widget.student?.emrNumber?.toString() ?? '0',
                  label: 'EMR',
                  color: Colors.cyan,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  value: '5',
                  label: 'Visits',
                  color: Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Last visit: ${widget.student?.formattedAppointmentDate ?? 'Never'}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color.withOpacity(0.8),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBasicInfoSection(),
            SizedBox(height: 32),
            _buildGradeClassSection(),
            SizedBox(height: 32),
            _buildFirstGuardianSection(),
            SizedBox(height: 32),
            _buildSecondGuardianSection(),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Form sections (same as before)
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
                onChanged: (value) => setState(() {}), // Update UI when name changes
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                label: 'Last name',
                controller: _lastNameController,
                isRequired: true,
                onChanged: (value) => setState(() {}), // Update UI when name changes
              ),
            ),
            SizedBox(width: 16),
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
        SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: CustomDropdownField(
                label: 'Country of citizenship',
                value: _selectedCountry,
                items: ['Egypt', 'Tunisia', 'Morocco', 'Algeria'],
                onChanged: (value) => setState(() => _selectedCountry = value),
                isRequired: true,
                icon: Icons.flag,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                label: 'National ID number',
                controller: _nationalIdController,
                isRequired: true,
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(width: 16),
            Expanded(child: SizedBox()),
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
                items: ['G1', 'G2', 'G3', 'G4', 'G5', 'G6'],
                onChanged: (value) => setState(() => _selectedGrade = value),
                isRequired: true,
                icon: Icons.school,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: CustomDropdownField(
                label: 'Class',
                value: _selectedClass,
                items: ['Lions', 'Tigers', 'Eagles', 'Bears'],
                onChanged: (value) => setState(() => _selectedClass = value),
                isRequired: true,
                icon: Icons.class_,
              ),
            ),
            SizedBox(width: 16),
            Expanded(child: SizedBox()),
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
                label: 'First name',
                controller: _guardian1FirstNameController,
                isRequired: true,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                label: 'Last name',
                controller: _guardian1LastNameController,
                isRequired: true,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: CustomDropdownField(
                label: 'Gender',
                value: _guardian1Gender,
                items: ['Male', 'Female'],
                onChanged: (value) => setState(() => _guardian1Gender = value),
                isRequired: true,
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: CustomDateField(
                label: 'Date of birth',
                selectedDate: _guardian1DateOfBirth,
                onDateSelected: (date) => setState(() => _guardian1DateOfBirth = date),
                isRequired: true,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: CustomDropdownField(
                label: 'Country of citizenship',
                value: _guardian1Country,
                items: ['Egypt', 'Tunisia', 'Morocco', 'Algeria'],
                onChanged: (value) => setState(() => _guardian1Country = value),
                isRequired: true,
                icon: Icons.flag,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                label: 'National ID number',
                controller: _guardian1NationalIdController,
                isRequired: true,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
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
            SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                label: 'Phone number',
                controller: _guardian1PhoneController,
                isRequired: true,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: CustomDropdownField(
                label: 'Relationship with student',
                value: _guardian1Relationship,
                items: ['Parent', 'Guardian', 'Relative', 'Other'],
                onChanged: (value) => setState(() => _guardian1Relationship = value),
                isRequired: true,
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
                label: 'First name',
                controller: _guardian2FirstNameController,
                isRequired: true,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                label: 'Last name',
                controller: _guardian2LastNameController,
                isRequired: true,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: CustomDropdownField(
                label: 'Gender',
                value: _guardian2Gender,
                items: ['Male', 'Female'],
                onChanged: (value) => setState(() => _guardian2Gender = value),
                isRequired: true,
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: CustomDateField(
                label: 'Date of birth',
                selectedDate: _guardian2DateOfBirth,
                onDateSelected: (date) => setState(() => _guardian2DateOfBirth = date),
                isRequired: true,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: CustomDropdownField(
                label: 'Country of citizenship',
                value: _guardian2Country,
                items: ['Egypt', 'Tunisia', 'Morocco', 'Algeria'],
                onChanged: (value) => setState(() => _guardian2Country = value),
                isRequired: true,
                icon: Icons.flag,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                label: 'National ID number',
                controller: _guardian2NationalIdController,
                isRequired: true,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'Email',
                controller: _guardian2EmailController,
                isRequired: true,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                label: 'Phone number',
                controller: _guardian2PhoneController,
                isRequired: true,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: CustomDropdownField(
                label: 'Relationship with student',
                value: _guardian2Relationship,
                items: ['Parent', 'Guardian', 'Relative', 'Other'],
                onChanged: (value) => setState(() => _guardian2Relationship = value),
                isRequired: true,
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
    _nationalIdController.dispose();
    _guardian1FirstNameController.dispose();
    _guardian1LastNameController.dispose();
    _guardian1EmailController.dispose();
    _guardian1PhoneController.dispose();
    _guardian1NationalIdController.dispose();
    _guardian2FirstNameController.dispose();
    _guardian2LastNameController.dispose();
    _guardian2EmailController.dispose();
    _guardian2PhoneController.dispose();
    _guardian2NationalIdController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

// Updated CustomTextField to support onChanged callback
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
                TextSpan(
                  text: '*',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
        SizedBox(height: 8),
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
              borderSide: BorderSide(color: Colors.blue),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

// Other form components remain the same...
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
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 24),
          ...children,
        ],
      ),
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
                TextSpan(
                  text: '*',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
        SizedBox(height: 8),
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
              borderSide: BorderSide(color: Colors.blue),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                TextSpan(
                  text: '*',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
        SizedBox(height: 8),
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
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 20, color: Colors.grey.shade600),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedDate != null
                        ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                        : label,
                    style: TextStyle(
                      color: selectedDate != null ? Colors.black87 : Colors.grey.shade400,
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

// ImagePickerWidget remains the same as in your code...
class ImagePickerWidget extends StatelessWidget {
  final Uint8List? selectedImageBytes;
  final String? selectedImageName;
  final bool isLoading;
  final VoidCallback onPickImage;
  final VoidCallback onRemoveImage;
  final Student? student;
  final bool isEditing;

  const ImagePickerWidget({
    Key? key,
    required this.selectedImageBytes,
    required this.selectedImageName,
    required this.isLoading,
    required this.onPickImage,
    required this.onRemoveImage,
    this.student,
    this.isEditing = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main avatar display
        _buildAvatarDisplay(),
        SizedBox(height: 20),
        
        // Action buttons
        _buildActionButtons(),
        
        // Image info (if selected)
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
            border: Border.all(
              color: Colors.grey.shade300,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: ClipOval(
            child: _buildAvatarContent(),
          ),
        ),
        
        // Loading overlay
        if (isLoading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.3),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          ),
        
        // Edit button
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.camera_alt,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarContent() {
    if (selectedImageBytes != null) {
      // Show selected image
      return Image.memory(
        selectedImageBytes!,
        fit: BoxFit.cover,
        width: 140,
        height: 140,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderAvatar();
        },
      );
    } else if (isEditing && student != null) {
      // Show existing student avatar
      return Container(
        color: student?.avatarColor ?? Colors.blue.shade200,
        child: Center(
          child: Text(
            student?.initials ?? '?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    } else {
      // Show placeholder
      return _buildPlaceholderAvatar();
    }
  }

  Widget _buildPlaceholderAvatar() {
    return Container(
      color: Colors.grey.shade100,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: 50,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 8),
            Text(
              'No Photo',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isLoading ? null : onPickImage,
            icon: Icon(Icons.upload, size: 18),
            label: Text('Select Photo'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: Colors.blue),
              foregroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        if (selectedImageBytes != null) ...[
          SizedBox(width: 8),
          IconButton(
            onPressed: onRemoveImage,
            icon: Icon(Icons.delete_outline),
            color: Colors.red,
            tooltip: 'Remove Photo',
            style: IconButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildImageInfo() {
    return Container(
      margin: EdgeInsets.only(top: 12),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: Colors.green.shade600,
          ),
          SizedBox(width: 8),
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
        ],
      ),
    );
  }
}