import 'package:flutter_getx_app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ForgotPasswordController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final RxString error = ''.obs;
  final RxString success = ''.obs;

  void submit() {
    final email = emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      error.value = 'Please enter a valid email address.';
      success.value = '';
      return;
    }
    // TODO: Implement actual password reset logic (API call)
    error.value = '';
    success.value = 'A password reset link has been sent to your email.';
    // Navigate to OTP screen
    Get.toNamed(Routes.OTP_REST_PASSWORD, arguments: {'email': email});
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
