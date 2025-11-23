import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/home_controller.dart';
import 'complete_walkin_dialog.dart';
import 'cancel_examination_dialog.dart';

class ProfileHeader extends StatelessWidget {
  final String appointmentType;
  final VoidCallback onBackPressed;
  final String studentName;

  const ProfileHeader({
    Key? key,
    required this.appointmentType,
    required this.onBackPressed,
    required this.studentName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Back Button
        InkWell(
          onTap: () {
            // Show cancel examination dialog
            CancelExaminationDialog.show(context).then((confirmed) {
              if (confirmed == true) {
                // User confirmed cancellation, proceed with back action
                onBackPressed();
              }
              // If confirmed is false or null, do nothing (user cancelled)
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.arrow_back,
                  size: 16,
                  color: Color(0xFF6B7280),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Back',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  appointmentType,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const Spacer(),
        
        // Medical History / Complete Walk in Button
        Obx(() {
          final controller = Get.find<HomeController>();
          final isPlansSelected = controller.selectedProfileMenuItem.value == 'Plans';
          
          return ElevatedButton(
            onPressed: () {
              if (isPlansSelected) {
                // Show Complete Walk in dialog
                CompleteWalkInDialog.show(context, studentName).then((result) {
                  if (result != null) {
                    // Handle the dialog result
                    print('Dialog result: $result');
                  }
                });
              } else {
                // Original medical history functionality
                controller.isMedicalHistoryView.toggle();
                controller.selectedProfileMenuItem.value = 'Medical history';
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isPlansSelected ? 'Complete Walk in' : 'Medical history',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.help_outline,
                    size: 12,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}