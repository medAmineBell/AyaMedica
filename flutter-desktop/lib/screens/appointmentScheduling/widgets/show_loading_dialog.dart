import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/loading_dialog_controller.dart';
import 'package:get/get.dart';

Future<void> showLoadingDialog({
  String title = 'Sending notifications..',
  String message = 'Please wait, we are notifying parents about this appointment',
  IconData icon = Icons.notifications_outlined,
  Color iconColor = const Color(0xFF1339FF),
  Color progressColor = const Color(0xFF00C447),
  Color progressBackgroundColor = const Color(0xFFD8FAE4),
  required Future<void> Function(LoadingDialogController) onProgress, // Changed to required
}) async {
  // Create a dedicated controller for this dialog instance
  final controller = Get.put(LoadingDialogController(), tag: 'loadingDialog');
  controller.reset(); // Reset progress to 0

  // Show the dialog
  Get.dialog(
    Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon container
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: iconColor.withOpacity(0.1),
                      ),
                      child: Icon(icon, size: 32, color: iconColor),
                    ),
                    const SizedBox(height: 24),
                    
                    // Title and message
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF2D2E2E),
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        height: 1.29,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF858789),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.43,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Progress Bar Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              // Background progress bar
                              Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: progressBackgroundColor,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              // Animated progress bar
                              Obx(() => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: MediaQuery.of(Get.context!).size.width * 0.7 * controller.progress.value,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: progressColor,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              )),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Obx(() => Text(
                          controller.progressText.value,
                          style: const TextStyle(
                            color: Color(0xFF2D2E2E),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        )),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    barrierDismissible: false,
    name: 'loadingDialog',
  );
  
  // Execute the progress callback
  await onProgress(controller);
  
  // Close the dialog when done
  if (Get.isDialogOpen == true) {
    Get.back();
  }
  
  // Remove the controller
  Get.delete<LoadingDialogController>(tag: 'loadingDialog');
}