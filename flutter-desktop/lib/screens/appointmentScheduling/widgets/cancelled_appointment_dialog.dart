import 'package:flutter/material.dart';

class CancelledAppointmentDialog extends StatelessWidget {
  final String status;
  final String? reason;

  const CancelledAppointmentDialog({
    Key? key,
    required this.status,
    this.reason,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context, {
    required String status,
    String? reason,
  }) {
    return showDialog(
      context: context,
      builder: (_) => CancelledAppointmentDialog(status: status, reason: reason),
    );
  }

  bool get _isExpired => status.toLowerCase() == 'expired';

  @override
  Widget build(BuildContext context) {
    final accent = _isExpired
        ? const Color(0xFFD97706)
        : const Color(0xFFEF4444);
    final title = _isExpired ? 'Appointment expired' : 'Appointment cancelled';
    final icon = _isExpired ? Icons.schedule : Icons.cancel_outlined;

    final trimmedReason = reason?.trim() ?? '';
    final body = _isExpired
        ? 'This appointment has expired and can no longer be modified.'
        : (trimmedReason.isNotEmpty ? trimmedReason : 'No reason provided.');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 460,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: accent),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            if (!_isExpired)
              const Text(
                'Cancellation reason',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
            if (!_isExpired) const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Text(
                body,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF374151),
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
