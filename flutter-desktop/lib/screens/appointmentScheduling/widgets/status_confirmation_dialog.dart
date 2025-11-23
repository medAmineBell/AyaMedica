// utils/dialogs/status_confirmation_dialog.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<bool?> showStatusChangeConfirmation({
  required bool isMarkingDone,
  required String studentName,
}) {
  final actionText = isMarkingDone ? 'mark this student as done' : 'mark this student as not done';
  final actionColor = isMarkingDone ? const Color(0xFF10B981) : const Color(0xFFDC2626);

  return Get.dialog<bool>(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 360, // smaller dialog width
        ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.help_outline, color: actionColor, size: 36),
            const SizedBox(height: 16),
            Text(
              'Are you sure?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Text(
              'Do you want to $actionText for "$studentName"?',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(result: false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Color(0xFFD1D5DB)),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(result: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: actionColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      isMarkingDone ? 'Mark as done' : 'Mark as not done',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    )),
    barrierDismissible: false,
  );
}
