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
      final selected = controller.selectedProfileMenuItem.value;

      if (selected == 'Medical history') {
        return MedicalHistoryView(student: activeStudent);
      } else if (selected == 'Medical records') {
        return MedicalRecordsView(student: activeStudent);
      } else if (selected == 'Assessment') {
        return AssessmentView(appointment: appointment);
      // } else if (selected == 'Monitoring signs') {
      //   return MonitoringSignsView(student: activeStudent);
      } else if (selected == 'Plans') {
        return const PlansView();
      }

      // Profile tab: show a spinner while the full student record is still
      // being resolved/fetched so users don't see a half-empty profile.
      if (controller.isLoadingStudent.value) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: const Padding(
            padding: EdgeInsets.all(48),
            child: Center(child: CircularProgressIndicator()),
          ),
        );
      }

      return controller.isSummaryMode.value
          ? ProfileSummaryContent(student: activeStudent)
          : ProfileFullContent(student: activeStudent);
    });
  }
}
