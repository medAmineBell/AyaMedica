import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import 'package:country_flags/country_flags.dart';

class DynamicLoginFieldWidget extends StatelessWidget {
  final AuthController authController;

  const DynamicLoginFieldWidget({Key? key, required this.authController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      switch (authController.selectedLoginMethod.value) {
        case 'aid':
          return _buildAIDField();
        case 'phone':
          return _buildPhoneField();
        case 'email':
          return _buildEmailField();
        case 'nid_ppn':
          return _buildNIDField();
        default:
          return _buildPhoneField();
      }
    });
  }

  Widget _buildAIDField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'enter_aid'.tr,
          style: TextStyle(
            color: authController.isFieldInvalid.value 
                ? const Color(0xFFED1F4F) 
                : const Color(0xFF2D2E2E), 
            fontSize: 14, 
            fontWeight: FontWeight.w500
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: authController.isFieldInvalid.value 
                ? const Color(0xFFFBFCFD) 
                : Colors.transparent,
            border: Border.all(
              color: authController.isFieldInvalid.value 
                  ? const Color(0xFFED1F4F) 
                  : const Color(0xFFE9E9E9),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: authController.isFieldInvalid.value 
                ? [
                    const BoxShadow(
                      color: Color(0x0C101828),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                      spreadRadius: 0,
                    )
                  ] 
                : null,
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              const Icon(
                Icons.badge_outlined,
                color: Color(0xFF595A5B),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: authController.primaryFieldController,
                  keyboardType: TextInputType.text,
                  style: TextStyle(
                    color: authController.isFieldInvalid.value 
                        ? const Color(0xFFED1F4F)
                        : const Color(0xFF2D2E2E),
                    fontSize: 14,
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.w500,
                    height: 1.43,
                    letterSpacing: 0.28,
                  ),
                  decoration: InputDecoration(
                    hintText: 'aid_hint'.tr,
                    hintStyle: const TextStyle(
                      color: Color(0xFFA0A4A8),
                      fontSize: 14,
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
        _buildErrorMessage(),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'enter_phone_number'.tr,
          style: TextStyle(
            color: authController.isFieldInvalid.value 
                ? const Color(0xFFED1F4F) 
                : const Color(0xFF2D2E2E), 
            fontSize: 14, 
            fontWeight: FontWeight.w500
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: authController.isFieldInvalid.value 
                ? const Color(0xFFFBFCFD) 
                : Colors.transparent,
            border: Border.all(
              color: authController.isFieldInvalid.value 
                  ? const Color(0xFFED1F4F) 
                  : const Color(0xFFE9E9E9),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: authController.isFieldInvalid.value 
                ? [
                    const BoxShadow(
                      color: Color(0x0C101828),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                      spreadRadius: 0,
                    )
                  ] 
                : null,
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              // Country flag
              Container(
                child: CountryFlag.fromCountryCode(
                  authController.countryService.countryIsoCode.value,
                  height: 24,
                  width: 24,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                authController.countryService.countryCode.value,
                style: TextStyle(
                  color: authController.isFieldInvalid.value 
                        ? const Color(0xFFED1F4F) 
                        : const Color(0xFF2D2E2E),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              // Vertical divider
              Container(
                height: 24,
                width: 1,
                color: const Color(0xFFE9E9E9),
              ),
              const SizedBox(width: 8),
              // Phone number text
              Expanded(
                child: TextField(
                  controller: authController.primaryFieldController,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(
                    color: authController.isFieldInvalid.value 
                        ? const Color(0xFFED1F4F)
                        : const Color(0xFF2D2E2E),
                    fontSize: 14,
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.w500,
                    height: 1.43,
                    letterSpacing: 0.28,
                  ),
                  decoration: InputDecoration(
                    hintText: 'phone_hint'.tr,
                    hintStyle: const TextStyle(
                      color: Color(0xFFA0A4A8),
                      fontSize: 14,
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
        _buildErrorMessage(),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'enter_email'.tr,
          style: TextStyle(
            color: authController.isFieldInvalid.value 
                ? const Color(0xFFED1F4F) 
                : const Color(0xFF2D2E2E), 
            fontSize: 14, 
            fontWeight: FontWeight.w500
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: authController.isFieldInvalid.value 
                ? const Color(0xFFFBFCFD) 
                : Colors.transparent,
            border: Border.all(
              color: authController.isFieldInvalid.value 
                  ? const Color(0xFFED1F4F) 
                  : const Color(0xFFE9E9E9),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: authController.isFieldInvalid.value 
                ? [
                    const BoxShadow(
                      color: Color(0x0C101828),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                      spreadRadius: 0,
                    )
                  ] 
                : null,
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              const Icon(
                Icons.email_outlined,
                color: Color(0xFF595A5B),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: authController.primaryFieldController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(
                    color: authController.isFieldInvalid.value 
                        ? const Color(0xFFED1F4F)
                        : const Color(0xFF2D2E2E),
                    fontSize: 14,
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.w500,
                    height: 1.43,
                    letterSpacing: 0.28,
                  ),
                  decoration: InputDecoration(
                    hintText: 'email_hint'.tr,
                    hintStyle: const TextStyle(
                      color: Color(0xFFA0A4A8),
                      fontSize: 14,
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
        _buildErrorMessage(),
      ],
    );
  }

  Widget _buildNIDField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'enter_nid'.tr,
          style: TextStyle(
            color: authController.isFieldInvalid.value 
                ? const Color(0xFFED1F4F) 
                : const Color(0xFF2D2E2E), 
            fontSize: 14, 
            fontWeight: FontWeight.w500
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: authController.isFieldInvalid.value 
                ? const Color(0xFFFBFCFD) 
                : Colors.transparent,
            border: Border.all(
              color: authController.isFieldInvalid.value 
                  ? const Color(0xFFED1F4F) 
                  : const Color(0xFFE9E9E9),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: authController.isFieldInvalid.value 
                ? [
                    const BoxShadow(
                      color: Color(0x0C101828),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                      spreadRadius: 0,
                    )
                  ] 
                : null,
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              const Icon(
                Icons.credit_card_outlined,
                color: Color(0xFF595A5B),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: authController.primaryFieldController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    color: authController.isFieldInvalid.value 
                        ? const Color(0xFFED1F4F)
                        : const Color(0xFF2D2E2E),
                    fontSize: 14,
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.w500,
                    height: 1.43,
                    letterSpacing: 0.28,
                  ),
                  decoration: InputDecoration(
                    hintText: 'nid_hint'.tr,
                    hintStyle: const TextStyle(
                      color: Color(0xFFA0A4A8),
                      fontSize: 14,
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
        _buildErrorMessage(),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Obx(() => authController.isFieldInvalid.value
        ? Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              authController.fieldErrorMessage.value,
              style: const TextStyle(
                color: Color(0xFFED1F4F),
                fontSize: 14,
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.w500,
                height: 1.43,
                letterSpacing: 0.28,
              ),
            ),
          )
        : const SizedBox.shrink());
  }
}
