import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/home_controller.dart';
import 'package:flutter_getx_app/models/appointment.dart';
import 'package:flutter_getx_app/models/appointment_models.dart';
import 'package:flutter_getx_app/screens/appointmentScheduling/widgets/create_appointment_dialog.dart';
import 'package:flutter_getx_app/screens/appointmentScheduling/widgets/chronic_disease_table.dart';
import 'package:flutter_getx_app/shared/widgets/primary_button.dart';
import 'package:flutter_getx_app/theme/app_theme.dart';
import 'package:get/get.dart';
import '../../../shared/widgets/breadcrumb_widget.dart';
import '../../../controllers/appointment_scheduling_controller.dart';
import 'widgets/appointment_error_widget.dart';
import 'widgets/appointment_loading_widget.dart';
import 'widgets/appointment_success_widget.dart';
import 'widgets/appointment_empty_widget.dart';

class AppointmentSchedulingScreen
    extends GetView<AppointmentSchedulingController> {
  AppointmentSchedulingScreen({Key? key}) : super(key: key);
  HomeController homeController = Get.find<HomeController>();

  void showCompleteAppointmentDialog(
      Appointment appointment, AppointmentSchedulingController controller) {
    final markAllDone = true.obs;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 486,
              minHeight: 300,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Green check icon
                const Icon(Icons.check_circle_rounded,
                    size: 64, color: Color(0xFF10B981)),

                const SizedBox(height: 16),

                // Title
                const Text(
                  'Complete Checkup',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),

                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'By clicking proceed, ${appointment.type} will be marked done for all the students and you can not undo this action',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),

                const SizedBox(height: 24),

                // Checkbox
                Obx(() => CheckboxListTile(
                      value: markAllDone.value,
                      onChanged: (val) => markAllDone.value = val ?? true,
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Mark All unchecked checkups status as done',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      activeColor: Color(0xFF1339FF),
                      controlAffinity: ListTileControlAffinity.leading,
                    )),

                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Dismiss
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: const BorderSide(color: Color(0xFFD1D5DB)),
                        ),
                        child: const Text('Dismiss'),
                      ),
                    ),
                    SizedBox(width: 16), // Spacing between buttons
                    // Complete
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (markAllDone.value) {
                            for (final student
                                in appointment.selectedStudents) {
                              final key = '${appointment.id}_${student.id}';
                              controller.appointmentStatuses[key] =
                                  AppointmentStatus.done;
                            }
                            controller.appointmentStatuses.refresh();

                            // Save medical checkup data if it's a medical checkup appointment
                            if (appointment.type
                                    .toLowerCase()
                                    .contains('medical') ||
                                appointment.type
                                    .toLowerCase()
                                    .contains('checkup')) {
                              controller.saveMedicalCheckupData(appointment.id!,
                                  appointment.selectedStudents);
                            }
                            controller.switchToAppointmentView();
                            // Mark appointment as completed with timestamp
                            if (appointment.id != null) {
                              controller
                                  .markAppointmentAsCompleted(appointment.id!);
                            }
                          }
                          controller.selectedAppointmentForStudents.value =
                              null;
                          Get.back(); // Close dialog
                          Get.snackbar(
                            'Completed',
                            'All checkups have been marked as done.',
                            backgroundColor: const Color(0xFF10B981),
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1339FF),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Complete Appointment'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFBFCFD),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height -
                80, // Subtract navbar height
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Appointment scheduling',
                        style: TextStyle(
                          color: Color(0xFF2D2E2E) /* Text-Text-100 */,
                          fontSize: 20,
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.w700,
                          height: 1.40,
                        ),
                      ),
                      const BreadcrumbWidget(
                        items: [
                          BreadcrumbItem(label: 'Ayamedica portal'),
                          BreadcrumbItem(label: 'Appointment scheduling'),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Chronic Diseases Button
                      // Obx(() => Container(
                      //       margin: const EdgeInsets.only(right: 12),
                      //       child: ElevatedButton.icon(
                      //         onPressed: () =>
                      //             controller.toggleChronicDiseasesTable(),
                      //         icon: Icon(
                      //           Icons.medical_services,
                      //           size: 18,
                      //           color: controller.currentViewMode.value ==
                      //                   TableViewMode.chronicDiseases
                      //               ? Colors.white
                      //               : const Color(0xFF1339FF),
                      //         ),
                      //         label: Text(
                      //           'Chronic Diseases',
                      //           style: TextStyle(
                      //             color: controller.currentViewMode.value ==
                      //                     TableViewMode.chronicDiseases
                      //                 ? Colors.white
                      //                 : const Color(0xFF1339FF),
                      //             fontWeight: FontWeight.w600,
                      //           ),
                      //         ),
                      //         style: ElevatedButton.styleFrom(
                      //           backgroundColor:
                      //               controller.currentViewMode.value ==
                      //                       TableViewMode.chronicDiseases
                      //                   ? const Color(0xFF1339FF)
                      //                   : Colors.white,
                      //           side:
                      //               BorderSide(color: const Color(0xFF1339FF)),
                      //           padding: const EdgeInsets.symmetric(
                      //               horizontal: 16, vertical: 12),
                      //           shape: RoundedRectangleBorder(
                      //             borderRadius: BorderRadius.circular(8),
                      //           ),
                      //         ),
                      //       ),
                      //     )),
                      // Main Action Button
                      Obx(() {
                        final isSelected =
                            controller.selectedAppointmentForStudents.value !=
                                null;

                        return PrimaryButton(
                          text: isSelected
                              ? 'Complete appointment'
                              : 'New appointments',
                          icon: isSelected
                              ? Icons.check_circle_outline
                              : Icons.add,
                          variant: ButtonVariant.primary,
                          backgroundColor: const Color(0xFF1339FF),
                          onPressed: () {
                            if (isSelected) {
                              showCompleteAppointmentDialog(
                                  controller
                                      .selectedAppointmentForStudents.value!,
                                  controller);
                            } else {
                              _showCreateAppointmentDialog(context);
                            }
                          },
                        );
                      }),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Obx(() {
                // Show chronic diseases table if that view mode is selected
                if (controller.currentViewMode.value ==
                    TableViewMode.chronicDiseases) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        'Chronic Diseases Management',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.colorPalette['neutral']!['90']!,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Manage and monitor chronic diseases for students',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.colorPalette['neutral']!['60']!,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ChronicDiseaseTable(
                        students: controller.getStudentsWithChronicDiseases(),
                      ),
                    ],
                  );
                }

                // Show regular appointment content
                switch (controller.screenState.value) {
                  case AppointmentScreenState.loading:
                    return const AppointmentLoadingWidget();
                  case AppointmentScreenState.error:
                    return AppointmentErrorWidget(
                      error: controller.errorMessage.value,
                      onRetry: controller.retryLoading,
                    );
                  case AppointmentScreenState.empty:
                    return SizedBox(
                        height: MediaQuery.of(context).size.height -
                            200, // Adjust height as needed
                        child: const AppointmentEmptyWidget());
                  case AppointmentScreenState.success:
                    return const AppointmentSuccessWidget();
                }
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateAppointmentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreateAppointmentDialog(),
    );
  }

  bool _isMedicalCheckupComplete(AppointmentSchedulingController controller) {
    final appointment = controller.selectedAppointmentForStudents.value;
    if (appointment == null) return false;

    // Check if all students have been marked for all health categories
    for (var student in appointment.selectedStudents) {
      final categories = ['Hair', 'Ears', 'Nails', 'Teeth', 'Uniform'];
      for (var category in categories) {
        final key = '${appointment.id}_${student.id}_$category';
        final status = controller.getHealthStatus(key);
        if (status == null) {
          return false; // Not all categories are marked
        }
      }
    }
    return true; // All checkups are complete
  }
}
