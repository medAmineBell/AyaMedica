import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ChangePasswordController extends GetxController {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final RxString passwordError = ''.obs;
  final RxString confirmPasswordError = ''.obs;
  final RxString success = ''.obs;

  final RxBool passwordVisible = false.obs;
  final RxBool confirmPasswordVisible = false.obs;

  void togglePasswordVisibility() {
    passwordVisible.value = !passwordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    confirmPasswordVisible.value = !confirmPasswordVisible.value;
  }

  void submit() {
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    bool valid = true;

    if (password.isEmpty || password.length < 6) {
      passwordError.value = 'Password must be at least 6 characters.';
      valid = false;
    } else {
      passwordError.value = '';
    }

    if (confirmPassword != password) {
      confirmPasswordError.value = 'Passwords do not match.';
      valid = false;
    } else {
      confirmPasswordError.value = '';
    }

    if (valid) {
      // TODO: Implement actual password change logic (API call)
      success.value = 'Password changed successfully!';
      // Navigate to reset password success screen
      Get.offAllNamed('/reset-password-success');
    } else {
      success.value = '';
    }
  }

  @override
  void onClose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
