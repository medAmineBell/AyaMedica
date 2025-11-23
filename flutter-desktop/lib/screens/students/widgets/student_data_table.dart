import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/home_controller.dart';
import 'package:flutter_getx_app/controllers/student_controller.dart';
import 'package:flutter_getx_app/models/student.dart';
import 'package:flutter_getx_app/screens/students/widgets/add_student_dialog.dart';
import 'package:flutter_getx_app/screens/students/widgets/student_details_sheet_widget.dart';
import 'package:flutter_getx_app/screens/students/widgets/student_table_header.dart';
import 'package:get/get.dart';

import 'defective_records_notification_widget.dart';
import 'student_table.dart';
import 'student_table_pagination.dart';

class StudentDataTable extends StatelessWidget {
  final StudentController controller = Get.put(StudentController());
  final HomeController homeController = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 700,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: Colors.blue.shade600,
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DefectiveRecordsNotification(controller: controller),
            ),
            StudentTableHeader(
              controller: controller,
              onAddStudent: _showAddStudentDialog,
            ),
            Expanded(
              child: StudentTable(
                controller: controller,
                onStudentTap: _showStudentDetails,
              ),
            ),
            StudentTablePagination(controller: controller),
          ],
        );
      }),
    );
  }

  void _showAddStudentDialog() {
    showDialog(
      context: Get.context!,
      builder: (context) => AddStudentDialog(),
    );
  }

  void _showStudentDetails(Student student) {
    // Navigate to student profile using HomeController
    homeController.navigateToStudentProfile(
      student,
      appointmentType: 'View Profile',
    );
  }
}
