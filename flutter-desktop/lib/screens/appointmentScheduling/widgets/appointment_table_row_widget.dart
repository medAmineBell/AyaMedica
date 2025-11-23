import 'package:flutter/material.dart';
import 'package:flutter_getx_app/models/appointment_models.dart';
import 'package:get/get.dart';
import '../../../../controllers/appointment_scheduling_controller.dart';
import '../../../../models/appointment.dart';
import 'appointment_status_badge_widget.dart';
import 'appointment_action_button_widget.dart';

class AppointmentTableRowWidget {
  final AppointmentStudent appointmentStudent;
  final Appointment appointment;

  const AppointmentTableRowWidget({
    required this.appointmentStudent,
    required this.appointment,
  });

  TableRow buildDataRow() {
    final controller = Get.find<AppointmentSchedulingController>();
    
    return TableRow(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      children: [
        _buildDataCell(
          child: Obx(() => Checkbox(
            value: controller.selectedAppointments.any((selected) => 
                selected.appointmentId == appointmentStudent.appointmentId &&
                selected.student.id == appointmentStudent.student.id),
            onChanged: (value) => controller.toggleAppointmentSelection(appointmentStudent),
            activeColor: const Color(0xFF1339FF),
          )),
        ),
        _buildDataCell(
          child: CircleAvatar(
            radius: 20,
            backgroundColor: appointmentStudent.student.avatarColor,
            child: Text(
              appointmentStudent.student.name.isNotEmpty 
                  ? appointmentStudent.student.name.substring(0, 2).toUpperCase() 
                  : 'AK',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        _buildDataCell(
          child: Text(
            appointmentStudent.student.name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
          ),
        ),
        _buildDataCell(
          child: Text(
            appointmentStudent.student.id,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
        _buildDataCell(
          child: AppointmentStatusBadgeWidget(
            status: appointmentStudent.status,
          ),
        ),
        _buildDataCell(
          child: AppointmentActionButtonWidget(
            appointmentStudent: appointmentStudent,
          ),
        ),
      ],
    );
  }

  Widget _buildDataCell({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: child,
    );
  }
}