import 'package:flutter/material.dart';
import 'package:flutter_getx_app/models/student.dart';
import 'package:get/get.dart';
import '../../../../controllers/home_controller.dart';
import 'guardian_section.dart';
import 'profile_section.dart';
import 'contact_details_section.dart';
import 'address_section.dart';
import 'additional_information_section.dart';

class ProfileFullContent extends StatelessWidget {
  final Student student;

  const ProfileFullContent({
    Key? key,
    required this.student,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Summarize Profile Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Guardian details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Guardian Information
            GuardianSection(student: student),

            const SizedBox(height: 32),

            // Profile Section
            ProfileSection(student: student),

            const SizedBox(height: 32),

            // Contact Details
            ContactDetailsSection(student: student),

            const SizedBox(height: 32),

            // Address
            AddressSection(student: student),

            const SizedBox(height: 32),

            // Additional Information
            AdditionalInformationSection(student: student),
          ],
        ),
      ),
    );
  }
}
