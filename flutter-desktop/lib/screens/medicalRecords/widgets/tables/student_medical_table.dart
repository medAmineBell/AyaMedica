import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_getx_app/controllers/medical_records_controller.dart';
import 'package:flutter_getx_app/models/student.dart';
import 'package:flutter_getx_app/shared/widgets/dynamic_table_widget.dart';

class StudentMedicalTable extends StatelessWidget {
    final void Function(Student)? onRowTap;

  const StudentMedicalTable({super.key, this.onRowTap});

   @override
  Widget build(BuildContext context) {
    final controller = Get.find<MedicalRecordsController>();

    return Obx(() {
      switch (controller.state.value) {
        case MedicalRecordsState.loading:
          return const Center(child: CircularProgressIndicator());
        case MedicalRecordsState.error:
          return Center(child: Text('Failed to load records.'));
        case MedicalRecordsState.empty:
          return Center(child: Text('No medical records found.'));
        case MedicalRecordsState.success:
          return DynamicTableWidget<Student>(
            items: controller.displayedStudents,
            columns: _buildColumns(),
            showActions: false,
            emptyMessage: 'No records found',
            onRowTap: (student, index) => onRowTap?.call(student),
          );
      }
    });
  }


  List<TableColumnConfig<Student>> _buildColumns() {
    return [
      TableColumnConfig<Student>(
        header: 'Student full name',
        columnWidth: const FlexColumnWidth(3),
        cellBuilder: (student, index) => Row(
          children: [
            TableCellHelpers.avatarCell(student.initials, backgroundColor: student.avatarColor),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student.name,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  Text(student.studentId ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
      TableColumnConfig<Student>(
        header: 'Grade & Class',
        cellBuilder: (student, index) => TableCellHelpers.textCell(student.gradeAndClass),
      ),
      TableColumnConfig<Student>(
        header: 'AID',
        cellBuilder: (student, index) => TableCellHelpers.textCell(student.aid ?? 'N/A'),
      ),
      TableColumnConfig<Student>(
        header: 'Number of records',
        cellBuilder: (student, index) => TableCellHelpers.badgeCell(
          (student.emrNumber ?? 0).toString(),
          backgroundColor: Colors.lightBlue.shade100,
          textColor: Colors.blue,
        ),
      ),
      TableColumnConfig<Student>(
        header: 'Last visit',
        tooltip: 'Last medical appointment',
        cellBuilder: (student, index) =>
            TableCellHelpers.textCell(student.formattedAppointmentDate),
      ),
    ];
  }
}
