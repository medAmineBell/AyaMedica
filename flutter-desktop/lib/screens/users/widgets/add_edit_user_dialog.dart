import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/branch_management_controller.dart';
import '../../../controllers/home_controller.dart';
import '../../../controllers/users_controller.dart';
import '../../../models/user_model.dart';

class AddEditUserDialog extends StatefulWidget {
  final UserModel? user;

  const AddEditUserDialog({Key? key, this.user}) : super(key: key);

  @override
  State<AddEditUserDialog> createState() => _AddEditUserDialogState();
}

class _AddEditUserDialogState extends State<AddEditUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _givenNameController = TextEditingController();
  final _familyNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedRole;
  List<String> _selectedRoles = [];
  final List<String> _selectedBranchIds = [];
  bool _isLoading = false;

  late final BranchManagementController _branchController;
  Worker? _branchWorker;

  bool get isEditMode => widget.user != null;
  bool get _canEditRoles => !Get.find<HomeController>().isRestrictedRole;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      _givenNameController.text = widget.user!.givenName;
      _familyNameController.text = widget.user!.familyName;
      _emailController.text = widget.user!.email;
      _phoneController.text = widget.user!.phone ?? '';
      _selectedRoles = widget.user!.roles.map((r) => r.role).toSet().toList();
    }

    _branchController = Get.find<BranchManagementController>();
    if (!isEditMode) {
      if (_branchController.branches.isEmpty) {
        _branchController.fetchBranches();
      }
      _maybeAutoSelectSingleBranch();
      _branchWorker = ever(
        _branchController.branches,
        (_) => _maybeAutoSelectSingleBranch(),
      );
    }
  }

  @override
  void dispose() {
    _branchWorker?.dispose();
    _givenNameController.dispose();
    _familyNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _maybeAutoSelectSingleBranch() {
    if (!mounted) return;
    if (_selectedBranchIds.isNotEmpty) return;
    final active = _branchController.branches
        .where((b) => b.status == 'active')
        .toList();
    if (active.length == 1) {
      setState(() => _selectedBranchIds.add(active.first.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildFormFields(),
                  const SizedBox(height: 24),
                  _buildActions(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF1339FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.person_add,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditMode ? 'Edit User' : 'Add New User',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2E2E),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isEditMode
                    ? 'Update user information'
                    : 'Create a new staff user',
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF595A5B).withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close, color: Color(0xFF595A5B)),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    final controller = Get.find<UsersController>();

    if (!isEditMode) {
      // Add-mode: assign an EXISTING user to one or more branches with a role.
      // Backend only needs email + role + branchIds.
      return Column(
        children: [
          _buildTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'Enter email of an existing user',
            icon: Icons.email,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email is required';
              }
              if (!GetUtils.isEmail(value.trim())) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            label: 'Role',
            icon: Icons.work,
            value: _selectedRole,
            items: controller.staffRoles
                .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                .toList(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Role is required';
              }
              return null;
            },
            onChanged: (value) {
              setState(() {
                _selectedRole = value;
              });
            },
          ),
          const SizedBox(height: 16),
          _buildBranchesSelector(),
        ],
      );
    }

    // Edit-mode: keep the existing full-profile form.
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _givenNameController,
                label: 'First Name',
                hint: 'Enter first name',
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'First name is required';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _familyNameController,
                label: 'Last Name',
                hint: 'Enter last name',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Last name is required';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emailController,
          label: 'Email',
          hint: 'Enter email address',
          icon: Icons.email,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Email is required';
            }
            if (!GetUtils.isEmail(value.trim())) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _phoneController,
          label: 'Phone',
          hint: 'Enter phone number (optional)',
          icon: Icons.phone,
        ),
        if (_canEditRoles) ...[
          const SizedBox(height: 16),
          _buildRolesSelector(controller),
        ],
      ],
    );
  }

  Widget _buildBranchesSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Branches',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2D2E2E),
          ),
        ),
        const SizedBox(height: 8),
        Obx(() {
          final activeBranches = _branchController.branches
              .where((b) => b.status == 'active')
              .toList();
          final isLoading = _branchController.isLoading.value;

          if (activeBranches.isEmpty && isLoading) {
            return _buildBranchesStatusBox(
              child: const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF1339FF)),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Loading branches…',
                    style: TextStyle(color: Color(0xFF595A5B)),
                  ),
                ],
              ),
            );
          }

          if (activeBranches.isEmpty) {
            return _buildBranchesStatusBox(
              child: const Text(
                'No active branches available',
                style: TextStyle(color: Color(0xFF595A5B)),
              ),
            );
          }

          final available = activeBranches
              .where((b) => !_selectedBranchIds.contains(b.id))
              .toList();

          String branchNameById(String id) {
            final match = activeBranches.firstWhereOrNull((b) => b.id == id);
            return match?.name ?? id;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                key: ValueKey('branch_picker_${_selectedBranchIds.length}'),
                value: null,
                isExpanded: true,
                hint: Text(
                  available.isEmpty
                      ? 'All branches added'
                      : 'Select a branch to add',
                  style: const TextStyle(color: Color(0xFF9CA3AF)),
                ),
                decoration: InputDecoration(
                  prefixIcon:
                      const Icon(Icons.apartment, color: Color(0xFF9CA3AF)),
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
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: available
                    .map((b) => DropdownMenuItem(
                          value: b.id,
                          child: Text(b.name),
                        ))
                    .toList(),
                onChanged: available.isEmpty
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() => _selectedBranchIds.add(value));
                        }
                      },
              ),
              if (_selectedBranchIds.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Select at least one branch',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red.shade700,
                    ),
                  ),
                )
              else ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedBranchIds.map((id) {
                    return Container(
                      padding: const EdgeInsets.only(
                          left: 12, right: 4, top: 6, bottom: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1339FF).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              const Color(0xFF1339FF).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            branchNameById(id),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF1339FF),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () {
                              setState(() => _selectedBranchIds.remove(id));
                            },
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEF4444),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close,
                                  size: 12, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          );
        }),
      ],
    );
  }

  Widget _buildBranchesStatusBox({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }

  Widget _buildRolesSelector(UsersController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Roles',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2D2E2E),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: controller.staffRoles.map((role) {
            final isSelected = _selectedRoles.contains(role);
            return FilterChip(
              label: Text(role),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedRoles.add(role);
                  } else {
                    _selectedRoles.remove(role);
                  }
                });
              },
              selectedColor: const Color(0xFF1339FF).withValues(alpha: 0.15),
              checkmarkColor: const Color(0xFF1339FF),
              labelStyle: TextStyle(
                color: isSelected
                    ? const Color(0xFF1339FF)
                    : const Color(0xFF595A5B),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFF1339FF)
                      : const Color(0xFFE5E7EB),
                ),
              ),
              backgroundColor: Colors.white,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2D2E2E),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF9CA3AF)),
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
              borderSide: const BorderSide(color: Color(0xFFDC2626)),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2D2E2E),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF9CA3AF)),
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
            filled: true,
            fillColor: Colors.white,
          ),
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF595A5B),
              side: const BorderSide(color: Color(0xFFE5E7EB)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1339FF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(isEditMode ? 'Update User' : 'Assign User'),
          ),
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    // Add-mode requires at least one branch (not part of form validators).
    if (!isEditMode && _selectedBranchIds.isEmpty) {
      setState(() {}); // refresh inline "select at least one branch" hint
      return;
    }

    setState(() => _isLoading = true);

    try {
      final controller = Get.find<UsersController>();
      bool success;

      if (isEditMode) {
        success = await controller.updateUser(
          widget.user!.id,
          givenName: _givenNameController.text.trim(),
          familyName: _familyNameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          roles: _canEditRoles && _selectedRoles.isNotEmpty
              ? _selectedRoles
              : null,
        );
      } else {
        success = await controller.assignUserRole(
          email: _emailController.text.trim(),
          role: _selectedRole!,
          branchIds: List<String>.from(_selectedBranchIds),
        );
      }

      if (success && mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
