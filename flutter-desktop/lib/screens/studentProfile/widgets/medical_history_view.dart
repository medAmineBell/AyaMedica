import 'package:flutter/material.dart';
import 'package:flutter_getx_app/models/student.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../controllers/home_controller.dart';
import 'medical_history_header.dart';

class MedicalHistoryView extends StatelessWidget {
  final Student student;

  const MedicalHistoryView({
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

      final history = controller.patientMedicalHistory;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MedicalHistoryHeader(),
          const SizedBox(height: 24),
          if (history.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: Text(
                  'No medical history available',
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
                            width: 160,
                            child: Text('Category',
                                style: _headerStyle)),
                        SizedBox(width: 16),
                        Expanded(
                            flex: 2,
                            child: Text('Type',
                                style: _headerStyle)),
                        SizedBox(width: 16),
                        SizedBox(
                            width: 120,
                            child: Text('Date',
                                style: _headerStyle)),
                        SizedBox(width: 16),
                        Expanded(
                            flex: 2,
                            child: Text('Medication',
                                style: _headerStyle)),
                        SizedBox(width: 16),
                        Expanded(
                            flex: 2,
                            child: Text('Note',
                                style: _headerStyle)),
                      ],
                    ),
                  ),
                  // Table rows
                  ...history.map((item) => _buildRow(item)),
                ],
              ),
            ),
        ],
      );
    });
  }

  Widget _buildRow(Map<String, dynamic> item) {
    final category = _formatCategoryTitle(
        item['medicalHistoryCategory'] as String? ?? 'Other');

    // Type: disease name or item name
    final disease = item['disease'] as Map<String, dynamic>?;
    final type = disease?['name'] as String? ??
        item['itemName'] as String? ??
        '-';

    // Date: for Diseases use 'date', for others use 'itemDate'
    final isDiseases = category.toLowerCase().contains('diseases');
    final date = _formatDate(
      isDiseases ? item['date'] as String? : (item['itemDate'] as String? ?? item['date'] as String?),
    );
    final notes = item['notes'] as String? ?? '-';

    // Medication column
    String medication = '-';
    if (category == 'Medication') {
      medication = item['itemName'] as String? ?? '-';
    } else {
      // Check medications array (for Diseases category)
      final medications = item['medications'] as List?;
      if (medications != null && medications.isNotEmpty) {
        medication = medications
            .map((m) => m['name'] as String? ?? '')
            .where((n) => n.isNotEmpty)
            .join(', ');
        if (medication.isEmpty) medication = '-';
      } else {
        // Fallback to itemIngredients (for single-item categories)
        final ingredients = item['itemIngredients'] as String?;
        if (ingredients != null && ingredients.isNotEmpty) {
          medication = ingredients;
        }
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFF3F4F6), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Category
          SizedBox(
            width: 160,
            child: Text(
              category,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Type
          Expanded(
            flex: 2,
            child: Text(
              type,
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

          // Date
          SizedBox(
            width: 120,
            child: Text(
              date.isNotEmpty ? date : '-',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Medication
          Expanded(
            flex: 2,
            child: medication != '-'
                ? Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(64),
                    ),
                    child: Text(
                      medication,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF374151),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                : const Text('-',
                    style:
                        TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
          ),
          const SizedBox(width: 16),

          // Note
          Expanded(
            flex: 2,
            child: Text(
              notes,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCategoryTitle(String category) {
    return category
        .split(' ')
        .map((w) => w.isNotEmpty
            ? '${w[0].toUpperCase()}${w.substring(1)}'
            : w)
        .join(' ');
  }

  static const _headerStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: Color(0xFF6B7280),
  );
}

String _formatDate(String? dateStr) {
  if (dateStr == null) return '';
  try {
    final date = DateTime.parse(dateStr);
    return DateFormat('dd/MM/yyyy').format(date);
  } catch (_) {
    return dateStr;
  }
}
