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
      // Student full name
      TableColumnConfig<MedicalStudent>(
        header: 'Student full name',
        columnWidth: const FlexColumnWidth(2.5),
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
              child: Text(
                student.fullName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1F2937),
                ),
                overflow: TextOverflow.ellipsis,
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

      // AID
      TableColumnConfig<MedicalStudent>(
        header: 'AID',
        columnWidth: const FlexColumnWidth(1.5),
        cellBuilder: (student, index) => Text(
          student.studentId,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF374151),
          ),
        ),
      ),

      // Number of records
      TableColumnConfig<MedicalStudent>(
        header: 'Number of records',
        columnWidth: const FlexColumnWidth(1.5),
        cellBuilder: (student, index) => InkWell(
          onTap: () => onRowTap?.call(student),
          child: Text(
            '${student.numberOfRecords}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3B82F6),
            ),
          ),
        ),
      ),

      // Last visit
      TableColumnConfig<MedicalStudent>(
        header: 'Last visit',
        columnWidth: const FlexColumnWidth(2),
        tooltip: 'Date and time of last medical visit',
        cellBuilder: (student, index) => Text(
          student.formattedLastVisit,
          style: TextStyle(
            fontSize: 13,
            color: student.lastVisit != null
                ? const Color(0xFF374151)
                : Colors.grey.shade500,
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
