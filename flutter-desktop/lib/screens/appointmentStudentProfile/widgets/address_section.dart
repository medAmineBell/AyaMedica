import 'package:flutter/material.dart';
import 'package:flutter_getx_app/models/student.dart';
import 'profile_field.dart';

class AddressSection extends StatelessWidget {
  final Student student;

  const AddressSection({Key? key, required this.student}) : super(key: key);

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
                    value: student.city,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: ProfileField(
                    label: 'Street',
                    value: student.street,
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
                    value: student.zipCode,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: ProfileField(
                    label: 'Province',
                    value: student.province,
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
