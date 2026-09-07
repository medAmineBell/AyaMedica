import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/student_controller.dart';
import 'student_filters_dropdown.dart';

class StudentTableHeader extends StatelessWidget {
  final StudentController controller;
  final VoidCallback onAddStudent;

  const StudentTableHeader({
    Key? key,
    required this.controller,
    required this.onAddStudent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.3,
            child: _buildSearchField(),
          ),
          const SizedBox(width: 16),
          _buildStudentsCountBadge(),
          const Spacer(),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: controller.searchTextController,
      onChanged: controller.searchStudents,
      decoration: InputDecoration(
        hintText: 'search',
        hintStyle: TextStyle(color: Colors.grey.shade500),
        prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
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
          borderSide: BorderSide(color: Colors.blue.shade400),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ExportButton(controller: controller),
        const SizedBox(width: 8),
        _FiltersButton(controller: controller),
      ],
    );
  }

  Widget _buildStudentsCountBadge() {
    return Obx(() {
      final count = controller.totalStudents.value;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.school_outlined,
              size: 16,
              color: Color(0xFF1339FF),
            ),
            const SizedBox(width: 6),
            Text(
              '$count Students',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _FiltersButton extends StatelessWidget {
  final StudentController controller;

  const _FiltersButton({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final filterCount = controller.activeFilterCount;
      return InkWell(
        onTap: () => _showFiltersDropdown(context),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.tune, size: 20, color: Colors.grey.shade700),
              const SizedBox(width: 8),
              Text(
                'Filters',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (filterCount > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      filterCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  void _showFiltersDropdown(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset position = button.localToGlobal(Offset.zero, ancestor: overlay);

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => StudentFiltersDropdown(
        controller: controller,
        position: Offset(position.dx + button.size.width - 300, position.dy + button.size.height + 4),
      ),
    );
  }
}

class _ExportButton extends StatelessWidget {
  final StudentController controller;

  const _ExportButton({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final busy = controller.isExporting.value;
      return InkWell(
        onTap: busy ? null : controller.exportStudents,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (busy)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(Icons.file_download_outlined,
                    size: 20, color: Colors.grey.shade700),
              const SizedBox(width: 8),
              Text(
                busy ? 'Exporting…' : 'Export',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
