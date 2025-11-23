import 'package:flutter/material.dart';
import 'package:flutter_getx_app/models/student.dart';

import '../../../../models/medicalRecord.dart';
import '../../../../shared/widgets/dynamic_table_widget.dart';

class StudentMedicalDetailTable extends StatelessWidget {
  final Student student;

  const StudentMedicalDetailTable({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final records = student.medicalRecords ?? [];

    return DynamicTableWidget<MedicalRecord>(
      items: records,
      columns: [
        TableColumnConfig<MedicalRecord>(
          header: 'Date',
          tooltip: 'Date & time of visit',
          cellBuilder: (record, _) => TableCellHelpers.textCell(record.formattedDate),
        ),
        TableColumnConfig<MedicalRecord>(
          header: 'Complaint',
          cellBuilder: (record, _) => TableCellHelpers.textCell(record.complaint),
        ),
        TableColumnConfig<MedicalRecord>(
          header: 'Suspected diseases',
          cellBuilder: (record, _) => TableCellHelpers.textCell(record.suspectedDiseases),
        ),
        TableColumnConfig<MedicalRecord>(
          header: 'Sick leave',
          cellBuilder: (record, _) => TableCellHelpers.badgeCell(
            '${record.sickLeaveDays} days',
            backgroundColor: Colors.lightBlue.shade100,
            textColor: Colors.blue,
          ),
        ),
        TableColumnConfig<MedicalRecord>(
          header: 'Sick leave start date',
          tooltip: 'First day of leave',
          cellBuilder: (record, _) => TableCellHelpers.textCell(record.formattedStartDate),
        ),
      ],
      showActions: false,
    );
  }
}
