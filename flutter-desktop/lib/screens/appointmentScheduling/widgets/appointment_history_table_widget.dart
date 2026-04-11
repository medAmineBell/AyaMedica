import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../controllers/appointment_history_controller.dart';
import '../../../controllers/home_controller.dart';
import '../../../models/appointment_history_model.dart';
import '../../../models/student.dart';
import 'delete_appointment_dialog.dart';
import 'edit_appointment_dialog.dart';

class AppointmentHistoryTableWidget extends StatelessWidget {
  const AppointmentHistoryTableWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AppointmentHistoryController>();

    return Obx(() {
      final appointments = controller.displayedAppointments;
      final isCancelled =
          controller.selectedFilter.value.toLowerCase() == 'cancelled';

      if (appointments.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text(
                'No appointments found',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          // Fixed Table Header
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Table(
              columnWidths: _columnWidths,
              children: [
                TableRow(
                  children: [
                    _buildHeaderCell('Name'),
                    _buildHeaderCellWithIcon('Appointment type'),
                    _buildHeaderCellWithIcon('Reason'),
                    _buildHeaderCell('Cases'),
                    _buildHeaderCellWithSort('Date & time'),
                    _buildHeaderCell(
                        isCancelled ? 'Cancellation reason' : 'Actions'),
                  ],
                ),
              ],
            ),
          ),
          // Scrollable Table Rows
          Expanded(
            child: SingleChildScrollView(
              child: Table(
                columnWidths: _columnWidths,
                children: appointments
                    .asMap()
                    .entries
                    .map((entry) =>
                        _buildTableRow(entry.value, entry.key, isCancelled))
                    .toList(),
              ),
            ),
          ),
        ],
      );
    });
  }

  Map<int, TableColumnWidth> get _columnWidths => const {
        0: FlexColumnWidth(2.0), // Name
        1: FlexColumnWidth(1.3), // Appointment type
        2: FlexColumnWidth(1.0), // Type
        3: FlexColumnWidth(0.7), // Cases
        4: FlexColumnWidth(1.5), // Date & time
        5: FlexColumnWidth(1.0), // Actions
      };

  Widget _buildHeaderCell(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF64748B),
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildHeaderCellWithIcon(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
              letterSpacing: 0.2,
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
    );
  }

  Widget _buildHeaderCellWithSort(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.arrow_downward,
            size: 14,
            color: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }

  void _onViewAppointment(AppointmentHistory appointment) {
    if (appointment.isWalkIn && appointment.onePatientAid != null) {
      final student = Student(
        id: appointment.onePatientAid!,
        name: appointment.fullName ?? '',
        avatarColor: const Color(0xFF1339FF),
        aid: appointment.onePatientAid,
        grade: appointment.gradeName,
        className: appointment.className,
        classId: appointment.classId,
      );
      final homeController = Get.find<HomeController>();
      final isFulfilled =
          appointment.appointmentStatus.toLowerCase() == 'fulfilled';
      if (isFulfilled) {
        homeController.currentStudent.value = student;
        homeController.currentAppointmentHistory.value = appointment;
        homeController.changeContent(ContentType.checkedOutWalkInSummary);
      } else {
        homeController.navigateToAppointmentStudentProfile(
          student,
          appointment,
        );
      }
    } else {
      final historyController = Get.find<AppointmentHistoryController>();
      historyController.viewAppointmentStudents(appointment);
    }
  }

  Widget _wrapClickable(AppointmentHistory appointment, Widget child) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _onViewAppointment(appointment),
        behavior: HitTestBehavior.opaque,
        child: child,
      ),
    );
  }

  TableRow _buildTableRow(
      AppointmentHistory appointment, int index, bool isCancelled) {
    return TableRow(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
      ),
      children: [
        _wrapClickable(appointment, _buildNameCell(appointment)),
        _wrapClickable(appointment, _buildTextCell(appointment.formattedType)),
        _wrapClickable(appointment, _buildTextCell(appointment.typeDisplay)),
        _wrapClickable(appointment, _buildTextCell(appointment.casesDisplay)),
        _wrapClickable(appointment, _buildDateTimeCell(appointment)),
        if (isCancelled)
          _wrapClickable(
              appointment, _buildTextCell(appointment.cancelReason ?? '--'))
        else
          _buildActionsCell(appointment),
      ],
    );
  }

  Widget _buildNameCell(AppointmentHistory appointment) {
    // Generate color from class name hash
    final colors = [
      const Color(0xFF1339FF),
      const Color(0xFF10B981),
      const Color(0xFF8B5CF6),
      const Color(0xFFEF4444),
      const Color(0xFFF59E0B),
      const Color(0xFF06B6D4),
    ];
    final colorIndex = appointment.className.hashCode.abs() % colors.length;
    final avatarColor = colors[colorIndex];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: avatarColor,
            child: Icon(
              appointment.isWalkIn ? Icons.person : Icons.groups,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          // Name and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.nameDisplay,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  appointment.subtitleDisplay,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextCell(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF475569),
        ),
      ),
    );
  }

  Widget _buildDateTimeCell(AppointmentHistory appointment) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      alignment: Alignment.centerLeft,
      child: Text(
        appointment.dateTimeFormatted,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF475569),
        ),
      ),
    );
  }

  Widget _buildActionsCell(AppointmentHistory appointment) {
    final isFulfilled =
        appointment.appointmentStatus.toLowerCase() == 'fulfilled';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isFulfilled) ...[
            // Cancel
            IconButton(
              onPressed: () {
                showDialog(
                  context: Get.context!,
                  builder: (_) =>
                      DeleteAppointmentDialog(appointment: appointment),
                );
              },
              icon: SvgPicture.asset(
                'assets/svg/note-remove.svg',
                width: 20,
                height: 20,
                color: const Color(0xFFED1F4F),
              ),
              iconSize: 20,
              tooltip: 'Cancel',
              splashRadius: 18,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
            // Edit
            IconButton(
              onPressed: () {
                showDialog(
                  context: Get.context!,
                  builder: (_) =>
                      EditAppointmentDialog(appointment: appointment),
                );
              },
              icon: SvgPicture.asset(
                'assets/svg/edit-2.svg',
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF6B7280),
                  BlendMode.srcIn,
                ),
              ),
              iconSize: 20,
              tooltip: 'Edit',
              splashRadius: 18,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
          // View
          IconButton(
            onPressed: () => _onViewAppointment(appointment),
            icon: SvgPicture.asset(
              'assets/svg/view.svg',
              width: 18,
              height: 18,
              colorFilter: const ColorFilter.mode(
                Color(0xFF6B7280),
                BlendMode.srcIn,
              ),
            ),
            iconSize: 20,
            tooltip: 'View',
            splashRadius: 18,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}
