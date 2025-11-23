import 'package:flutter/material.dart';

class ParentsNotificationDialog extends StatelessWidget {
  final VoidCallback onDismiss;

  const ParentsNotificationDialog({
    Key? key,
    required this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon section (empty stack placeholder, can be customized)
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.notifications_active_outlined,
                color: Color(0xFF2D2E2E),
                size: 28,
              ),
            ),

            const SizedBox(height: 24),

            // Title
            const Text(
              'Parents notification',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF2D2E2E), // Text-Text-100
                fontSize: 28,
                fontWeight: FontWeight.w700,
                fontFamily: 'IBM Plex Sans Arabic',
                height: 1.29,
                letterSpacing: -0.14,
              ),
            ),

            const SizedBox(height: 16),

            // Message
            const Text(
              'Parents will be notified when you create the Vaccination appointment. '
              'Parents have to approve the request in order to proceed.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF858789), // Text-Text-70
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: 'IBM Plex Sans Arabic',
                height: 1.43,
              ),
            ),

            const SizedBox(height: 32),

            // Dismiss Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onDismiss,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(
                    color: Color(0xFFA6A9AC), // Stroke-Stroke-60
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Dismiss',
                  style: TextStyle(
                    color: Color(0xFF747677), // Text-Text-80
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'IBM Plex Sans Arabic',
                    letterSpacing: 0.28,
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
