import 'package:flutter/material.dart';
import 'package:flutter_getx_app/config/app_config.dart';
import 'package:flutter_getx_app/models/appointment.dart';
import 'package:flutter_getx_app/models/appointment_models.dart';
import 'package:flutter_getx_app/models/student.dart';
import 'package:get/get.dart';
import '../../../controllers/appointment_history_controller.dart';
import '../../../controllers/appointment_scheduling_controller.dart';
import 'package:flutter_getx_app/utils/app_snackbar.dart';

class StudentTableWidget extends StatefulWidget {
  final Appointment appointment;
  final VoidCallback? onBack;

  const StudentTableWidget({
    Key? key,
    required this.appointment,
    this.onBack,
  }) : super(key: key);

  @override
  State<StudentTableWidget> createState() => _StudentTableWidgetState();
}

class _StudentTableWidgetState extends State<StudentTableWidget> {
  final _searchController = TextEditingController();
  final _statusFilter = 'all'.obs; // 'all', 'noAction', 'done', 'notDone'
  late final AppointmentSchedulingController controller;

  Appointment get appointment => widget.appointment;

  @override
  void initState() {
    super.initState();
    controller = Get.find<AppointmentSchedulingController>();
    controller.studentSearchQuery.value = '';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildSearchAndStatusBar(),
          Expanded(
            child: SingleChildScrollView(
              child: _buildStudentTable(),
            ),
          ),
        ],
      ),
    );
  }

  // ─── HEADER ───────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (widget.onBack != null) {
                widget.onBack!();
              } else {
                controller.switchToAppointmentView();
              }
            },
            icon: const Icon(Icons.arrow_back,
                color: Color(0xFF6B7280), size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          const SizedBox(width: 16),
          CircleAvatar(
            radius: 24,
            backgroundColor: _getClassColor(appointment.className),
            child: const Icon(
              Icons.school_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${appointment.grade} | ${appointment.className}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${appointment.type} • ${appointment.disease}',
                  style:
                      const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          if (appointment.status != AppointmentStatus.done && appointment.status != AppointmentStatus.cancelled)
            ElevatedButton(
              onPressed: () => _showCompleteAppointmentDialog(),
              child: const Text('Complete Appointment'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                elevation: 0,
              ),
            ),
        ],
      ),
    );
  }

  // ─── SEARCH + STATUS CHIPS ────────────────────────────────────────────

  Widget _buildSearchAndStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          // Search field
          SizedBox(
            width: 280,
            height: 40,
            child: TextField(
              controller: _searchController,
              onChanged: (value) => controller.studentSearchQuery.value = value,
              decoration: InputDecoration(
                hintText: 'search',
                hintStyle:
                    const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                prefixIcon: const Icon(Icons.search,
                    color: Color(0xFF9CA3AF), size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF2563EB)),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              style: const TextStyle(fontSize: 14, color: Color(0xFF111827)),
            ),
          ),
          const Spacer(),
          // Status count chips
          Obx(() {
            // Trigger reactivity
            controller.appointmentStatuses.length;

            int noAction = 0, done = 0, notDone = 0;
            for (var student in appointment.selectedStudents) {
              final key = '${appointment.id}_${student.id}';
              if (!controller.appointmentStatuses.containsKey(key)) {
                noAction++;
              } else {
                final status = controller.appointmentStatuses[key]!;
                if (status == AppointmentStatus.done) {
                  done++;
                } else {
                  notDone++;
                }
              }
            }

            final selectedFilter = _statusFilter.value;

            return Row(
              children: [
                _buildStatusChip(
                  '$noAction No action taken',
                  const Color(0xFF6B7280),
                  const Color(0xFFF3F4F6),
                  filterKey: 'noAction',
                  isSelected: selectedFilter == 'noAction',
                ),
                const SizedBox(width: 8),
                _buildStatusChip(
                  '$done Done',
                  const Color(0xFF059669),
                  const Color(0xFFDCFCE7),
                  icon: Icons.check_circle,
                  filterKey: 'done',
                  isSelected: selectedFilter == 'done',
                ),
                const SizedBox(width: 8),
                _buildStatusChip(
                  '$notDone Not Done',
                  const Color(0xFFDC2626),
                  const Color(0xFFFEE2E2),
                  icon: Icons.cancel,
                  filterKey: 'notDone',
                  isSelected: selectedFilter == 'notDone',
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, Color textColor, Color bgColor,
      {IconData? icon, required String filterKey, bool isSelected = false}) {
    return GestureDetector(
      onTap: () {
        if (_statusFilter.value == filterKey) {
          _statusFilter.value = 'all';
        } else {
          _statusFilter.value = filterKey;
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: textColor, width: 2)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: textColor),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w500, color: textColor),
            ),
          ],
        ),
      ),
    );
  }

  // ─── TABLE ────────────────────────────────────────────────────────────

  Widget _buildStudentTable() {
    return Obx(() {
      // Filter students by search
      final query = controller.studentSearchQuery.value.toLowerCase();
      final statusFilter = _statusFilter.value;
      final filteredStudents = appointment.selectedStudents.where((s) {
        // Search filter
        if (query.isNotEmpty &&
            !s.name.toLowerCase().contains(query) &&
            !(s.aid ?? s.id).toLowerCase().contains(query)) {
          return false;
        }
        // Status filter
        if (statusFilter != 'all') {
          final key = '${appointment.id}_${s.id}';
          final hasAction = controller.appointmentStatuses.containsKey(key);
          if (statusFilter == 'noAction') return !hasAction;
          if (statusFilter == 'done') {
            return hasAction && controller.appointmentStatuses[key] == AppointmentStatus.done;
          }
          if (statusFilter == 'notDone') {
            return hasAction && controller.appointmentStatuses[key] != AppointmentStatus.done;
          }
        }
        return true;
      }).toList();

      return Table(
        columnWidths: const {
          0: FixedColumnWidth(50),
          1: FixedColumnWidth(60),
          2: FlexColumnWidth(3),
          3: FlexColumnWidth(2),
          4: FlexColumnWidth(2),
          5: FlexColumnWidth(2.5),
        },
        children: [
          _buildTableHeaderRow(),
          ...filteredStudents.map((student) {
            final appointmentStudent = AppointmentStudent(
              appointmentId: appointment.id ?? '',
              student: student,
              status: controller.getAppointmentStatus(
                  appointment.id ?? '', student.id),
            );
            return _buildStudentRow(appointmentStudent);
          }),
        ],
      );
    });
  }

  TableRow _buildTableHeaderRow() {
    return TableRow(
      decoration: const BoxDecoration(
        color: Color(0xFFF9FAFB),
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      children: [
        _buildHeaderCell(
          child: appointment.status == AppointmentStatus.done || appointment.status == AppointmentStatus.cancelled
              ? const SizedBox()
              : Obx(() {
                  final allSelected = _areAllStudentsSelected();
                  return Checkbox(
                    value: allSelected,
                    onChanged: (_) => _toggleSelectAllStudents(),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }),
        ),
        _buildHeaderCell(child: const SizedBox()),
        _buildHeaderCell(
          child: const Text('Student full name',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280))),
        ),
        _buildHeaderCell(
          child: Row(
            children: [
              const Text('AID',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B7280))),
              const SizedBox(width: 4),
              Icon(Icons.help_outline, size: 14, color: Colors.grey.shade400),
            ],
          ),
        ),
        _buildHeaderCell(
          child: const Text('Status',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280))),
        ),
        _buildHeaderCell(
          child: const Text('Actions',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280))),
        ),
      ],
    );
  }

  TableRow _buildStudentRow(AppointmentStudent appointmentStudent) {
    final isSelected = controller.selectedAppointmentStudents.any(
      (s) =>
          s.appointmentId == appointmentStudent.appointmentId &&
          s.student.id == appointmentStudent.student.id,
    );

    return TableRow(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      children: [
        _buildDataCell(
          child: appointment.status == AppointmentStatus.done || appointment.status == AppointmentStatus.cancelled
              ? const SizedBox()
              : Checkbox(
                  value: isSelected,
                  onChanged: (_) => controller
                      .toggleAppointmentStudentSelection(appointmentStudent),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
        ),
        _buildDataCell(child: _buildStudentAvatar(appointmentStudent.student)),
        _buildDataCell(
          child: Text(
            appointmentStudent.student.name,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151)),
          ),
        ),
        _buildDataCell(
          child: Text(
            appointmentStudent.student.aid ?? appointmentStudent.student.id,
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
        ),
        _buildDataCell(
          child: _buildStatusBadge(appointmentStudent),
        ),
        _buildDataCell(
          child: _buildActionSelector(appointmentStudent),
        ),
      ],
    );
  }

  // ─── STATUS BADGE (4 states) ──────────────────────────────────────────

  Widget _buildStatusBadge(AppointmentStudent appointmentStudent) {
    return Obx(() {
      final isLoading = controller.isLoadingStudent(
          appointmentStudent.appointmentId, appointmentStudent.student.id);

      if (isLoading) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Loading..',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
              const SizedBox(width: 4),
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.grey.shade500),
                ),
              ),
            ],
          ),
        );
      }

      final key =
          '${appointmentStudent.appointmentId}_${appointmentStudent.student.id}';
      final hasAction = controller.appointmentStatuses.containsKey(key);

      if (!hasAction) {
        // Undefined — no action taken
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Undefined',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280)),
          ),
        );
      }

      final status = controller.appointmentStatuses[key]!;

      if (status == AppointmentStatus.done) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Good',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF059669)),
          ),
        );
      }

      if (status == AppointmentStatus.absent) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Student is absent',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFFDC2626)),
          ),
        );
      }

      // notDone with issue — show the note text
      final note = controller.appointmentNotes[key] ?? '';
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          note.isNotEmpty ? note : 'Not Done',
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFFD97706)),
          overflow: TextOverflow.ellipsis,
        ),
      );
    });
  }

  // ─── ACTIONS COLUMN (Good | Or | Issue) ───────────────────────────────

  Widget _buildActionSelector(AppointmentStudent appointmentStudent) {
    return Obx(() {
      final isLoading = controller.isLoadingStudent(
          appointmentStudent.appointmentId, appointmentStudent.student.id);
      final key =
          '${appointmentStudent.appointmentId}_${appointmentStudent.student.id}';
      final hasAction = controller.appointmentStatuses.containsKey(key);

      if (isLoading) {
        return const SizedBox(
          width: 16,
          height: 16,
          child: Center(
              child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Color(0xFF6B7280)))),
        );
      }

      // If already actioned, show the result with undo
      if (hasAction) {
        return _buildActionDisplay(appointmentStudent);
      }

      // If fulfilled, no actions available for unactioned students
      if (appointment.status == AppointmentStatus.done || appointment.status == AppointmentStatus.cancelled) {
        return const Text('--', style: TextStyle(color: Color(0xFF9CA3AF)));
      }

      // Default: Good | Or | Issue
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => _onGoodPressed(appointmentStudent),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF86EFAC)),
              ),
              child: const Text(
                'Good',
                style: TextStyle(
                    color: Color(0xFF059669),
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('Or',
                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
          ),
          GestureDetector(
            onTapDown: (details) =>
                _showIssuePopupMenu(appointmentStudent, details.globalPosition),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Issue',
                      style: TextStyle(
                          color: Color(0xFFDC2626),
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                  SizedBox(width: 2),
                  Icon(Icons.keyboard_arrow_down,
                      size: 14, color: Color(0xFFDC2626)),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildActionDisplay(AppointmentStudent appointmentStudent) {
    final key =
        '${appointmentStudent.appointmentId}_${appointmentStudent.student.id}';
    final status = controller.appointmentStatuses[key]!;

    Color bgColor;
    Color textColor;
    Color borderColor;
    String label;
    IconData icon;

    if (status == AppointmentStatus.done) {
      bgColor = const Color(0xFFDCFCE7);
      textColor = const Color(0xFF059669);
      borderColor = const Color(0xFF86EFAC);
      label = 'Good';
      icon = Icons.check_circle;
    } else if (status == AppointmentStatus.absent) {
      bgColor = const Color(0xFFFEE2E2);
      textColor = const Color(0xFFDC2626);
      borderColor = const Color(0xFFFCA5A5);
      label = 'Absent';
      icon = Icons.cancel;
    } else {
      bgColor = const Color(0xFFFEE2E2);
      textColor = const Color(0xFFDC2626);
      borderColor = const Color(0xFFFCA5A5);
      label = 'Issue';
      icon = Icons.error;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: textColor),
              const SizedBox(width: 4),
              Text(label,
                  style: TextStyle(
                      color: textColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        if (appointment.status != AppointmentStatus.done && appointment.status != AppointmentStatus.cancelled) ...[
          const SizedBox(width: 6),
          // Undo button
          GestureDetector(
            onTap: () => _onUndoPressed(appointmentStudent),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: const Icon(Icons.undo, size: 14, color: Color(0xFF2563EB)),
            ),
          ),
        ],
      ],
    );
  }

  // ─── HANDLERS ─────────────────────────────────────────────────────────

  void _onGoodPressed(AppointmentStudent student) {
    controller.updatePatientStatus(
      sessionId: student.appointmentId,
      patientAid: student.student.aid ?? student.student.id,
      patientStatus: 'checked',
      studentId: student.student.id,
    );
  }

  void _onUndoPressed(AppointmentStudent student) {
    controller.updatePatientStatus(
      sessionId: student.appointmentId,
      patientAid: student.student.aid ?? student.student.id,
      patientStatus: 'pending',
      studentId: student.student.id,
    );
  }

  void _showIssuePopupMenu(AppointmentStudent student, Offset tapPosition) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(tapPosition, tapPosition.translate(1, 1)),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      items: [
        PopupMenuItem<String>(
          value: 'absent',
          child: Row(
            children: [
              Icon(Icons.person_off, color: Colors.red.shade600, size: 20),
              const SizedBox(width: 12),
              const Text('Absent'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'freetext',
          child: Row(
            children: [
              Icon(Icons.edit_note, color: Colors.blue.shade600, size: 20),
              const SizedBox(width: 12),
              const Text('Free text'),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == 'absent') {
        controller.updatePatientStatus(
          sessionId: student.appointmentId,
          patientAid: student.student.aid ?? student.student.id,
          patientStatus: 'absent',
          patientNote: 'Student is Absent',
          studentId: student.student.id,
        );
      } else if (value == 'freetext') {
        _showMarkAsNotDoneDialog(student);
      }
    });
  }

  void _showMarkAsNotDoneDialog(AppointmentStudent student) {
    final reasonController = TextEditingController(text: 'Student is Absent');

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Red X icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEE2E2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close,
                      color: Color(0xFFDC2626), size: 24),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Mark as not done',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please provide a reason for marking this task as not done.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text.rich(
                    TextSpan(children: [
                      TextSpan(
                          text: 'Reason',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF374151))),
                      TextSpan(
                          text: '*',
                          style: TextStyle(color: Color(0xFFDC2626))),
                    ]),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: reasonController,
                  decoration: InputDecoration(
                    hintText: 'Student is Absent',
                    hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
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
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          side: const BorderSide(color: Color(0xFFD1D5DB)),
                        ),
                        child: const Text('Dismiss',
                            style: TextStyle(color: Color(0xFF374151))),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final reason = reasonController.text.trim();
                          if (reason.isNotEmpty) {
                            Get.back();
                            controller.updatePatientStatus(
                              sessionId: student.appointmentId,
                              patientAid:
                                  student.student.aid ?? student.student.id,
                              patientStatus: 'issue',
                              patientNote: reason,
                              studentId: student.student.id,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  void _showCompleteAppointmentDialog() {
    final markAllDone = true.obs;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 486),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded,
                    size: 64, color: Color(0xFF10B981)),
                const SizedBox(height: 16),
                Text(
                  'Complete ${appointment.type}',
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827)),
                ),
                const SizedBox(height: 8),
                Text(
                  'By clicking proceed, ${appointment.type} will be marked done for all the students and you can not undo this action',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 14, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 24),
                Obx(() => CheckboxListTile(
                      value: markAllDone.value,
                      onChanged: (val) => markAllDone.value = val ?? true,
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Mark All unchecked checkups status as done',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      activeColor: const Color(0xFF2563EB),
                      controlAffinity: ListTileControlAffinity.leading,
                    )),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          side: const BorderSide(color: Color(0xFFD1D5DB)),
                        ),
                        child: const Text('Dismiss',
                            style: TextStyle(color: Color(0xFF374151))),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Get.back();

                          // If checkbox is checked, mark all pending students as "checked" (good)
                          if (markAllDone.value) {
                            for (final student in appointment.selectedStudents) {
                              final key = '${appointment.id}_${student.id}';
                              if (!controller.appointmentStatuses.containsKey(key)) {
                                await controller.updatePatientStatus(
                                  sessionId: appointment.id!,
                                  patientAid: student.aid ?? student.id,
                                  patientStatus: 'checked',
                                  studentId: student.id,
                                );
                              }
                            }
                          }

                          final success = await controller
                              .checkoutAppointmentSession(appointment.id!);
                          if (success) {
                            // Refresh appointment history list
                            if (Get.isRegistered<AppointmentHistoryController>()) {
                              Get.find<AppointmentHistoryController>().refreshAppointments();
                            }
                            appSnackbar(
                              'Success',
                              'Appointment completed successfully',
                              backgroundColor: const Color(0xFF10B981),
                              colorText: Colors.white,
                            );
                            if (widget.onBack != null) {
                              widget.onBack!();
                            } else {
                              controller.switchToAppointmentView();
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        child: const Text('Complete Appointment'),
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

  // ─── HELPERS ──────────────────────────────────────────────────────────

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

  Widget _buildStudentAvatar(Student student) {
    final imageUrl = student.imageUrl;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      final fullUrl = imageUrl.startsWith('http')
          ? imageUrl
          : '${AppConfig.newBackendUrl}$imageUrl';
      return CircleAvatar(
        radius: 18,
        backgroundColor: student.avatarColor,
        backgroundImage: NetworkImage(fullUrl),
        onBackgroundImageError: (_, __) {},
      );
    }
    return CircleAvatar(
      radius: 18,
      backgroundColor: student.avatarColor,
      child: const Icon(Icons.person, color: Colors.white, size: 20),
    );
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

  bool _areAllStudentsSelected() {
    if (appointment.selectedStudents.isEmpty) return false;
    return appointment.selectedStudents.every((student) {
      return controller.selectedAppointmentStudents.any(
        (s) => s.appointmentId == appointment.id && s.student.id == student.id,
      );
    });
  }

  void _toggleSelectAllStudents() {
    final allSelected = _areAllStudentsSelected();
    if (allSelected) {
      controller.selectedAppointmentStudents.removeWhere(
        (s) => s.appointmentId == appointment.id,
      );
    } else {
      for (var student in appointment.selectedStudents) {
        final appointmentStudent = AppointmentStudent(
          appointmentId: appointment.id ?? '',
          student: student,
          status:
              controller.getAppointmentStatus(appointment.id ?? '', student.id),
        );
        if (!controller.selectedAppointmentStudents.any(
          (s) =>
              s.appointmentId == appointmentStudent.appointmentId &&
              s.student.id == appointmentStudent.student.id,
        )) {
          controller.selectedAppointmentStudents.add(appointmentStudent);
        }
      }
    }
  }
}
