import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_getx_app/config/app_config.dart';
import 'package:flutter_getx_app/models/create_branch_request.dart';
import 'package:flutter_getx_app/utils/location_service.dart';
import 'package:flutter_getx_app/utils/storage_service.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:flutter_getx_app/utils/app_snackbar.dart';

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
  String _selectedEducationType = 'American';
  String? _selectedGovernorate;
  String? _selectedCity;
  bool _isHeadquarters = false;

  // Image upload state
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  String? _existingLogoUrl;
  final RxBool _isUploadingImage = false.obs;

  // Grade selection - Multiple grades
  List<String> _selectedGrades = [];

  // Grade options per education type. Order here is the order shown in the
  // dropdown.
  static const Map<String, List<String>> _gradesByEducationType = {
    'British': [
      'Pre-KG',
      'FS1',
      'FS2',
      'Y1',
      'Y2',
      'Y3',
      'Y4',
      'Y5',
      'Y6',
      'Y7',
      'Y8',
      'Y9',
      'Y10',
      'Y11',
      'Y12',
    ],
    'American': [
      'Pre-KG',
      'KG1',
      'KG2',
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
      'G12',
    ],
  };

  List<String> get _allGrades =>
      _gradesByEducationType[_selectedEducationType] ??
      const ['G1', 'G2', 'G3', 'G4', 'G5', 'G6'];

  // Per-row grade text controllers, used for all education types.
  List<TextEditingController> _customGradeControllers = [];

  // Education type to display name mapping
  static const Map<String, String> _educationTypeFromApi = {
    'AMERICAN': 'American',
    'BRITISH': 'British',
    'CUSTOM': 'Custom',
  };

  bool get _isEditMode =>
      homeController.isEditingBranch.value &&
      homeController.branchToEdit.value != null;

  late HomeController homeController;
  late BranchManagementController branchController;
  late LocationService locationService;
  late StorageService _storageService;

  /// Country code for the currently selected organization/branch.
  /// Falls back to 'EG' when no branch is selected yet.
  String get _country {
    final branchData = _storageService.getSelectedBranchData();
    final code = branchData?['country'] as String?;
    return (code != null && code.isNotEmpty) ? code : 'EG';
  }

  @override
  void initState() {
    super.initState();
    homeController = Get.find();
    branchController = Get.find();
    locationService = Get.find();
    _storageService = Get.find();
    // Refresh governorates for the organization's country (service is shared
    // across the app and may have been primed with a different country).
    locationService.fetchGovernorates(country: _country);
    _initializeForm();
  }

  void _initializeForm() {
    if (homeController.isEditingBranch.value &&
        homeController.branchToEdit.value != null) {
      final branch = homeController.branchToEdit.value!;

      // Basic info
      _branchNameController.text = branch.name;
      if (branch.role.isNotEmpty) {
        _selectedAccountType = branch.role;
      }

      // Address
      if (branch.street != null && branch.street!.isNotEmpty) {
        _streetAddressController.text = branch.street!;
      }
      // Resolve governorate: API returns key (e.g. "CAIRO"), resolve to display name
      if (branch.governorate != null && branch.governorate!.isNotEmpty) {
        final govName =
            locationService.getGovernorateNameFromKey(branch.governorate!);
        _selectedGovernorate = govName ?? branch.governorate!;
        // Load cities for this governorate
        final govKey =
            locationService.getGovernorateKey(_selectedGovernorate!) ??
                branch.governorate!.toUpperCase();
        locationService.fetchCities(govKey, country: _country).then((_) {
          // Resolve city name after cities are loaded
          if (branch.city != null && branch.city!.isNotEmpty) {
            final cityName = locationService.getCityNameFromKey(branch.city!);
            if (cityName != null) {
              setState(() => _selectedCity = cityName);
            } else {
              setState(() => _selectedCity = branch.city!);
            }
          }
        });
      }
      if (branch.city != null && branch.city!.isNotEmpty) {
        _selectedCity = branch.city!;
      }

      // Education details - normalize from API uppercase to title case
      if (branch.educationType != null && branch.educationType!.isNotEmpty) {
        final apiType = branch.educationType!.toUpperCase();
        _selectedEducationType =
            _educationTypeFromApi[apiType] ?? branch.educationType!;
      }
      if (branch.grades != null && branch.grades!.isNotEmpty) {
        _selectedGrades = List.from(branch.grades!);
      }
      if (branch.isHeadquarters != null) {
        _isHeadquarters = branch.isHeadquarters!;
      }
      if (branch.logoUrl != null && branch.logoUrl!.isNotEmpty) {
        _existingLogoUrl = branch.logoUrl;
      }

      _initGradeControllers();
    } else {
      _initGradeControllers();
    }
  }

  void _initGradeControllers() {
    _disposeGradeControllers();
    _customGradeControllers = _selectedGrades
        .map((grade) => TextEditingController(text: grade))
        .toList();
    if (_customGradeControllers.isEmpty) {
      _customGradeControllers.add(TextEditingController());
    }
  }

  void _disposeGradeControllers() {
    for (final controller in _customGradeControllers) {
      controller.dispose();
    }
    _customGradeControllers = [];
  }

  void _syncGradesFromControllers() {
    _selectedGrades = _customGradeControllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();
  }

  @override
  void dispose() {
    _branchNameController.dispose();
    _streetAddressController.dispose();
    _disposeGradeControllers();
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
                    : const Color(0xFF1339FF),
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
            value: '${_selectedCity ?? '-'}, ${_selectedGovernorate ?? '-'}',
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

  // Branch logo paths come back from the API as bare GCS object paths
  // (e.g. "EG/organizations/.../logo-xxx.png"). Resolve them through the
  // backend's /api/files/gcs/ proxy. Absolute URLs and backend-rooted paths
  // are passed through.
  String _resolveBranchLogoUrl(String raw) {
    if (raw.startsWith('http')) return raw;
    if (raw.startsWith('/')) return '${AppConfig.newBackendUrl}$raw';
    return '${AppConfig.newBackendUrl}/api/files/gcs/$raw';
  }

  Widget _buildImageUploadSection() {
    DecorationImage? bgImage;
    if (_selectedImageBytes != null) {
      bgImage = DecorationImage(
        image: MemoryImage(_selectedImageBytes!),
        fit: BoxFit.cover,
      );
    } else if (_existingLogoUrl != null && _existingLogoUrl!.isNotEmpty) {
      bgImage = DecorationImage(
        image: NetworkImage(_resolveBranchLogoUrl(_existingLogoUrl!)),
        fit: BoxFit.cover,
        onError: (_, __) {},
      );
    }
    final hasImage = bgImage != null;

    return Stack(
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE5E7EB), width: 3),
            image: bgImage,
          ),
          child: hasImage
              ? null
              : const Icon(
                  Icons.business_outlined,
                  color: Color(0xFF9CA3AF),
                  size: 48,
                ),
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
                    color: const Color(0xFF1339FF),
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
          appSnackbar(
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
      appSnackbar(
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
            _buildAddressDetailsSection(),
            const SizedBox(height: 24),
            _buildBranchDetailsSection(),
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
        CustomTextField(
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
        const SizedBox(height: 16),
        Row(
          children: [
            Checkbox(
              value: _isHeadquarters,
              onChanged: (value) {
                setState(() => _isHeadquarters = value ?? false);
              },
              activeColor: const Color(0xFF1339FF),
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

  Widget _buildAddressDetailsSection() {
    return Obx(() {
      final governorateNames = locationService.governorateNames;
      final cityNames = locationService.cityNames;

      // Ensure selected values are valid within current lists
      final validGovernorate = (_selectedGovernorate != null &&
              governorateNames.contains(_selectedGovernorate))
          ? _selectedGovernorate
          : null;
      final validCity =
          (_selectedCity != null && cityNames.contains(_selectedCity))
              ? _selectedCity
              : null;

      return FormSection(
        title: 'Address details',
        children: [
          Row(
            children: [
              Expanded(
                child: CustomDropdownField(
                  label: 'Governorate',
                  value: validGovernorate,
                  isRequired: true,
                  items: governorateNames,
                  onChanged: (value) {
                    setState(() {
                      _selectedGovernorate = value;
                      _selectedCity = null;
                    });
                    if (value != null) {
                      final govKey = locationService.getGovernorateKey(value);
                      if (govKey != null) {
                        locationService.fetchCities(govKey,
                            country: _country);
                      }
                    }
                  },
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: locationService.isLoadingCities.value
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Row(
                            children: [
                              Text(
                                'City',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF374151),
                                ),
                              ),
                              Text(
                                '*',
                                style:
                                    TextStyle(color: Colors.red, fontSize: 14),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                        ],
                      )
                    : CustomDropdownField(
                        label: 'City',
                        value: validCity,
                        isRequired: true,
                        items: cityNames,
                        onChanged: (value) {
                          setState(() => _selectedCity = value);
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
          ),
        ],
      );
    });
  }

  Widget _buildBranchDetailsSection() {
    return FormSection(
      title: 'Branch details',
      children: [
        CustomDropdownField(
          label: 'Education type',
          value: _selectedEducationType,
          isRequired: true,
          icon: Icons.school_outlined,
          items: const ['American', 'British', 'Custom'],
          onChanged: (value) {
            setState(() {
              final oldType = _selectedEducationType;
              _selectedEducationType = value!;
              if (oldType != value) {
                _syncGradesFromControllers();
                final oldPredefined = oldType == 'Custom'
                    ? const <String>[]
                    : (_gradesByEducationType[oldType] ?? const <String>[]);
                _selectedGrades = _selectedGrades
                    .where((g) => !oldPredefined.contains(g))
                    .toList();
                _initGradeControllers();
              }
            });
          },
        ),
        const SizedBox(height: 4),
        Text(
          'Select an education type or enter a custom name here and press enter',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 24),
        if (_selectedEducationType != 'Custom') ...[
          _buildPredefinedGradeDropdown(),
          const SizedBox(height: 16),
        ],
        _buildCustomGradeTable(),
      ],
    );
  }

  Widget _buildPredefinedGradeDropdown() {
    _syncGradesFromControllers();
    final available =
        _allGrades.where((g) => !_selectedGrades.contains(g)).toList();
    if (available.isEmpty) {
      return const SizedBox.shrink();
    }
    return DropdownButtonFormField<String>(
      key: ValueKey(
          'predefined_grade_${_selectedEducationType}_${_selectedGrades.length}'),
      value: null,
      hint: Row(
        children: [
          Icon(Icons.school_outlined, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            'Pick a $_selectedEducationType grade to add',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
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
          borderSide: const BorderSide(color: Color(0xFF1339FF)),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        filled: true,
        fillColor: Colors.white,
      ),
      items: available
          .map((g) => DropdownMenuItem(value: g, child: Text(g)))
          .toList(),
      onChanged: (value) {
        if (value == null) return;
        setState(() {
          _syncGradesFromControllers();
          if (_customGradeControllers.length == 1 &&
              _customGradeControllers.first.text.trim().isEmpty) {
            _customGradeControllers.first.text = value;
          } else {
            _customGradeControllers.add(TextEditingController(text: value));
          }
          _syncGradesFromControllers();
        });
      },
    );
  }

  Future<void> _showRenameGradeDialog({
    required String oldName,
    required ValueChanged<String> onLocalApplied,
  }) async {
    if (!_isEditMode) return;
    final branchId = homeController.branchToEdit.value!.id;

    final dialogKey = GlobalKey<FormState>();
    final newNameController = TextEditingController(text: oldName);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Obx(() {
          final isLoading = branchController.isRenamingGrade.value;
          return PopScope(
            canPop: !isLoading,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Text('Rename grade'),
              content: Form(
                key: dialogKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Old name: $oldName',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: newNameController,
                      autofocus: true,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        labelText: 'New name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        final trimmed = value?.trim() ?? '';
                        if (trimmed.isEmpty) {
                          return 'Name is required';
                        }
                        if (trimmed == oldName) {
                          return 'New name must differ from old name';
                        }
                        final duplicate = _selectedGrades.any((g) =>
                            g != oldName && g == trimmed);
                        if (duplicate) {
                          return 'A grade with this name already exists';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (!(dialogKey.currentState?.validate() ?? false)) {
                            return;
                          }
                          final newName = newNameController.text.trim();
                          final success = await branchController.renameGrade(
                            branchId: branchId,
                            oldName: oldName,
                            newName: newName,
                          );
                          if (success) {
                            onLocalApplied(newName);
                            if (dialogContext.mounted) {
                              Navigator.of(dialogContext).pop();
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1339FF),
                    foregroundColor: Colors.white,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text('Rename'),
                ),
              ],
            ),
          );
        });
      },
    );

    newNameController.dispose();
  }

  Widget _buildCustomGradeTable() {
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
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Column(
            children: [
              // Table header
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Grade name',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      child: Text(
                        'Actions',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              // Table rows
              ...List.generate(_customGradeControllers.length, (index) {
                return _buildCustomGradeRow(index);
              }),
            ],
          ),
        ),
        if (_customGradeControllers.isEmpty ||
            _customGradeControllers.every((c) => c.text.trim().isEmpty))
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Please add at least one grade',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red.shade700,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCustomGradeRow(int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Builder(
              builder: (context) {
                final text = _customGradeControllers[index].text;
                final isReadOnly = _selectedEducationType != 'Custom' &&
                    text.isNotEmpty &&
                    _allGrades.contains(text);
                return TextFormField(
                  controller: _customGradeControllers[index],
                  readOnly: isReadOnly,
                  decoration: InputDecoration(
                    hintText: 'Grade name goes here',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade400,
                    ),
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
                      borderSide: BorderSide(
                        color: isReadOnly
                            ? const Color(0xFFE5E7EB)
                            : const Color(0xFF1339FF),
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    filled: true,
                    fillColor:
                        isReadOnly ? const Color(0xFFF9FAFB) : Colors.white,
                  ),
                  onChanged: isReadOnly
                      ? null
                      : (value) {
                          _syncGradesFromControllers();
                        },
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _customGradeControllers[index].dispose();
                      _customGradeControllers.removeAt(index);
                      _syncGradesFromControllers();
                    });
                  },
                  icon: SvgPicture.asset(
                    'assets/svg/note-remove.svg',
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                        Color(0xFFEF4444), BlendMode.srcIn),
                  ),
                  tooltip: 'Delete',
                ),
                IconButton(
                  onPressed: () {
                    if (_isEditMode) {
                      final current =
                          _customGradeControllers[index].text.trim();
                      if (current.isEmpty) return;
                      _showRenameGradeDialog(
                        oldName: current,
                        onLocalApplied: (newName) {
                          setState(() {
                            _customGradeControllers[index].text = newName;
                            _syncGradesFromControllers();
                          });
                        },
                      );
                    } else {
                      FocusScope.of(context).requestFocus(FocusNode());
                      Future.delayed(const Duration(milliseconds: 50), () {
                        _customGradeControllers[index].selection =
                            TextSelection.fromPosition(
                          TextPosition(
                              offset:
                                  _customGradeControllers[index].text.length),
                        );
                      });
                    }
                  },
                  icon: SvgPicture.asset(
                    'assets/svg/edit-2.svg',
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                        Color(0xFF6B7280), BlendMode.srcIn),
                  ),
                  tooltip: _isEditMode ? 'Rename' : 'Edit',
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _customGradeControllers.insert(
                          index + 1, TextEditingController());
                    });
                  },
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  color: const Color(0xFF1339FF),
                  tooltip: 'Add below',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleSaveBranch() {
    if (_formKey.currentState!.validate()) {
      // For custom education type, sync grades from controllers
      if (_selectedEducationType == 'Custom') {
        _syncGradesFromControllers();
      }

      // Validate required fields
      if (_selectedGrades.isEmpty) {
        appSnackbar(
          'Error',
          'Please select at least one grade',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final streetText = _streetAddressController.text.trim();

      // Resolve governorate and city to API keys
      final governorateKey =
          locationService.getGovernorateKey(_selectedGovernorate ?? '') ??
              _selectedGovernorate ??
              '';
      final cityKey = locationService.getCityKey(_selectedCity ?? '') ??
          _selectedCity ??
          '';

      // Create request object
      final request = CreateBranchRequest(
        name: _branchNameController.text.trim(),
        accountType: _selectedAccountType,
        isHeadquarters: _isHeadquarters,
        educationType: _selectedEducationType,
        grades: _selectedGrades,
        address: BranchAddress(
          governorate: governorateKey,
          city: cityKey,
          street: streetText.isEmpty ? null : streetText,
        ),
        phone: null,
        website: null,
        logoBytes: _selectedImageBytes,
        logoFileName: _selectedImageName,
      );

      // Check if editing or creating
      if (homeController.isEditingBranch.value &&
          homeController.branchToEdit.value != null) {
        final branchId = homeController.branchToEdit.value!.id;
        branchController.updateBranch(branchId, request).then((success) {
          if (success) {
            homeController.exitBranchForm();
          }
        });
      } else {
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
              borderSide: const BorderSide(color: Color(0xFF1339FF)),
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
              borderSide: const BorderSide(color: Color(0xFF1339FF)),
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
