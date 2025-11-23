import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_getx_app/controllers/organization_controller.dart';

class TermsSection extends StatelessWidget {
  final OrganizationController controller = Get.find();

   TermsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Obx(
          () => Checkbox(
            value: controller.organization.value.acceptTerms,
            onChanged: (value) {
              controller.toggleTerms(value);
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'I agree to the ',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2D2E2E),
                  ),
                ),
                TextSpan(
                  text: 'Terms and Conditions',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1A73E8),
                    decoration: TextDecoration.underline,
                  ),
                ),
                TextSpan(
                  text: ' and ',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2D2E2E),
                  ),
                ),
                TextSpan(
                  text: 'Privacy Policy',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1A73E8),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
