import 'package:flutter/material.dart';
import 'package:flutter_getx_app/models/appointment.dart';
import 'package:flutter_getx_app/models/appointment_models.dart';
import 'package:flutter_getx_app/screens/appointmentScheduling/widgets/show_loading_dialog.dart';
import 'package:flutter_getx_app/screens/appointmentScheduling/widgets/status_confirmation_dialog.dart';
import 'package:get/get.dart';
import '../../../controllers/appointment_scheduling_controller.dart';
import 'bulk_action_dialog.dart';
import 'class_header.dart';
import 'show_send_reminder_dialog.dart';

class StudentTableNotifyWidget extends StatelessWidget {
  final Appointment appointment;

  const StudentTableNotifyWidget({
    Key? key,
    required this.appointment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AppointmentSchedulingController>();

    return Column(
      children: [
    
        // Header with back button and appointment info
        _buildHeader(controller),
        _buildSearchAndStatusHeader(controller),
    
        // Student table
        _buildStudentTable(controller),
    
     
      ],
    );
  }

  Widget _buildHeader(AppointmentSchedulingController controller) {
    return Container(
      padding: const EdgeInsets.only(bottom: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: Row(
        children: [
          // Back Button
          IconButton(
            onPressed: () {
              controller.switchToAppointmentView();
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFF6B7280),
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          const SizedBox(width: 16),

          // Class Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: _getClassColor(appointment.className),
            child: Text(
              appointment.className.isNotEmpty
                  ? appointment.className.substring(0, 2).toUpperCase()
                  : 'CL',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Appointment Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${appointment.className} | ${appointment.grade}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${appointment.type} • ${appointment.disease}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
 Row(
  mainAxisSize: MainAxisSize.min,
  children: [
      OutlinedButton.icon(
      onPressed: () {
              showSendReminderDialog(
      onConfirm: () async {
                Get.back();

        await showLoadingDialog(
          onProgress: (controller) async {
            for (int i = 0; i <= 100; i += 10) {
              await Future.delayed(const Duration(milliseconds: 200));
              controller.updateProgress(i / 100);
            }
            await Future.delayed(const Duration(milliseconds: 500));
          },
        );
      },
    );
              },
      icon: const Icon(Icons.notifications_outlined, size: 20, color: Color(0xFF747677)),
      label: const Text(
        'Notify All pending parents',
        style: TextStyle(
          color: Color(0xFF747677),
          fontSize: 14,
          fontFamily: 'IBM Plex Sans Arabic',
          fontWeight: FontWeight.w500,
          letterSpacing: 0.28,
          height: 1.43,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFFA6A9AC), width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: Colors.white,
        shadowColor: const Color(0x0C101828),
        elevation: 2,
      ),
    ),
     const SizedBox(width: 12),

    // ElevatedButton: "Go to appointment"
    ElevatedButton(
      onPressed: () {
        // Handle navigation
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1339FF),
        foregroundColor: const Color(0xFFCDF7FF),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
        shadowColor: const Color(0x0C101828),
        textStyle: const TextStyle(
          fontSize: 14,
          fontFamily: 'IBM Plex Sans Arabic',
          fontWeight: FontWeight.w500,
          letterSpacing: 0.28,
          height: 1.43,
        ),
      ),
      child: const Text('Go to appointment'),
    ),


   ],
)


         ],
      ),
    );
  }
 Widget _buildSearchAndStatusHeader(AppointmentSchedulingController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search',
                        hintStyle: const TextStyle(
                          color: Color(0xFFA6A9AC),
                          fontSize: 14,
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.w500,
                          height: 1.43,
                          letterSpacing: 0.28,
                        ),
                        prefixIcon: const Icon(Icons.search, size: 24),
                        filled: true,
                        fillColor: const Color(0xFFFBFCFD),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            width: 1,
                            color: Color(0xFFE9E9E9),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            width: 1,
                            color: Color(0xFFE9E9E9),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            width: 1,
                            color: Color(0xFF1339FF),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Spacer(flex: 1),
          Obx(() {
            final statusCounts = controller.getStatusCounts(appointment.id ?? '');
            
            return Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusChip(
                  count: statusCounts['done'] ?? 0,
                  label: 'Approved',
                  bgColor: const Color(0xFFD8FAE4),
                  textColor: const Color(0xFF1D743D),
                ),
                const SizedBox(width: 8),
                _buildStatusChip(
                  count: statusCounts['pending'] ?? 0,
                  label: 'Pending approval',
                  bgColor: const Color(0xFFFFF9E6),
                  textColor: const Color(0xFF856300),
                ),
                const SizedBox(width: 8),
                _buildStatusChip(
                  count: statusCounts['declined'] ?? 0,
                  label: 'Declined',
                  bgColor: const Color(0xFFFBD2DC),
                  textColor: const Color(0xFF771028),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatusChip({
    required int count,
    required String label,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: ShapeDecoration(
        color: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count $label',
            textAlign: TextAlign.center,
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
  Widget _buildStudentTable(AppointmentSchedulingController controller) {
    return Obx(() {
      return Table(
        columnWidths: const {
          0: FixedColumnWidth(50), // Checkbox
          1: FixedColumnWidth(60), // Avatar
          2: FlexColumnWidth(3), // Name
          3: FlexColumnWidth(2), // AID
          4: FlexColumnWidth(2), // Status
        },
        children: [
          // Header Row
          _buildTableHeaderRow(controller),

          // Student Rows
          ...appointment.selectedStudents.map((student) {
            final appointmentStudent = AppointmentStudent(
              appointmentId: appointment.id ?? '',
              student: student,
              status: controller.getAppointmentStatus(
                  appointment.id ?? '', student.id),
            );

            return _buildStudentRow(appointmentStudent, controller);
          }).toList(),
        ],
      );
    });
  }

  TableRow _buildTableHeaderRow(AppointmentSchedulingController controller) {
    return TableRow(
      decoration: const BoxDecoration(
        color: Color(0xFFF9FAFB),
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      children: [
        _buildHeaderCell(
          child: Obx(() {
            final allSelected = _areAllStudentsSelected(controller);
            return Checkbox(
              value: allSelected,
              onChanged: (value) {
                _toggleSelectAllStudents(controller);
              },
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            );
          }),
        ),
        _buildHeaderCell(child: const SizedBox()),
        _buildHeaderCell(
          child: const Text(
            'Student full name',
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
                'AID',
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

      ],
    );
  }

  TableRow _buildStudentRow(
    AppointmentStudent appointmentStudent,
    AppointmentSchedulingController controller,
  ) {
    final isSelected = controller.selectedAppointmentStudents.any(
      (selected) =>
          selected.appointmentId == appointmentStudent.appointmentId &&
          selected.student.id == appointmentStudent.student.id,
    );

    return TableRow(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      children: [
        _buildDataCell(
          child: Checkbox(
            value: isSelected,
            onChanged: (value) {
              controller.toggleAppointmentStudentSelection(appointmentStudent);
            },
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        _buildDataCell(
          child: CircleAvatar(
            radius: 18,
            backgroundColor: appointmentStudent.student.avatarColor,
            child: Text(
              _getInitials(appointmentStudent.student.name),
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
          child: _buildStatusBadge(
  appointmentStudent.status,
  appointmentStudent.appointmentId,
  appointmentStudent.student.id,
  controller,
),
        ),
 
      ],
    );
  }

Widget _buildStatusBadge(AppointmentStatus status, String appointmentId, String studentId, AppointmentSchedulingController controller) {
  return Obx(() {
    final isLoading = controller.isLoadingStudent(appointmentId, studentId);

    if (isLoading) {
      return Container(
        width: 80,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Row(
          children: [
                        SizedBox(width: 12),

            Text("loading..."),
            SizedBox(width: 4),
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status == AppointmentStatus.done
            ? const Color(0xFFDCFCE7)
            : const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status == AppointmentStatus.done ? 'Approved' : status == AppointmentStatus.notDone ? 'Pending' : 'Declined',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: status == AppointmentStatus.done
              ? const Color(0xFF059669)
              : const Color(0xFFD97706),
        ),
      ),
    );
  });
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

  String _getInitials(String name) {
    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (words.isNotEmpty) {
      return words[0].substring(0, 1).toUpperCase();
    }
    return 'U';
  }

  Color _getClassColor(String className) {
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

  bool _areAllStudentsSelected(AppointmentSchedulingController controller) {
    if (appointment.selectedStudents.isEmpty) return false;

    return appointment.selectedStudents.every((student) {
      return controller.selectedAppointmentStudents.any(
        (selected) =>
            selected.appointmentId == appointment.id &&
            selected.student.id == student.id,
      );
    });
  }

  void _toggleSelectAllStudents(AppointmentSchedulingController controller) {
    final allSelected = _areAllStudentsSelected(controller);

    if (allSelected) {
      // Remove all students of this appointment from selection
      controller.selectedAppointmentStudents.removeWhere(
        (selected) => selected.appointmentId == appointment.id,
      );
    } else {
      // Add all students of this appointment to selection
      for (var student in appointment.selectedStudents) {
        final appointmentStudent = AppointmentStudent(
          appointmentId: appointment.id ?? '',
          student: student,
          status:
              controller.getAppointmentStatus(appointment.id ?? '', student.id),
        );

        // Only add if not already selected
        if (!controller.selectedAppointmentStudents.any(
          (selected) =>
              selected.appointmentId == appointmentStudent.appointmentId &&
              selected.student.id == appointmentStudent.student.id,
        )) {
          controller.selectedAppointmentStudents.add(appointmentStudent);
        }
      }
    }
  }

}
