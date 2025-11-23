import 'package:flutter/material.dart';
import 'package:flutter_getx_app/models/appointment.dart';
import 'package:get/get.dart';
import '../../../controllers/appointment_scheduling_controller.dart';
import '../../../controllers/home_controller.dart';
import '../../../models/appointment_models.dart';

class AppointmentTableDataWidget extends StatelessWidget {
  const AppointmentTableDataWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AppointmentSchedulingController>();
    
    return Obx(() {
      final paginatedAppointments = controller.paginatedAppointments;
      
      if (paginatedAppointments.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(32),
          child: const Center(
            child: Text(
              'No appointments found',
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
          0: FixedColumnWidth(80),   // Avatar
          1: FlexColumnWidth(3),     // Name
          2: FlexColumnWidth(2),     // Type
          3: FlexColumnWidth(2),     // Appointment type
          4: FixedColumnWidth(80),   // Cases
          5: FlexColumnWidth(2),     // Date & time
          6: FlexColumnWidth(4),     // Status
          7: FlexColumnWidth(2),     // Actions
        },
        children: [
          // Header
          _buildHeaderRow(),
          
          // Data rows
          ...paginatedAppointments.map((appointment) {
            final overallStatus = controller.getAppointmentOverallStatus(appointment.id ?? '');
            return _buildDataRow(appointment, overallStatus, controller);
          }).toList(),
        ],
      );
    });
  }

