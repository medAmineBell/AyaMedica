import 'package:flutter/material.dart';
import 'package:flutter_getx_app/screens/appointmentScheduling/appointment_history_screen.dart';
import 'package:flutter_getx_app/screens/calendar/calendar_base.dart';
import 'package:flutter_getx_app/screens/communication/communication_screen.dart';
import 'package:flutter_getx_app/screens/dashboard/dashboard_screen.dart';
import 'package:flutter_getx_app/screens/settings/widgets/gard_settings_screen.dart';
import 'package:flutter_getx_app/screens/settings/ayamedica_solution_screen.dart';
import 'package:flutter_getx_app/screens/medicalRecords/medical_records_screen.dart';
import 'package:flutter_getx_app/screens/studentProfile/student_profile_screen.dart';
import 'package:flutter_getx_app/screens/students/student_overView_screen.dart';
import 'package:flutter_getx_app/screens/users/user_screen.dart';
import 'package:flutter_getx_app/screens/feedbackDashboard/feedback_details_screen.dart';
import 'package:flutter_getx_app/screens/medicalCheckup/medical_checkup_table_screen.dart';
import 'package:flutter_getx_app/screens/reports/reports_screen.dart';

import 'package:get/get.dart';
import '../../../controllers/home_controller.dart';
import '../../appointmentScheduling/appointment_scheduling_screen.dart';

import '../../students/student_form_screen.dart';
import '../../students/students_list_screen.dart';
import '../../branches/branches_management_screen.dart';
import '../../branches/widgets/branch_form_widget.dart';

class MainContentLayout extends GetView<HomeController> {
  const MainContentLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: Obx(() {
        return _buildContentByType(controller.currentContent.value,
            context: context);
      }),
    );
  }

  Widget _buildContentByType(ContentType contentType, {BuildContext? context}) {
    switch (contentType) {
      case ContentType.dashboard:
        return DashboardScreen();

      case ContentType.calendar:
        return CalendarBase();
      case ContentType.studentProfile:
        // Show student profile if student is selected
        if (controller.currentStudent.value != null) {
          return StudentProfileScreen(
            student: controller.currentStudent.value!,
            appointmentType: controller.currentAppointmentType.value,
          );
        }
        // Fallback to appointment scheduling if no student selected
        return AppointmentHistoryScreen();
      case ContentType.studentsOverview:
        return StudentOverviewScreen();
      case ContentType.studentsList:
        return StudentsListScreen();

      case ContentType.studentForm:
        // Return student form with proper parameters
        return Obx(() => StudentFormScreen(
              student: controller.studentToEdit.value,
              isEditing: controller.isEditingStudent.value,
              onSave: () => controller.exitStudentForm(),
              onCancel: () => controller.exitStudentForm(),
            ));
      case ContentType.branchForm:
        // Return branch form with proper parameters
        return const BranchFormWidget();
      case ContentType.medicalCheckups:
        return MedicalRecordsScreen();
      case ContentType.medicalCheckupTable:
        return _buildMedicalCheckupTableContent();
      case ContentType.reports:
        return const ReportsScreen();
      case ContentType.branches:
        return BranchManagementScreen();
      case ContentType.gradesSettings:
        return _buildGradesSettingsContent();
      case ContentType.users:
        return _buildUsersContent();
      case ContentType.settings:
        return AyamedicaSolutionScreen();
      case ContentType.feedbackDetails:
        return FeedbackDetailsScreen();
      case ContentType.communication:
        return CommunicationScreen();
      case ContentType.appointmentScheduling:
        return Container(
          child: Center(
            child: AppointmentHistoryScreen(),
          ),
        );
      default:
        return DashboardScreen();
    }
  }

  Widget _buildGradesSettingsContent() {
    return GardSettingsScreen();
  }

  Widget _buildUsersContent() {
    return UsersScreen();
  }

  Widget _buildMedicalCheckupTableContent() {
    return Obx(() {
      final controller = Get.find<HomeController>();
      final appointment = controller.currentAppointment.value;
      final medicalCheckupData = controller.currentMedicalCheckupData.value;

      if (appointment == null || medicalCheckupData.isEmpty) {
        return const Center(
          child: Text(
            'No medical checkup data available',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
            ),
          ),
        );
      }

      return MedicalCheckupTableScreen(
        appointment: appointment,
        medicalCheckupData: medicalCheckupData,
      );
    });
  }
}
