import 'package:flutter/material.dart';
import 'package:flutter_getx_app/models/student.dart';
import 'profile_field.dart';

class AdditionalInformationSection extends StatelessWidget {
  final Student student;

  const AdditionalInformationSection({Key? key, required this.student}) : super(key: key);

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
                    value: student.passportIdNumber,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: ProfileField(
                    label: 'Nationality',
                    value: student.nationality,
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
                    value: student.nationalId,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: ProfileField(
                    label: 'Gender',
                    value: student.gender,
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
                    value: student.phoneNumber,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: ProfileField(
                    label: 'Email',
                    value: student.email,
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
