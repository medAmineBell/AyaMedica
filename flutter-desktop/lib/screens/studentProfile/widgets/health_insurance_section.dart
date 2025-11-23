import 'package:flutter/material.dart';
import 'profile_field.dart';

class HealthInsuranceSection extends StatelessWidget {
  const HealthInsuranceSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Health insurance details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ProfileField(
                label: 'Insurance Company',
                value: 'Insurance Company',
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: ProfileField(
                label: 'Policy Number',
                value: 'Policy Number',
              ),
            ),
          ],
        ),
      ],
    );
  }
}