import 'package:flutter/material.dart';
import 'package:flutter_getx_app/config/app_config.dart';
import 'package:flutter_getx_app/models/appointment.dart';
import 'package:flutter_getx_app/models/appointment_models.dart';
import 'package:flutter_getx_app/models/health_status.dart';
import 'package:flutter_getx_app/models/student.dart';
import 'package:get/get.dart';
import '../../../controllers/appointment_history_controller.dart';
import '../../../controllers/appointment_scheduling_controller.dart';
import 'package:flutter_getx_app/utils/app_snackbar.dart';

class MedicalCheckupTableWidget extends StatefulWidget {
  final Appointment appointment;
  final VoidCallback? onBack;

  const MedicalCheckupTableWidget({
    Key? key,
    required this.appointment,
    this.onBack,
  }) : super(key: key);

  @override
  State<MedicalCheckupTableWidget> createState() =>
      _MedicalCheckupTableWidgetState();
}

class _MedicalCheckupTableWidgetState extends State<MedicalCheckupTableWidget> {
  final _searchController = TextEditingController();
  final _searchQuery = ''.obs;
  late final AppointmentSchedulingController controller;

  Appointment get appointment => widget.appointment;

  // Category-specific issue options
  static const Map<String, List<String>> categoryIssueOptions = {
    'Hair': ['Long', 'Lice', 'Loose', 'Absent'],
    'Ears': ['Unclean', 'Earwax', 'Absent'],
    'Nails': ['Unclean', 'Onychophagia/Bitten', 'Polish', 'Long', 'Absent'],
    'Teeth': ['Unclean', 'Tartar', 'Bad breath', 'Absent'],
    'Uniform': ['Unclean', 'Violation', 'Absent'],
  };

  static const _categories = ['Hair', 'Ears', 'Nails', 'Teeth', 'Uniform'];

  @override
  void initState() {
    super.initState();
    controller = Get.find<AppointmentSchedulingController>();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ─── helpers ──────────────────────────────────────────────────────────

  bool _isStudentDone(Student student) {
    for (var cat in _categories) {
      final key = '${appointment.id}_${student.id}_$cat';
      final s = controller.getHealthStatus(key);
      if (s == null) return false;
    }
    return true;
  }

  int _getDoneCount() {
    return appointment.selectedStudents.where((s) => _isStudentDone(s)).length;
  }

  int _getNotDoneCount() {
    return appointment.selectedStudents.length - _getDoneCount();
  }

  List<Student> _getFilteredStudents() {
    final query = _searchQuery.value.toLowerCase();
    return appointment.selectedStudents.where((s) {
      if (query.isEmpty) return true;
      return s.name.toLowerCase().contains(query) ||
          (s.aid ?? s.id).toLowerCase().contains(query);
    }).toList();
  }

  // ─── build ────────────────────────────────────────────────────────────

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
            child: Obx(() {
              // trigger reactivity on health statuses & search
              controller.healthStatuses.length;
              _searchQuery.value;

              final students = _getFilteredStudents();

              return SingleChildScrollView(
                child: _buildTable(students),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ─── HEADER (matches Figma) ───────────────────────────────────────────

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
            backgroundColor: _classColor(appointment.className),
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
                  '${appointment.type} | ${appointment.disease}',
                  style:
                      const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          if (appointment.status != AppointmentStatus.done && appointment.status != AppointmentStatus.cancelled)
            ElevatedButton(
              onPressed: () => _completeAppointment(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                elevation: 0,
              ),
              child: const Text('Complete Appointment'),
            ),
        ],
      ),
    );
  }

  // ─── SEARCH + STATUS BADGES ──────────────────────────────────────────

