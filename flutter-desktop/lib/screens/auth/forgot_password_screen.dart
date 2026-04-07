import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/auth/forgot_password_controller.dart';

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({Key? key}) : super(key: key);

  final ForgotPasswordController controller =
      Get.find<ForgotPasswordController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        return Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: 566,
                  constraints: const BoxConstraints(
                    maxWidth: 566,
                    minWidth: 320,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 32,
                  ),
                  child: _buildCurrentStep(),
                ),
              ),
            ),
            if (controller.showSuccessDialog.value) _buildSuccessOverlay(),
          ],
        );
      }),
    );
  }

  Widget _buildCurrentStep() {
    switch (controller.currentStep.value) {
      case ForgotPasswordStep.email:
        return _buildEmailStep();
      case ForgotPasswordStep.otp:
        return _buildOtpStep();
      case ForgotPasswordStep.newPassword:
        return _buildNewPasswordStep();
    }
  }

  // ==================== STEP 1: EMAIL ====================
  Widget _buildEmailStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'password_recovery'.tr,
          style: const TextStyle(
            color: Color(0xFF2D2E2E),
            fontSize: 20,
            fontFamily: 'IBM Plex Sans Arabic',
            fontWeight: FontWeight.w700,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'password_recovery_subtitle'.tr,
          style: const TextStyle(
            color: Color(0xFF858789),
            fontSize: 12,
            fontFamily: 'IBM Plex Sans Arabic',
            fontWeight: FontWeight.w400,
            height: 1.33,
          ),
        ),
        const SizedBox(height: 32),
        // Email label
        Row(
          children: [
            Text(
              'email'.tr,
              style: const TextStyle(
                color: Color(0xFF2D2E2E),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Text(
              '*',
              style: TextStyle(color: Color(0xFFEF4444), fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Email field
        Container(
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(
              color: controller.emailError.value.isNotEmpty
                  ? const Color(0xFFEF4444)
                  : const Color(0xFFE9E9E9),
            ),
            borderRadius: BorderRadius.circular(8),
            color: controller.emailError.value.isNotEmpty
                ? const Color(0xFFFEF2F2)
                : null,
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              const Icon(Icons.mail_outline, color: Color(0xFF595A5B)),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'tech@ayamedica.com',
                    hintStyle: const TextStyle(
                      color: Color(0xFF9AA6AC),
                      fontSize: 14,
                      fontFamily: 'IBM Plex Sans Arabic',
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(
                    color: Color(0xFF2D2E2E),
                    fontSize: 14,
                    fontFamily: 'IBM Plex Sans Arabic',
                  ),
                ),
              ),
            ],
          ),
        ),
        // Error text
        if (controller.emailError.value.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            controller.emailError.value,
            style: const TextStyle(
              color: Color(0xFFEF4444),
              fontSize: 12,
              fontFamily: 'IBM Plex Sans Arabic',
            ),
          ),
        ],
        const SizedBox(height: 16),
        // Contact support
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => launchUrl(
              Uri.parse('https://wa.me/+201091808186'),
              mode: LaunchMode.externalApplication,
            ),
            child: Text(
              'contact_support'.tr,
              style: const TextStyle(
                color: Color(0xFF1339FF),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Proceed button
        _buildActionButton(
          label: 'proceed'.tr,
          enabled: controller.isEmailValid && !controller.isLoading.value,
          isLoading: controller.isLoading.value,
          onTap: controller.submitEmail,
        ),
        const SizedBox(height: 16),
        // Go back to login
        Center(
          child: TextButton(
            onPressed: controller.goToLogin,
            child: Text(
              'go_back_to_login'.tr,
              style: const TextStyle(
                color: Color(0xFF1339FF),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==================== STEP 2: OTP ====================
  Widget _buildOtpStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title with email
        RichText(
          text: TextSpan(
            style: const TextStyle(
              color: Color(0xFF2D2E2E),
              fontSize: 20,
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
            children: [
              TextSpan(text: '${'email_sent_to'.tr} '),
              TextSpan(text: controller.email),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // Change email link
        GestureDetector(
          onTap: controller.changeEmail,
          child: Text(
            'change_email'.tr,
            style: const TextStyle(
              color: Color(0xFF1339FF),
              fontSize: 14,
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'otp_subtitle'.tr,
          style: const TextStyle(
            color: Color(0xFF858789),
            fontSize: 12,
            fontFamily: 'IBM Plex Sans Arabic',
            fontWeight: FontWeight.w400,
            height: 1.33,
          ),
        ),
        const SizedBox(height: 32),
        // OTP boxes
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) => _buildOtpBox(index)),
        ),
        // OTP error
        if (controller.otpError.value.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            controller.otpError.value,
            style: const TextStyle(
              color: Color(0xFFEF4444),
              fontSize: 12,
              fontFamily: 'IBM Plex Sans Arabic',
            ),
          ),
        ],
        const SizedBox(height: 16),
        // Resend code + Contact support row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed:
                  controller.isLoading.value ? null : controller.resendCode,
              child: Text(
                'resend_code'.tr,
                style: const TextStyle(
                  color: Color(0xFF1339FF),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'contact_support'.tr,
                style: const TextStyle(
                  color: Color(0xFF1339FF),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Proceed button
        _buildActionButton(
          label: 'proceed'.tr,
          enabled: controller.isOtpComplete && !controller.isLoading.value,
          isLoading: controller.isLoading.value,
          onTap: controller.submitOtp,
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: controller.goToLogin,
            child: Text(
              'go_back_to_login'.tr,
              style: const TextStyle(
                color: Color(0xFF1339FF),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 56,
      height: 56,
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) => controller.onOtpKeyEvent(index, event),
        child: TextField(
          controller: controller.otpControllers[index],
          focusNode: controller.otpFocusNodes[index],
          textAlign: TextAlign.center,
          maxLength: 1,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D2E2E),
          ),
          decoration: InputDecoration(
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE9E9E9)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: Color(0xFF1339FF), width: 1.5),
            ),
          ),
          onChanged: (value) => controller.onOtpDigitChanged(index, value),
        ),
      ),
    );
  }

  // ==================== STEP 3: NEW PASSWORD ====================
  Widget _buildNewPasswordStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'new_password_title'.tr,
          style: const TextStyle(
            color: Color(0xFF2D2E2E),
            fontSize: 20,
            fontFamily: 'IBM Plex Sans Arabic',
            fontWeight: FontWeight.w700,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'new_password_subtitle'.tr,
          style: const TextStyle(
            color: Color(0xFF858789),
            fontSize: 12,
            fontFamily: 'IBM Plex Sans Arabic',
            fontWeight: FontWeight.w400,
            height: 1.33,
          ),
        ),
        const SizedBox(height: 32),
        // Password field
        _buildPasswordField(
          label: 'enter_your_password'.tr,
          controller: controller.passwordController,
          obscure: controller.obscurePassword,
        ),
        const SizedBox(height: 16),
        // Confirm password field
        _buildPasswordField(
          label: 'repeat_password'.tr,
          controller: controller.confirmPasswordController,
          obscure: controller.obscureConfirmPassword,
        ),
        const SizedBox(height: 24),
        // Password rules
        _buildPasswordRule('rule_min_length'.tr, controller.hasMinLength),
        const SizedBox(height: 8),
        _buildPasswordRule('rule_upper_lower'.tr, controller.hasUpperAndLower),
        const SizedBox(height: 8),
        _buildPasswordRule('rule_special_char'.tr, controller.hasSpecialChar),
        const SizedBox(height: 8),
        _buildPasswordRule('rule_match'.tr, controller.passwordsMatch),
        // Error
        if (controller.passwordError.value.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            controller.passwordError.value,
            style: const TextStyle(
              color: Color(0xFFEF4444),
              fontSize: 12,
              fontFamily: 'IBM Plex Sans Arabic',
            ),
          ),
        ],
        const SizedBox(height: 16),
        // Contact support
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => launchUrl(
              Uri.parse('https://wa.me/+201091808186'),
              mode: LaunchMode.externalApplication,
            ),
            child: Text(
              'contact_support'.tr,
              style: const TextStyle(
                color: Color(0xFF1339FF),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Complete button
        _buildActionButton(
          label: 'complete'.tr,
          enabled:
              controller.allPasswordRulesPass && !controller.isLoading.value,
          isLoading: controller.isLoading.value,
          onTap: controller.submitNewPassword,
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required RxBool obscure,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF2D2E2E),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Text(
              '*',
              style: TextStyle(color: Color(0xFFEF4444), fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE9E9E9)),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Obx(() => Row(
                children: [
                  const Icon(Icons.lock_outline, color: Color(0xFF595A5B)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      obscureText: obscure.value,
                      decoration: InputDecoration(
                        hintText: 'password_hint'.tr,
                        hintStyle: const TextStyle(
                          color: Color(0xFF9AA6AC),
                          fontSize: 14,
                          fontFamily: 'IBM Plex Sans Arabic',
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(
                        color: Color(0xFF2D2E2E),
                        fontSize: 14,
                        fontFamily: 'IBM Plex Sans Arabic',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      obscure.value
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: const Color(0xFF595A5B),
                    ),
                    onPressed: () => obscure.value = !obscure.value,
                  ),
                ],
              )),
        ),
      ],
    );
  }

  Widget _buildPasswordRule(String text, bool passed) {
    return Row(
      children: [
        Icon(
          Icons.check_circle,
          size: 20,
          color: passed ? const Color(0xFF10B981) : const Color(0xFFCBD5E1),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              color: passed ? const Color(0xFF10B981) : const Color(0xFF858789),
              fontSize: 13,
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  // ==================== SUCCESS DIALOG ====================
  Widget _buildSuccessOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFD1FAE5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF10B981),
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'password_changed'.tr,
                style: const TextStyle(
                  color: Color(0xFF2D2E2E),
                  fontSize: 20,
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'password_changed_subtitle'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF858789),
                  fontSize: 14,
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: controller.goToLogin,
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1339FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'login'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== SHARED BUTTON ====================
  Widget _buildActionButton({
    required String label,
    required bool enabled,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFF1339FF) : const Color(0xFFE4E9ED),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Color(0xFF1339FF),
                  strokeWidth: 2.0,
                ),
              )
            : Text(
                label,
                style: TextStyle(
                  color: enabled ? Colors.white : const Color(0xFF9AA6AC),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
