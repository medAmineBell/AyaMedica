import 'package:flutter/material.dart';
import 'package:flutter_getx_app/models/student.dart';
import 'package:intl/intl.dart';
import 'profile_field.dart';

class ProfileSection extends StatelessWidget {
  final Student student;

  const ProfileSection({
    Key? key,
    required this.student,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 16),
        _buildProfileGrid(),
      ],
    );
  }

  Widget _buildProfileGrid() {
    final dateOfBirthStr = student.dateOfBirth != null
        ? DateFormat('dd/MM/yyyy').format(student.dateOfBirth!)
        : '-';
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ProfileField(
                label: 'Date of Birth',
                value: dateOfBirthStr,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: ProfileField(
                label: 'Go-To Hospital',
                value: student.goToHospital,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ProfileField(
                label: 'Blood Type',
                value: student.bloodType,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: ProfileField(
                label: 'Weight (Kg)',
                value: student.weightKg != null 
                    ? '${student.weightKg!.toStringAsFixed(1)} Kg' 
                    : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ProfileField(
                label: 'Height (Cm)',
                value: student.heightCm != null 
                    ? '${student.heightCm!.toStringAsFixed(0)} Cm' 
                    : null,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(child: Container()),
          ],
        ),
      ],
    );
  }
}