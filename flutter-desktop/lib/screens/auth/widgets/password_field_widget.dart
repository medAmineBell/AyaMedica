import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart'; // Import AuthController

class PasswordFieldWidget extends StatelessWidget {
  final AuthController authController; // Receive AuthController

  const PasswordFieldWidget({Key? key, required this.authController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'enter_password'.tr,
          style: const TextStyle(color: Color(0xFF2D2E2E), fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        Container(
          height: 48, // Placeholder height
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE9E9E9)),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Obx(() => Row(
            children: [
              const Icon(Icons.lock_outline),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: authController.passwordController, // Use the password controller
                  obscureText: authController.obscurePassword.value, // Use observable for visibility
                  decoration: InputDecoration(
                    hintText: 'password_hint'.tr,
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              // Add the eye icon to toggle visibility
              IconButton(
                icon: Icon(
                  authController.obscurePassword.value ? Icons.visibility_off : Icons.visibility,
                  color: const Color(0xFF595A5B), // textSecondary color
                ),
                onPressed: () => authController.obscurePassword.value = !authController.obscurePassword.value,
              ),
            ]
          )),
        ),
      ],
    );
  }
} 