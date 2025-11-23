import 'package:flutter/material.dart';
import 'package:flutter_getx_app/models/appointment.dart';
import 'package:flutter_getx_app/models/appointment_models.dart';
import 'package:flutter_getx_app/screens/appointmentScheduling/widgets/status_confirmation_dialog.dart';
import 'package:get/get.dart';
import '../../../controllers/appointment_scheduling_controller.dart';
import 'bulk_action_dialog.dart';

class StudentTableWidget extends StatelessWidget {
  final Appointment appointment;

  const StudentTableWidget({
    Key? key,
    required this.appointment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AppointmentSchedulingController>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          // Header with back button and appointment info
          _buildHeader(controller),

          // Student table
          _buildStudentTable(controller),

          // Footer with actions
          _buildFooter(controller),
        ],
      ),
    );
  }

  Widget _buildHeader(AppointmentSchedulingController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
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

          // Progress Info
          Obx(() {
            final totalStudents = appointment.selectedStudents.length;
            final doneStudents = appointment.selectedStudents.where((student) {
              final status = controller.getAppointmentStatus(
                  appointment.id ?? '', student.id);
              return status == AppointmentStatus.done;
            }).length;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$doneStudents/$totalStudents completed',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF374151),
                ),
              ),
            );
          }),
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
          5: FlexColumnWidth(2), // Bulk action
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
        _buildHeaderCell(
          child: const Text(
            'Bulk action',
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
        _buildDataCell(
          child: _buildBulkActionButton(appointmentStudent, controller),
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
        status == AppointmentStatus.done ? 'Done' : 'Not Done',
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


  Widget _buildBulkActionButton(
    AppointmentStudent appointmentStudent,
    AppointmentSchedulingController controller,
  ) {
    final isDone = appointmentStudent.status == AppointmentStatus.done;

    return SizedBox(
      height: 32,
      child: ElevatedButton(
       onPressed: () async {
  final confirmed = await showStatusChangeConfirmation(
    isMarkingDone: !isDone,
    studentName: appointmentStudent.student.name,
  );

  if (confirmed == true) {
    controller.setLoadingForStudent(
        appointmentStudent.appointmentId, appointmentStudent.student.id, true);

    await Future.delayed(const Duration(milliseconds: 800));

    controller.toggleAppointmentStudentStatus(appointmentStudent);

    controller.setLoadingForStudent(
        appointmentStudent.appointmentId, appointmentStudent.student.id, false);
  }
},

        style: ElevatedButton.styleFrom(
          backgroundColor:
              isDone ? const Color(0xFFDC2626) : const Color(0xFF10B981),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          minimumSize: Size.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      child: Obx(() {
  final isLoading = controller.isLoadingStudent(
      appointmentStudent.appointmentId, appointmentStudent.student.id);

  return isLoading
      ? const SizedBox(
          height: 16,
          width: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
      : Text(
          isDone ? 'Mark as not done' : 'Mark as done',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        );
}),
      ),
    );
  }

  Widget _buildFooter(AppointmentSchedulingController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Obx(() {
            final hasSelected =
                controller.selectedAppointmentStudents.isNotEmpty;
            final selectedCount = controller.selectedAppointmentStudents.length;

            return Row(
              children: [
                if (hasSelected) ...[
                  ElevatedButton(
                    onPressed: () {
                      _showMarkAsDoneConfirmation(controller, selectedCount);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Mark as done ($selectedCount)'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      _showMarkAsNotDoneConfirmation(controller, selectedCount);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Mark as not done ($selectedCount)'),
                  ),
                ],
              ],
            );
          }),
        ],
      ),
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

  void _showMarkAsDoneConfirmation(
      AppointmentSchedulingController controller, int selectedCount) {
    Get.dialog(
      BulkActionDialog(
        title: 'Mark all as done',
        message:
            'By clicking proceed, ${appointment.type} will be marked done for all the selected students ($selectedCount)',
        actionText: 'Proceed',
        actionColor: const Color(0xFF2563EB),
        onConfirm: () {
          // Mark selected students as done
          for (var student in controller.selectedAppointmentStudents) {
            final key = '${student.appointmentId}_${student.student.id}';
            controller.appointmentStatuses[key] = AppointmentStatus.done;
          }
          controller.selectedAppointmentStudents.clear();
        },
      ),
      barrierDismissible: true,
    );
  }

  void _showMarkAsNotDoneConfirmation(
      AppointmentSchedulingController controller, int selectedCount) {
    Get.dialog(
      BulkActionDialog(
        title: 'Mark all as not done',
        message:
            'By clicking proceed, ${appointment.type} will be marked as not done for all the selected students ($selectedCount)',
        actionText: 'Proceed',
        actionColor: const Color(0xFFDC2626),
        onConfirm: () {
          // Mark selected students as not done
          for (var student in controller.selectedAppointmentStudents) {
            final key = '${student.appointmentId}_${student.student.id}';
            controller.appointmentStatuses[key] = AppointmentStatus.notDone;
          }
          controller.selectedAppointmentStudents.clear();
        },
      ),
      barrierDismissible: true,
    );
  }
}
