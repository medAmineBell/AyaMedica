import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/appointment_history_controller.dart';
import '../../../models/appointment_history_model.dart';
import '../../../shared/widgets/dynamic_table_widget.dart';

class AppointmentHistoryTableWidget extends StatelessWidget {
  const AppointmentHistoryTableWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AppointmentHistoryController>();

    return Obx(() {
      final appointments = controller.displayedAppointments;

      return DynamicTableWidget<AppointmentHistory>(
        items: appointments,
        columns: _buildColumns(),
        actions: _buildActions(),
        showActions: true,
        emptyMessage: 'No appointments found',
        headerColor: const Color(0xFFF8FAFC),
        borderColor: const Color(0xFFE2E8F0),
      );
    });
  }

  List<TableColumnConfig<AppointmentHistory>> _buildColumns() {
    return [
      // Name Column
      TableColumnConfig<AppointmentHistory>(
        header: 'Name',
        columnWidth: const FlexColumnWidth(2.5),
        cellBuilder: (appointment, index) => Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: _getAvatarColor(appointment.patient.id),
              child: Text(
                appointment.patient.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    appointment.patient.fullName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    appointment.gradeAndClass,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Appointment Type
      TableColumnConfig<AppointmentHistory>(
        header: 'Appointment type',
        columnWidth: const FlexColumnWidth(1.5),
        cellBuilder: (appointment, index) => Text(
          appointment.formattedType,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF374151),
          ),
        ),
      ),

      // Type (Disease Type)
      TableColumnConfig<AppointmentHistory>(
        header: 'Type',
        columnWidth: const FlexColumnWidth(1.5),
        cellBuilder: (appointment, index) => Text(
          appointment.disease ?? '—',
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF374151),
          ),
        ),
      ),

      // Cases
      TableColumnConfig<AppointmentHistory>(
        header: 'Cases',
        columnWidth: const FlexColumnWidth(0.8),
        cellBuilder: (appointment, index) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${appointment.cases}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade800,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),

      // Date & Time
      TableColumnConfig<AppointmentHistory>(
        header: 'Date & time',
        columnWidth: const FlexColumnWidth(2),
        cellBuilder: (appointment, index) => Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 14,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 6),
            Text(
              appointment.dateTime,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),

      // Status
      TableColumnConfig<AppointmentHistory>(
        header: 'Status',
        columnWidth: const FlexColumnWidth(1.2),
        cellBuilder: (appointment, index) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: appointment.statusBackgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            appointment.statusDisplay,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: appointment.statusColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ];
  }

  List<TableActionConfig<AppointmentHistory>> _buildActions() {
    return [
      TableActionConfig<AppointmentHistory>(
        icon: Icons.delete_outline,
        color: const Color(0xFFDC2626),
        tooltip: 'Delete',
        onPressed: (appointment, index) {
          _showDeleteDialog(appointment);
        },
      ),
      TableActionConfig<AppointmentHistory>(
        icon: Icons.edit_outlined,
        color: const Color(0xFF747677),
        tooltip: 'Edit',
        onPressed: (appointment, index) {
          print('Edit appointment: ${appointment.id}');
        },
      ),
      TableActionConfig<AppointmentHistory>(
        icon: Icons.visibility_outlined,
        color: const Color(0xFF3B82F6),
        tooltip: 'View',
        onPressed: (appointment, index) {
          print('View appointment: ${appointment.id}');
        },
      ),
    ];
  }

  void _showDeleteDialog(AppointmentHistory appointment) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 48,
                color: Colors.orange.shade600,
              ),
              const SizedBox(height: 16),
              const Text(
                'Delete Appointment',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to delete this appointment for ${appointment.patient.fullName}?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        // Handle delete
                        print('Delete appointment: ${appointment.id}');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getAvatarColor(String id) {
    final hash = id.hashCode;
    final colors = [
      const Color(0xFF3B82F6), // Blue
      const Color(0xFF059669), // Green
      const Color(0xFF7C3AED), // Purple
      const Color(0xFFDC2626), // Red
      const Color(0xFFD97706), // Orange
      const Color(0xFF0891B2), // Cyan
    ];
    return colors[hash.abs() % colors.length];
  }
}
