import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_getx_app/controllers/permissions_controller.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_getx_app/theme/app_typography.dart';

class LocationPermissionScreen extends StatelessWidget {
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
                      'assets/svg/enable_location.svg',
                      height: 200,
                      width: 200,
                    ),

                    const SizedBox(height: 48),

                    // Title
                    Text(
                      'Enable location',
                      style: AppTypography.heading3,
                    ),

                    const SizedBox(height: 16),

                    // Description
                    Text(
                      'We\'ll only use your location to provide personalized recommendations tailored to your area. Let\'s get started by enabling location services.',
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

            // Enable location button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.requestLocationPermission,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D6EFD),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    'Enable location',
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
