import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/medical_records_controller.dart';
import 'package:get/get.dart';
import '../../../../models/medicalRecord.dart';
import '../../../../shared/widgets/dynamic_table_widget.dart';

class StudentMedicalDetailTable extends StatelessWidget {
  const StudentMedicalDetailTable({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MedicalRecordsController>();

    return Obx(() {
      final records = controller.studentRecords;
      final isLoading = controller.isLoadingStudentDetails.value;

      if (isLoading) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          ),
        );
      }

      return DynamicTableWidget<MedicalRecord>(
        items: records,
        columns: [
          TableColumnConfig<MedicalRecord>(
            header: 'Date',
            columnWidth: const FlexColumnWidth(2),
            cellBuilder: (record, _) => Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  record.dateTime,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF374151),
                  ),
                ),
              ],
            ),
          ),
          TableColumnConfig<MedicalRecord>(
            header: 'Complaint',
            columnWidth: const FlexColumnWidth(1.5),
            cellBuilder: (record, _) => Text(
              record.complaint,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF374151),
              ),
            ),
          ),
          TableColumnConfig<MedicalRecord>(
            header: 'Suspected diseases',
            columnWidth: const FlexColumnWidth(1.5),
            cellBuilder: (record, _) => Text(
              record.suspectedDiseases,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF374151),
              ),
            ),
          ),
          TableColumnConfig<MedicalRecord>(
            header: 'Sick leave',
            columnWidth: const FlexColumnWidth(1),
            cellBuilder: (record, _) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: record.sickLeave != null
                    ? Colors.blue.shade100
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                record.sickLeave ?? 'None',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: record.sickLeave != null
                      ? Colors.blue.shade800
                      : Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          TableColumnConfig<MedicalRecord>(
            header: 'Sick leave start date',
            columnWidth: const FlexColumnWidth(1.5),
            cellBuilder: (record, _) => Text(
              record.formattedSickLeaveStartDate,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF374151),
              ),
            ),
          ),
        ],
        showActions: false,
        emptyMessage: 'No medical records found',
        headerColor: const Color(0xFFF8FAFC),
        borderColor: const Color(0xFFE2E8F0),
      );
    });
  }
}
