import 'package:flutter/material.dart';
import 'package:flutter_getx_app/models/appointment_history_model.dart';
import 'package:flutter_getx_app/models/student.dart';
import 'package:get/get.dart';
import '../../../controllers/assessment_controller.dart';
import '../../../controllers/home_controller.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_sidebar.dart';
import 'widgets/profile_main_content.dart';

class AppointmentStudentProfileScreen extends StatefulWidget {
  final Student student;
  final AppointmentHistory appointment;

  const AppointmentStudentProfileScreen({
    Key? key,
    required this.student,
    required this.appointment,
  }) : super(key: key);

  @override
  State<AppointmentStudentProfileScreen> createState() =>
      _AppointmentStudentProfileScreenState();
}

class _AppointmentStudentProfileScreenState
    extends State<AppointmentStudentProfileScreen> {
  late final AssessmentController assessmentController;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<AssessmentController>()) {
      assessmentController = Get.find<AssessmentController>();
    } else {
      assessmentController = Get.put(AssessmentController());
    }
    assessmentController.init(
        widget.appointment.id, widget.appointment.medicalRecordId);
  }

  @override
  void dispose() {
    if (Get.isRegistered<AssessmentController>()) {
      Get.delete<AssessmentController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: const Color(0xFFFBFCFD),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Back Button
            ProfileHeader(
              appointmentType: widget.appointment.appointmentType,
              appointmentId: widget.appointment.id,
              studentName: widget.student.name,
              onBackPressed: () {
                homeController.changeContent(ContentType.appointmentScheduling);
              },
            ),
            const SizedBox(height: 24),

            // Sidebar + Main Content Layout
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fixed Sidebar
                  ProfileSidebar(student: widget.student),
                  const SizedBox(width: 24),

                  // Scrollable Main Content
                  Expanded(
                    child: SingleChildScrollView(
                      child: ProfileMainContent(student: widget.student, appointment: widget.appointment),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