  TableRow _buildHeaderRow() {
    return TableRow(
      decoration: const BoxDecoration(
        color: Color(0xFFF9FAFB),
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      children: [
        _buildHeaderCell(child: const SizedBox()),
        _buildHeaderCell(
          child: const Text(
            'Name',
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
                'Type',
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
            'Appointment type',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
        _buildHeaderCell(
          child: const Text(
            'Cases',
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
                'Date & time',
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
            'Status',
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

  TableRow _buildDataRow(
    appointment, 
    AppointmentStatus overallStatus, 
    AppointmentSchedulingController controller
  ) {
    return TableRow(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      children: [
        // Clickable Avatar
        _buildDataCell(
          child: InkWell(
            onTap: () => _showStudentDetails(appointment),
            borderRadius: BorderRadius.circular(20),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: _getClassColor(appointment.className),
              child: Text(
                appointment.className.isNotEmpty 
                    ? appointment.className.substring(0, 2).toUpperCase() 
                    : 'CL',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        
        // Clickable Name
        _buildDataCell(
          child: InkWell(
            onTap: () => _showStudentDetails(appointment),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${appointment.className} | ${appointment.grade}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF374151),
                      decoration: TextDecoration.underline,
                      decorationColor: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${appointment.selectedStudents.length} students',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        _buildDataCell(
          child: Text(
            appointment.disease,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
        _buildDataCell(
          child: Text(
            appointment.type,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
        _buildDataCell(
          child: Text(
            '${appointment.selectedStudents.length}',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
        _buildDataCell(
          child: Text(
            '${appointment.date.day}/${appointment.date.month}/${appointment.date.year} ${appointment.time}',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
        _buildDataCell(
          child: _buildStatusBadge(appointment.status),
        ),
        _buildDataCell(
          child: _buildActionButtons(appointment, overallStatus),
        ),
      ],
    );
  }

Widget _buildStatusBadge(AppointmentStatus status) {
  // Define colors and styles based on status
  Color bgColor;
  Color textColor;
  String displayText;

  switch (status) {
    case AppointmentStatus.done:
      bgColor = const Color(0xFFDCFCE7);
      textColor = const Color(0xFF059669);
      displayText = 'Done';
      break;
    case AppointmentStatus.notDone:
      bgColor = const Color(0xFFFEF3C7);
      textColor = const Color(0xFFB45309);
      displayText = 'In Progress';
      break;
    case AppointmentStatus.pendingApproval:
      bgColor = const Color(0xFFD6A100);
      textColor = const Color(0xFFFFEDB9);
      displayText = 'Awaiting parent approvals';
      break;
    default:
      bgColor = const Color(0xFFF3F4F6);
      textColor = const Color(0xFF4B5563);
      displayText = "Unknown";
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(50),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          displayText,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: textColor,
            
            fontSize: 14,
            fontFamily: 'IBM Plex Sans Arabic',
            fontWeight: FontWeight.w500,
            height: 1.43,
            letterSpacing: 0.28,
          ),
        ),
      ],
    ),
  );
}

  Widget _buildActionButtons(Appointment appointment, AppointmentStatus status) {
  if (appointment.status == AppointmentStatus.done) {

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () {
            // Handle print
            print('Printing appointment ${appointment.id}');
          },
          icon: const Icon(Icons.print_outlined, color: Color(0xFF6B7280), size: 18),
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        IconButton(
          onPressed: () {
            // Handle view details
            _showStudentDetails(appointment);
          },
          icon: const Icon(Icons.visibility_outlined, color: Color(0xFF6B7280), size: 18),
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ],
    );
  }
  else if (appointment.status == AppointmentStatus.pendingApproval) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [

    IconButton(
        onPressed: () {
          _showDeleteConfirmation(appointment);
        },
        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
        padding: const EdgeInsets.all(4),
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      ),
      IconButton(
        onPressed: () {
          // Handle edit
        },
        icon: const Icon(Icons.edit_outlined, color: Color(0xFF6B7280), size: 18),
        padding: const EdgeInsets.all(4),
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      ),
      IconButton(
        onPressed: () {
          _showStudentDetailsForNotify(appointment);
        },
        icon: const Icon(Icons.notifications, color: Color(0xFF6B7280), size: 18),
        padding: const EdgeInsets.all(4),
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      ),
   
      ],
    );

  }

  // Default actions when not done
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(
        onPressed: () {
          _showDeleteConfirmation(appointment);
        },
        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
        padding: const EdgeInsets.all(4),
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      ),
      IconButton(
        onPressed: () {
          // Handle edit
        },
        icon: const Icon(Icons.edit_outlined, color: Color(0xFF6B7280), size: 18),
        padding: const EdgeInsets.all(4),
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      ),
      IconButton(
        onPressed: () {
          _showStudentDetails(appointment);
        },
        icon: const Icon(Icons.visibility_outlined, color: Color(0xFF6B7280), size: 18),
        padding: const EdgeInsets.all(4),
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      ),
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

void _showDeleteConfirmation(Appointment appointment) {
  final TextEditingController reasonController = TextEditingController();

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.delete_outline, size: 48, color: Colors.redAccent),
              const SizedBox(height: 20),
              const Text(
                'Delete Appointment?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Please confirm that you want to delete this appointment. '
                'This action cannot be undone and parents will be notified',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Deletion reason goes here',
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFD1D5DB)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                     onPressed: () async {
  final reason = reasonController.text.trim();
  final controller = Get.find<AppointmentSchedulingController>();
  
  // Optional: validate that a reason was entered
  if (reason.isEmpty) {
    Get.snackbar('Reason required', 'Please provide a reason before deleting.',
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.black87,
        snackPosition: SnackPosition.BOTTOM);
    return;
  }

  await controller.deleteAppointment(appointment);

  Get.back(); // Close dialog
  Get.snackbar('Appointment deleted', 'Reason: $reason',
      backgroundColor: Colors.green.shade100,
      colorText: Colors.black87,
      snackPosition: SnackPosition.BOTTOM);
},

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Delete Appointment',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
    barrierDismissible: false,
  );
}


  // Navigate to student view
  void _showStudentDetails(Appointment appointment) {
    print('=== _showStudentDetails called ===');
    print('Appointment ID: ${appointment.id}');
    print('Appointment type: ${appointment.type}');
    print('Appointment status: ${appointment.status}');
    
    final controller = Get.find<AppointmentSchedulingController>();
    
    // Check if this is a medical checkup appointment with saved data
    final hasMedicalCheckupData = controller.hasMedicalCheckupData(appointment.id!);
    final medicalCheckupData = hasMedicalCheckupData 
        ? controller.exportMedicalCheckupData(appointment.id!) 
        : null;

    if (hasMedicalCheckupData && medicalCheckupData != null && medicalCheckupData.isNotEmpty) {
      // Show medical checkup details in main content layout
      final studentsData = medicalCheckupData['students'] as Map<String, dynamic>;
      final homeController = Get.find<HomeController>();
      homeController.showMedicalCheckupTable(appointment, studentsData);
    } else {
      // If appointment type is "Checkup", show medical checkup table
      if (appointment.type.toLowerCase().contains('checkup')) {
        print('✅ Appointment is Checkup type - calling showMedicalCheckupView');
        controller.showMedicalCheckupView(appointment);
      } else {
        print('❌ Appointment is NOT Checkup type - calling showStudentsForAppointment');
        controller.showStudentsForAppointment(appointment);
      }
    }
  }

  void _showStudentDetailsForNotify(Appointment appointment) {
    final controller = Get.find<AppointmentSchedulingController>();
    controller.showStudentsForAppointmentNotify(appointment);
  }
}