import 'package:flutter/material.dart';
import 'package:flutter_getx_app/models/student.dart';
import 'package:flutter_getx_app/screens/studentProfile/widgets/assessment_view.dart';
import 'package:flutter_getx_app/screens/studentProfile/widgets/plans_view.dart';
import 'package:flutter_getx_app/screens/studentProfile/widgets/monitoring_signs_view.dart';
import 'package:get/get.dart';
import '../../../../controllers/home_controller.dart';
import 'medical_history_view.dart';
import 'profile_full_content.dart';
import 'profile_summary_content.dart';
import 'medical_records_view.dart';

class ProfileMainContent extends StatelessWidget {
  final Student student;

  const ProfileMainContent({
    Key? key,
    required this.student,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(() {
      if (controller.selectedProfileMenuItem.value == 'Medical history') {
        return MedicalHistoryView(student: student);
      } else if (controller.selectedProfileMenuItem.value ==
          'Medical records') {
        return MedicalRecordsView(student: student);
      } else if (controller.selectedProfileMenuItem.value == 'Assessment') {
        return AssessmentView();
      } else if (controller.selectedProfileMenuItem.value ==
          'Monitoring signs') {
        return MonitoringSignsView(student: student);
      } else if (controller.selectedProfileMenuItem.value == 'Plans') {
        return const PlansView();
      }

      return controller.isSummaryMode.value
          ? ProfileSummaryContent(student: student)
          : ProfileFullContent(student: student);
    });
  }
}
