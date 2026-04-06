import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/appointment_history_controller.dart';
import '../../../../controllers/assessment_controller.dart';
import '../../../../controllers/home_controller.dart';
import 'complete_walkin_dialog.dart';
import 'cancel_examination_dialog.dart';

class ProfileHeader extends StatelessWidget {
  final String appointmentType;
  final String appointmentId;
  final VoidCallback onBackPressed;
  final String studentName;

  const ProfileHeader({
    Key? key,
    required this.appointmentType,
    required this.appointmentId,
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
            CancelExaminationDialog.show(context).then((result) {
              if (result == 'back') {
                // Just go back to appointments
                onBackPressed();
              } else if (result == 'cancel_appointment') {
                // Call cancel API then go back
                final historyController =
                    Get.find<AppointmentHistoryController>();
                historyController
                    .cancelAppointment(appointmentId, 'Cancelled by doctor')
                    .then((_) => onBackPressed());
              }
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
          final homeController = Get.find<HomeController>();
          final assessmentController = Get.find<AssessmentController>();
          final selectedTab = homeController.selectedProfileMenuItem.value;
          final isAssessmentTab = selectedTab == 'Assessment';
          final isPlansTab = selectedTab == 'Plans';
          final isFilled = assessmentController.isAssessmentFilled;

          final showCompleteWalkIn =
              (isAssessmentTab && isFilled) || isPlansTab;
          final buttonText =
              (isAssessmentTab || isPlansTab) ? 'Complete Walk in' : 'Assessment';

          return ElevatedButton(
            onPressed: () {
              if (isAssessmentTab && !isFilled) {
                // Show popup to fill assessment data
                Get.snackbar(
                  'Assessment Incomplete',
                  'Please fill in the required assessment fields (Chief complaint, Suspected diseases, Recommendations)',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: const Color(0xFFFEF3C7),
                  colorText: const Color(0xFF92400E),
                  duration: const Duration(seconds: 3),
                  margin: const EdgeInsets.all(16),
                );
              } else if (showCompleteWalkIn) {
                CompleteWalkInDialog.show(context, studentName)
                    .then((result) async {
                  if (result != null) {
                    // Show loading overlay
                    if (!context.mounted) return;
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );

                    final success =
                        await assessmentController.completeWalkIn();

                    // Close loading
                    if (!context.mounted) return;
                    Navigator.of(context).pop();

                    if (success) {
                      // Refresh appointments list
                      try {
                        final historyController =
                            Get.find<AppointmentHistoryController>();
                        await historyController.fetchAppointmentHistory();
                      } catch (_) {}

                      homeController
                          .changeContent(ContentType.appointmentScheduling);
                    }
                  }
                });
              } else {
                // Navigate to Assessment tab
                homeController.selectedProfileMenuItem.value = 'Assessment';
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D6EFD),
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
                  buttonText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
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
