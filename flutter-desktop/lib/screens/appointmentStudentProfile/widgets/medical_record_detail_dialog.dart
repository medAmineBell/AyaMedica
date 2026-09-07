import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../config/app_config.dart';
import '../../../models/student.dart';

class MedicalRecordDetailDialog extends StatelessWidget {
  final Map<String, dynamic> record;
  final Student? student;

  const MedicalRecordDetailDialog({
    super.key,
    required this.record,
    this.student,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: _buildContent(),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: InkWell(
                borderRadius: BorderRadius.circular(100),
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4E9ED),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Icon(Icons.close, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final fullName = student?.name ?? '-';
    final grade = student?.grade ?? '';
    final studentClass = student?.className ?? '';
    final initials = fullName.split(' ').length >= 2
        ? '${fullName.split(' ')[0][0]}${fullName.split(' ')[1][0]}'.toUpperCase()
        : fullName.isNotEmpty
            ? fullName[0].toUpperCase()
            : '?';

    final rawDate = (record['effectiveDateTime'] as String?) ??
        (record['createdDate'] as String?) ??
        (record['date'] as String?);
    final formattedTime = _formatHeaderTime(rawDate);

    final specialtyRaw = (record['specialty'] as String?) ??
        (record['type'] as String?) ??
        (record['doctor_aid'] != null ? 'School' : 'General');
    final specialty = specialtyRaw.isNotEmpty
        ? '${specialtyRaw[0].toUpperCase()}${specialtyRaw.substring(1).toLowerCase()}'
        : '-';

    final clinicAddress = (record['clinicAddress'] as String?) ?? '';
    final doctorAid = (record['doctor_aid'] as String?) ??
        (record['doctorName'] as String?) ??
        (record['created_by_aid'] as String?) ??
        '';

    final signs = record['signs'] as Map<String, dynamic>?;
    final hasVitals =
        signs != null && signs.values.any((v) => v != null && '$v'.isNotEmpty);

    final assessment = record['assessment'] as Map<String, dynamic>? ?? {};
    final complaints = assessment['chief_complaints'] as List? ?? [];
    final examination = assessment['examination_details'] as String?;
    final diseases = assessment['suspected_diseases'] as List? ?? [];
    final recommendations = assessment['recommendation'] as List? ?? [];
    final note = (record['note'] as String?) ??
        (assessment['assessment_note'] as String?);

    final drugs = record['drugs'] as List? ?? [];
    final sickLeave = record['sick_leave'] as Map<String, dynamic>?;
    final attachments = record['attachments'] as List? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Student header
        if (student != null) ...[
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFC4A84E),
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(fullName,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  Text('$grade - $studentClass',
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF6B7280))),
                ],
              ),
              const Spacer(),
              const SizedBox(width: 40),
              Text(formattedTime,
                  style:
                      const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
              const SizedBox(width: 40),
            ],
          ),
          const SizedBox(height: 24),
        ],

        // Specialty
        Text(specialty,
            style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),

        // Created by
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Text('Created by',
                  style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
              const SizedBox(width: 16),
              const Icon(Icons.local_hospital,
                  size: 16, color: Color(0xFF2563EB)),
              const SizedBox(width: 6),
              Text(clinicAddress, style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 16),
              const Icon(Icons.medical_services,
                  size: 16, color: Color(0xFF6B7280)),
              const SizedBox(width: 6),
              Text(doctorAid, style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Vitals
        if (hasVitals) ...[
          _buildVitalsRow(
            signs['heart_rate'],
            signs['blood_pressure'],
            signs['temperature'],
            signs['respiratory_rate'],
            signs['blood_glucose'],
            signs['oxygen_saturation'],
            signs['height'],
            signs['weight'],
          ),
          const SizedBox(height: 24),
        ],

        // Chief complaint
        _buildSectionTitle('Chief complaint'),
        const SizedBox(height: 8),
        _buildInfoRow('Chief complaint',
            complaints.isNotEmpty ? complaints.join(', ') : '-'),
        _buildInfoRow('Examination details', examination ?? '-'),

        const SizedBox(height: 24),

        // Assessment
        _buildSectionTitle('Assessment'),
        const SizedBox(height: 8),
        _buildInfoRow('Suspected disease(s)',
            diseases.isNotEmpty ? diseases.join(', ') : '-'),
        _buildInfoRow('Recommendations(s)',
            recommendations.isNotEmpty ? recommendations.join(', ') : '-'),

        const SizedBox(height: 24),

        // Plan
        if (drugs.isNotEmpty) ...[
          _buildSectionTitle('Plan'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: drugs
                .map((d) => _buildDrugCard(d as Map<String, dynamic>))
                .toList(),
          ),
          const SizedBox(height: 24),
        ],

        // General Notes & sick leave
        _buildSectionTitle('General Notes & sick leave (if applicable)'),
        const SizedBox(height: 8),
        _buildInfoRow('General note', note ?? '-'),
        if (sickLeave != null)
          _buildInfoRow(
            'Sick leave details',
            '${sickLeave['days']} Days | From ${sickLeave['start_date'] ?? '-'} To ${_calcEndDate(sickLeave)}',
          ),

        // Attachments
        if (attachments.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildSectionTitle('Attachments'),
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
            itemBuilder: (context, index) =>
                _buildAttachmentTile(context, attachments[index].toString()),
          ),
        ],
      ],
    );
  }

  Widget _buildAttachmentTile(BuildContext context, String rawUrl) {
    final fullUrl = _resolveAttachmentUrl(rawUrl);
    final isImage = _isImage(fullUrl);
    final filename = _filenameOf(rawUrl);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () => _openAttachment(context, rawUrl),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: isImage
              ? Image.network(
                  fullUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: const Color(0xFFD9D9D9),
                      child: const Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFD9D9D9),
                    child: const Center(
                      child: Icon(Icons.broken_image_outlined,
                          color: Color(0xFF9CA3AF), size: 32),
                    ),
                  ),
                )
              : Container(
                  color: const Color(0xFFD9D9D9),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.picture_as_pdf,
                          color: Color(0xFFEF4444), size: 32),
                      const SizedBox(height: 6),
                      Text(
                        filename,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  static String _resolveAttachmentUrl(String raw) {
    if (raw.isEmpty) return raw;
    if (raw.startsWith('http')) return raw;
    if (raw.startsWith('gcs:')) {
      return '${AppConfig.newBackendUrl}/api/files/gcs/${raw.substring(4)}';
    }
    return '${AppConfig.newBackendUrl}${raw.startsWith('/') ? '' : '/'}$raw';
  }

  static bool _isImage(String url) {
    final ext = url.split('?').first.split('.').last.toLowerCase();
    return const ['png', 'jpg', 'jpeg', 'gif', 'webp', 'bmp'].contains(ext);
  }

  static String _filenameOf(String rawUrl) {
    final tail = rawUrl.split('?').first.split('/').last;
    if (tail.isEmpty) return 'Attachment';
    try {
      return Uri.decodeComponent(tail);
    } catch (_) {
      return tail;
    }
  }

  Future<void> _openAttachment(BuildContext context, String rawUrl) async {
    final fullUrl = _resolveAttachmentUrl(rawUrl);
    if (_isImage(fullUrl)) {
      _showImagePreview(context, fullUrl, _filenameOf(rawUrl));
    } else {
      final uri = Uri.tryParse(fullUrl);
      if (uri != null) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  void _showImagePreview(BuildContext context, String url, String title) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: const BoxDecoration(
                  border:
                      Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, size: 20),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: InteractiveViewer(
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.broken_image_outlined,
                                size: 48, color: Color(0xFF9CA3AF)),
                            SizedBox(height: 8),
                            Text('Failed to load image',
                                style: TextStyle(color: Color(0xFF6B7280))),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVitalsRow(
    dynamic heartRate,
    dynamic bloodPressure,
    dynamic temperature,
    dynamic respiratoryRate,
    dynamic bloodGlucose,
    dynamic oxygenSaturation,
    dynamic height,
    dynamic weight,
  ) {
    final vitals = [
      {
        'title': 'Heart Rate',
        'value': heartRate?.toString() ?? '-',
        'svg': 'assets/svg/heart_rate_01.svg'
      },
      {
        'title': 'Blood Pressure',
        'value': bloodPressure?.toString() ?? '-',
        'svg': 'assets/svg/blood_pressure_02.svg'
      },
      {
        'title': 'Temperature',
        'value': temperature?.toString() ?? '-',
        'svg': 'assets/svg/blood_pressure_01.svg'
      },
      {
        'title': 'Respiratory Rate',
        'value': respiratoryRate?.toString() ?? '-',
        'svg': 'assets/svg/lungs.svg'
      },
      {
        'title': 'Blood Glucose',
        'value': bloodGlucose?.toString() ?? '-',
        'svg': 'assets/svg/blood_glucose.svg'
      },
      {
        'title': 'Oxygen Saturation',
        'value': oxygenSaturation != null ? '$oxygenSaturation%' : '-',
        'svg': 'assets/svg/Heading.svg'
      },
      {
        'title': 'Height & weight',
        'value': '${height ?? '-'} / ${weight ?? '-'}',
        'svg': 'assets/svg/weight.svg'
      },
    ];

    return Row(
      children: vitals
          .map((v) => Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE4E9ED)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      SvgPicture.asset(v['svg']!,
                          width: 22,
                          height: 22,
                          colorFilter: const ColorFilter.mode(
                              Color(0xFF1339FF), BlendMode.srcIn)),
                      const SizedBox(height: 4),
                      Text(v['title']!,
                          style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFFA6A9AC),
                              fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: const Color(0xFFE4E9ED), width: 0.5),
                        ),
                        child: Text(v['value']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Color(0xFF2D2E2E),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
          const SizedBox(width: 24),
          Flexible(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827)),
                textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }

  Widget _buildDrugCard(Map<String, dynamic> drug) {
    final name = drug['drug_name'] as String? ?? '{Drug name}';
    final ingredient = drug['drug_active_ingredient'] as String? ?? '-';
    final form = drug['drug_administration_form'] as String? ?? '';
    final foodRelation = drug['drug_relation_to_food'];
    final timing = foodRelation is List
        ? foodRelation.join(', ')
        : foodRelation?.toString() ?? '-';
    final dose = drug['dose']?.toString() ?? '-';
    final doseType = drug['dose_type']?.toString() ?? '';
    final drugNote = drug['drug_note'] as String?;
    final days = drug['drug_days']?.toString() ?? '-';
    final hours = drug['drug_hours']?.toString() ?? '-';
    final startDate = drug['drug_start_date']?.toString() ?? '-';
    final endDate = drug['drug_end_date']?.toString() ?? '-';

    return Container(
      width: 220,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFCFD),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              _pill(ingredient),
              if (form.isNotEmpty) _pill(form),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$dose $doseType',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF595A5B)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    Text(timing,
                        style: const TextStyle(
                            fontSize: 10, color: Color(0xFF747677)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('$days days',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF595A5B))),
                  Text('Every $hours hours',
                      style: const TextStyle(
                          fontSize: 10, color: Color(0xFF747677))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEDF1F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _dateCol('Starting date', _formatDate(startDate)),
                _dateCol('End date', _formatDate(endDate)),
              ],
            ),
          ),
          if (drugNote != null && drugNote.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(drugNote,
                style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF747677),
                    fontStyle: FontStyle.italic),
                maxLines: 3,
                overflow: TextOverflow.ellipsis),
          ],
        ],
      ),
    );
  }

  Widget _pill(String text) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 180),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFEDF1F5),
          borderRadius: BorderRadius.circular(64),
        ),
        child: Text(text,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF595A5B)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ),
    );
  }

  Widget _dateCol(String label, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 10, color: Color(0xFF747677))),
        Text(date,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1339FF))),
      ],
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty || dateStr == '-') return '-';
    try {
      final d = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(d);
    } catch (_) {
      return dateStr;
    }
  }

  String _formatHeaderTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final d = DateTime.parse(dateStr);
      final now = DateTime.now();
      final isToday =
          d.year == now.year && d.month == now.month && d.day == now.day;
      return isToday
          ? 'Today at ${DateFormat('hh:mm a').format(d)}'
          : DateFormat('dd/MM/yyyy \'at\' hh:mm a').format(d);
    } catch (_) {
      return dateStr;
    }
  }

  String _calcEndDate(Map<String, dynamic> sickLeave) {
    final startStr = sickLeave['start_date'] as String?;
    final days = sickLeave['days'] as int? ?? 0;
    if (startStr == null) return '-';
    try {
      final start = DateTime.parse(startStr);
      final end = start.add(Duration(days: days));
      return DateFormat('dd/MM/yyyy').format(end);
    } catch (_) {
      return '-';
    }
  }
}
