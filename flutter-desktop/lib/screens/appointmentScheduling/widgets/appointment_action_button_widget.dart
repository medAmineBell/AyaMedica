import 'package:flutter/material.dart';
import 'package:flutter_getx_app/models/appointment_models.dart';
import 'package:get/get.dart';
import '../../../../controllers/appointment_scheduling_controller.dart';
import 'appointment_confirmation_dialog.dart';

class AppointmentActionButtonWidget extends StatelessWidget {
  final AppointmentStudent appointmentStudent;

  const AppointmentActionButtonWidget({
    Key? key,
    required this.appointmentStudent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AppointmentSchedulingController>();
    
    return Obx(() {
      final currentStatus = controller.getAppointmentStatus(
        appointmentStudent.appointmentId, 
        appointmentStudent.student.id
      );
      
      return ElevatedButton(
        onPressed: () => _showConfirmationDialog(context, currentStatus),
        style: ElevatedButton.styleFrom(
          backgroundColor: currentStatus == AppointmentStatus.done
              ? const Color(0xFFEF4444)
              : const Color(0xFF10B981),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          minimumSize: const Size(80, 32),
        ),
        child: Text(
          currentStatus == AppointmentStatus.done
              ? 'Mark as not done'
              : 'Mark as done',
          style: const TextStyle(fontSize: 11),
        ),
      );
    });
  }

  void _showConfirmationDialog(BuildContext context, AppointmentStatus currentStatus) {
    final controller = Get.find<AppointmentSchedulingController>();
    final appointmentType = controller.getAppointmentType(appointmentStudent.appointmentId);
    
    showDialog(
      context: context,
      builder: (context) => AppointmentConfirmationDialog(
        title: currentStatus == AppointmentStatus.done 
            ? 'Mark as not done' 
            : 'Mark as done',
        message: currentStatus == AppointmentStatus.done
            ? 'By clicking proceed, {$appointmentType} will be marked not done for ${appointmentStudent.student.name}'
            : 'By clicking proceed, {$appointmentType} will be marked done for ${appointmentStudent.student.name}',
        onConfirm: () {
          controller.toggleAppointmentStatus(appointmentStudent);
          Get.back();
        },
        onCancel: () => Get.back(),
      ),
    );
  }
}