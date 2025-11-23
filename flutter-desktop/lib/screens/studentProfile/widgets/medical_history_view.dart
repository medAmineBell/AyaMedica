import 'package:flutter/material.dart';
import 'package:flutter_getx_app/models/student.dart';
import 'package:flutter_getx_app/screens/studentProfile/widgets/medication_category_section.dart';
import 'package:get/get.dart';
import '../../../../controllers/home_controller.dart';
import 'medical_history_header.dart';
import 'expandable_section.dart';
import 'chronic_illness_section.dart';

class MedicalHistoryView extends StatelessWidget {
  final Student student;

  const MedicalHistoryView({
    Key? key,
    required this.student,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MedicalHistoryHeader(),
        const SizedBox(height: 24),
        const ExpandableSection(title: 'Previous surgeries'),
              const SizedBox(height: 12),
       SingleChildScrollView(
  child: MedicationCategorySection(controller: controller),
),
        const SizedBox(height: 12),
       SingleChildScrollView(
  child: ChronicIllnessSection(controller: controller),
),

        const SizedBox(height: 12),
        const ExpandableSection(title: 'Chronic illnesses'),
        const SizedBox(height: 12),
        const ExpandableSection(title: 'Previous surgeries'),
      ],
    );
  }
}