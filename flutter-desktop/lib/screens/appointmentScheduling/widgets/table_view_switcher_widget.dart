import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/appointment_scheduling_controller.dart';
import 'appointment_student_notify_table_widget.dart';
import 'appointment_table_widget.dart';
import 'appointment_student_table_widget.dart';
import 'medical_checkup_table_widget.dart';

class TableViewSwitcherWidget extends StatelessWidget {
  const TableViewSwitcherWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AppointmentSchedulingController>();

    return Column(
      children: [
        // View Mode Switcher
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() => _buildSwitchButton(
                    label: 'Appointments',
                    isSelected: controller.currentViewMode.value ==
                        TableViewMode.appointments,
                    onTap: () => controller.switchToAppointmentView(),
                  )),
              const SizedBox(width: 4),
              Obx(() => _buildSwitchButton(
                    label: 'Individual Students',
                    isSelected: controller.currentViewMode.value ==
                        TableViewMode.appointmentStudents,
                    onTap: () => controller.switchToAppointmentStudentView(),
                  )),
            ],
          ),
        ),

        // Table based on current view mode
        Obx(() {
          print('Current view mode: ${controller.currentViewMode.value}');

          switch (controller.currentViewMode.value) {
            case TableViewMode.medicalCheckup:
              print(
                  'Case 4: Showing medical checkup table for appointment ${controller.selectedAppointmentForStudents.value?.id}');
              return MedicalCheckupTableWidget(
                  appointment:
                      controller.selectedAppointmentForStudents.value!);
            case TableViewMode.appointments:
              return AppointmentTableWidget();
            case TableViewMode.appointmentStudents:
              print('Case 2: Showing appointment students table');
              return const AppointmentStudentTableWidget();
            case TableViewMode.appointmentStudentsNotify:
              print('Case 3: Showing appointment students notify table');
              return const AppointmentStudentNotifyTableWidget();

            default:
              return const SizedBox.shrink();
          }
        }),
      ],
    );
  }

  Widget _buildSwitchButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color:
                isSelected ? const Color(0xFF374151) : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}
