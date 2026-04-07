import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/branch_management_controller.dart';
import 'package:flutter_getx_app/screens/medicalRecords/widgets/tables/student_medical_detail_table.dart';
import 'package:flutter_getx_app/screens/medicalRecords/widgets/tables/student_medical_table.dart';
import 'package:get/get.dart';
import '../../controllers/medical_records_controller.dart';
import '../../models/medical_student.dart';

class MedicalRecordsScreen extends StatelessWidget {
  const MedicalRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MedicalRecordsController());
    final branchController = Get.find<BranchManagementController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title section with branch info
          _buildTitleSection(controller, branchController),

          // Search & actions header
          _buildSearchHeader(controller),

          // Table content
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
              child: Obx(() {
                final MedicalStudent? student =
                    controller.selectedStudent.value;

                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: student == null
                      ? _buildStudentsList(controller)
                      : _buildStudentDetails(controller, student),
                );
              }),
            ),
          ),

          // Pagination
          Obx(() => controller.totalPages.value > 1
              ? _buildPagination(controller)
              : const SizedBox()),
        ],
      ),
    );
  }

  Widget _buildTitleSection(MedicalRecordsController controller,
      BranchManagementController branchController) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with branch count and dropdown
          Obx(() {
            final count = branchController.branches.length;
            return Row(
              children: [
                const Text(
                  'Medical records,',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(width: 6),
                InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$count ${count != 1 ? 'branches' : 'branch'}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 24,
                        color: Colors.blue.shade600,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 12),
          // Branch chips
          Obx(() => Wrap(
                spacing: 8,
                children: branchController.branches
                    .map((branch) => _buildBranchChip(branch.name))
                    .toList(),
              )),
        ],
      ),
    );
  }

  Widget _buildBranchChip(String branchName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            branchName,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1E40AF),
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: () {},
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                color: Color(0xFFDC6B30),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader(MedicalRecordsController controller) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          // Search field
          SizedBox(
            width: 400,
            child: TextField(
              onChanged: controller.searchRecords,
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
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          const Spacer(),
          // Export button
          InkWell(
            onTap: controller.exportRecords,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Center(
                child: Icon(Icons.download_outlined,
                    size: 20, color: Colors.grey.shade700),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Filters button
          InkWell(
            onTap: () {},
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsList(MedicalRecordsController controller) {
    return Obx(() {
      if (controller.state.value == MedicalRecordsState.loading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.state.value == MedicalRecordsState.error) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
              const SizedBox(height: 16),
              const Text(
                'Failed to load medical records',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: controller.refreshRecords,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        );
      }

      if (controller.state.value == MedicalRecordsState.empty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.folder_open, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text(
                'No students found',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text(
                'Try adjusting your search or filters',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        );
      }

      return StudentMedicalTable(
        onRowTap: (MedicalStudent s) => controller.selectStudentWithDetails(s),
      );
    });
  }

  Widget _buildStudentDetails(
      MedicalRecordsController controller, MedicalStudent student) {
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: controller.clearStudentDetails,
                icon: const Icon(Icons.arrow_back_ios_new, size: 16),
              ),
              const SizedBox(width: 8),
              Obx(() {
                final studentDetails = controller.selectedStudentDetails.value;
                return Text(
                  'Medical Records - ${studentDetails?.fullName ?? student.fullName}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }),
              const Spacer(),
              Obx(() {
                final recordsCount = controller.studentRecords.length;
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: recordsCount > 0
                        ? Colors.green.shade100
                        : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$recordsCount Records',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: recordsCount > 0
                          ? Colors.green.shade800
                          : Colors.orange.shade800,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        Expanded(
          child: StudentMedicalDetailTable(),
        ),
      ],
    );
  }

  Widget _buildPagination(MedicalRecordsController controller) {
    return Obx(() {
      final currentPage = controller.currentPage.value;
      final totalPages = controller.totalPages.value;

      if (totalPages <= 1) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavButton(
              icon: Icons.arrow_back,
              label: 'Previous',
              isLeading: true,
              enabled: currentPage > 1,
              onTap: controller.previousPage,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: _buildPageNumbers(currentPage, totalPages, controller),
            ),
            _buildNavButton(
              icon: Icons.arrow_forward,
              label: 'Next',
              isLeading: false,
              enabled: currentPage < totalPages,
              onTap: controller.nextPage,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required bool isLeading,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    final color = enabled ? Colors.grey.shade800 : Colors.grey.shade400;

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLeading) ...[
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
            if (!isLeading) ...[
              const SizedBox(width: 8),
              Icon(icon, size: 16, color: color),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPageNumbers(
      int currentPage, int totalPages, MedicalRecordsController controller) {
    final pageNumbers = _getVisiblePages(currentPage, totalPages);
    final pages = <Widget>[];

    for (int i = 0; i < pageNumbers.length; i++) {
      final page = pageNumbers[i];

      if (page == -1) {
        pages.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '...',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ),
        );
      } else {
        final isActive = page == currentPage;
        pages.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: InkWell(
              onTap: () => controller.goToPage(page),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: isActive
                      ? Border.all(color: const Color(0xFF1339FF), width: 1.5)
                      : null,
                ),
                child: Center(
                  child: Text(
                    page.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      color: isActive
                          ? const Color(0xFF1339FF)
                          : Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    return pages;
  }

  List<int> _getVisiblePages(int currentPage, int totalPages) {
    if (totalPages <= 7) {
      return List.generate(totalPages, (i) => i + 1);
    }

    final pages = <int>[];

    if (currentPage <= 4) {
      for (int i = 1; i <= 5; i++) {
        pages.add(i);
      }
      pages.add(-1);
      pages.add(totalPages - 1);
      pages.add(totalPages);
    } else if (currentPage >= totalPages - 3) {
      pages.add(1);
      pages.add(2);
      pages.add(-1);
      for (int i = totalPages - 4; i <= totalPages; i++) {
        pages.add(i);
      }
    } else {
      pages.add(1);
      pages.add(2);
      pages.add(3);
      pages.add(-1);
      pages.add(currentPage - 1);
      pages.add(currentPage);
      pages.add(currentPage + 1);
      pages.add(-1);
      pages.add(totalPages - 1);
      pages.add(totalPages);
    }

    return pages;
  }
}
