import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
//import 'package:flutter_getx_app/models/branch_model.dart';
import 'package:flutter_getx_app/models/create_branch_request.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

import '../../../controllers/home_controller.dart';
import '../../../controllers/branch_management_controller.dart';

class BranchFormWidget extends StatefulWidget {
  const BranchFormWidget({Key? key}) : super(key: key);

  @override
  State<BranchFormWidget> createState() => _BranchFormWidgetState();
}

class _BranchFormWidgetState extends State<BranchFormWidget> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _branchNameController = TextEditingController();
  final _streetAddressController = TextEditingController();

  // Form state
  String _selectedAccountType = 'School';
  String _selectedEducationType = 'British';
  String _selectedGovernorate = 'Alexandria';
  String _selectedCity = 'Alexandria';
  bool _isHeadquarters = false;

  // Image upload state
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  final RxBool _isUploadingImage = false.obs;

  // Grade selection - Multiple grades
  List<String> _selectedGrades = [];
  final List<String> _allGrades = ['G1', 'G2', 'G3', 'G4', 'G5', 'G6'];

  late HomeController homeController;
  late BranchManagementController branchController;

  @override
  void initState() {
    super.initState();
    homeController = Get.find();
    branchController = Get.find();
    _initializeForm();
  }

  void _initializeForm() {
    if (homeController.isEditingBranch.value &&
        homeController.branchToEdit.value != null) {
      final branch = homeController.branchToEdit.value!;

      // Basic info
      _branchNameController.text = branch.name;
      _selectedAccountType = branch.role;

      // Address
      if (branch.street != null && branch.street!.isNotEmpty) {
        _streetAddressController.text = branch.street!;
      }
      if (branch.governorate != null && branch.governorate!.isNotEmpty) {
        _selectedGovernorate = branch.governorate!;
      }
      if (branch.city != null && branch.city!.isNotEmpty) {
        _selectedCity = branch.city!;
      }

      // Education details
      if (branch.educationType != null && branch.educationType!.isNotEmpty) {
        _selectedEducationType = branch.educationType!;
      }
      if (branch.grades != null && branch.grades!.isNotEmpty) {
        _selectedGrades = List.from(branch.grades!);
      }
      if (branch.isHeadquarters != null) {
        _isHeadquarters = branch.isHeadquarters!;
      }

      print('✅ Form initialized with branch data');
      print('📋 Grades: $_selectedGrades');
      print('📋 City: $_selectedCity, Governorate: $_selectedGovernorate');
    }
  }

  @override
  void dispose() {
    _branchNameController.dispose();
    _streetAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: Form(
        key: _formKey,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSidebar(),
            Expanded(child: _buildMainContent()),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () => homeController.exitBranchForm(),
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
      ),
      title: Row(
        children: [
          const Text(
            'Branches',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            homeController.isEditingBranch.value ? 'Edit Branch' : 'Add new',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => homeController.exitBranchForm(),
          child: const Text(
            'Cancel',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Obx(() => ElevatedButton(
              onPressed: branchController.isSaving.value
                  ? null
                  : () => _handleSaveBranch(),
              style: ElevatedButton.styleFrom(
                backgroundColor: branchController.isSaving.value
                    ? Colors.grey
                    : const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: branchController.isSaving.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Text(
                      'Save details',
                      style: TextStyle(fontSize: 16),
                    ),
            )),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 320,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildImageUploadSection(),
            const SizedBox(height: 16),
            Text(
              _branchNameController.text.isEmpty
                  ? 'Branch name'
                  : _branchNameController.text,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _selectedAccountType,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildQuickInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Info',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 12),
          _buildQuickInfoItem(
            icon: Icons.school_outlined,
            label: 'Education Type',
            value: _selectedEducationType,
          ),
          const SizedBox(height: 8),
          _buildQuickInfoItem(
            icon: Icons.class_outlined,
            label: 'Grades',
            value: _selectedGrades.isEmpty
                ? 'Not selected'
                : _selectedGrades.join(', '),
          ),
          const SizedBox(height: 8),
          _buildQuickInfoItem(
            icon: Icons.location_on_outlined,
            label: 'Location',
            value: '$_selectedCity, $_selectedGovernorate',
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
      crossAxisAlignment: CrossAxisAlignment.start,
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
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF374151),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageUploadSection() {
    return Stack(
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE5E7EB), width: 3),
            image: _selectedImageBytes != null
                ? DecorationImage(
                    image: MemoryImage(_selectedImageBytes!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: _selectedImageBytes == null
              ? const Icon(
                  Icons.business_outlined,
                  color: Color(0xFF9CA3AF),
                  size: 48,
                )
              : null,
        ),
        Positioned(
          bottom: 5,
          right: 5,
          child: Obx(() => GestureDetector(
                onTap: _isUploadingImage.value ? null : _pickImage,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: _isUploadingImage.value
                      ? const Padding(
                          padding: EdgeInsets.all(8),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 18,
                        ),
                ),
              )),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    _isUploadingImage.value = true;
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        if (file.size > 5 * 1024 * 1024) {
          Get.snackbar(
            'Error',
            'Image size must be less than 5MB',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }

        setState(() {
          _selectedImageBytes = file.bytes;
          _selectedImageName = file.name;
        });
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isUploadingImage.value = false;
    }
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBranchTypeSection(),
            const SizedBox(height: 24),
            _buildBranchDetailsSection(),
            const SizedBox(height: 24),
            _buildAddressDetailsSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchTypeSection() {
    return FormSection(
      title: 'Branch type',
      children: [
        Row(
          children: [
            Expanded(
              child: CustomDropdownField(
                label: 'Account type',
                value: _selectedAccountType,
                isRequired: true,
                items: const ['School', 'Hospital', 'Clinic', 'University'],
                onChanged: (value) {
                  setState(() => _selectedAccountType = value!);
                },
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: CustomTextField(
                controller: _branchNameController,
                label: 'Branch name',
                hint: 'School',
                isRequired: true,
                prefixIcon: Icons.business_outlined,
                onChanged: (value) => setState(() {}),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Branch name is required';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Checkbox(
              value: _isHeadquarters,
              onChanged: (value) {
                setState(() => _isHeadquarters = value ?? false);
              },
              activeColor: const Color(0xFF3B82F6),
            ),
            const Text(
              'This branch is representing the headquarters',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF374151),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBranchDetailsSection() {
    return FormSection(
      title: 'Branch details',
      children: [
        Row(
          children: [
            Expanded(
              child: CustomDropdownField(
                label: 'Education type',
                value: _selectedEducationType,
                isRequired: true,
                icon: Icons.school_outlined,
                items: const ['British', 'American', 'National'],
                onChanged: (value) {
                  setState(() => _selectedEducationType = value!);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildMultiGradeSelector(),
      ],
    );
  }

  Widget _buildMultiGradeSelector() {
    // Get grades that haven't been selected yet
    final availableGrades =
        _allGrades.where((g) => !_selectedGrades.contains(g)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Grades',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151),
              ),
            ),
            const Text(
              '*',
              style: TextStyle(color: Colors.red, fontSize: 14),
            ),
            const Spacer(),
            if (availableGrades.isNotEmpty &&
                _selectedGrades.length < _allGrades.length)
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedGrades = List.from(_allGrades);
                  });
                },
                icon: const Icon(Icons.add_circle_outline, size: 16),
                label: const Text('Add All'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF3B82F6),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: _selectedGrades.isEmpty
                  ? Colors.red.shade200
                  : const Color(0xFFE5E7EB),
            ),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dropdown to add grades
              if (availableGrades.isNotEmpty)
                DropdownButtonFormField<String>(
                  key: ValueKey('grade_dropdown_${_selectedGrades.length}'),
                  value: null,
                  hint: Row(
                    children: [
                      Icon(
                        Icons.school_outlined,
                        size: 20,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Select grade to add',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF3B82F6)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  items: availableGrades.map((String grade) {
                    return DropdownMenuItem(
                      value: grade,
                      child: Text(grade),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    if (value != null) {
                      setState(() {
                        _selectedGrades.add(value);
                      });
                    }
                  },
                ),

              // Show message when all grades are selected
              if (availableGrades.isEmpty &&
                  _selectedGrades.length == _allGrades.length)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle,
                          size: 20, color: Colors.green.shade600),
                      const SizedBox(width: 8),
                      Text(
                        'All grades selected',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

              // Selected grades chips
              if (_selectedGrades.isNotEmpty) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Selected Grades (${_selectedGrades.length})',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    if (_selectedGrades.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedGrades.clear();
                          });
                        },
                        child: const Text(
                          'Clear All',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedGrades.map((grade) {
                    return _buildGradeChip(grade);
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
        if (_selectedGrades.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Please select at least one grade',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red.shade700,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGradeChip(String grade) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            grade,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF3B82F6),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedGrades.remove(grade);
              });
            },
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: Color(0xFF3B82F6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 10,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressDetailsSection() {
    return FormSection(
      title: 'Address details',
      children: [
        Row(
          children: [
            Expanded(
              child: CustomDropdownField(
                label: 'Governorate',
                value: _selectedGovernorate,
                isRequired: true,
                items: const ['Alexandria', 'Cairo', 'Giza', 'Luxor', 'Aswan'],
                onChanged: (value) {
                  setState(() => _selectedGovernorate = value!);
                },
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: CustomDropdownField(
                label: 'City',
                value: _selectedCity,
                isRequired: true,
                items: const ['Alexandria', 'Cairo', 'Giza', 'Luxor', 'Aswan'],
                onChanged: (value) {
                  setState(() => _selectedCity = value!);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        CustomTextField(
          controller: _streetAddressController,
          label: 'Street address',
          hint: 'Street address',
          isRequired: true,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Street address is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  void _handleSaveBranch() {
    if (_formKey.currentState!.validate()) {
      // Validate required fields
      if (_selectedGrades.isEmpty) {
        Get.snackbar(
          'Error',
          'Please select at least one grade',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Create request object
      final request = CreateBranchRequest(
        name: _branchNameController.text.trim(),
        accountType: _selectedAccountType,
        isHeadquarters: _isHeadquarters,
        educationType: _selectedEducationType,
        grades: _selectedGrades,
        address: BranchAddress(
          governorate: _selectedGovernorate,
          city: _selectedCity,
          street: _streetAddressController.text.trim(),
        ),
        phone: null,
        website: null,
      );

      // Check if editing or creating
      if (homeController.isEditingBranch.value &&
          homeController.branchToEdit.value != null) {
        // UPDATE existing branch
        final branchId = homeController.branchToEdit.value!.id;
        branchController.updateBranch(branchId, request).then((success) {
          if (success) {
            homeController.exitBranchForm();
          }
        });
      } else {
        // CREATE new branch
        branchController.createBranch(request).then((success) {
          if (success) {
            homeController.exitBranchForm();
          }
        });
      }
    }
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
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
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
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
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool isRequired;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;
  final Function(String)? onChanged;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.label,
    required this.hint,
    this.isRequired = false,
    this.prefixIcon,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151),
              ),
            ),
            if (isRequired)
              const Text(
                '*',
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 20, color: const Color(0xFF6B7280))
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF3B82F6)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            filled: true,
            fillColor: Colors.white,
          ),
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
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151),
              ),
            ),
            if (isRequired)
              const Text(
                '*',
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          decoration: InputDecoration(
            prefixIcon: icon != null
                ? Icon(icon, size: 20, color: const Color(0xFF6B7280))
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF3B82F6)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          items: items.map((String item) {
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
