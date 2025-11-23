import 'package:flutter/material.dart';
import 'package:flutter_getx_app/models/student.dart';
import 'package:get/get.dart';
import '../../../controllers/home_controller.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_sidebar.dart';
import 'widgets/profile_main_content.dart';

class StudentProfileScreen extends StatelessWidget {
  final Student student;
  final String appointmentType;

  const StudentProfileScreen({
    Key? key,
    required this.student,
    this.appointmentType = 'Walk-In',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: const Color(0xFFFBFCFD),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Back Button
            ProfileHeader(
              appointmentType: appointmentType,
              studentName: student.name,
              onBackPressed: () {
                homeController.changeContent(ContentType.appointmentScheduling);
              },
            ),
            const SizedBox(height: 24),

            // Sidebar + Main Content Layout
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fixed Sidebar
                  ProfileSidebar(student: student),
                  const SizedBox(width: 24),

                  // Scrollable Main Content
                  Expanded(
                    child: SingleChildScrollView(
                      child: ProfileMainContent(student: student),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
