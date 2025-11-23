import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_getx_app/models/branch_model.dart';
import 'package:get/get.dart';
import '../../../controllers/home_controller.dart';
import '../../../controllers/branch_management_controller.dart';
// Note: Add these packages to pubspec.yaml:
// image_picker: ^1.0.4
// path_provider: ^2.1.1

class BranchFormWidget extends StatefulWidget {
  const BranchFormWidget({Key? key}) : super(key: key);

  @override
  State<BranchFormWidget> createState() => _BranchFormWidgetState();
}

class _BranchFormWidgetState extends State<BranchFormWidget> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _branchNameController = TextEditingController();
  final _headquartersController = TextEditingController();
  final _streetAddressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _studentCountController = TextEditingController();
  final _teacherCountController = TextEditingController();

  // Form state
  String _selectedAccountType = 'School';
  String _selectedEducationType = 'British';
  String _selectedCountry = 'Egypt';
  String _selectedGovernorate = 'Alexandria';
  String _selectedCity = 'Alexandria';
  String _selectedArea = 'Alexandria';
  String _selectedUser = 'Ahmed mansour Saied';
  String _selectedRole = 'Doctor';
  String _selectedStatus = 'active';

  // Image upload state
  Uint8List? _selectedImageBytes;
  String? _selectedImagePath;
  final RxBool _isUploadingImage = false.obs;

  List<String> _selectedGrades = ['Year 1', 'Year 2'];
  List<Map<String, String>> _assignedUsers = [
    {'name': 'Dr. Ahmed mansour Saied', 'role': 'Doctor'}
  ];

  late HomeController homeController;
  late BranchManagementController branchController;

  @override
  void initState() {
    super.initState();
    homeController = Get.find<HomeController>();
    branchController = Get.find<BranchManagementController>();
    
    // Initialize with default or existing data
    _initializeForm();
  }

  void _initializeForm() {
    if (homeController.isEditingBranch.value && homeController.branchToEdit.value != null) {
      final branch = homeController.branchToEdit.value!;
      _branchNameController.text = branch.name;
      _headquartersController.text = branch.address ?? '';
      _phoneController.text = branch.phone ?? '';
      _emailController.text = branch.email ?? '';
      _studentCountController.text = branch.studentCount?.toString() ?? '0';
      _teacherCountController.text = branch.teacherCount?.toString() ?? '0';
      _selectedStatus = branch.status ?? 'active';
      
      // Load existing image if available
      // In a real app, you would load the image from the stored path/URL
      // if (branch.imagePath != null) {
      //   _loadExistingImage(branch.imagePath!);
      // }
    }
  }

  // Future<void> _loadExistingImage(String imagePath) async {
  //   try {
  //     if (kIsWeb) {
  //       // For web, load from URL
  //       final response = await http.get(Uri.parse(imagePath));
  //       _selectedImageBytes = response.bodyBytes;
  //     } else {
  //       // For mobile, load from file path
  //       final file = File(imagePath);
  //       _selectedImageBytes = await file.readAsBytes();
  //     }
  //     setState(() {});
  //   } catch (e) {
  //     print('Failed to load existing image: $e');
  //   }
  // }

  @override
  void dispose() {
    _branchNameController.dispose();
    _headquartersController.dispose();
    _streetAddressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _studentCountController.dispose();
    _teacherCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          homeController.isEditingBranch.value ? 'Edit Branch' : 'Add New Branch',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
        leading: IconButton(
          onPressed: () => homeController.exitBranchForm(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sidebar with photo upload
            _buildSidebar(),
            // Main form content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBranchTypeSection(),
                      const SizedBox(height: 32),
                      _buildBranchDetailsSection(),
                      const SizedBox(height: 32),
                      _buildAddressDetailsSection(),
                      const SizedBox(height: 32),
                      _buildRolesSection(),
                      const SizedBox(height: 48),
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    final screenWidth = MediaQuery.of(context).size.width;
    final sidebarWidth = screenWidth < 1200 ? 280.0 : 300.0;
    
    return Container(
      width: sidebarWidth,
      height: MediaQuery.of(context).size.height - 80, // Account for AppBar
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: Column(
        children: [
          // Photo upload section
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Text(
                  'Branch Photo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 24),
                _buildImageUploadSection(),
                const SizedBox(height: 16),
                Text(
                  _selectedImageBytes != null ? 'Photo uploaded' : 'No photo selected',
                  style: TextStyle(
                    fontSize: 14,
                    color: _selectedImageBytes != null 
                        ? const Color(0xFF059669) 
                        : const Color(0xFF6B7280),
                  ),
                ),
                if (_selectedImageBytes != null) ...[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _removeImage,
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('Remove Photo'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ],
            ),
          ),
    ],
      ),
    );
  }

  Widget _buildQuickInfoItem(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchTypeSection() {
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
          const Text(
            'Branch type',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: 'Account type',
                  value: _selectedAccountType,
                  isRequired: true,
                  items: ['School', 'Hospital', 'Clinic', 'University'],
                  onChanged: (value) {
                    setState(() => _selectedAccountType = value!);
                    _updateQuickInfo();
                  },
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildTextField(
                  controller: _branchNameController,
                  label: 'Branch name',
                  hint: 'School',
                  isRequired: true,
                  prefixIcon: Icons.business,
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
        ],
      ),
    );
  }

  Widget _buildBranchDetailsSection() {
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
          const Text(
            'Branch details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _headquartersController,
                  label: 'Headquarters',
                  hint: 'Address goes here',
                  isRequired: true,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Headquarters address is required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildDropdownField(
                  label: 'Education type',
                  value: _selectedEducationType,
                  isRequired: true,
                  icon: Icons.school,
                  items: ['British', 'American', 'Arabic', 'French', 'German'],
                  onChanged: (value) {
                    setState(() => _selectedEducationType = value!);
                    _updateQuickInfo();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildGradesSection(),
        ],
      ),
    );
  }

  Widget _buildGradesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'Grades',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151),
              ),
            ),
            Text(
              '*',
              style: TextStyle(color: Colors.red, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.school, size: 20, color: Color(0xFF6B7280)),
                  const SizedBox(width: 8),
                  Text(
                    _selectedEducationType,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF374151),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._selectedGrades.map((grade) => _buildGradeChip(grade)),
                  _buildAddGradeButton(),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGradeChip(String grade) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            grade,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => _removeGrade(grade),
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: Color(0xFFEF4444),
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

  Widget _buildAddGradeButton() {
    return GestureDetector(
      onTap: _showAddGradeDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 16, color: Color(0xFF6B7280)),
            SizedBox(width: 4),
            Text(
              'Add Grade',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressDetailsSection() {
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
          const Text(
            'Address details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: 'Country',
                  value: _selectedCountry,
                  isRequired: true,
                  flag: '🇪🇬',
                  items: ['Egypt', 'Saudi Arabia', 'UAE', 'Kuwait'],
                  onChanged: (value) {
                    setState(() => _selectedCountry = value!);
                    _updateQuickInfo();
                  },
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildDropdownField(
                  label: 'Governorate',
                  value: _selectedGovernorate,
                  isRequired: true,
                  items: ['Alexandria', 'Cairo', 'Giza', 'Luxor'],
                  onChanged: (value) => setState(() => _selectedGovernorate = value!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
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
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: 'City',
                  value: _selectedCity,
                  isRequired: true,
                  items: ['Alexandria', 'Cairo', 'Giza', 'Luxor'],
                  onChanged: (value) => setState(() => _selectedCity = value!),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildTextField(
                  controller: TextEditingController(text: _selectedArea),
                  label: 'Area',
                  hint: 'Alexandria',
                  isRequired: true,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Area is required';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRolesSection() {
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
          const Text(
            'Roles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: 'Select user',
                  value: _selectedUser,
                  isRequired: true,
                  items: ['Ahmed mansour Saied', 'Dr. Sarah Ahmed', 'Prof. Mohamed Ali'],
                  onChanged: (value) => setState(() => _selectedUser = value!),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildDropdownField(
                  label: 'Role / Position',
                  value: _selectedRole,
                  isRequired: true,
                  items: ['Doctor', 'Teacher', 'Principal', 'Nurse', 'Administrator'],
                  onChanged: (value) => setState(() => _selectedRole = value!),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                margin: const EdgeInsets.only(top: 24),
                child: ElevatedButton(
                  onPressed: _addUserRole,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(12),
                    minimumSize: const Size(48, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_assignedUsers.isNotEmpty) ...[
            const Text(
              'Assigned Users',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 12),
            ..._assignedUsers.map((user) => _buildAssignedUserCard(user)),
          ],
        ],
      ),
    );
  }

  Widget _buildAssignedUserCard(Map<String, String> user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFF3B82F6),
            child: Text(
              user['name']!.split(' ').map((n) => n[0]).take(2).join(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${user['name']} - ${user['role']}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF374151),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _removeUserRole(user),
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Color(0xFFEF4444),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
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
        const SizedBox(width: 16),
        Obx(() => ElevatedButton.icon(
              onPressed: branchController.isLoading.value
                  ? null
                  : () => _handleSaveBranch(),
              icon: branchController.isLoading.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(
                branchController.isLoading.value 
                    ? (homeController.isEditingBranch.value ? 'Updating...' : 'Adding...') 
                    : (homeController.isEditingBranch.value ? 'Update Branch' : 'Save Branch'),
                style: const TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildImageUploadSection() {
    return Stack(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(60),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
            image: _selectedImageBytes != null 
                ? DecorationImage(
                    image: MemoryImage(_selectedImageBytes!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: _selectedImageBytes == null
              ? const Icon(
                  Icons.camera_alt_outlined,
                  color: Color(0xFF9CA3AF),
                  size: 48,
                )
              : null,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Obx(() => GestureDetector(
                onTap: _isUploadingImage.value ? null : _showImagePicker,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: _isUploadingImage.value
                      ? const Padding(
                          padding: EdgeInsets.all(8),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 18,
                        ),
                ),
              )),
        ),
      ],
    );
  }

  void _showImagePicker() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Branch Photo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildImageOption(
                    icon: Icons.photo_library,
                    title: 'Gallery',
                    subtitle: 'Choose from gallery',
                    onTap: () => _pickImage(fromCamera: false),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildImageOption(
                    icon: Icons.camera_alt,
                    title: 'Camera',
                    subtitle: 'Take a photo',
                    onTap: () => _pickImage(fromCamera: true),
                  ),
                ),
              ],
            ),
            if (_selectedImageBytes != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: _buildImageOption(
                  icon: Icons.delete,
                  title: 'Remove Photo',
                  subtitle: 'Delete current photo',
                  onTap: _removeImage,
                  color: Colors.red,
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    final iconColor = color ?? const Color(0xFF3B82F6);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage({required bool fromCamera}) async {
    try {
      Get.back(); // Close bottom sheet
      _isUploadingImage.value = true;

      // Simulate image picker - In real app, use image_picker package
      // final picker = ImagePicker();
      // final XFile? image = await picker.pickImage(
      //   source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      //   maxWidth: 800,
      //   maxHeight: 800,
      //   imageQuality: 85,
      // );

      // For demo purposes, simulate image selection with delay
      await Future.delayed(const Duration(seconds: 1));

      // In real implementation, you would:
      // if (image != null) {
      //   if (kIsWeb) {
      //     _selectedImageBytes = await image.readAsBytes();
      //   } else {
      //     _selectedImagePath = image.path;
      //     _selectedImageBytes = await File(image.path).readAsBytes();
      //   }
      //   setState(() {});
      // }

      // Demo: Create a placeholder colored image
      _simulateImageSelection();

      Get.snackbar(
        'Success',
        'Image uploaded successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to upload image: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFF44336),
        colorText: Colors.white,
      );
    } finally {
      _isUploadingImage.value = false;
    }
  }

  void _simulateImageSelection() {
    // Create a simple colored square as demo image
    final width = 100;
    final height = 100;
    final bytes = Uint8List(width * height * 4); // RGBA
    
    // Fill with a blue gradient
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final index = (y * width + x) * 4;
        bytes[index] = (x * 255 ~/ width);     // R
        bytes[index + 1] = (y * 255 ~/ height); // G
        bytes[index + 2] = 200;                // B
        bytes[index + 3] = 255;                // A
      }
    }
    
    setState(() {
      _selectedImageBytes = bytes;
    });
  }

  void _removeImage() {
    setState(() {
      _selectedImageBytes = null;
      _selectedImagePath = null;
    });
    
    Get.snackbar(
      'Removed',
      'Branch photo removed',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF6B7280),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  // Method to update quick info when form values change
  void _updateQuickInfo() {
    setState(() {
      // This will trigger a rebuild of the sidebar with updated values
    });
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isRequired = false,
    IconData? prefixIcon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
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
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20) : null,
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
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    bool isRequired = false,
    IconData? icon,
    String? flag,
  }) {
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
            prefixIcon: flag != null 
                ? Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(flag, style: const TextStyle(fontSize: 18)),
                  )
                : icon != null 
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
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _removeGrade(String grade) {
    setState(() {
      _selectedGrades.remove(grade);
    });
    _updateQuickInfo();
  }

  void _showAddGradeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Grade'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            'Year 3', 'Year 4', 'Year 5', 'Year 6', 'Year 7', 'Year 8', 'Year 9', 'Year 10', 'Year 11', 'Year 12'
          ].where((grade) => !_selectedGrades.contains(grade)).map((grade) => 
            ListTile(
              title: Text(grade),
              onTap: () {
                setState(() {
                  _selectedGrades.add(grade);
                });
                Navigator.pop(context);
                _updateQuickInfo();
              },
            ),
          ).toList(),
        ),
      ),
    );
  }

  void _addUserRole() {
    if (_selectedUser.isNotEmpty && _selectedRole.isNotEmpty) {
      final newUser = {'name': _selectedUser, 'role': _selectedRole};
      if (!_assignedUsers.any((user) => user['name'] == _selectedUser && user['role'] == _selectedRole)) {
        setState(() {
          _assignedUsers.add(newUser);
        });
        _updateQuickInfo();
      }
    }
  }

  void _removeUserRole(Map<String, String> user) {
    setState(() {
      _assignedUsers.remove(user);
    });
    _updateQuickInfo();
  }

  void _handleSaveBranch() {
    if (_formKey.currentState!.validate()) {
      final newBranch = BranchModel(
        id: homeController.isEditingBranch.value && homeController.branchToEdit.value != null
            ? homeController.branchToEdit.value!.id
            : DateTime.now().millisecondsSinceEpoch.toString(),
        name: _branchNameController.text,
        role: 'Branch Admin',
        icon: 'clinic',
        address: '${_streetAddressController.text}, $_selectedArea, $_selectedCity, $_selectedGovernorate, $_selectedCountry',
        phone: _phoneController.text,
        email: _emailController.text,
        principalName: _assignedUsers.isNotEmpty ? _assignedUsers.first['name']! : 'N/A',
        studentCount: int.tryParse(_studentCountController.text) ?? 0,
        teacherCount: int.tryParse(_teacherCountController.text) ?? 0,
        status: _selectedStatus,
        createdAt: homeController.isEditingBranch.value && homeController.branchToEdit.value != null
            ? homeController.branchToEdit.value!.createdAt
            : DateTime.now(),
        // Note: In a real app, you would save the image to storage and store the URL/path
        // imagePath: _selectedImagePath,
        // imageBytes: _selectedImageBytes,
      );

      // Show success message with image info
      final imageStatus = _selectedImageBytes != null ? ' with photo' : '';
      
      if (homeController.isEditingBranch.value) {
        branchController.updateBranch(newBranch).then((_) {
          Get.snackbar(
            'Success',
            'Branch updated successfully$imageStatus',
            snackPosition: SnackPosition.TOP,
            backgroundColor: const Color(0xFF4CAF50),
            colorText: Colors.white,
          );
          homeController.exitBranchForm();
        });
      } else {
        branchController.addBranch(newBranch).then((_) {
          Get.snackbar(
            'Success',
            'Branch created successfully$imageStatus',
            snackPosition: SnackPosition.TOP,
            backgroundColor: const Color(0xFF4CAF50),
            colorText: Colors.white,
          );
          homeController.exitBranchForm();
        });
      }
    }
  }
}