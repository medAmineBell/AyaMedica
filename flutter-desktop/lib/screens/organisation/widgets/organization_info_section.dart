import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_getx_app/controllers/organization_controller.dart';
import 'form_fields/custom_text_field.dart';

class OrganizationInfoSection extends StatelessWidget {
  final OrganizationController controller = Get.find();

   OrganizationInfoSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Organization Name',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2D2E2E),
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          label: '',
          value: controller.organization.value.organizationName,
          onChanged: (value) => controller.updateField('organizationName', value),
          validator: (value) => value?.isEmpty ?? true ? 'Please enter organization name' : null,
          hintText: 'Enter organization name',
          
        ),
        const SizedBox(height: 16),
        const Text(
          'Headquarters',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2D2E2E),
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          label: '',
          value: controller.organization.value.headquarters,
          onChanged: (value) => controller.updateField('headquarters', value),
          validator: (value) => value?.isEmpty ?? true ? 'Please enter headquarters' : null,
          hintText: 'Enter headquarters',
        ),
      ],
    ));
  }
}
