import 'package:flutter/material.dart';
import 'profile_field.dart';

class AdditionalInformationSection extends StatelessWidget {
  const AdditionalInformationSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Additional Information',
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
                    label: 'Passport ID Number',
                    value: 'Passport ID Number',
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: ProfileField(
                    label: 'Nationality',
                    value: 'Nationality',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ProfileField(
                    label: 'National ID',
                    value: 'National ID',
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: ProfileField(
                    label: 'Gender',
                    value: 'Gender',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ProfileField(
                    label: 'Phone Number',
                    value: 'Phone Number',
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: ProfileField(
                    label: 'Email',
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