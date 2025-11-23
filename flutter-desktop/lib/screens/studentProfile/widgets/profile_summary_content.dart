import 'package:flutter/material.dart';
import 'package:flutter_getx_app/models/student.dart';
import 'guardian_section.dart';
import 'profile_section.dart';
import 'contact_details_section.dart';

class ProfileSummaryContent extends StatelessWidget {
  final Student student;

  const ProfileSummaryContent({
    Key? key,
    required this.student,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final age = student.dateOfBirth != null
        ? DateTime.now().year - student.dateOfBirth!.year
        : null;
    final gender = student.gender?.toLowerCase() ?? 'student';
    final nationality = student.nationality ?? 'unknown';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(bottom: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF9333EA), Color(0xFF3B82F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child:
                    const Icon(Icons.insights, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ayamedica insights',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6366F1),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${student.name} is a ${age != null ? '$age-year-old' : 'young'} $nationality $gender currently in 6th grade. He lives in ${student.street ?? 'unknown street'}, ${student.city ?? 'unknown city'}, ${student.province ?? ''} (zip: ${student.zipCode ?? '-'}) and can be contacted via guardian at ${student.phoneNumber ?? '-'}. Blood type is ${student.bloodType ?? '-'}, height is ${student.heightCm?.toStringAsFixed(0) ?? '-'} cm, and weight is ${student.weightKg?.toStringAsFixed(1) ?? '-'} kg.",
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const GuardianSection(),
        const SizedBox(height: 32),
        ProfileSection(student: student),
        const SizedBox(height: 32),
        const ContactDetailsSection(),
      ],
    );
  }
}
