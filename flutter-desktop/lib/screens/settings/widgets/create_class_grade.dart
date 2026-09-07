import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/branch_management_controller.dart';
import 'package:flutter_getx_app/controllers/resources_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_getx_app/utils/app_snackbar.dart';

class CreateClassScreen extends StatefulWidget {
  final Map<String, dynamic>? classToEdit;

  const CreateClassScreen({Key? key, this.classToEdit}) : super(key: key);

  @override
  State<CreateClassScreen> createState() => _CreateClassScreenState();
}

class _ClassDraft {
  final TextEditingController nameController = TextEditingController();
  final List<String> grades = [];
  final Map<String, int?> capacities = {};

  void dispose() => nameController.dispose();
}

class _CreateClassScreenState extends State<CreateClassScreen> {
  // Branch selection (shared across the batch)
  String? selectedBranchId;
  List<String> availableGrades = [];

  // One row per class the user wants to create. Edit mode uses exactly one draft.
  final List<_ClassDraft> _drafts = [];

  // True while iterating createClass calls in the batch — keeps the dialog
  // locked across multiple POSTs (controller.isLoading flips per call).
  bool _isBatchSaving = false;

  // Capacity options for dropdown
  final List<int> capacityOptions = List.generate(15, (i) => (i + 1) * 10);

  final controller = Get.find<ResourcesController>();
  late BranchManagementController branchController;

  @override
  void initState() {
    super.initState();
    branchController = Get.find<BranchManagementController>();

    if (widget.classToEdit != null) {
      final draft = _ClassDraft();
      draft.nameController.text = widget.classToEdit!['name'] ?? '';
      selectedBranchId = widget.classToEdit!['branchId'];

      final grade = widget.classToEdit!['grade'];
      if (grade != null) {
        draft.grades.add(grade);
        draft.capacities[grade] =
            widget.classToEdit!['maximumCapacity'] as int? ?? 30;
      }
      _drafts.add(draft);

      if (selectedBranchId != null) {
        _loadGradesForBranch(selectedBranchId!);
      }
    } else {
      _drafts.add(_ClassDraft());
    }
  }

  void _loadGradesForBranch(String branchId) {
    final branch =
        branchController.branches.firstWhereOrNull((b) => b.id == branchId);
    if (branch != null && branch.grades != null) {
      setState(() {
        availableGrades = List.from(branch.grades!);
      });
    }
  }

  void _addDraft() {
    setState(() => _drafts.add(_ClassDraft()));
  }

  void _removeDraft(int index) {
    setState(() {
      _drafts.removeAt(index).dispose();
    });
  }

