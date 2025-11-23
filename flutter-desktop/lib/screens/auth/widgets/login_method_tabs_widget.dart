import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/auth_controller.dart';
import 'package:get/get.dart';

class LoginMethodTabsWidget extends StatelessWidget {
  final AuthController authController; // Receive AuthController

  const LoginMethodTabsWidget({Key? key, required this.authController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final methods = [
      'aid',
      'phone', 
      'email',
      'nid_ppn',
    ];

    // We need LayoutBuilder here to handle responsiveness as in the original code
    return LayoutBuilder(
      builder: (context, constraints) {
        return constraints.maxWidth > 600
            ? Row(
                children: methods
                    .map((method) => Padding(
                          padding: EdgeInsets.only(right: 24),
                          child: _buildMethodTab(method),
                        ))
                    .toList(),
              )
            : Wrap(
                spacing: 12,
                runSpacing: 12,
                children: methods.map((method) => _buildMethodTab(method)).toList(),
              );
      },
    );
  }

  Widget _buildMethodTab(String method) {
    // Use Obx to react to changes in selectedLoginMethod
    return Obx(() {
      bool isSelected = method == authController.selectedLoginMethod.value;
      return GestureDetector(
        onTap: () => authController.selectLoginMethod(method), // Call controller method
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: ShapeDecoration(
            color: isSelected ? const Color(0xFF1339FF) : const Color(0xFFE4E9ED), // primaryColor vs Not selected
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          child: Text(
            _getMethodDisplayName(method),
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF595A5B), // White vs textSecondary
              fontSize: 14,
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w500,
              height: 1.43,
              letterSpacing: 0.28,
            ),
          ),
        ),
      );
    });
  }

  String _getMethodDisplayName(String method) {
    switch (method) {
      case 'aid':
        return 'aid'.tr;
      case 'phone':
        return 'phone'.tr;
      case 'email':
        return 'email'.tr;
      case 'nid_ppn':
        return 'nid_ppn'.tr;
      default:
        return method;
    }
  }
}
