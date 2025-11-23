import 'package:flutter/material.dart';
import 'profile_field.dart';

class ContactDetailsSection extends StatelessWidget {
  const ContactDetailsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ProfileField(
                    label: 'First Guardian phone',
                    value: '+201070000003',
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: ProfileField(
                    label: 'Second Guardian phone',
                    value: '+201070000003',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ProfileField(
                    label: 'First Guardian email',
                    value: 'user@domain.com',
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: ProfileField(
                    label: 'Second Guardian email',
                    value: 'user@domain.com',
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}