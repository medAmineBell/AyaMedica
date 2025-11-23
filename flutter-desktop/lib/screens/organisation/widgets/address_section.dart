import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_getx_app/controllers/organization_controller.dart';
import 'form_fields/custom_text_field.dart';
import 'form_fields/custom_dropdown_field.dart';

class AddressSection extends StatelessWidget {
  final OrganizationController controller = Get.find();

  AddressSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
      children: [
        _buildFormRow(
          children: [
            CustomTextField(
              label: 'Headquarters',
              value: controller.organization.value.headquarters,
              onChanged: (value) => controller.updateField('headquarters', value),
              validator: (value) => value?.isEmpty ?? true ? 'Please enter headquarters' : null,
            ),
            CustomDropdownField(
              label: 'Country',
              value: controller.organization.value.country,
              items: controller.countries,
              onChanged: (value) => controller.updateField('country', value),
              validator: (value) => value == null ? 'Please select a country' : null,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildFormRow(
          children: [
            CustomTextField(
              label: 'Street address',
              value: controller.organization.value.streetAddress,
              onChanged: (value) => controller.updateField('streetAddress', value),
              validator: (value) => value?.isEmpty ?? true ? 'Please enter street address' : null,
            ),
            CustomDropdownField(
              label: 'Governorate',
              value: controller.organization.value.governorate,
              items: controller.governorates,
              onChanged: (value) => controller.updateField('governorate', value),
              validator: (value) => value == null ? 'Please select a governorate' : null,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildFormRow(
          children: [
            CustomDropdownField(
              label: 'City',
              value: controller.organization.value.city,
              items: controller.cities,
              onChanged: (value) => controller.updateField('city', value),
              validator: (value) => value == null ? 'Please select a city' : null,
            ),
            CustomDropdownField(
              label: 'Area',
              value: controller.organization.value.area,
              items: controller.areas,
              onChanged: (value) => controller.updateField('area', value),
              validator: (value) => value == null ? 'Please select an area' : null,
            ),
          ],
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
