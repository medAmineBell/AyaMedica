import 'package:flutter/material.dart';
import 'package:flutter_getx_app/screens/studentProfile/widgets/medication_category_card.dart';
import 'package:get/get.dart';
import '../../../../controllers/home_controller.dart';

class MedicationCategorySection extends StatelessWidget {
  final HomeController controller;

  const MedicationCategorySection({
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
            onTap: () => controller.isMedicationExpanded.toggle(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Medication category',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  Obx(() => Icon(
                        controller.isMedicationExpanded.value
                            ? Icons.expand_less
                            : Icons.expand_more,
                        color: const Color(0xFF374151),
                      )),
                ],
              ),
            ),
          ),

          // Expandable content
Obx(() => controller.isMedicationExpanded.value
    ? Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,

            mainAxisExtent:  316
          ),
          itemBuilder: (context, index) => MedicationCategoryCard(
                drugName: 'Paracetamol',
                activeIngredient: 'Active ingredient',
                route: 'Oral',
                dosage: 'x2',
                timing: 'After Dinner',
                duration: '4 days',
                frequency: 'Every 24 hours',
                startDate: '27/07/2025',
                endDate: '31/07/2025',
              ),
        ),
      )
    : const SizedBox.shrink()),

        ],
      ),
    );
  }
}