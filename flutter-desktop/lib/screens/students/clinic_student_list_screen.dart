import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/student_controller.dart';
import 'package:flutter_getx_app/screens/students/widgets/add_student_dialog.dart';
import 'package:flutter_getx_app/screens/students/widgets/student_data_table.dart';
import 'package:flutter_getx_app/shared/widgets/breadcrumb_widget.dart';
import 'package:get/get.dart';

class ClinicStudentListScreen extends StatelessWidget {
  const ClinicStudentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StudentController());

    return Container(
      color: const Color(0xFFFBFCFD),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Students List',
                        style: TextStyle(
                          color: Color(0xFF2D2E2E),
                          fontSize: 20,
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.w700,
                          height: 1.40,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _BranchDropdown(controller: controller),
                    ],
                  ),
                  const BreadcrumbWidget(
                    items: [
                      BreadcrumbItem(label: 'Ayamedica portal'),
                      BreadcrumbItem(label: 'Students'),
                      BreadcrumbItem(label: 'Students List'),
                    ],
                  ),
                ],
              ),
              _AddStudentButton(),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(child: StudentDataTable(fromClinic: true)),
        ],
      ),
    );
  }
}

class _BranchDropdown extends StatelessWidget {
  final StudentController controller;
  const _BranchDropdown({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (ctx) {
      return Obx(() {
        final count = controller.accessibleBranches.length;
        final label = count > 1 ? '$count branches' : controller.selectedBranchName;
        return InkWell(
          onTap: () => _showBranchMenu(ctx),
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1339FF),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_drop_down,
                    color: Color(0xFF1339FF), size: 22),
              ],
            ),
          ),
        );
      });
    });
  }

  void _showBranchMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      items: controller.accessibleBranches.map((b) {
        final isSelected = b.id == controller.selectedBranchId.value;
        return PopupMenuItem<String>(
          value: b.id,
          child: Row(
            children: [
              if (isSelected)
                const Icon(Icons.check, size: 16, color: Color(0xFF1339FF))
              else
                const SizedBox(width: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  b.name,
                  style: TextStyle(
                    fontSize: 14,
                    color: isSelected
                        ? const Color(0xFF1339FF)
                        : const Color(0xFF374151),
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    ).then((id) {
      if (id != null) controller.changeBranch(id);
    });
  }
}

class _AddStudentButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showDialog(
        context: Get.context!,
        builder: (_) => AddStudentDialog(),
      ),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: const Color(0xFF1339FF),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_circle_outline,
                color: Color(0xFFFFFFFF), size: 18),
            SizedBox(width: 8),
            Text(
              'Add student(s)',
              style: TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 13,
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 4),
            Icon(Icons.arrow_drop_down,
                color: Color(0xFFFFFFFF), size: 18),
          ],
        ),
      ),
    );
  }
}
