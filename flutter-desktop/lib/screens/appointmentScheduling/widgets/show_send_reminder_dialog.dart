import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<bool?> showSendReminderDialog({
  String title = 'Send reminder?',
  String message = 'Parents will be be notified about the appointment to approve ',
  String dismissText = 'Dismiss',
  String confirmText = 'Send Reminder',
  IconData icon = Icons.notifications_outlined,
  Color iconColor = const Color(0xFF1339FF),
  Color confirmButtonColor = const Color(0xFF1339FF),
  Color confirmTextColor = const Color(0xFFCDF7FF),
  VoidCallback? onDismiss,
Future<void> Function()? onConfirm,}) {
  return Get.dialog<bool>(
    Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 440,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 396,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Icon container
                          Container(
                            width: 56,
                            height: 56,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: iconColor.withOpacity(0.1),
                            ),
                            child: Icon(
                              icon,
                              size: 32,
                              color: iconColor,
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          Container(
                            width: double.infinity,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 396,
                                  child: Text(
                                    title,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: const Color(0xFF2D2E2E),
                                      fontSize: 28,
                                      fontFamily: 'IBM Plex Sans Arabic',
                                      fontWeight: FontWeight.w700,
                                      height: 1.29,
                                      letterSpacing: -0.14,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: 396,
                                  child: Text(
                                    message,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: const Color(0xFF858789),
                                      fontSize: 14,
                                      fontFamily: 'IBM Plex Sans Arabic',
                                      fontWeight: FontWeight.w400,
                                      height: 1.43,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (onDismiss != null) {
                            onDismiss();
                          }
                          Get.back(result: false);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          clipBehavior: Clip.antiAlias,
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 1,
                                color: const Color(0xFFA6A9AC),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            shadows: [
                              BoxShadow(
                                color: Color(0x0C101828),
                                blurRadius: 2,
                                offset: Offset(0, 1),
                                spreadRadius: 0,
                              )
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                dismissText,
                                style: TextStyle(
                                  color: const Color(0xFF747677),
                                  fontSize: 14,
                                  fontFamily: 'IBM Plex Sans Arabic',
                                  fontWeight: FontWeight.w500,
                                  height: 1.43,
                                  letterSpacing: 0.28,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                     Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: confirmButtonColor,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                        ),
                      
                      onPressed: () async {
                        if (onConfirm != null) {
                          await onConfirm(); // Await the async operation
                        }
                        Get.back(result: true); // Close dialog AFTER async operation
                      },
                      child: Text(
                        confirmText,
                        style: TextStyle(
                          color: confirmTextColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),)
            ],
          ),
        ),
      ),
    ),
    barrierDismissible: false,
  );
}