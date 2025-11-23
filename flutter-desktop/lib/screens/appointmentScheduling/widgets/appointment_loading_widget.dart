import 'package:flutter/material.dart';

class AppointmentLoadingWidget extends StatelessWidget {
  const AppointmentLoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Color(0xFF1339FF),
          ),
          SizedBox(height: 16),
          Text(
            'Loading appointments...',
            style: TextStyle(
              color: Color(0xFF595A5B),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
