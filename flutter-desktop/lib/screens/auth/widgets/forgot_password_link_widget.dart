import 'package:flutter/material.dart';

class ForgotPasswordLinkWidget extends StatelessWidget {
  const ForgotPasswordLinkWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: () {},
        child: const Text(
          'Forgot your password?',
          style: TextStyle(color: Color(0xFF1339FF), fontSize: 14, fontWeight: FontWeight.w500), // primaryColor
        ),
      ),
    );
  }
} 