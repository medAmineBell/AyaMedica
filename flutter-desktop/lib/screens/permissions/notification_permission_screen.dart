import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_getx_app/controllers/permissions_controller.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_getx_app/theme/app_typography.dart';

class NotificationPermissionScreen extends StatelessWidget {
  final PermissionsController controller = Get.put(PermissionsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // SVG Illustration
                    SvgPicture.asset(
                      'assets/svg/enable_notifications.svg',
                      height: 200,
                      width: 200,
                    ),

                    const SizedBox(height: 48),

                    // Title
                    const Text(
                      'Enable notifications',
                      style: AppTypography.heading3,
                    ),

                    const SizedBox(height: 16),

                    // Description
                    Text(
                      'We\'ll only send you relevant and timely notifications to enhance your experience. Let\'s stay connected',
                      style: AppTypography.bodyMediumRegular.copyWith(
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            // Enable notifications button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.requestNotificationPermission,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D6EFD),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Enable notifications',
                    style: AppTypography.bodyMediumSemibold,
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
