import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_getx_app/models/student.dart';
import 'package:flutter_getx_app/models/create_student_request.dart';
import 'package:flutter_getx_app/controllers/student_controller.dart';
import 'package:flutter_getx_app/controllers/home_controller.dart';
import 'package:flutter_getx_app/controllers/resources_controller.dart';
import 'package:flutter_getx_app/config/app_config.dart';
import 'package:flutter_getx_app/utils/location_service.dart';
import 'package:flutter_getx_app/utils/storage_service.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_getx_app/utils/app_snackbar.dart';

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
  final ResourcesController _resourcesController =
      Get.find<ResourcesController>();
  final LocationService _locationService = Get.find<LocationService>();

  // Image picker state
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  bool _isImageLoading = false;

  // Controllers for form fields
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _documentNumberController = TextEditingController();

  // Guardian 1 controllers
  final _guardian1FullNameController = TextEditingController();
  final _guardian1EmailController = TextEditingController();
  final _guardian1PhoneController = TextEditingController();

  // Guardian 2 controllers
  final _guardian2FullNameController = TextEditingController();
  final _guardian2EmailController = TextEditingController();
  final _guardian2PhoneController = TextEditingController();

  // Document types accepted by the API (api value -> display label).
  static const Map<String, String> _documentTypeLabels = {
    'passport': 'Passport',
    'national_id': 'National ID',
    'residence_id': 'Residence ID',
  };

  // Relationship enum values expected by the API.
  // Keep this list aligned with the bulk-upload XLS template — both single
  // add/edit and bulk upload should accept the same set.
  static const List<String> _relationOptions = [
    'FATHER',
    'MOTHER',
    'HUSBAND',
    'WIFE',
    'SON',
    'DAUGHTER',
    'BROTHER',
    'SISTER',
    'GRANDFATHER',
    'GRANDMOTHER',
    'GRANDSON',
    'GRANDDAUGHTER',
    'UNCLE',
    'AUNT',
    'NEPHEW',
    'NIECE',
    'COUSIN',
    'FRIEND',
    'OTHER',
  ];

  static String _relationLabel(String key) {
    if (key.isEmpty) return key;
    return key[0].toUpperCase() + key.substring(1).toLowerCase();
  }

  // Dropdown values
  String? _selectedNationalityKey; // ISO country key -> payload `nationality`
  String? _selectedDocumentType = 'national_id';
  String? _selectedGender = 'male';
  String? _selectedGrade;
  String? _selectedClass; // class name shown in dropdown
  String? _selectedClassId; // resolved class UUID (sent to API)
  String? _guardian1Relationship = 'MOTHER';
  String? _guardian2Relationship = 'FATHER';

  DateTime? _dateOfBirth;

  @override
  void initState() {
    super.initState();
    _resourcesController.loadClasses();
    _locationService.fetchCountries();
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

    if ((student.documentNumber?.isNotEmpty ?? false)) {
      _documentNumberController.text = student.documentNumber!;
    } else if ((student.nationalId?.isNotEmpty ?? false)) {
      _documentNumberController.text = student.nationalId!;
    } else if ((student.passportIdNumber?.isNotEmpty ?? false)) {
      _documentNumberController.text = student.passportIdNumber!;
    }

    if ((student.documentType ?? '').isNotEmpty) {
      _selectedDocumentType = student.documentType;
    } else if ((student.passportIdNumber?.isNotEmpty ?? false) &&
        (student.nationalId?.isEmpty ?? true)) {
      _selectedDocumentType = 'passport';
    }

    _dateOfBirth = student.dateOfBirth;
    _selectedNationalityKey = student.nationality;
    if ((student.gender ?? '').isNotEmpty) {
      _selectedGender = student.gender!.toLowerCase();
    }
    _selectedGrade = student.grade;
    _selectedClass = student.className;
    _selectedClassId = student.classId;

    if (student.firstGuardianName != null) {
      _guardian1FullNameController.text = student.firstGuardianName!;
    }
    _guardian1EmailController.text = student.firstGuardianEmail ?? '';
    _guardian1PhoneController.text = student.firstGuardianPhone ?? '';
    if ((student.firstGuardianRelation ?? '').isNotEmpty) {
      _guardian1Relationship = student.firstGuardianRelation!.toUpperCase();
    }

    if (student.secondGuardianName != null) {
      _guardian2FullNameController.text = student.secondGuardianName!;
    }
    _guardian2EmailController.text = student.secondGuardianEmail ?? '';
    _guardian2PhoneController.text = student.secondGuardianPhone ?? '';
    if ((student.secondGuardianRelation ?? '').isNotEmpty) {
      _guardian2Relationship = student.secondGuardianRelation!.toUpperCase();
    }
  }

  void _showErrorSnackbar(String message) {
    appSnackbar(
      'Error',
      message,
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

  /// Full URL of the existing photo on the server (edit mode only).
  /// The API returns a relative path like `/api/files/gcs/EG/avatars/....jpg`.
  String? _existingPhotoUrl() {
    final url = widget.student?.imageUrl;
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    return '${AppConfig.newBackendUrl}$url';
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
            backgroundColor: isSaving ? Colors.grey : Color(0xFF1339FF),
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

    // In edit mode the user may not touch the class dropdown, and the loaded
    // student record may not carry classId (or classes loaded after init), so
    // the dropdown shows the class name without _selectedClassId being set.
    // Resolve the id from the cached classes when we have the name + grade.
    if ((_selectedClassId == null || _selectedClassId!.isEmpty) &&
        _selectedClass != null &&
        _selectedGrade != null) {
      final match = _resourcesController.getClassByNameAndGrade(
          _selectedClass!, _selectedGrade!);
      _selectedClassId = match?['id']?.toString();
    }

    if (_selectedClassId == null || _selectedClassId!.isEmpty) {
      _showErrorSnackbar('Class is required');
      return;
    }

    if (_documentNumberController.text.trim().isEmpty) {
      _showErrorSnackbar('Document number is required');
      return;
    }

    if (_selectedNationalityKey == null || _selectedNationalityKey!.isEmpty) {
      _showErrorSnackbar('Nationality is required');
      return;
    }

    // Country of residence is derived from the selected branch, not picked.
    final branchCountryKey = (branchData['country'] as String?)?.toUpperCase();
    if (branchCountryKey == null || branchCountryKey.isEmpty) {
      _showErrorSnackbar('Selected branch is missing a country');
      return;
    }

    final docNum = _documentNumberController.text.trim();
    final natKey = _selectedNationalityKey;
    final resKey = branchCountryKey;
    if (_selectedDocumentType == 'national_id' &&
        natKey == 'EG' &&
        resKey == 'EG') {
      final error = _validateEgyptianNationalId(
        docNum,
        _selectedGender ?? 'male',
        _dateOfBirth,
      );
      if (error != null) {
        _showErrorSnackbar(error);
        return;
      }
    } else if (_selectedDocumentType == 'national_id' &&
        natKey == 'SA' &&
        resKey == 'SA') {
      if (!RegExp(r'^\d{10}$').hasMatch(docNum)) {
        _showErrorSnackbar('Must be exactly 10 digits');
        return;
      }
      if (docNum[0] != '1') {
        _showErrorSnackbar('Saudi National ID must start with 1');
        return;
      }
    } else if (_selectedDocumentType == 'residence_id' && resKey == 'SA') {
      if (!RegExp(r'^\d{10}$').hasMatch(docNum)) {
        _showErrorSnackbar('Must be exactly 10 digits');
        return;
      }
      if (natKey == 'SA' && docNum[0] != '1') {
        _showErrorSnackbar('Saudi Residence ID must start with 1');
        return;
      }
      if (natKey != 'SA' && docNum[0] == '1') {
        _showErrorSnackbar('Non-Saudi Residence ID must not start with 1');
        return;
      }
    }

    String? orNull(TextEditingController c) {
      final v = c.text.trim();
      return v.isEmpty ? null : v;
    }

    String? photoBase64;
    String? photoContentType;
    if (_selectedImageBytes != null) {
      photoBase64 = base64Encode(_selectedImageBytes!);
      final name = (_selectedImageName ?? '').toLowerCase();
      if (name.endsWith('.png')) {
        photoContentType = 'image/png';
      } else if (name.endsWith('.webp')) {
        photoContentType = 'image/webp';
      } else if (name.endsWith('.gif')) {
        photoContentType = 'image/gif';
      } else {
        photoContentType = 'image/jpeg';
      }
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
      classId: _selectedClassId!,
      nationality: _selectedNationalityKey,
      documentType: _selectedDocumentType,
      documentNumber: orNull(_documentNumberController),
      addressCountry: branchCountryKey,
      fgFullName: orNull(_guardian1FullNameController),
      fgRelation: _guardian1Relationship,
      fgEmail: orNull(_guardian1EmailController),
      fgPhone: orNull(_guardian1PhoneController),
      sgFullName: orNull(_guardian2FullNameController),
      sgRelation: _guardian2Relationship,
      sgEmail: orNull(_guardian2EmailController),
      sgPhone: orNull(_guardian2PhoneController),
      photoBase64: photoBase64,
      photoContentType: photoContentType,
    );

    // Call controller method (create vs update)
    final bool success;
    if (widget.isEditing && widget.student != null) {
      success = await _studentController.updateStudent(
        widget.student!.id,
        request.toUpdateJson(),
      );
    } else {
      success = await _studentController.createStudent(request);
    }

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
          existingImageUrl: _existingPhotoUrl(),
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
              ? (widget.student!.aid ??
                  widget.student!.studentId ??
                  'No ID')
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
            label: 'Nationality',
            value: _countryDisplay(_selectedNationalityKey),
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
                readOnly: widget.isEditing,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomDropdownField(
                label: 'Gender',
                value: _selectedGender,
                items: const ['male', 'female'],
                onChanged: (value) =>
                    setState(() => _selectedGender = value ?? 'male'),
                isRequired: true,
                icon: Icons.person_outline,
                itemLabel: (item) =>
                    '${item[0].toUpperCase()}${item.substring(1)}',
                readOnly: widget.isEditing,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildCountryDropdown(
                label: 'Nationality',
                currentKey: _selectedNationalityKey,
                onKeySelected: (key) => setState(() {
                  _selectedNationalityKey = key;
                  _reconcileDocumentType();
                }),
                icon: Icons.flag,
                readOnly: widget.isEditing,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(child: _buildDocumentTypeDropdown()),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                label: 'Document number',
                controller: _documentNumberController,
                isRequired: true,
                readOnly: widget.isEditing,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _countryDisplay(String? key) {
    if (key == null || key.isEmpty) return 'Not selected';
    return _locationService.getCountryNameFromKey(key) ?? key;
  }

  Widget _buildCountryDropdown({
    required String label,
    required String? currentKey,
    required ValueChanged<String?> onKeySelected,
    required IconData icon,
    bool readOnly = false,
  }) {
    return Obx(() {
      final names = _locationService.countryNames;
      String? currentName;
      if (currentKey != null && currentKey.isNotEmpty) {
        currentName = _locationService.getCountryNameFromKey(currentKey);
        if (currentName == null) {
          final match = names.firstWhereOrNull(
              (n) => n.toLowerCase() == currentKey.toLowerCase());
          if (match != null) currentName = match;
        }
      }
      final value = names.contains(currentName) ? currentName : null;
      return CustomDropdownField(
        label: label,
        value: value,
        items: names,
        onChanged: (name) => onKeySelected(
          name == null ? null : _locationService.getCountryKey(name),
        ),
        isRequired: true,
        icon: icon,
        readOnly: readOnly,
      );
    });
  }

  // Branch country (residence). Derived from the selected branch in storage
  // so the student inherits the branch's country without a UI control.
  String? get _branchCountryKey {
    final data = _storageService.getSelectedBranchData();
    final key = (data?['country'] as String?)?.toUpperCase();
    return (key == null || key.isEmpty) ? null : key;
  }

  // Document types allowed given current nationality / branch country.
  // Mirrors RegisterScreen._getDocumentTypeItems on mobile.
  Map<String, String> _allowedDocumentTypes() {
    final nat = _selectedNationalityKey;
    final res = _branchCountryKey;
    if (nat != null && res != null && nat == res) {
      return const {'national_id': 'National ID'};
    }
    if (res == 'SA') {
      return const {'residence_id': 'Residence ID'};
    }
    if (res == 'EG') {
      return const {
        'passport': 'Passport',
        'residence_id': 'Residence ID',
      };
    }
    return _documentTypeLabels;
  }

  // Reconcile _selectedDocumentType against the currently allowed set.
  // Call inside setState after changing nationality.
  void _reconcileDocumentType() {
    final allowed = _allowedDocumentTypes();
    final nat = _selectedNationalityKey;
    final res = _branchCountryKey;
    if (nat != null && res != null && nat == res) {
      _selectedDocumentType = 'national_id';
      return;
    }
    if (_selectedDocumentType != null &&
        !allowed.containsKey(_selectedDocumentType)) {
      _selectedDocumentType = null;
    }
  }

  // Egyptian National ID validator ported from mobile RegisterScreen.
  String? _validateEgyptianNationalId(
      String id, String gender, DateTime? selectedDob) {
    if (id.length != 14) return 'Must be exactly 14 digits';
    if (!RegExp(r'^\d{14}$').hasMatch(id)) return 'Must contain only digits';

    final century = int.parse(id[0]);
    if (century != 2 && century != 3) return 'Invalid Egyptian National ID';

    final yearPrefix = century == 2 ? 1900 : 2000;
    final year = yearPrefix + int.parse(id.substring(1, 3));
    final month = int.parse(id.substring(3, 5));
    final day = int.parse(id.substring(5, 7));
    if (month < 1 || month > 12 || day < 1 || day > 31) {
      return 'Invalid birth date in ID';
    }
    try {
      final idDate = DateTime(year, month, day);
      if (idDate.month != month || idDate.day != day) {
        return 'Invalid birth date in ID';
      }
      if (idDate.isAfter(DateTime.now())) {
        return 'Birth date in ID is in the future';
      }
      if (selectedDob != null) {
        if (idDate.year != selectedDob.year ||
            idDate.month != selectedDob.month ||
            idDate.day != selectedDob.day) {
          return 'ID birth date does not match selected date of birth';
        }
      }
    } catch (_) {
      return 'Invalid Egyptian National ID';
    }

    final genderDigit = int.parse(id[12]);
    final isMaleFromId = genderDigit.isOdd;
    if (gender == 'male' && !isMaleFromId) {
      return 'ID gender does not match selected gender';
    }
    if (gender == 'female' && isMaleFromId) {
      return 'ID gender does not match selected gender';
    }

    return null;
  }

  Widget _buildDocumentTypeDropdown() {
    final allowed = Map<String, String>.from(_allowedDocumentTypes());
    if (widget.isEditing &&
        _selectedDocumentType != null &&
        !allowed.containsKey(_selectedDocumentType) &&
        _documentTypeLabels.containsKey(_selectedDocumentType)) {
      allowed[_selectedDocumentType!] =
          _documentTypeLabels[_selectedDocumentType!]!;
    }
    final labels = allowed.values.toList();
    final currentLabel =
        _selectedDocumentType == null ? null : allowed[_selectedDocumentType!];
    return CustomDropdownField(
      label: 'Document type',
      value: currentLabel,
      items: labels,
      onChanged: (label) => setState(() {
        _selectedDocumentType = label == null
            ? null
            : allowed.entries.firstWhere((e) => e.value == label).key;
      }),
      isRequired: true,
      icon: Icons.badge_outlined,
      readOnly: widget.isEditing,
    );
  }

  Widget _buildGradeClassSection() {
    return FormSection(
      title: 'Grade & Class',
      children: [
        Row(
          children: [
            Expanded(
              child: Obx(() {
                final grades = _resourcesController.availableGrades;
                final current =
                    grades.contains(_selectedGrade) ? _selectedGrade : null;
                return CustomDropdownField(
                  label: 'Grade',
                  value: current,
                  items: grades,
                  onChanged: (value) => setState(() {
                    _selectedGrade = value;
                    _selectedClass = null;
                    _selectedClassId = null;
                  }),
                  isRequired: true,
                  icon: Icons.school,
                );
              }),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Obx(() {
                // Read .classes so Obx re-runs when data loads.
                _resourcesController.classes.length;
                final classes =
                    _resourcesController.getClassNamesForGrade(_selectedGrade);
                final current =
                    classes.contains(_selectedClass) ? _selectedClass : null;
                return CustomDropdownField(
                  label: 'Class',
                  value: current,
                  items: classes,
                  onChanged: (value) => setState(() {
                    _selectedClass = value;
                    if (value != null && _selectedGrade != null) {
                      final match = _resourcesController.getClassByNameAndGrade(
                          value, _selectedGrade!);
                      _selectedClassId = match?['id']?.toString();
                    } else {
                      _selectedClassId = null;
                    }
                  }),
                  isRequired: true,
                  icon: Icons.class_,
                );
              }),
            ),
            const SizedBox(width: 16),
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }

  Widget _buildFirstGuardianSection() => _buildGuardianSection(
        title: 'First guardian details',
        fullNameController: _guardian1FullNameController,
        emailController: _guardian1EmailController,
        phoneController: _guardian1PhoneController,
        relationship: _guardian1Relationship,
        onRelationshipChanged: (value) =>
            setState(() => _guardian1Relationship = value),
        required: true,
      );

  Widget _buildSecondGuardianSection() => _buildGuardianSection(
        title: 'Second guardian details',
        fullNameController: _guardian2FullNameController,
        emailController: _guardian2EmailController,
        phoneController: _guardian2PhoneController,
        relationship: _guardian2Relationship,
        onRelationshipChanged: (value) =>
            setState(() => _guardian2Relationship = value),
        required: false,
      );

  Widget _buildGuardianSection({
    required String title,
    required TextEditingController fullNameController,
    required TextEditingController emailController,
    required TextEditingController phoneController,
    required String? relationship,
    required ValueChanged<String?> onRelationshipChanged,
    required bool required,
  }) {
    return FormSection(
      title: title,
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'Full name',
                controller: fullNameController,
                isRequired: required,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomDropdownField(
                label: 'Relationship with student',
                value: relationship,
                items: _relationOptions,
                onChanged: onRelationshipChanged,
                isRequired: required,
                itemLabel: _relationLabel,
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
                controller: emailController,
                isRequired: required,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                label: 'Phone number',
                controller: phoneController,
                isRequired: required,
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
    _documentNumberController.dispose();
    _guardian1FullNameController.dispose();
    _guardian1EmailController.dispose();
    _guardian1PhoneController.dispose();
    _guardian2FullNameController.dispose();
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
  final bool readOnly;

  const CustomTextField({
    Key? key,
    required this.label,
    required this.controller,
    this.isRequired = false,
    this.keyboardType,
    this.prefixIcon,
    this.onChanged,
    this.readOnly = false,
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
          readOnly: readOnly,
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
            fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
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
  final String Function(String item)? itemLabel;
  final bool readOnly;

  const CustomDropdownField({
    Key? key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.isRequired = false,
    this.icon,
    this.itemLabel,
    this.readOnly = false,
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
          onChanged: readOnly ? null : onChanged,
          isExpanded: true,
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
            fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
          ),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                itemLabel?.call(item) ?? item,
                overflow: TextOverflow.ellipsis,
              ),
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
  final bool readOnly;

  const CustomDateField({
    Key? key,
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
    this.isRequired = false,
    this.readOnly = false,
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
          onTap: readOnly
              ? null
              : () async {
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
              color: readOnly ? Colors.grey.shade100 : Colors.white,
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
  final String? existingImageUrl;
  final bool isLoading;
  final VoidCallback onPickImage;
  final VoidCallback onRemoveImage;
  final String studentName;

  const ImagePickerWidget({
    Key? key,
    required this.selectedImageBytes,
    required this.selectedImageName,
    this.existingImageUrl,
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
                : (existingImageUrl != null && existingImageUrl!.isNotEmpty)
                    ? Image.network(
                        existingImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.person,
                              size: 60, color: Colors.grey),
                        ),
                      )
                    : Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.person,
                            size: 60, color: Colors.grey),
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
                color: Color(0xFF1339FF),
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
