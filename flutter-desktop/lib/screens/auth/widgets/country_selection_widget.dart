import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart'; // Import AuthController
import 'package:country_flags/country_flags.dart'; // Import the country_flags package for Flag widget

class CountrySelectionWidget extends StatelessWidget {
  final AuthController authController; // Receive AuthController

  const CountrySelectionWidget({Key? key, required this.authController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Only show country picker when phone is selected
      if (authController.selectedLoginMethod.value != 'phone') {
        return const SizedBox.shrink();
      }
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'select_country'.tr,
            style: const TextStyle(color: Color(0xFF2D2E2E), fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          // Wrap with GestureDetector to open the country picker
          GestureDetector(
            onTap: () => authController.countryService.showCountryPicker(),
            child: Container(
              height: 48, // Placeholder height
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE9E9E9)),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Obx(() => Row(
                children: [
                  // Use Flag.fromCountryCode for displaying the flag
                  CountryFlag.fromCountryCode(
                    authController.countryService.countryIsoCode.value, // Use ISO code
                    height: 24, // Match placeholder height
                    width: 24, // Match placeholder width
                  ),
                  const SizedBox(width: 8),
                  Text(
                    authController.countryService.countryName.value, // Display selected country name
                    style: TextStyle(color: const Color(0xFF2D2E2E)),
                  ), // Placeholder text
                  const Spacer(),
                  const Icon(Icons.arrow_drop_down),
                ],
              )),
            ),
          ),
        ],
      );
    });
  }
} 