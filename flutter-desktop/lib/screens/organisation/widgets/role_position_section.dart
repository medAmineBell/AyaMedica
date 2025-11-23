import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_getx_app/controllers/organization_controller.dart';
import 'form_fields/custom_dropdown_field.dart';

class RolePositionSection extends StatelessWidget {
  final OrganizationController controller = Get.find();

  RolePositionSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => _buildFormRow(
      children: [
        CustomDropdownField(
          label: 'Role / Position',
          value: controller.organization.value.role,
          items: controller.roles,
          onChanged: (value) => controller.updateField('role', value),
          validator: (value) => value == null ? 'Please select a role' : null,
        ),
        CustomDropdownField(
          label: 'Education type',
          value: controller.organization.value.educationType,
          items: controller.educationTypes,
          onChanged: (value) => controller.updateField('educationType', value),
          validator: (value) => value == null ? 'Please select education type' : null,
        ),
      ],
    ));
  }

  Widget _buildFormRow({required List<Widget> children}) {
    return Row(
      children: [
        Expanded(child: children[0]),
        const SizedBox(width: 32),
        Expanded(child: children[1]),
      ],
    );
  }
}
