import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../config/app_config.dart';
import '../../../controllers/clinic_visits_controller.dart';
import '../../../models/clinic_visit_row.dart';

class ClinicVisitsTableWidget extends StatelessWidget {
  const ClinicVisitsTableWidget({super.key});

  static const _avatarColors = [
    Color(0xFF1339FF),
    Color(0xFF10B981),
    Color(0xFF8B5CF6),
    Color(0xFFEF4444),
    Color(0xFFF59E0B),
    Color(0xFF06B6D4),
  ];

  Map<int, TableColumnWidth> get _columnWidths => const {
        0: FlexColumnWidth(2.0), // Student full name
        1: FlexColumnWidth(1.2), // Grade & Class
        2: FlexColumnWidth(0.6), // Cases
        3: FlexColumnWidth(1.5), // Date & time
        4: FlexColumnWidth(0.9), // App. type
        5: FlexColumnWidth(1.3), // Disease
        6: FlexColumnWidth(1.3), // Doctor
        7: FlexColumnWidth(1.4), // Status
      };

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ClinicVisitsController>();

    return Obx(() {
      final rows = controller.displayedRows;

      if (rows.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text(
                'No appointment records',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text(
                'There is no available appointment records, please refresh or\ncontact school appointments manager',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Table(
              columnWidths: _columnWidths,
              children: [
                TableRow(
                  children: [
                    _headerCell('Student full name'),
                    _headerCell('Grade & Class'),
                    _headerCell('Cases'),
                    _headerCellWithIcon('Date & time'),
                    _headerCell('App. type'),
                    _headerCell('Disease'),
                    _headerCellWithIcon('Doctor'),
                    _headerCell('Status'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Table(
                columnWidths: _columnWidths,
                children: rows.map(_buildRow).toList(),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _headerCell(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF64748B),
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _headerCellWithIcon(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.help_outline, size: 14, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  TableRow _buildRow(ClinicVisitRow row) {
    return TableRow(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
      ),
      children: [
        _nameCell(row),
        _textCell(row.gradeAndClass),
        _casesCell(row.cases),
        _textCell(row.dateTimeFormatted),
        _textCell(row.formattedType),
        _textCell(row.disease),
        _textCell((row.doctor == null || row.doctor!.isEmpty) ? '--' : row.doctor!),
        _statusCell(row),
      ],
    );
  }

  String? _resolvePhotoUrl(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final uri = Uri.tryParse(raw);
    if (uri != null && uri.hasScheme && uri.host.isNotEmpty) return raw;
    final base = AppConfig.newBackendUrl;
    if (raw.startsWith('/')) return '$base$raw';
    return '$base/$raw';
  }

  Widget _nameCell(ClinicVisitRow row) {
    final colorIndex = row.studentName.hashCode.abs() % _avatarColors.length;
    final avatarColor = _avatarColors[colorIndex];
    final photoUrl = _resolvePhotoUrl(row.studentPhotoUrl);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: avatarColor,
            backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
            child: photoUrl == null
                ? Text(
                    row.initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.studentName.isEmpty ? '--' : row.studentName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (row.studentAid.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    row.studentAid,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _textCell(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, color: Color(0xFF475569)),
      ),
    );
  }

  Widget _casesCell(int cases) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      alignment: Alignment.centerLeft,
      child: Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: Color(0xFFE0E7FF),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          '$cases',
          style: const TextStyle(
            color: Color(0xFF1339FF),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _statusCell(ClinicVisitRow row) {
    final isCanceled = row.displayStatus == 'Canceled';
    final isClickable = isCanceled && row.hasCancellationReason;

    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: row.displayStatusBgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isCanceled) ...[
            Icon(Icons.error_outline,
                size: 14, color: row.displayStatusColor),
            const SizedBox(width: 4),
          ],
          Text(
            row.displayStatus,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: row.displayStatusColor,
            ),
          ),
          if (isClickable) ...[
            const SizedBox(width: 4),
            Icon(Icons.info_outline,
                size: 12, color: row.displayStatusColor),
          ],
        ],
      ),
    );

    if (!isClickable) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        alignment: Alignment.centerLeft,
        child: pill,
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showCancellationReasonDialog(row),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          alignment: Alignment.centerLeft,
          child: pill,
        ),
      ),
    );
  }

  void _showCancellationReasonDialog(ClinicVisitRow row) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: row.displayStatusBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.error_outline,
                        size: 20, color: row.displayStatusColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${row.displayStatus} visit',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                        ),
                        if (row.studentName.isNotEmpty)
                          Text(
                            row.studentName,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    color: const Color(0xFF6B7280),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Reason',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Text(
                  row.cancellationReason!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1339FF),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 10),
                  ),
                  child: const Text('Close',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
