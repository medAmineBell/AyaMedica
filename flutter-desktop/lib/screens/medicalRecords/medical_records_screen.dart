import 'package:flutter/material.dart';
import 'package:flutter_getx_app/screens/medicalRecords/widgets/selected_student_info_sidebar.dart';
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Medical Records',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
        actions: [
          // Statistics badge
          Obx(() => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.people,
                            size: 16, color: Colors.blue.shade700),
                        const SizedBox(width: 4),
                        Text(
                          '${controller.totalStudents.value} Students',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )),
          Obx(() => controller.isLoading.value
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  onPressed: controller.refreshRecords,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh',
                )),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          // Sidebar - only show when student is selected
          Obx(() {
            final MedicalStudent? student = controller.selectedStudent.value;
            return student == null
                ? const SizedBox()
                : SelectedStudentInfoSidebar();
          }),

          // Main content
          Expanded(
            child: Column(
              children: [
                _buildHeader(controller),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(16),
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
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(MedicalRecordsController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search students by name, ID, grade, or class...',
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
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
                  borderSide: const BorderSide(color: Color(0xFF3B82F6)),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: controller.searchRecords,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: PopupMenuButton<String>(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.filter_list, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Obx(() => Text(
                          controller.selectedFilter.value == 'all'
                              ? 'All Students'
                              : controller.selectedFilter.value == 'visited'
                                  ? 'Visited'
                                  : 'Not Visited',
                          style: TextStyle(color: Colors.grey.shade600),
                        )),
                  ],
                ),
              ),
              onSelected: controller.filterByStatus,
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'all', child: Text('All Students')),
                const PopupMenuItem(value: 'visited', child: Text('Visited')),
                const PopupMenuItem(
                    value: 'not_visited', child: Text('Not Visited')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsList(MedicalRecordsController controller) {
    return Obx(() {
      // Show loading state
      if (controller.state.value == MedicalRecordsState.loading) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      // Show error state
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

      // Show empty state
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

      // Show students table
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
              bottom: BorderSide(
                color: Colors.grey.shade200,
              ),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: controller.clearStudentDetails,
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 16,
                ),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: controller.currentPage.value > 1
                ? controller.previousPage
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          const SizedBox(width: 16),
          Text(
            'Page ${controller.currentPage.value} of ${controller.totalPages.value}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed:
                controller.currentPage.value < controller.totalPages.value
                    ? controller.nextPage
                    : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
