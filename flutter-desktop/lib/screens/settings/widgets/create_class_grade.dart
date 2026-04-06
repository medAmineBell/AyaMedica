import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/branch_management_controller.dart';
import 'package:flutter_getx_app/controllers/resources_controller.dart';
import 'package:get/get.dart';

class CreateClassScreen extends StatefulWidget {
  final Map<String, dynamic>? classToEdit;

  const CreateClassScreen({Key? key, this.classToEdit}) : super(key: key);

  @override
  State<CreateClassScreen> createState() => _CreateClassScreenState();
}

class _CreateClassScreenState extends State<CreateClassScreen> {
  final TextEditingController classNameController = TextEditingController();

  // Branch selection
  String? selectedBranchId;
  List<String> availableGrades = [];

  // Multi-grade selection
  List<String> selectedGrades = [];

  // Per-grade max capacity
  Map<String, int?> gradeCapacities = {};

  // Capacity options for dropdown
  final List<int> capacityOptions = List.generate(15, (i) => (i + 1) * 10);

  final controller = Get.find<ResourcesController>();
  late BranchManagementController branchController;

  @override
  void initState() {
    super.initState();
    branchController = Get.find<BranchManagementController>();

    // If editing, populate fields
    if (widget.classToEdit != null) {
      classNameController.text = widget.classToEdit!['name'] ?? '';
      selectedBranchId = widget.classToEdit!['branchId'];

      // For edit mode, single grade from existing class
      final grade = widget.classToEdit!['grade'];
      if (grade != null) {
        selectedGrades = [grade];
        gradeCapacities[grade] =
            widget.classToEdit!['maximumCapacity'] as int? ?? 30;
      }

      // Load grades from the branch
      if (selectedBranchId != null) {
        _loadGradesForBranch(selectedBranchId!);
      }
    }
  }

  void _loadGradesForBranch(String branchId) {
    final branch = branchController.branches
        .firstWhereOrNull((b) => b.id == branchId);
    if (branch != null && branch.grades != null) {
      setState(() {
        availableGrades = List.from(branch.grades!);
      });
    }
  }

  bool _validateForm() {
    if (selectedBranchId == null) {
      Get.snackbar('Error', 'Please select a branch',
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }

    if (selectedGrades.isEmpty) {
      Get.snackbar('Error', 'Please select at least one grade',
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }

    if (classNameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter a class name',
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }

    return true;
  }

  Future<void> _saveClass() async {
    if (!_validateForm()) return;

    bool success;
    if (widget.classToEdit != null) {
      // Update existing class (single grade)
      final classData = {
        'name': classNameController.text.trim(),
        'grade': selectedGrades.first,
        'classType': widget.classToEdit!['classType'] ?? 'Offline',
        'maximumCapacity': gradeCapacities[selectedGrades.first] ?? 30,
        'status': widget.classToEdit!['status'] ?? 'active',
      };
      success =
          await controller.updateClass(widget.classToEdit!['id'], classData);
    } else {
      // Create new class (multi-grade)
      final classData = {
        'branchId': selectedBranchId,
        'grades': selectedGrades
            .map((g) => {
                  'grade': g,
                  'maximumCapacity': gradeCapacities[g] ?? 30,
                })
            .toList(),
        'name': classNameController.text.trim(),
        'classType': 'Offline',
      };
      success = await controller.createClass(classData);
    }

    if (success) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.classToEdit != null;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEditing ? 'Edit class' : 'Add new class',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isEditing
                            ? 'Update the class details'
                            : 'Add the new class and grades details',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Branch section
              const Text(
                'Branch',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              _buildBranchDropdown(),
              const SizedBox(height: 24),

              // Select grades and name the class
              const Text(
                'Select grades and name the class',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildGradeSelector()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildClassNameField()),
                ],
              ),
              const SizedBox(height: 24),

              // Class maximum capacity (per grade)
              if (selectedGrades.isNotEmpty) ...[
                const Text(
                  'Class maximum capacity',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                _buildCapacitySection(),
                const SizedBox(height: 24),
              ],

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 14),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Back',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Obx(() => ElevatedButton(
                          onPressed:
                              controller.isLoading.value ? null : _saveClass,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: const Color(0xFF1339FF),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 14),
                          ),
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Save'),
                        )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBranchDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text('Branch name',
                style: TextStyle(fontWeight: FontWeight.w500)),
            Text('*', style: TextStyle(color: Colors.red)),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() {
          final branches = branchController.branches
              .where((b) => b.status == 'active' || b.status == null)
              .toList();

          return DropdownButtonFormField<String>(
            value: selectedBranchId,
            decoration: InputDecoration(
              hintText: 'Branch name',
              prefixIcon: Icon(Icons.search,
                  size: 20, color: Colors.grey.shade400),
              border: const OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF3B82F6)),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
            items: branches.map((branch) {
              return DropdownMenuItem(
                value: branch.id,
                child: Text(branch.name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedBranchId = value;
                selectedGrades.clear();
                gradeCapacities.clear();
                if (value != null) {
                  _loadGradesForBranch(value);
                }
              });
            },
          );
        }),
      ],
    );
  }

  Widget _buildGradeSelector() {
    final unselectedGrades =
        availableGrades.where((g) => !selectedGrades.contains(g)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text('Grade(s)', style: TextStyle(fontWeight: FontWeight.w500)),
            Text('*', style: TextStyle(color: Colors.red)),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          key: ValueKey('grade_selector_${selectedGrades.length}'),
          value: null,
          decoration: InputDecoration(
            hintText: 'search',
            prefixIcon:
                Icon(Icons.search, size: 20, color: Colors.grey.shade400),
            border: const OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF3B82F6)),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
          items: unselectedGrades.map((grade) {
            return DropdownMenuItem(
              value: grade,
              child: Text(grade),
            );
          }).toList(),
          onChanged: selectedBranchId == null
              ? null
              : (value) {
                  if (value != null) {
                    setState(() {
                      selectedGrades.add(value);
                      gradeCapacities[value] = null;
                    });
                  }
                },
        ),
        if (selectedGrades.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selectedGrades.map((grade) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: const Color(0xFF3B82F6).withOpacity(0.3)),
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
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedGrades.remove(grade);
                          gradeCapacities.remove(grade);
                        });
                      },
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            size: 10, color: Colors.white),
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
  }

  Widget _buildClassNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text('Class name', style: TextStyle(fontWeight: FontWeight.w500)),
            Text('*', style: TextStyle(color: Colors.red)),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: classNameController,
          decoration: InputDecoration(
            hintText: 'search',
            border: const OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF3B82F6)),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildCapacitySection() {
    final grades = selectedGrades;
    final List<Widget> rows = [];

    for (int i = 0; i < grades.length; i += 2) {
      final first = grades[i];
      final second = (i + 1 < grades.length) ? grades[i + 1] : null;

      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Expanded(child: _buildCapacityItem(first)),
              const SizedBox(width: 16),
              if (second != null)
                Expanded(child: _buildCapacityItem(second))
              else
                const Expanded(child: SizedBox()),
            ],
          ),
        ),
      );
    }

    return Column(children: rows);
  }

  Widget _buildCapacityItem(String grade) {
    return Row(
      children: [
        Text(
          '$grade -',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<int>(
            value: gradeCapacities[grade],
            decoration: InputDecoration(
              hintText: 'Maximum capacity',
              border: const OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF3B82F6)),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
            items: capacityOptions.map((cap) {
              return DropdownMenuItem(
                value: cap,
                child: Text('$cap'),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                gradeCapacities[grade] = value;
              });
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    classNameController.dispose();
    super.dispose();
  }
}
