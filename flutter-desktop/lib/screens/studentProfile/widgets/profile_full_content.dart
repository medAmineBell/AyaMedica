import 'package:flutter/material.dart';
import 'package:flutter_getx_app/models/student.dart';
import 'package:get/get.dart';
import '../../../../controllers/home_controller.dart';
import 'guardian_section.dart';
import 'profile_section.dart';
import 'contact_details_section.dart';
import 'address_section.dart';
import 'health_insurance_section.dart';
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
                ElevatedButton(
                  onPressed: () {
                    homeController.isSummaryMode.toggle();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Summarize profile',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          size: 10,
                          color: Color(0xFF8B5CF6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Guardian Information
            const GuardianSection(),
            
            const SizedBox(height: 32),
            
            // Profile Section
            ProfileSection(student: student),
            
            const SizedBox(height: 32),
            
            // Contact Details
            const ContactDetailsSection(),
            
            const SizedBox(height: 32),
            
            // Address
            const AddressSection(),
            
            const SizedBox(height: 32),
            
            // Health Insurance Details
            const HealthInsuranceSection(),
            
            const SizedBox(height: 32),
            
            // Additional Information
            const AdditionalInformationSection(),
          ],
        ),
      ),
    );
  }
}