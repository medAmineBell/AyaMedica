import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MedicalRecordDetailDialog extends StatelessWidget {
  final Map<String, dynamic> record;

  const MedicalRecordDetailDialog({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        constraints: const BoxConstraints(maxWidth: 800),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE4E9ED),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Icon(Icons.close, size: 20),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(height: 24),
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildCreatedBySection(),
                const SizedBox(height: 24),
                _buildRecordDetailsSection(),
                const SizedBox(height: 24),
                _buildDrugsSection(),
                const SizedBox(height: 24),
                _buildAttachmentsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final createdDate = _formatDateTime(record['createdDate'] as String?);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Medical record details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D2E2E),
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14),
                const SizedBox(width: 4),
                Text(
                  createdDate,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF707579),
                      ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(width: 100, height: 40),
      ],
    );
  }

  Widget _buildCreatedBySection() {
    final doctorName = record['doctorName'] as String? ?? '-';
    final clinicAddress = record['clinicAddress'] as String? ?? '-';
    final date = _formatDateTime(record['date'] as String?);
    final createdByAid = record['created_by_aid'] as String? ?? '-';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Created by',
          style: TextStyle(
            color: Color(0xFF747677),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        _buildHistoryItem(
          avatarColor: const Color(0xFFD8FAE4),
          name: createdByAid,
          date: _formatDateTime(record['createdDate'] as String?),
        ),
        _buildHistoryItem(
          avatarColor: const Color(0xFFCDF7FF),
          name: doctorName,
          date: date,
        ),
        _buildInfoRow('Appointment date', date),
        _buildInfoRow('Clinic / School details', doctorName),
        _buildInfoRow('Address', clinicAddress),
      ],
    );
  }

  Widget _buildRecordDetailsSection() {
    final type = record['type'] as String? ?? '-';
    final specialty = record['specialty'] as String? ?? type;
    final assessment = record['assessment'] as Map<String, dynamic>?;

    final complaints = assessment?['chief_complaints'] as List?;
    final examination = assessment?['examination_details'] as String?;
    final diseases = assessment?['suspected_diseases'] as List?;
    final recommendations = assessment?['recommendation'] as List?;
    final assessmentNote = assessment?['assessment_note'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Record details',
          style: TextStyle(
            color: Color(0xFF747677),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        _buildInfoRow('Type', specialty),
        if (complaints != null && complaints.isNotEmpty)
          _buildInfoRow('Chief Complaints', complaints.join(', ')),
        if (examination != null && examination.isNotEmpty)
          _buildInfoRow('Examination', examination),
        if (diseases != null && diseases.isNotEmpty)
          _buildInfoRow('Suspected Diseases', diseases.join(', ')),
        if (recommendations != null && recommendations.isNotEmpty)
          _buildInfoRow('Recommendation', recommendations.join(', ')),
        if (assessmentNote != null && assessmentNote.isNotEmpty)
          _buildInfoRow('Note', assessmentNote),
      ],
    );
  }

  Widget _buildDrugsSection() {
    final drugs = record['drugs'] as List?;
    if (drugs == null || drugs.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Drugs details',
          style: TextStyle(
            color: Color(0xFF747677),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.start,
          children: drugs.map((drug) {
            return SizedBox(
              width: 240,
              child: _buildDrugCard(drug as Map<String, dynamic>),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDrugCard(Map<String, dynamic> drug) {
    final name = drug['drug_name'] as String? ?? '-';
    final ingredient = drug['drug_active_ingredient'] as String? ?? '-';
    final form = drug['drug_administration_form'] as String? ?? '-';
    final hours = drug['drug_hours'] as String? ?? '-';
    final days = drug['drug_days'] as String? ?? '-';
    final startDate = drug['drug_start_date'] as String? ?? '-';
    final endDate = drug['drug_end_date'] as String? ?? '-';

    // drug_relation_to_food can be a list or string
    final foodRelation = drug['drug_relation_to_food'];
    final timing = foodRelation is List
        ? foodRelation.join(', ')
        : foodRelation?.toString() ?? '-';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFCFD),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D2E2E),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _buildDrugTag(ingredient),
              _buildDrugTag(form),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hours != '-' ? 'Every $hours hrs' : '-',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF595A5B),
                    ),
                  ),
                  Text(
                    timing,
                    style: const TextStyle(
                      color: Color(0xFF747677),
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    days != '-' ? '$days days' : '-',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF595A5B),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEDF1F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDateInfo('Starting date', startDate),
                _buildDateInfo('End date', endDate),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentsSection() {
    final attachments = record['attachments'] as List?;
    if (attachments == null || attachments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Attachments',
          style: TextStyle(
            color: Color(0xFF747677),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: attachments.length,
          itemBuilder: (context, index) => Container(
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Center(
              child: Icon(Icons.image, color: Color(0xFF9CA3AF), size: 32),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryItem({
    required Color avatarColor,
    required String name,
    required String date,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1, color: Color(0xFFDCE0E4)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: avatarColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, size: 16),
              ),
              const SizedBox(width: 8),
              Text(name),
            ],
          ),
          Text(
            date,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D2E2E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1, color: Color(0xFFDCE0E4)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF595A5B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 24),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF2D2E2E),
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrugTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF1F5),
        borderRadius: BorderRadius.circular(64),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF595A5B),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildDateInfo(String title, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF747677),
            fontSize: 10,
          ),
        ),
        Text(
          date,
          style: const TextStyle(
            color: Color(0xFF1339FF),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  String _formatDateTime(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final d = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy | hh:mm a').format(d);
    } catch (_) {
      return dateStr;
    }
  }
}
