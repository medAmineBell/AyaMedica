import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/gardes_controller.dart';
import 'package:flutter_getx_app/models/appointment.dart';
import 'package:flutter_getx_app/models/gardes.dart';
import 'package:get/get.dart';
import '../../../controllers/appointment_scheduling_controller.dart';
import '../../../models/appointment_models.dart';

class GardesSettingsDatatable extends StatelessWidget {
  const GardesSettingsDatatable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GardesController>();

    return Obx(() {
      final gardes = controller.gardes;

      if (gardes.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(32),
          child: const Center(
            child: Text(
              'No gardes found',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        );
      }

      return Table(
        columnWidths: const {
          0: FlexColumnWidth(3), // Name
          1: FlexColumnWidth(2), // Type
          2: FlexColumnWidth(2), // Appointment type
          3: FlexColumnWidth(2), // Date & time
          4: FlexColumnWidth(2), // Status
          5: FlexColumnWidth(2), // Actions
        },
        children: [
          // Header
          _buildHeaderRow(),

          // Data rows
          ...gardes.map((garde) {
            return _buildDataRow(garde, controller);
          }).toList(),
        ],
      );
    });
  }

  TableRow _buildHeaderRow() {
    return TableRow(
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 240, 242, 245),
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      children: [
        _buildHeaderCell(
          child: const Text(
            'Branch name & AID',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
        _buildHeaderCell(
          child: Row(
            children: [
              const Text(
                'Class',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.help_outline,
                size: 14,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
        _buildHeaderCell(
          child: const Text(
            'Maximum capacity',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
        _buildHeaderCell(
          child: const Text(
            'Actual capacity',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
        _buildHeaderCell(
          child: const Text(
            'Actions',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
      ],
    );
  }

  TableRow _buildDataRow(gardes, GardesController controller) {
    return TableRow(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      children: [
        // Clickable Avatar

        // Clickable Name
        _buildDataCell(
          child: Row(
            children: [
              InkWell(
                // onTap: () => _showStudentDetails(appointment),
                borderRadius: BorderRadius.circular(20),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: _getClassColor(gardes.name),
                  child: Text(
                    gardes.name.isNotEmpty
                        ? gardes.name.substring(0, 2).toUpperCase()
                        : 'CL',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              InkWell(
                // onTap: () => _showStudentDetails(appointment),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${gardes.name}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF374151),
                          decorationColor: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${gardes.NumClasses} classes ',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        _buildDataCell(
          child: Text(
            gardes.ClassName,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
        _buildDataCell(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: gardes.MaxCapacity > 20
                  ? const Color(0xFFDCFCE7)
                  : const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${gardes.MaxCapacity} Students',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: gardes.MaxCapacity > 20
                    ? const Color(0xFF059669)
                    : const Color(0xFFD97706),
              ),
            ),
          ),
        ),
        _buildDataCell(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: gardes.ActualCapacity > 20
                  ? const Color(0xFFDCFCE7)
                  : const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${gardes.ActualCapacity} Students',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: gardes.ActualCapacity > 20
                    ? const Color(0xFF059669)
                    : const Color(0xFFD97706),
              ),
            ),
          ),
        ),

        _buildDataCell(
          child: _buildActionButtons(gardes),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Gardes gardes) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () {
            // _showDeleteConfirmation(appointment);
          },
          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        IconButton(
          onPressed: () {
            // Handle edit appointment
          },
          icon: const Icon(Icons.edit_outlined,
              color: Color(0xFF6B7280), size: 18),
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        // IconButton(
        //   onPressed: () {
        //     // Handle view appointment details - could also show student details
        //     // _showStudentDetails(appointment);
        //   },
        //   icon: const Icon(Icons.visibility_outlined,
        //       color: Color(0xFF6B7280), size: 18),
        //   padding: const EdgeInsets.all(4),
        //   constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        // ),
      ],
    );
  }

  Widget _buildHeaderCell({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: child,
    );
  }

  Widget _buildDataCell({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: child,
    );
  }

  Color _getClassColor(String className) {
    // Generate a color based on class name hash
    final hash = className.hashCode;
    final colors = [
      const Color(0xFF1339FF),
      const Color(0xFF10B981),
      const Color(0xFFEF4444),
      const Color(0xFF8B5CF6),
      const Color(0xFFF59E0B),
      const Color(0xFF06B6D4),
    ];
    return colors[hash.abs() % colors.length];
  }

  void _showDeleteConfirmation(appointment) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Appointment'),
        content: Text(
            'Are you sure you want to delete the appointment for ${appointment.className}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Handle delete logic here
              Get.back();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Navigate to student view
  void _showStudentDetails(Appointment appointment) {
    final controller = Get.find<AppointmentSchedulingController>();
    controller.showStudentsForAppointment(appointment);
  }
}
