import 'package:get/get.dart';
import 'package:flutter/material.dart';

class OtpController extends GetxController {
  final TextEditingController otpController = TextEditingController();
  final RxString otp = ''.obs;
  final RxString error = ''.obs;
  final RxBool approved = false.obs;

  OtpController() {
    otpController.addListener(() {
      otp.value = otpController.text;
      if (otp.value == '123456') {
        approved.value = true;
        error.value = '';
      } else {
        approved.value = false;
      }
    });
  }

  void submitOtp() {
    final code = otp.value.trim();
    if (code.length != 6) {
      error.value = 'Please enter a valid 6-digit code.';
      approved.value = false;
      return;
    }
    if (code == '123456') {
      approved.value = true;
      error.value = '';
      // TODO: Implement success logic, e.g. navigate to home
      // Get.offAllNamed('/home');
    } else {
      approved.value = false;
      error.value = 'Invalid code. Please try again.';
    }
  }

  @override
  void onClose() {
    otpController.dispose();
    super.onClose();
  }
}
