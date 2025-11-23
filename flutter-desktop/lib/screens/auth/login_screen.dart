import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import Get package
import '../../controllers/auth_controller.dart'; // Import the AuthController with relative path
import 'widgets/language_dropdown_widget.dart'; // Import the new widget
import 'widgets/welcome_section_widget.dart'; // Import the new widget
import 'widgets/country_selection_widget.dart'; // Import the new widget
import 'widgets/login_method_tabs_widget.dart'; // Import the new widget
import 'widgets/dynamic_login_field_widget.dart'; // Import the dynamic field widget
import 'widgets/password_field_widget.dart'; // Import the new widget
import 'widgets/login_button_widget.dart'; // Import the new widget

class LoginScreen extends StatefulWidget { // Change to StatefulWidget
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState(); // Create State
}

class _LoginScreenState extends State<LoginScreen> { // Define State
  // Get the AuthController instance
  final AuthController authController = Get.put(AuthController()); // Using Get.put for simplicity

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: 566, // Max width based on previous context
            constraints: const BoxConstraints(
              maxWidth: 566,
              minWidth: 320,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 32,
            ),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Language Dropdown Placeholder
                LanguageDropdownWidget(), // Use the new widget
                const SizedBox(height: 32),
                // Welcome Section
                WelcomeSectionWidget(), // Use the new widget
                const SizedBox(height: 32),
                // Country Selection Placeholder
                CountrySelectionWidget(authController: authController), // Use the new widget and pass the controller
                const SizedBox(height: 32),
                // Login Method Tabs Placeholder
                LoginMethodTabsWidget(authController: authController), // Use the new widget and pass the controller
                const SizedBox(height: 32),
                // Dynamic Login Field (changes based on selected method)
                DynamicLoginFieldWidget(authController: authController), // Use the dynamic field widget
                const SizedBox(height: 24),
                // Password Field
                PasswordFieldWidget(authController: authController),
                const SizedBox(height: 16),
                // Forgot Password Link
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      'forgot_password'.tr,
                      style: const TextStyle(color: Color(0xFF1339FF), fontSize: 14, fontWeight: FontWeight.w500), // primaryColor
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Login Button
                LoginButtonWidget(authController: authController),
                
                // Development Mode Indicator
                if (AuthController.isDevelopment) _buildDevelopmentIndicator(authController),
                
                // Error Message
                Obx(() => authController.showLoginError.value ? _buildErrorBanner(authController) : const SizedBox.shrink()),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildErrorBanner(AuthController authController) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: ShapeDecoration(
        color: const Color(0xFFFBD2DC) /* Danger-Surface */,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        shadows: [
          BoxShadow(
            color: const Color(0x14000000),
            blurRadius: 32,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 8),
          const Icon(
            Icons.error_outline,
            color: Color(0xFF771028),
            size: 24,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               Text(
  'login_failed_title'.tr,
  style: const TextStyle(
    color: Color(0xFF771028),
    fontSize: 16,
    fontFamily: 'IBM Plex Sans Arabic',
    fontWeight: FontWeight.w700,
    height: 1.50,
    letterSpacing: 0.16,
  ),
),
                const SizedBox(height: 8),
                Text(
                  authController.loginErrorMessage.value,
                  style: const TextStyle(
                    color: Color(0xFF771028) /* Danger-Pressed */,
                    fontSize: 12,
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.w400,
                    height: 1.33,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDevelopmentIndicator(AuthController authController) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD), // Light blue background
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2196F3), width: 1),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.developer_mode,
            color: Color(0xFF2196F3),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Development Mode - Credentials auto-filled',
              style: const TextStyle(
                color: Color(0xFF1976D2),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () => authController.clearDevelopmentCredentials(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Clear',
              style: TextStyle(
                color: Color(0xFF1976D2),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 4),
          TextButton(
            onPressed: () => authController.refillDevelopmentCredentials(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Refill',
              style: TextStyle(
                color: Color(0xFF1976D2),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 