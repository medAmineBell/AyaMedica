import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';

class LoginButtonWidget extends StatelessWidget {
  final AuthController authController;
  
  const LoginButtonWidget({Key? key, required this.authController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Force refresh when form validity changes
      final _ = authController.isFormValid.value;
      
      // Get current button state
      final buttonState = authController.loginButtonState.value;
      
      // Determine button color based on state
      Color buttonColor;
      switch (buttonState) {
        case LoginButtonState.valid:
          buttonColor = const Color(0xFF0D6EFD); // Blue for valid state
          break;
        case LoginButtonState.loading:
          buttonColor = const Color(0xFFCDF7FF); // Same blue for loading state
          break;
        case LoginButtonState.disabled:
        default:
          buttonColor = const Color(0xFFE4E9ED); // Gray for disabled state
          break;
      }
      
      return GestureDetector(
        onTap: buttonState == LoginButtonState.disabled ? null : authController.login,
        child: Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: buttonState == LoginButtonState.loading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color:  Color(0xFF1339FF),
                  strokeWidth: 2.0,
                ),
              )
            : Text(
                'login'.tr,
                style: TextStyle(
                  color: buttonState == LoginButtonState.disabled 
                    ? const Color(0xFF9AA6AC) // Gray text for disabled
                    : Colors.white, // White text for valid
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
        ),
      );
    });
  }
}