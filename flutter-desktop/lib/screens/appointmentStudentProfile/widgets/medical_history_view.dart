import 'package:flutter/material.dart';
import 'package:flutter_getx_app/models/student.dart';
import 'package:flutter_getx_app/screens/studentProfile/widgets/medication_category_card.dart';
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

      // Group medical history by medicalHistoryCategory
      final history = controller.patientMedicalHistory;
      final grouped = <String, List<Map<String, dynamic>>>{};
      for (final item in history) {
        final category =
            item['medicalHistoryCategory'] as String? ?? 'Other';
        grouped.putIfAbsent(category, () => []).add(item);
      }

      // Extract specific groups
      final medications = grouped['Medication'] ?? [];
      final vaccinations = grouped['Vaccinations'] ?? [];
      final surgeries = grouped.entries
          .where((e) => e.key == 'Surgeries')
          .expand((e) => e.value)
          .toList();

      // Disease groups
      final diseaseGroups = <String, List<Map<String, dynamic>>>{};
      for (final entry in grouped.entries) {
        if (entry.key != 'Medication' &&
            entry.key != 'Vaccinations' &&
            entry.key != 'Surgeries') {
          diseaseGroups[entry.key] = entry.value;
        }
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MedicalHistoryHeader(),
          const SizedBox(height: 24),

          // Previous surgeries
          _SurgerySection(items: surgeries),
          const SizedBox(height: 12),

          // Medication category
          _MedicationSection(
              controller: controller, medications: medications),
          const SizedBox(height: 12),

          // Disease sections (chronic, infectious, allergies, immunities, other)
          ...diseaseGroups.entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _DiseaseSection(
                    title: entry.key, items: entry.value),
              )),

          // Vaccinations
          if (vaccinations.isNotEmpty) ...[
            _VaccinationSection(items: vaccinations),
            const SizedBox(height: 12),
          ],
        ],
      );
    });
  }
}

// --- Previous Surgeries Section ---
class _SurgerySection extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  const _SurgerySection({required this.items});

  @override
  State<_SurgerySection> createState() => _SurgerySectionState();
}

class _SurgerySectionState extends State<_SurgerySection> {
  bool _isExpanded = false;

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
          InkWell(
            onTap: widget.items.isNotEmpty
                ? () => setState(() => _isExpanded = !_isExpanded)
                : null,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Previous surgeries',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                      if (widget.items.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5E7EB),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('${widget.items.length}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ],
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                    color: const Color(0xFF374151),
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded && widget.items.isNotEmpty) ...[
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: widget.items
                    .map((item) => _buildSurgeryItem(item))
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSurgeryItem(Map<String, dynamic> item) {
    final name = item['itemName'] as String? ?? '-';
    final date = _formatDate(item['date'] as String?);
    final notes = item['notes'] as String?;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 5),
            decoration: const BoxDecoration(
                color: Color(0xFF2563EB), shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                if (date.isNotEmpty)
                  Text(date,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF6B7280))),
                if (notes != null && notes.isNotEmpty)
                  Text(notes,
                      style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                          fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Medication Section ---
class _MedicationSection extends StatelessWidget {
  final HomeController controller;
  final List<Map<String, dynamic>> medications;

  const _MedicationSection({
    required this.controller,
    required this.medications,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => controller.isMedicationExpanded.toggle(),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Medication category',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                      if (medications.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5E7EB),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('${medications.length}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ],
                  ),
                  Obx(() => Icon(
                        controller.isMedicationExpanded.value
                            ? Icons.expand_less
                            : Icons.expand_more,
                        color: const Color(0xFF374151),
                      )),
                ],
              ),
            ),
          ),
          Obx(() => controller.isMedicationExpanded.value &&
                  medications.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: medications.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      mainAxisExtent: 316,
                    ),
                    itemBuilder: (context, index) {
                      final med = medications[index];
                      final name = med['itemName'] as String? ?? '-';
                      final ingredients =
                          med['itemIngredients'] as String? ?? '-';
                      final date = _formatDate(med['date'] as String?);

                      return MedicationCategoryCard(
                        drugName: name,
                        activeIngredient: ingredients,
                        route: '-',
                        dosage: '-',
                        timing: '-',
                        duration: '-',
                        frequency: '-',
                        startDate: date,
                        endDate: '-',
                      );
                    },
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
}

// --- Disease Section (chronic, infectious, allergies, etc.) ---
class _DiseaseSection extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> items;

  const _DiseaseSection({required this.title, required this.items});

  @override
  State<_DiseaseSection> createState() => _DiseaseSectionState();
}

class _DiseaseSectionState extends State<_DiseaseSection> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        _formatCategoryTitle(widget.title),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('${widget.items.length}',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: const Color(0xFF374151),
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.items.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  mainAxisExtent: 180,
                ),
                itemBuilder: (context, index) =>
                    _buildDiseaseCard(widget.items[index]),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDiseaseCard(Map<String, dynamic> item) {
    final disease = item['disease'] as Map<String, dynamic>?;
    final name = disease?['name'] as String? ??
        item['itemName'] as String? ??
        '-';
    final date = _formatDate(item['date'] as String?);
    final notes = item['notes'] as String?;
    final createdDate = _formatDate(item['createdDate'] as String?);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFCFD),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              color: Color(0xFF2D2E2E),
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          if (notes != null && notes.isNotEmpty) ...[
            Text(
              notes,
              style: const TextStyle(
                color: Color(0xFF2D2E2E),
                fontSize: 13,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
          ],
          const Spacer(),
          Row(
            children: [
              const Icon(Icons.calendar_today,
                  size: 12, color: Color(0xFF6B7280)),
              const SizedBox(width: 4),
              Text(
                date.isNotEmpty ? date : createdDate,
                style: const TextStyle(
                  color: Color(0xFF1339FF),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCategoryTitle(String category) {
    // "chronic diseases" -> "Chronic Diseases"
    return category
        .split(' ')
        .map((w) => w.isNotEmpty
            ? '${w[0].toUpperCase()}${w.substring(1)}'
            : w)
        .join(' ');
  }
}

// --- Vaccination Section ---
class _VaccinationSection extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  const _VaccinationSection({required this.items});

  @override
  State<_VaccinationSection> createState() => _VaccinationSectionState();
}

class _VaccinationSectionState extends State<_VaccinationSection> {
  bool _isExpanded = false;

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
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Vaccinations',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('${widget.items.length}',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                    color: const Color(0xFF374151),
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: widget.items
                    .map((item) => _buildVaccineItem(item))
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVaccineItem(Map<String, dynamic> item) {
    final name = item['itemName'] as String? ?? '-';
    final date = _formatDate(item['date'] as String?);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 3),
            decoration: const BoxDecoration(
                color: Color(0xFF10B981), shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(name,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500)),
          ),
          Text(date,
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF1339FF),
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
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
