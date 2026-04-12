import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../config/app_config.dart';
import '../../utils/api_service.dart';
import 'package:flutter_getx_app/utils/app_snackbar.dart';

enum ForgotPasswordStep { email, otp, newPassword }

class ForgotPasswordController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  // Step management
  final currentStep = ForgotPasswordStep.email.obs;

  // Loading state
  final isLoading = false.obs;

  // Email step
  final emailController = TextEditingController();
  final emailError = ''.obs;

  // OTP step
  final List<TextEditingController> otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> otpFocusNodes = List.generate(6, (_) => FocusNode());
  final otpError = ''.obs;
  String _verifiedOtp = '';

  // Password step
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final obscurePassword = true.obs;
  final obscureConfirmPassword = true.obs;
  final passwordError = ''.obs;

  // Success dialog
  final showSuccessDialog = false.obs;

  // Reactive triggers for validation
  final _emailText = ''.obs;
  final _passwordText = ''.obs;
  final _confirmPasswordText = ''.obs;
  final _otpText = ''.obs;

  String get email => emailController.text.trim();
  bool get isEmailValid => AppConfig.isValidEmail(_emailText.value.trim());

  String get _otp => otpControllers.map((c) => c.text).join();
  bool get isOtpComplete => _otpText.value.length == 6;

  // Password rules
  bool get hasMinLength => _passwordText.value.length >= 8;
  bool get hasUpperAndLower =>
      RegExp(r'[A-Z]').hasMatch(_passwordText.value) &&
      RegExp(r'[a-z]').hasMatch(_passwordText.value);
  bool get hasSpecialChar =>
      RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(_passwordText.value);
  bool get passwordsMatch =>
      _passwordText.value.isNotEmpty &&
      _passwordText.value == _confirmPasswordText.value;
  bool get allPasswordRulesPass =>
      hasMinLength && hasUpperAndLower && hasSpecialChar && passwordsMatch;

  @override
  void onInit() {
    super.onInit();
    emailController.addListener(() {
      _emailText.value = emailController.text;
      emailError.value = '';
    });
    passwordController.addListener(() {
      _passwordText.value = passwordController.text;
      passwordError.value = '';
    });
    confirmPasswordController.addListener(() {
      _confirmPasswordText.value = confirmPasswordController.text;
    });
  }

  @override
  void onClose() {
    emailController.dispose();
    for (final c in otpControllers) {
      c.dispose();
    }
    for (final f in otpFocusNodes) {
      f.dispose();
    }
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // Step 1: Submit email
  Future<void> submitEmail() async {
    if (!isEmailValid) {
      emailError.value = 'email_invalid'.tr;
      return;
    }

    isLoading.value = true;
    final result = await _apiService.forgotPassword(email: email);
    isLoading.value = false;

    if (result['success'] == true) {
      currentStep.value = ForgotPasswordStep.otp;
      // Focus first OTP field after frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        otpFocusNodes[0].requestFocus();
      });
    } else {
      emailError.value = result['error'] ?? 'error_occurred'.tr;
    }
  }

  // Go back to email step
  void changeEmail() {
    for (final c in otpControllers) {
      c.clear();
    }
    otpError.value = '';
    currentStep.value = ForgotPasswordStep.email;
  }

  // OTP digit changed
  void onOtpDigitChanged(int index, String value) {
    otpError.value = '';
    _otpText.value = _otp;
    if (value.isNotEmpty && index < 5) {
      otpFocusNodes[index + 1].requestFocus();
    }
  }

  // Handle OTP backspace
  void onOtpKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        otpControllers[index].text.isEmpty &&
        index > 0) {
      otpControllers[index - 1].clear();
      otpFocusNodes[index - 1].requestFocus();
      _otpText.value = _otp;
    }
  }

  // Step 2: Submit OTP (just store and proceed, verification happens with reset-password)
  void submitOtp() {
    if (!isOtpComplete) {
      otpError.value = 'Please enter all 6 digits';
      return;
    }
    _verifiedOtp = _otp;
    currentStep.value = ForgotPasswordStep.newPassword;
  }

  // Resend OTP
  Future<void> resendCode() async {
    isLoading.value = true;
    final result = await _apiService.forgotPassword(email: email);
    isLoading.value = false;

    if (result['success'] == true) {
      appSnackbar('', 'code_resent'.tr,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          duration: const Duration(seconds: 2));
    } else {
      otpError.value = result['error'] ?? 'error_occurred'.tr;
    }
  }

  // Step 3: Submit new password
  Future<void> submitNewPassword() async {
    if (!allPasswordRulesPass) return;

    isLoading.value = true;
    final result = await _apiService.resetPassword(
      email: email,
      otp: _verifiedOtp,
      newPassword: passwordController.text,
    );
    isLoading.value = false;

    if (result['success'] == true) {
      showSuccessDialog.value = true;
    } else {
      passwordError.value = result['error'] ?? 'error_occurred'.tr;
    }
  }

  void goToLogin() {
    Get.offAllNamed('/login');
  }
}