  bool _validateForm() {
    if (selectedBranchId == null) {
      appSnackbar('Error', 'Please select a branch',
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }
    if (_drafts.isEmpty) {
      appSnackbar('Error', 'Please add at least one class',
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }

    for (int i = 0; i < _drafts.length; i++) {
      final d = _drafts[i];
      final label = _drafts.length == 1 ? 'Class' : 'Class ${i + 1}';
      if (d.nameController.text.trim().isEmpty) {
        appSnackbar('Error', '$label needs a name',
            backgroundColor: Colors.red, colorText: Colors.white);
        return false;
      }
      if (d.grades.isEmpty) {
        appSnackbar('Error', '$label needs at least one grade',
            backgroundColor: Colors.red, colorText: Colors.white);
        return false;
      }
      for (final g in d.grades) {
        if (d.capacities[g] == null) {
          appSnackbar('Error', '$label is missing a capacity for $g',
              backgroundColor: Colors.red, colorText: Colors.white);
          return false;
        }
      }
    }

    // Intra-batch duplicate name check.
    final seen = <String, int>{};
    for (int i = 0; i < _drafts.length; i++) {
      final n = _drafts[i].nameController.text.trim().toLowerCase();
      final prev = seen[n];
      if (prev != null) {
        appSnackbar(
          'Error',
          'Class ${prev + 1} and Class ${i + 1} have the same name',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
      seen[n] = i;
    }

    return true;
  }

  Future<void> _saveClass() async {
    if (!_validateForm()) return;

    setState(() => _isBatchSaving = true);
    try {
      final branchId = selectedBranchId!;

      // Reuse cached list when we're already looking at this branch.
      final List<Map<String, dynamic>> existing;
      if (controller.selectedBranchId.value == branchId &&
          controller.classes.isNotEmpty) {
        existing = controller.classes;
      } else {
        existing = await controller.fetchClassesForBranch(branchId);
      }

      final editingId = widget.classToEdit?['id'];
      bool isDuplicate(String name, String grade) {
        final n = name.trim().toLowerCase();
        return existing.any((c) =>
            (c['name']?.toString().trim().toLowerCase() ?? '') == n &&
            (c['grade']?.toString() ?? '') == grade &&
            c['id'] != editingId);
      }

      // Collect duplicates against existing classes before issuing any POST.
      final conflicts = <String>[];
      for (final d in _drafts) {
        final n = d.nameController.text.trim();
        for (final g in d.grades) {
          if (isDuplicate(n, g)) conflicts.add('$n ($g)');
        }
      }
      if (conflicts.isNotEmpty) {
        appSnackbar(
          'Error',
          'Already exist in this branch: ${conflicts.join(', ')}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Edit mode keeps its single-PUT path.
      if (widget.classToEdit != null) {
        final d = _drafts.single;
        final classData = {
          'name': d.nameController.text.trim(),
          'grade': d.grades.first,
          'classType': widget.classToEdit!['classType'] ?? 'Offline',
          'maximumCapacity': d.capacities[d.grades.first] ?? 30,
          'status': widget.classToEdit!['status'] ?? 'active',
        };
        final ok = await controller.updateClass(
            widget.classToEdit!['id'], classData);
        if (ok && mounted) Navigator.pop(context);
        return;
      }

      // Create mode: one POST per (draft × grade).
      int successCount = 0;
      final failures = <String>[];
      final completed = <int>{};

      for (int i = 0; i < _drafts.length; i++) {
        final d = _drafts[i];
        final name = d.nameController.text.trim();
        bool draftOk = true;
        for (final grade in List<String>.from(d.grades)) {
          final body = {
            'branchId': branchId,
            'classType': 'Offline',
            'name': name,
            'grades': [
              {'grade': grade, 'maximumCapacity': d.capacities[grade] ?? 30}
            ],
          };
          final ok = await controller.createClass(body);
          if (ok) {
            successCount++;
          } else {
            draftOk = false;
            failures.add('$name ($grade)');
          }
        }
        if (draftOk) completed.add(i);
      }

      // Drop drafts that succeeded entirely, keep failed ones for retry.
      if (mounted) {
        setState(() {
          final indices = completed.toList()..sort((a, b) => b - a);
          for (final i in indices) {
            _drafts.removeAt(i).dispose();
          }
          if (_drafts.isEmpty) _drafts.add(_ClassDraft());
        });
      }

      if (failures.isEmpty) {
        appSnackbar(
          'Success',
          '$successCount class${successCount == 1 ? '' : 'es'} created',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        if (mounted) Navigator.pop(context);
      } else {
        appSnackbar(
          'Partial success',
          '$successCount created, ${failures.length} failed: ${failures.join(', ')}',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } finally {
      if (mounted) setState(() => _isBatchSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.classToEdit != null;

    return Obx(() {
      final isSaving = controller.isLoading.value || _isBatchSaving;
      return PopScope(
        canPop: !isSaving,
        child: Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
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
                                : 'Add one or more classes for this branch',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed:
                            isSaving ? null : () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close,
                          color:
                              isSaving ? Colors.grey.shade300 : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Branch
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

                  // Drafts
                  for (int i = 0; i < _drafts.length; i++) ...[
                    _buildDraftSection(i, _drafts[i], isEditing, isSaving),
                    const SizedBox(height: 24),
                  ],

                  if (!isEditing)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: isSaving ? null : _addDraft,
                        icon: const Icon(Icons.add),
                        label: const Text('Add another class'),
                      ),
                    ),
                  const SizedBox(height: 8),

                  // Actions
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
                          onPressed:
                              isSaving ? null : () => Navigator.pop(context),
                          child: const Text(
                            'Back',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isSaving ? null : _saveClass,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: const Color(0xFF1339FF),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 14),
                          ),
                          child: isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildDraftSection(
      int index, _ClassDraft draft, bool isEditing, bool isSaving) {
    final canRemove = !isEditing && !isSaving && _drafts.length > 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isEditing)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Class ${index + 1}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  tooltip: 'Remove this class',
                  onPressed: canRemove ? () => _removeDraft(index) : null,
                  icon: Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: canRemove ? Colors.red : Colors.grey.shade300,
                  ),
                ),
              ],
            ),
          if (!isEditing) const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildGradeSelector(draft)),
              const SizedBox(width: 16),
              Expanded(child: _buildClassNameField(draft)),
            ],
          ),
          if (draft.grades.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Class maximum capacity',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _buildCapacitySection(draft),
          ],
        ],
      ),
    );
  }

  Widget _buildBranchDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text('Branch name', style: TextStyle(fontWeight: FontWeight.w500)),
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
              prefixIcon:
                  Icon(Icons.search, size: 20, color: Colors.grey.shade400),
              border: const OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF1339FF)),
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
            onChanged: _isBatchSaving
                ? null
                : (value) {
                    setState(() {
                      selectedBranchId = value;
                      for (final d in _drafts) {
                        d.grades.clear();
                        d.capacities.clear();
                      }
                      if (value != null) {
                        _loadGradesForBranch(value);
                      } else {
                        availableGrades = [];
                      }
                    });
                  },
          );
        }),
      ],
    );
  }

  Widget _buildGradeSelector(_ClassDraft draft) {
    final unselectedGrades =
        availableGrades.where((g) => !draft.grades.contains(g)).toList();

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
          key: ValueKey('grade_selector_${draft.hashCode}_${draft.grades.length}'),
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
              borderSide: BorderSide(color: Color(0xFF1339FF)),
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
          onChanged: selectedBranchId == null || _isBatchSaving
              ? null
              : (value) {
                  if (value != null) {
                    setState(() {
                      draft.grades.add(value);
                      draft.capacities[value] = null;
                    });
                  }
                },
        ),
        if (draft.grades.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: draft.grades.map((grade) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1339FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: const Color(0xFF1339FF).withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      grade,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF1339FF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: _isBatchSaving
                          ? null
                          : () {
                              setState(() {
                                draft.grades.remove(grade);
                                draft.capacities.remove(grade);
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

  Widget _buildClassNameField(_ClassDraft draft) {
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
          controller: draft.nameController,
          enabled: !_isBatchSaving,
          decoration: InputDecoration(
            hintText: 'e.g., Grade A',
            border: const OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF1339FF)),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildCapacitySection(_ClassDraft draft) {
    final grades = draft.grades;
    final List<Widget> rows = [];

    for (int i = 0; i < grades.length; i += 2) {
      final first = grades[i];
      final second = (i + 1 < grades.length) ? grades[i + 1] : null;

      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Expanded(child: _buildCapacityItem(draft, first)),
              const SizedBox(width: 16),
              if (second != null)
                Expanded(child: _buildCapacityItem(draft, second))
              else
                const Expanded(child: SizedBox()),
            ],
          ),
        ),
      );
    }

    return Column(children: rows);
  }

  Widget _buildCapacityItem(_ClassDraft draft, String grade) {
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
            value: draft.capacities[grade],
            decoration: InputDecoration(
              hintText: 'Maximum capacity',
              border: const OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF1339FF)),
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
            onChanged: _isBatchSaving
                ? null
                : (value) {
                    setState(() {
                      draft.capacities[grade] = value;
                    });
                  },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    for (final d in _drafts) {
      d.dispose();
    }
    super.dispose();
  }
}
