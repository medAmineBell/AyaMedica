import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_getx_app/controllers/organization_controller.dart';
import 'package:flutter_getx_app/screens/auth/widgets/language_dropdown_widget.dart';

import 'widgets/profile_header.dart';
import 'widgets/organization_logo_section.dart';
import 'widgets/account_type_section.dart';
import 'widgets/role_position_section.dart';
import 'widgets/address_section.dart';
import 'widgets/organization_info_section.dart';
import 'widgets/terms_section.dart';
import 'widgets/form_action_buttons.dart';
import 'widgets/section_title.dart';

class CreateOrganizationScreen extends StatelessWidget {
  final OrganizationController controller = Get.put(OrganizationController());

  CreateOrganizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) => Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: Form(
                  key: controller.formKey,
                  child: Container(
                    width: 781,
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 64,
                      maxHeight: double.infinity,
                    ),
                    padding: const EdgeInsets.all(32),
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Obx(() => Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const ProfileHeader(),
                            LanguageDropdownWidget(),
                          ],
                        ),
                        const SizedBox(height: 32),
                        OrganizationLogoSection(),
                        const SizedBox(height: 32),
                        AccountTypeSection(),
                        SectionTitle(title: 'Account details'),
                        RolePositionSection(),
                        SectionTitle(title: 'Address details'),
                        AddressSection(),
                        OrganizationInfoSection(),
                        const SizedBox(height: 24),
                        TermsSection(),
                        const SizedBox(height: 32),
                        FormActionButtons(),
                        if (controller.errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text(
                              controller.errorMessage.value,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                      ],
                    )),
                  ),
                ),
              ),
            ),
          ),
        ),
      
    );
  }

}