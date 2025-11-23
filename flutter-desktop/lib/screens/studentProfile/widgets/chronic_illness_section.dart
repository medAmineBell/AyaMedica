import 'package:flutter/material.dart';
import 'package:flutter_getx_app/screens/studentProfile/widgets/medical_card.dart';
import 'package:get/get.dart';
import '../../../../controllers/home_controller.dart';
import 'profile_field.dart';
import 'uploaded_file_card.dart';

class ChronicIllnessSection extends StatelessWidget {
  final HomeController controller;

  const ChronicIllnessSection({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Expandable Header
          InkWell(
            onTap: () => controller.isChronicExpanded.toggle(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Chronic illnesses',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  Obx(() => Icon(
                        controller.isChronicExpanded.value
                            ? Icons.expand_less
                            : Icons.expand_more,
                        color: const Color(0xFF374151),
                      )),
                ],
              ),
            ),
          ),

          // Expandable content
Obx(() => controller.isChronicExpanded.value
    ? Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 9,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,

            mainAxisExtent:  316
          ),
          itemBuilder: (context, index) => const MedicalCard(),
        ),
      )
    : const SizedBox.shrink()),

        ],
      ),
    );
  }
}