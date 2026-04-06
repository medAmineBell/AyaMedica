import 'package:flutter/material.dart';
import 'package:flutter_getx_app/models/student.dart';
import 'profile_field.dart';

class ContactDetailsSection extends StatelessWidget {
  final Student student;

  const ContactDetailsSection({Key? key, required this.student}) : super(key: key);

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
                    value: student.firstGuardianPhone,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: ProfileField(
                    label: 'Second Guardian phone',
                    value: student.secondGuardianPhone,
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
                    value: student.firstGuardianEmail,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: ProfileField(
                    label: 'Second Guardian email',
                    value: student.secondGuardianEmail,
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
