import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/student_controller.dart';

class StudentFiltersDropdown extends StatefulWidget {
  final StudentController controller;
  final Offset position;

  const StudentFiltersDropdown({
    Key? key,
    required this.controller,
    required this.position,
  }) : super(key: key);

  @override
  State<StudentFiltersDropdown> createState() => _StudentFiltersDropdownState();
}

class _StudentFiltersDropdownState extends State<StudentFiltersDropdown> {
  bool _isGradesExpanded = true;
  bool _isClassesExpanded = true;
  final TextEditingController _classSearchController = TextEditingController();
  String _classSearchQuery = '';

  @override
  void dispose() {
    _classSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Dismiss on tap outside
        Positioned.fill(
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            behavior: HitTestBehavior.opaque,
            child: const SizedBox.expand(),
          ),
        ),
        Positioned(
          left: widget.position.dx,
          top: widget.position.dy,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            shadowColor: Colors.black.withOpacity(0.15),
            child: Container(
              width: 300,
              constraints: const BoxConstraints(maxHeight: 500),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildGradesSection(),
                          _buildClassesSection(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Filters',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Obx(() {
            final count = widget.controller.activeFilterCount;
            if (count == 0) return const SizedBox.shrink();
            return GestureDetector(
              onTap: () {
                widget.controller.clearFilters();
              },
              child: const Text(
                'Clear filters',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1339FF),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGradesSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () => setState(() => _isGradesExpanded = !_isGradesExpanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Grades',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(
                  _isGradesExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 20,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ),
        if (_isGradesExpanded)
          Obx(() => Column(
                mainAxisSize: MainAxisSize.min,
                children: StudentController.allGrades.map((grade) {
                  final isSelected =
                      widget.controller.selectedGrades.contains(grade);
                  return _buildCheckboxItem(
                    label: grade,
                    isSelected: isSelected,
                    onTap: () => widget.controller.toggleGrade(grade),
                  );
                }).toList(),
              )),
      ],
    );
  }

  Widget _buildClassesSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () => setState(() => _isClassesExpanded = !_isClassesExpanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Classes',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(
                  _isClassesExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 20,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ),
        if (_isClassesExpanded) ...[
          // Search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              controller: _classSearchController,
              onChanged: (value) => setState(() => _classSearchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                suffixIcon:
                    Icon(Icons.search, color: Colors.grey.shade400, size: 18),
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
                  borderSide: const BorderSide(color: Color(0xFF1339FF)),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                isDense: true,
              ),
              style: const TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(height: 4),
          Obx(() {
            final classes = widget.controller.availableClasses
                .where((c) =>
                    _classSearchQuery.isEmpty ||
                    c.toLowerCase().contains(_classSearchQuery.toLowerCase()))
                .toList();

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: classes.map((className) {
                final isSelected =
                    widget.controller.selectedClasses.contains(className);
                return _buildCheckboxItem(
                  label: className,
                  isSelected: isSelected,
                  onTap: () => widget.controller.toggleClass(className),
                );
              }).toList(),
            );
          }),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildCheckboxItem({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1339FF) : Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF1339FF)
                      : Colors.grey.shade400,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
