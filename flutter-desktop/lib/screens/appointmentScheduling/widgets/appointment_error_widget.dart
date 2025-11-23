import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppointmentErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const AppointmentErrorWidget({
    Key? key,
    required this.error,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/svg/error.svg',
            width: 64,
            height: 64,
            colorFilter: const ColorFilter.mode(
              Color(0xFFFC2E53),
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            error,
            style: const TextStyle(
              color: Color(0xFF595A5B),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1339FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
