import 'package:flutter/material.dart';
import 'package:flutter_getx_app/screens/medicalRecords/widgets/selected_student_info_sidebar.dart';
import 'package:flutter_getx_app/screens/medicalRecords/widgets/tables/student_medical_detail_table.dart';
import 'package:flutter_getx_app/screens/medicalRecords/widgets/tables/student_medical_table.dart';
import 'package:get/get.dart';

import '../../controllers/medical_records_controller.dart';

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
            Obx(() => controller.selectedStudent.value == null
                  ? const SizedBox()
                  : SelectedStudentInfoSidebar(student:controller.selectedStudent.value! ,)),
          Expanded(
            child: SizedBox(
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
                final student = controller.selectedStudent.value;
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: student == null
                ? StudentMedicalTable(
                    onRowTap: (s) => controller.selectedStudent.value = s,
                  )
                : Column(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: controller.clearSelectedStudent,
                              icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                            ),
                            Text(
                              'Medical Records - ${student.name}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: StudentMedicalDetailTable(student: student),
                      ),
                    ],
                  ),
                );
              }),
              
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

  Widget _buildHeader(MedicalRecordsController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search students...',
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.filter_list, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text('Filter', style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              ),
              onSelected: controller.filterByStatus,
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'all', child: Text('All')),
                const PopupMenuItem(value: 'visited', child: Text('Visited')),
                const PopupMenuItem(value: 'not_visited', child: Text('Not Visited')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
