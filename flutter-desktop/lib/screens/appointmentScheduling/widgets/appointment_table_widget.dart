import 'package:flutter/material.dart';
import 'package:flutter_getx_app/screens/appointmentScheduling/widgets/student_table_notify_widget.dart';
import 'package:get/get.dart';
import '../../../controllers/appointment_scheduling_controller.dart';
import 'appointment_filters_widget.dart';
import 'appointment_table_data_widget.dart';
import 'medical_checkup_table_widget.dart';
import 'student_table_widget.dart';
import 'appointment_pagination_appointments_widget.dart';

class AppointmentTableWidget extends StatelessWidget {
  const AppointmentTableWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AppointmentSchedulingController>();
    
    return Obx(() {
      // Show student table if we're in student view mode
      if (controller.currentViewMode.value == TableViewMode.appointmentStudents &&
          controller.selectedAppointmentForStudents.value != null) {
        final appt = controller.selectedAppointmentForStudents.value!;
        // Show hygiene table when disease is Hygiene
        if (appt.type.toLowerCase().contains('checkup') &&
            appt.disease.toLowerCase() == 'hygiene') {
          return MedicalCheckupTableWidget(appointment: appt);
        }
        return StudentTableWidget(appointment: appt);
      }
      if (controller.currentViewMode.value == TableViewMode.appointmentStudentsNotify &&
          controller.selectedAppointmentForStudents.value != null) {
        return StudentTableNotifyWidget(
          appointment: controller.selectedAppointmentForStudents.value!,
        );
      }
      
      // Otherwise show the regular appointment table
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: const Column(
          children: [
            
            // Header Filters
            AppointmentFiltersWidget(),
            
            // Table
            AppointmentTableDataWidget(),
            
            // Pagination
            AppointmentPaginationAppointmentsWidget(),
          ],
        ),
      );
    });
  }
}