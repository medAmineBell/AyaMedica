import 'package:flutter/material.dart';
import 'package:flutter_getx_app/models/appointment_models.dart';
import 'package:get/get.dart';
import '../../../../controllers/appointment_scheduling_controller.dart';
import '../../../../models/appointment.dart';
import 'appointment_bulk_actions_widget_student.dart';
import 'appointment_pagination_widget.dart';

class AppointmentStudentTableWidget  extends StatelessWidget {
  const AppointmentStudentTableWidget({Key? key}) : super(key: key);

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
          // Back Button
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    // Navigate back to appointments table
                    controller.currentViewMode.value = TableViewMode.appointments;
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.arrow_back,
                          size: 16,
                          color: Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Back',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
          
          // Bulk Actions Header
          Obx(() => controller.selectedAppointmentStudents.isNotEmpty
              ? const AppointmentBulkActionsWidgetStudent()
              : const SizedBox.shrink()),
          
          // Table
          _buildTable(controller),
          
          // Pagination
          const AppointmentPaginationWidget(),
        ],
      ),
    );
  }

  Widget _buildTable(AppointmentSchedulingController controller) {
    return Obx(() {
      final paginatedStudents = controller.paginatedAppointmentStudents;
      
      if (paginatedStudents.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(32),
          child: const Center(
            child: Text(
              'No appointment students found',
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
          0: FixedColumnWidth(50),  // Checkbox
          1: FixedColumnWidth(80),  // Avatar
          2: FlexColumnWidth(3),    // Student name
          3: FlexColumnWidth(2),    // AID
          4: FlexColumnWidth(2),    // Status
          5: FlexColumnWidth(2),    // Action
        },
        children: [
          // Header
          _buildHeaderRow(controller),
          
          // Data rows
          ...paginatedStudents.map((appointmentStudent) {
            final appointment = controller.appointments.firstWhere(
              (app) => app.id == appointmentStudent.appointmentId,
            );
            
            return _buildDataRow(appointmentStudent, appointment, controller);
          }).toList(),
        ],
      );
    });
  }

  TableRow _buildHeaderRow(AppointmentSchedulingController controller) {
    return TableRow(
      decoration: const BoxDecoration(
        color: Color(0xFFF9FAFB),
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      children: [
        _buildHeaderCell(
          child: Obx(() => Checkbox(
            value: controller.isAllSelected,
            onChanged: (value) => controller.toggleSelectAll(),
            activeColor: const Color(0xFF1339FF),
          )),
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
            'Action',
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
    AppointmentStudent appointmentStudent, 
    Appointment appointment, 
    AppointmentSchedulingController controller
  ) {
    return TableRow(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      children: [
        _buildDataCell(
          child: Obx(() => Checkbox(
            value: controller.selectedAppointmentStudents.any((selected) => 
                selected.appointmentId == appointmentStudent.appointmentId &&
                selected.student.id == appointmentStudent.student.id),
            onChanged: (value) => controller.toggleAppointmentStudentSelection(appointmentStudent),
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
          child: Obx(() => _buildStatusBadge(appointmentStudent, controller)),
        ),
        _buildDataCell(
          child: Obx(() => _buildActionButton(appointmentStudent, controller)),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(AppointmentStudent appointmentStudent, AppointmentSchedulingController controller) {
    final status = controller.getAppointmentStatus(
      appointmentStudent.appointmentId, 
      appointmentStudent.student.id
    );
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status == AppointmentStatus.done
            ? const Color(0xFFDCFCE7)
            : const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status == AppointmentStatus.done ? 'Done' : 'Not Done',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: status == AppointmentStatus.done
              ? const Color(0xFF059669)
              : const Color(0xFFDC2626),
        ),
      ),
    );
  }

  Widget _buildActionButton(AppointmentStudent appointmentStudent, AppointmentSchedulingController controller) {
    final currentStatus = controller.getAppointmentStatus(
      appointmentStudent.appointmentId, 
      appointmentStudent.student.id
    );
    
    return ElevatedButton(
      onPressed: () => controller.toggleAppointmentStudentStatus(appointmentStudent),
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
}