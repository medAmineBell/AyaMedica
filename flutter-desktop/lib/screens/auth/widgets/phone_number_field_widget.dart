import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import 'package:country_flags/country_flags.dart';

class PhoneNumberFieldWidget extends StatelessWidget {
  final AuthController authController;

  const PhoneNumberFieldWidget({Key? key, required this.authController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        Obx(() => Container(
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
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
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
                style:  TextStyle(
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
                  decoration:  InputDecoration(
                    hintText: 'phone_hint'.tr,
                    hintStyle: TextStyle(
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
        )),
        // Error message (only shows when there's an error)
        Obx(() => authController.isFieldInvalid.value
            ? Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'phone_not_exist'.tr,
                  style: TextStyle(
                    color: const Color(0xFFED1F4F),
                    fontSize: 14,
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.w500,
                    height: 1.43,
                    letterSpacing: 0.28,
                  ),
                ),
              )
            : const SizedBox.shrink()),
        const SizedBox(height: 24),
      ],
    );
  }
} 