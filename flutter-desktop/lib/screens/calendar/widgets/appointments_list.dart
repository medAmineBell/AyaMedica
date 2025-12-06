import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/calendar_controller.dart';
import 'package:flutter_getx_app/models/appointment.dart';
import 'package:flutter_getx_app/models/appointment_models.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AppointmentsList extends GetView<CalendarController> {
  const AppointmentsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final filteredAppointments = controller.filteredAppointments;
      
      if (filteredAppointments.isEmpty) {
        return Center(
          child: Text(
            'No appointments found',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        );
      }

      return SingleChildScrollView(
        child: Column(
          children: [
            // Table Header
            _buildTableHeader(),
            // Table Rows
            ...filteredAppointments.map((appointment) => 
              _buildAppointmentRow(context, appointment)
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: _buildHeaderCell('Name')),
          Expanded(flex: 1, child: _buildHeaderCell('Appointment type', showInfo: true)),
          Expanded(flex: 1, child: _buildHeaderCell('Type', showInfo: true)),
          Expanded(flex: 1, child: _buildHeaderCell('Cases')),
          Expanded(flex: 1, child: _buildHeaderCell('Date & time', showSort: true)),
          Expanded(flex: 1, child: _buildHeaderCell('Status', showInfo: true)),
          Expanded(flex: 1, child: _buildHeaderCell('Actions')),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, {bool showInfo = false, bool showSort = false}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            if (showInfo) ...[
              const SizedBox(width: 4),
              Icon(Icons.help_outline, size: 16, color: Colors.grey[600]),
            ],
            if (showSort) ...[
              const SizedBox(width: 4),
              Icon(Icons.arrow_downward, size: 16, color: Colors.grey[600]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentRow(BuildContext context, Appointment appointment) {
    final status = controller.appointmentStatuses[appointment.id] ?? appointment.status;
    final isStartingSoon = _isStartingSoon(appointment);
    
    return InkWell(
      onTap: () {
        // Show appointment details in the same view
        controller.showAppointmentDetails(appointment);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: isStartingSoon ? const Color(0xFFF0FDF4) : Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: _buildNameCell(appointment),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Center(child: _buildAppointmentTypeCell(appointment)),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Center(child: _buildTypeCell(appointment)),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Center(child: _buildCasesCell(appointment)),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Center(child: _buildDateTimeCell(appointment)),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Center(child: _buildStatusCell(status, appointment)),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Center(child: _buildActionsCell(context, appointment)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameCell(Appointment appointment) {
    final studentCount = appointment.allStudents 
        ? '23 students' 
        : appointment.selectedStudents.length == 1
            ? appointment.selectedStudents.first.name
            : '${appointment.selectedStudents.length} students';
    
    final displayName = appointment.allStudents
        ? '${appointment.className} | ${appointment.grade}'
        : appointment.selectedStudents.isNotEmpty
            ? appointment.selectedStudents.first.name
            : '${appointment.className} | ${appointment.grade}';

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF0066FF),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              _getInitials(displayName),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                studentCount,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentTypeCell(Appointment appointment) {
    return Text(
      appointment.type,
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF374151),
      ),
    );
  }

  Widget _buildTypeCell(Appointment appointment) {
    return Text(
      appointment.diseaseType.isEmpty ? '--' : appointment.diseaseType,
      style: TextStyle(
        fontSize: 14,
        color: appointment.diseaseType.isEmpty 
            ? Colors.grey[400] 
            : const Color(0xFF374151),
      ),
    );
  }

  Widget _buildCasesCell(Appointment appointment) {
    final cases = appointment.allStudents 
        ? 23 
        : appointment.selectedStudents.length;
    return Text(
      cases.toString(),
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF374151),
      ),
    );
  }

  Widget _buildDateTimeCell(Appointment appointment) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    return Text(
      '${dateFormat.format(appointment.date)} ${appointment.time}',
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF374151),
      ),
    );
  }

  Widget _buildStatusCell(AppointmentStatus status, Appointment appointment) {
    String statusText;
    Color backgroundColor;
    Color textColor;

    if (_isStartingSoon(appointment)) {
      final minutesUntilStart = _getMinutesUntilStart(appointment);
      statusText = 'Starting in $minutesUntilStart min';
      backgroundColor = const Color(0xFF10B981);
      textColor = Colors.white;
    } else {
      switch (status) {
        case AppointmentStatus.done:
          statusText = 'Checked Out';
          backgroundColor = const Color(0xFF10B981);
          textColor = Colors.white;
          break;
        case AppointmentStatus.notDone:
        case AppointmentStatus.received:
        case AppointmentStatus.pendingApproval:
          statusText = 'Incomplete';
          backgroundColor = const Color(0xFFF59E0B);
          textColor = Colors.white;
          break;
        case AppointmentStatus.cancelled:
          statusText = 'Not Started';
          backgroundColor = const Color(0xFFEF4444);
          textColor = Colors.white;
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildActionsCell(BuildContext context, Appointment appointment) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.delete_outline, size: 20, color: Color(0xFF6B7280)),
          onPressed: () {
            controller.deleteAppointment(appointment.id!);
          },
        ),
        IconButton(
          icon: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF6B7280)),
          onPressed: () {
            // Handle edit
            print('Edit appointment: ${appointment.id}');
          },
        ),
        IconButton(
          icon: const Icon(Icons.visibility_outlined, size: 20, color: Color(0xFF6B7280)),
          onPressed: () {
            // Handle view
            print('View appointment: ${appointment.id}');
          },
        ),
      ],
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  bool _isStartingSoon(Appointment appointment) {
    final now = DateTime.now();
    final appointmentDateTime = _parseAppointmentDateTime(appointment);
    if (appointmentDateTime == null) return false;
    
    final difference = appointmentDateTime.difference(now);
    return difference.inMinutes >= 0 && difference.inMinutes <= 5;
  }

  int _getMinutesUntilStart(Appointment appointment) {
    final now = DateTime.now();
    final appointmentDateTime = _parseAppointmentDateTime(appointment);
    if (appointmentDateTime == null) return 0;
    
    final difference = appointmentDateTime.difference(now);
    return difference.inMinutes.clamp(0, 999);
  }

  DateTime? _parseAppointmentDateTime(Appointment appointment) {
    try {
      // Parse time like "08:00 AM - 08:30 AM" and extract start time
      final timeParts = appointment.time.split(' - ');
      if (timeParts.isEmpty) return null;
      
      final startTimeStr = timeParts[0].trim();
      final timeFormat = DateFormat('hh:mm a');
      final parsedTime = timeFormat.parse(startTimeStr);
      
      return DateTime(
        appointment.date.year,
        appointment.date.month,
        appointment.date.day,
        parsedTime.hour,
        parsedTime.minute,
      );
    } catch (e) {
      // Fallback: try to parse just the date
      return DateTime(
        appointment.date.year,
        appointment.date.month,
        appointment.date.day,
        0,
        0,
      );
    }
  }
}

