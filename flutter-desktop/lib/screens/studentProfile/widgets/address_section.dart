import 'package:flutter/material.dart';
import 'profile_field.dart';

class AddressSection extends StatelessWidget {
  const AddressSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Address',
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
                    label: 'City',
                    value: 'City',
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: ProfileField(
                    label: 'Street',
                    value: 'Street',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ProfileField(
                    label: 'Zip Code',
                    value: 'Zip Code',
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: ProfileField(
                    label: 'Province',
                    value: 'Province',
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