import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/home_controller.dart';
import 'upload_students_dialog.dart';

class AddStudentDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 320,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _AddStudentOption(
              icon: Icons.person_add_outlined,
              title: 'Add one student',
              onTap: _handleAddSingleStudent,
            ),
            SizedBox(height: 8),
            _AddStudentOption(
              icon: Icons.upload_outlined,
              title: 'Upload multiple students',
              onTap: _handleUploadMultiple,
            ),
          ],
        ),
      ),
    );
  }

  void _handleAddSingleStudent() {
    Get.back(); // Close the dialog first
    // Use the HomeController to navigate to student form
    final HomeController homeController = Get.find<HomeController>();
    homeController.navigateToAddStudent();
  }

  void _handleUploadMultiple() {
    Get.back();
    showDialog(
      context: Get.context!,
      builder: (context) => UploadStudentsDialog(),
    );
  }
}

class _AddStudentOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _AddStudentOption({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.grey.shade600,
                size: 20,
              ),
            ),
            SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
