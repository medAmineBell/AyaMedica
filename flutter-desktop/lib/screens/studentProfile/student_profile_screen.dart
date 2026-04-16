import 'package:flutter/material.dart';
import 'package:flutter_getx_app/models/student.dart';
import 'package:get/get.dart';
import '../../../controllers/home_controller.dart';
import 'widgets/add_medical_history_dialog.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_sidebar.dart';
import 'widgets/profile_main_content.dart';

class StudentProfileScreen extends StatelessWidget {
  final Student student;

  const StudentProfileScreen({
    Key? key,
    required this.student,
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
              onBackPressed: () {
                homeController.changeContent(ContentType.studentsList);
              },
              trailing: ElevatedButton.icon(
                onPressed: () => AddMedicalHistoryDialog.show(context),
                icon: const Icon(
                  Icons.add,
                  size: 18,
                  color: Colors.white,
                ),
                label: const Text('Add medical history'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1339FF),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
              ),
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
