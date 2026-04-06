import 'package:flutter/material.dart';
import 'package:flutter_getx_app/models/student.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../controllers/home_controller.dart';
import 'medical_records_header.dart';
import 'medical_record_detail_dialog.dart';

class MedicalRecordsView extends StatelessWidget {
  final Student student;

  const MedicalRecordsView({
    Key? key,
    required this.student,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(() {
      if (controller.isLoadingPatientRecords.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(48),
            child: CircularProgressIndicator(),
          ),
        );
      }

      final records = controller.patientMedicalRecords;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MedicalRecordsHeader(),
          const SizedBox(height: 24),
          if (records.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: Text(
                  'No medical records available',
                  style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  // Table header
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: const Row(
                      children: [
                        SizedBox(
                            width: 120,
                            child: Text('Speciality',
                                style: _headerStyle)),
                        SizedBox(width: 16),
                        Expanded(
                            flex: 2,
                            child: Text('Complaint',
                                style: _headerStyle)),
                        SizedBox(width: 16),
                        Expanded(
                            flex: 2,
                            child: Text('Drugs',
                                style: _headerStyle)),
                        SizedBox(width: 16),
                        SizedBox(
                            width: 180,
                            child: Text('Date & time',
                                style: _headerStyle)),
                        SizedBox(width: 16),
                        Expanded(
                            child: Text('Record added by',
                                style: _headerStyle)),
                      ],
                    ),
                  ),
                  // Table rows
                  ...records.map((record) => _buildRow(context, record)),
                ],
              ),
            ),
        ],
      );
    });
  }

  Widget _buildRow(BuildContext context, Map<String, dynamic> record) {
    final specialty = (record['specialty'] as String? ??
            record['type'] as String? ??
            '-')
        .toLowerCase();
    final formattedSpecialty =
        specialty.isNotEmpty
            ? '${specialty[0].toUpperCase()}${specialty.substring(1)}'
            : '-';

    final assessment = record['assessment'] as Map<String, dynamic>?;
    final complaints = assessment?['chief_complaints'] as List?;
    final complaintText = complaints != null && complaints.isNotEmpty
        ? complaints.join(', ')
        : '-';

    final drugs = record['drugs'] as List?;
    final drugNames = <String>[];
    if (drugs != null) {
      for (final d in drugs) {
        final name = (d as Map<String, dynamic>)['drug_name'] as String?;
        if (name != null) drugNames.add(name);
      }
    }

    final dateStr = record['date'] as String?;
    final formattedDate = _formatDateTime(dateStr);

    final doctorName = record['doctorName'] as String? ??
        record['created_by_aid'] as String? ??
        '-';

    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => MedicalRecordDetailDialog(record: record),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFF3F4F6), width: 1),
          ),
        ),
        child: Row(
          children: [
            // Speciality
            SizedBox(
              width: 120,
              child: Text(
                formattedSpecialty,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Complaint
            Expanded(
              flex: 2,
              child: Text(
                complaintText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 16),

            // Drugs (pill tags)
            Expanded(
              flex: 2,
              child: drugNames.isEmpty
                  ? const Text('-',
                      style:
                          TextStyle(fontSize: 14, color: Color(0xFF6B7280)))
                  : Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: drugNames
                          .take(2)
                          .map((name) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(64),
                                ),
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF374151),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ))
                          .toList(),
                    ),
            ),
            const SizedBox(width: 16),

            // Date & time
            SizedBox(
              width: 180,
              child: Text(
                formattedDate,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Record added by
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      doctorName,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF374151),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final d = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy \'at\' hh:mm a').format(d);
    } catch (_) {
      return dateStr;
    }
  }

  static const _headerStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: Color(0xFF6B7280),
  );
}
