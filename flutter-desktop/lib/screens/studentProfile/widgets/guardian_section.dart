import 'package:flutter/material.dart';
import 'status_badge.dart';

class GuardianSection extends StatelessWidget {
  const GuardianSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // First Guardian
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'First Guardian',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  const Text(
                    'Jane Doe',
                    style: TextStyle(
                      color: Color(0xFF111827),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge(
                    label: 'Undefined',
                    bgColor: const Color(0xFFD1D5DB),
                    dotColor: const Color(0xFF6B7280),
                  ),
                ],
              )
            ],
          ),
        ),

        const SizedBox(width: 16),

        // Divider
        Container(
          height: 40,
          width: 1,
          color: const Color(0xFFE5E7EB),
        ),

        const SizedBox(width: 16),

        // Second Guardian
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Second Guardian',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  const Text(
                    'Jane Doe',
                    style: TextStyle(
                      color: Color(0xFF111827),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge(
                    label: 'Offline',
                    bgColor: const Color(0xFFFEE2E2),
                    dotColor: const Color(0xFFDC2626),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}