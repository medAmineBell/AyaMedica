import 'package:flutter/material.dart';
import 'package:flutter_getx_app/models/appointment_history_model.dart';
import 'package:flutter_getx_app/models/student.dart';
import 'assessment_view.dart';
import 'plans_view.dart';
// import 'package:flutter_getx_app/screens/studentProfile/widgets/monitoring_signs_view.dart';
import 'package:get/get.dart';
import '../../../../controllers/home_controller.dart';
import 'medical_history_view.dart';
import 'profile_full_content.dart';
import 'profile_summary_content.dart';
import 'medical_records_view.dart';

class ProfileMainContent extends StatelessWidget {
  final Student student;
  final AppointmentHistory appointment;

  const ProfileMainContent({
    Key? key,
    required this.student,
    required this.appointment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(() {
      final activeStudent = controller.currentStudent.value ?? student;

      if (controller.selectedProfileMenuItem.value == 'Medical history') {
        return MedicalHistoryView(student: activeStudent);
      } else if (controller.selectedProfileMenuItem.value ==
          'Medical records') {
        return MedicalRecordsView(student: activeStudent);
      } else if (controller.selectedProfileMenuItem.value == 'Assessment') {
        return AssessmentView(appointment: appointment);
      // } else if (controller.selectedProfileMenuItem.value ==
      //     'Monitoring signs') {
      //   return MonitoringSignsView(student: activeStudent);
      } else if (controller.selectedProfileMenuItem.value == 'Plans') {
        return const PlansView();
      }

      return controller.isSummaryMode.value
          ? ProfileSummaryContent(student: activeStudent)
          : ProfileFullContent(student: activeStudent);
    });
  }
}
