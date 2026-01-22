import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/medical_records_controller.dart';
import 'package:flutter_getx_app/models/medical_student.dart';
import 'package:flutter_getx_app/shared/widgets/dynamic_table_widget.dart';
import 'package:get/get.dart';

class StudentMedicalTable extends StatelessWidget {
  final Function(MedicalStudent)? onRowTap;

  const StudentMedicalTable({
    Key? key,
    this.onRowTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MedicalRecordsController>();

    return DynamicTableWidget<MedicalStudent>(
      items: controller.displayedStudents,
      columns: _buildColumns(),
      onRowTap:
          onRowTap != null ? (student, index) => onRowTap!(student) : null,
      showActions: false,
      emptyMessage: 'No students found',
      headerColor: const Color(0xFFF8FAFC),
      borderColor: const Color(0xFFE2E8F0),
    );
  }

  List<TableColumnConfig<MedicalStudent>> _buildColumns() {
    return [
      // Student Info
      TableColumnConfig<MedicalStudent>(
        header: 'Student',
        columnWidth: const FlexColumnWidth(3),
        cellBuilder: (student, index) => Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: _getAvatarColor(student.id),
              child: Text(
                student.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.fullName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'ID: ${student.studentId}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Grade & Class
      TableColumnConfig<MedicalStudent>(
        header: 'Grade & Class',
        columnWidth: const FlexColumnWidth(2),
        cellBuilder: (student, index) => Text(
          student.gradeAndClass ?? 'N/A',
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF374151),
          ),
        ),
      ),

      // Number of Records
      TableColumnConfig<MedicalStudent>(
        header: 'Records',
        columnWidth: const FlexColumnWidth(1.5),
        cellBuilder: (student, index) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: student.numberOfRecords > 0
                ? Colors.blue.shade100
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${student.numberOfRecords}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: student.numberOfRecords > 0
                  ? Colors.blue.shade800
                  : Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),

      // Last Visit
      TableColumnConfig<MedicalStudent>(
        header: 'Last Visit',
        columnWidth: const FlexColumnWidth(2),
        cellBuilder: (student, index) => Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 14,
              color: student.lastVisit != null
                  ? Colors.green.shade600
                  : Colors.grey.shade400,
            ),
            const SizedBox(width: 6),
            Text(
              student.formattedLastVisit,
              style: TextStyle(
                fontSize: 12,
                color: student.lastVisit != null
                    ? const Color(0xFF374151)
                    : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),

      // Status
      TableColumnConfig<MedicalStudent>(
        header: 'Status',
        columnWidth: const FlexColumnWidth(1.5),
        cellBuilder: (student, index) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: student.hasVisited
                ? Colors.green.shade100
                : Colors.orange.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            student.hasVisited ? 'Visited' : 'Not Visited',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: student.hasVisited
                  ? Colors.green.shade800
                  : Colors.orange.shade800,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ];
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