  Widget _buildSearchAndStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 280,
            height: 40,
            child: TextField(
              controller: _searchController,
              onChanged: (v) => _searchQuery.value = v,
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
          Obx(() {
            controller.healthStatuses.length; // reactivity
            return Row(
              children: [
                _buildBadge(
                  icon: Icons.check_circle,
                  color: const Color(0xFF059669),
                  bg: const Color(0xFFDCFCE7),
                  count: _getDoneCount(),
                  label: 'Done',
                ),
                const SizedBox(width: 8),
                _buildBadge(
                  icon: Icons.cancel,
                  color: const Color(0xFFDC2626),
                  bg: const Color(0xFFFEE2E2),
                  count: _getNotDoneCount(),
                  label: 'Not Done',
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required Color color,
    required Color bg,
    required int count,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            '$count $label',
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w500, color: color),
          ),
        ],
      ),
    );
  }

  // ─── TABLE ────────────────────────────────────────────────────────────

  Widget _buildTable(List<Student> students) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2.5), // Student
        1: FlexColumnWidth(2), // Hair
        2: FlexColumnWidth(2), // Ears
        3: FlexColumnWidth(2), // Nails
        4: FlexColumnWidth(2), // Teeth
        5: FlexColumnWidth(2), // Uniform
      },
      children: [
        _buildHeaderRow(),
        ...students.map((s) => _buildStudentRow(s)),
      ],
    );
  }

  TableRow _buildHeaderRow() {
    return TableRow(
      decoration: const BoxDecoration(
        color: Color(0xFFF9FAFB),
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      children: [
        _headerCell('Student full name'),
        ..._categories.map((c) => _headerCell(c)),
      ],
    );
  }

  Widget _headerCell(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF6B7280),
        ),
      ),
    );
  }

  TableRow _buildStudentRow(Student student) {
    return TableRow(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      children: [
        _buildStudentCell(student),
        ..._categories.map((cat) => _buildHealthCell(cat, student)),
      ],
    );
  }

  // ─── STUDENT CELL ─────────────────────────────────────────────────────

  Widget _buildStudentCell(Student student) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildAvatar(student),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  student.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF111827),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                Text(
                  student.aid ?? student.id,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(Student student) {
    if (student.imageUrl != null && student.imageUrl!.isNotEmpty) {
      String url = student.imageUrl!;
      // Prepend backend host if the URL is a relative path
      if (url.startsWith('/')) {
        url = '${AppConfig.newBackendUrl}$url';
      }
      return CircleAvatar(
        radius: 18,
        backgroundImage: NetworkImage(url),
        backgroundColor: student.avatarColor,
        onBackgroundImageError: (_, __) {},
      );
    }
    return CircleAvatar(
      radius: 18,
      backgroundColor: student.avatarColor,
      child: const Icon(Icons.person, color: Colors.white, size: 20),
    );
  }

  // ─── HEALTH STATUS CELL ───────────────────────────────────────────────

  Widget _buildHealthCell(String category, Student student) {
    return Obx(() {
      controller.healthStatuses.length; // reactivity
      final key = '${appointment.id}_${student.id}_$category';
      final status = controller.getHealthStatus(key);

      final isDone = appointment.status == AppointmentStatus.done || appointment.status == AppointmentStatus.cancelled;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: status == null
            ? (isDone
                ? const Text('--', style: TextStyle(color: Color(0xFF9CA3AF)))
                : _buildSelector(category, student))
            : _buildStatusChip(status, category, student, readOnly: isDone),
      );
    });
  }

  Widget _buildSelector(String category, Student student) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            final key = '${appointment.id}_${student.id}_$category';
            controller.setHealthStatus(key, HealthStatus.good);
            _syncStudentHygiene(student);
          },
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
                color: Color(0xFF15803D),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text('Or',
              style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
        ),
        GestureDetector(
          onTapDown: (d) => _showIssueMenu(category, student, d.globalPosition),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFCA5A5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Issue',
                  style: TextStyle(
                    color: Color(0xFFDC2626),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 2),
                Icon(Icons.keyboard_arrow_down,
                    size: 14, color: Color(0xFFDC2626)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(
      HealthStatusData status, String category, Student student,
      {bool readOnly = false}) {
    final isGood = status.status == HealthStatus.good;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: isGood ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    isGood ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isGood ? Icons.check_circle : Icons.cancel,
                  color: isGood
                      ? const Color(0xFF15803D)
                      : const Color(0xFFDC2626),
                  size: 14,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    isGood ? 'Good - done' : status.issueDescription ?? '',
                    style: TextStyle(
                      color: isGood
                          ? const Color(0xFF15803D)
                          : const Color(0xFFDC2626),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                if (!isGood) ...[
                  const SizedBox(width: 2),
                  const Icon(Icons.keyboard_arrow_down,
                      size: 14, color: Color(0xFFDC2626)),
                ],
              ],
            ),
          ),
        ),
        if (!readOnly) ...[
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () {
              final key = '${appointment.id}_${student.id}_$category';
              controller.clearHealthStatus(key);
              _syncStudentHygiene(student);
            },
            child: const Icon(Icons.undo, color: Color(0xFF6B7280), size: 18),
          ),
        ],
      ],
    );
  }

  // ─── SYNC HYGIENE TO API ────────────────────────────────────────────

  /// Syncs hygiene data to API only when ALL 5 categories for the student are filled.
  void _syncStudentHygiene(Student student) {
    // Check if every category has a status
    for (final cat in _categories) {
      final key = '${appointment.id}_${student.id}_$cat';
      if (controller.getHealthStatus(key) == null) return; // not complete yet
    }

    // All categories filled — send to API
    final statuses = <String, HealthStatusData?>{};
    for (final cat in _categories) {
      final key = '${appointment.id}_${student.id}_$cat';
      statuses[cat] = controller.getHealthStatus(key);
    }
    controller.updatePatientHygieneStatus(
      sessionId: appointment.id!,
      patientAid: student.aid ?? student.id,
      studentId: student.id,
      categoryStatuses: statuses,
    );
  }

  // ─── ISSUE MENU ───────────────────────────────────────────────────────

  void _showIssueMenu(String category, Student student, Offset tapPosition) {
    final options = categoryIssueOptions[category] ?? [];
    final overlay = Get.overlayContext!.findRenderObject() as RenderBox;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(tapPosition, tapPosition.translate(1, 1)),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: Get.context!,
      position: position,
      items: options
          .map((o) => PopupMenuItem<String>(value: o, child: Text(o)))
          .toList(),
    ).then((value) {
      if (value != null) {
        if (value == 'Absent') {
          // Mark ALL categories as Absent for this student
          for (final cat in _categories) {
            final k = '${appointment.id}_${student.id}_$cat';
            controller.setHealthStatusWithIssue(
                k, HealthStatus.issue, 'Absent');
          }
        } else {
          final key = '${appointment.id}_${student.id}_$category';
          controller.setHealthStatusWithIssue(key, HealthStatus.issue, value);
        }
        _syncStudentHygiene(student);
      }
    });
  }

  // ─── COMPLETE ─────────────────────────────────────────────────────────

  void _completeAppointment() {
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
                  style:
                      const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
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

                          // If checkbox is checked, mark all unchecked hygiene categories as good and sync
                          if (markAllDone.value) {
                            for (final student
                                in appointment.selectedStudents) {
                              bool changed = false;
                              for (final cat in _categories) {
                                final key =
                                    '${appointment.id}_${student.id}_$cat';
                                if (controller.getHealthStatus(key) == null) {
                                  controller.setHealthStatus(
                                      key, HealthStatus.good);
                                  changed = true;
                                }
                              }
                              if (changed) {
                                _syncStudentHygiene(student);
                              }
                            }
                          }

                          // Save hygiene data and checkout
                          controller.saveMedicalCheckupData(
                              appointment.id!, appointment.selectedStudents);

                          final success = await controller
                              .checkoutAppointmentSession(appointment.id!);
                          if (success) {
                            if (Get.isRegistered<
                                AppointmentHistoryController>()) {
                              Get.find<AppointmentHistoryController>()
                                  .refreshAppointments();
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

  // ─── UTILS ────────────────────────────────────────────────────────────

  Color _classColor(String className) {
    final colors = [
      const Color(0xFF6366F1),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFFF59E0B),
      const Color(0xFF10B981),
      const Color(0xFF1339FF),
    ];
    return colors[className.hashCode.abs() % colors.length];
  }
}
