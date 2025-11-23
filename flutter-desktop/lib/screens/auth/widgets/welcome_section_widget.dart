import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WelcomeSectionWidget extends StatelessWidget {
  const WelcomeSectionWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'welcome_title'.tr,
          style: const TextStyle(
            color: Color(0xFF2D2E2E), // textPrimary
            fontSize: 20,
            fontFamily: 'IBM Plex Sans Arabic',
            fontWeight: FontWeight.w700,
            height: 1.40,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'welcome_subtitle'.tr,
          style: const TextStyle(
            color: Color(0xFF858789), // textTertiary
            fontSize: 12,
            fontFamily: 'IBM Plex Sans Arabic',
            fontWeight: FontWeight.w400,
            height: 1.33,
          ),
        ),
      ],
    );
  }
}