import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:flutter_getx_app/controllers/organization_controller.dart';
import 'form_fields/custom_dropdown_field.dart';
import 'form_fields/custom_text_field.dart';

class AccountTypeSection extends StatelessWidget {
  final OrganizationController controller = Get.find();

  AccountTypeSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Account type',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2D2E2E),
                ),
              ),
              
              Obx(
                () => CustomDropdownField(
                  label: '',
                  value: controller.organization.value.accountType,
                  items: controller.accountTypes,
                  onChanged: (value) {
                    controller.updateField('accountType', value);
                  },
                  validator: (value) => value == null ? 'Please select an account type' : null,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
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
              
              Obx(
                () => CustomTextField(
                  label: '',
                  value: controller.organization.value.organizationName,
                  onChanged: (value) => controller.updateField('organizationName', value),
                  validator: (value) => value?.isEmpty ?? true ? 'Please enter organization name' : null,
                  hintText: 'Enter organization name',
                  prefixIcon: SvgPicture.asset("assets/svg/organization.svg",width: 12,),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}