import 'package:flutter/material.dart';
import 'package:flutter_getx_app/config/app_config.dart';
import 'package:flutter_getx_app/controllers/student_controller.dart';
import 'package:flutter_getx_app/models/student.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../controllers/home_controller.dart';
import 'widgets/address_section.dart';
import 'widgets/additional_information_section.dart';
import 'widgets/profile_field.dart';
import 'widgets/profile_header.dart';
import 'widgets/status_badge.dart';

class ClinicStudentProfileScreen extends StatelessWidget {
  final Student student;

  const ClinicStudentProfileScreen({
    Key? key,
    required this.student,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    final studentController = Get.find<StudentController>();

    return Scaffold(
      backgroundColor: const Color(0xFFFBFCFD),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileHeader(
              onBackPressed: () {
                homeController.changeContent(ContentType.clinicStudentsList);
              },
              subtitle: 'View student profile',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _DeleteButton(
                    onPressed: () =>
                        studentController.showDeleteConfirmation(student),
                  ),
                  const SizedBox(width: 12),
                  _EditButton(
                    onPressed: () =>
                        homeController.navigateToEditStudent(student),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StudentSummaryCard(student: student),
                  const SizedBox(width: 24),
                  Expanded(
                    child: SingleChildScrollView(
                      child: _ProfileDetailsContent(student: student),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _DeleteButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: SvgPicture.asset(
        'assets/svg/note-remove.svg',
        width: 18,
        height: 18,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      ),
      label: const Text('Delete student details'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFEF4444),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EditButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _EditButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: SvgPicture.asset(
        'assets/svg/edit-2.svg',
        width: 18,
        height: 18,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      ),
      label: const Text('Edit details'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1339FF),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StudentSummaryCard extends StatelessWidget {
  final Student student;
  const _StudentSummaryCard({required this.student});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          _buildAvatar(),
          const SizedBox(height: 16),
          Text(
            student.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          if ((student.aid ?? '').isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFCCF1FF),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                student.aid!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2563EB),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            [student.grade, student.className]
                .whereType<String>()
                .where((s) => s.isNotEmpty)
                .join(' '),
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          _SummaryField(label: 'Gender', value: _capitalize(student.gender)),
          _SummaryField(
              label: 'Date of Birth', value: _formatDate(student.dateOfBirth)),
          _SummaryField(label: 'Blood Type', value: student.bloodType),
          _SummaryField(
              label: 'Height (Cm)',
              value: student.heightCm?.toStringAsFixed(0)),
          _SummaryField(
              label: 'Weight (Kg)',
              value: student.weightKg?.toStringAsFixed(1)),
          _SummaryField(
              label: 'Emergency Hospital',
              value: student.goToHospital,
              isLast: true),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final imageUrl = student.imageUrl;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      final fullUrl = imageUrl.startsWith('http')
          ? imageUrl
          : '${AppConfig.newBackendUrl}$imageUrl';
      return CircleAvatar(
        radius: 60,
        backgroundColor: student.avatarColor,
        backgroundImage: NetworkImage(fullUrl),
        onBackgroundImageError: (_, __) {},
      );
    }
    return CircleAvatar(
      radius: 60,
      backgroundColor: student.avatarColor,
      child: Text(
        student.initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String? _capitalize(String? s) {
    if (s == null || s.isEmpty) return null;
    return '${s[0].toUpperCase()}${s.substring(1).toLowerCase()}';
  }

  String? _formatDate(DateTime? d) {
    if (d == null) return null;
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }
}

class _SummaryField extends StatelessWidget {
  final String label;
  final String? value;
  final bool isLast;

  const _SummaryField({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0xFFF3F4F6)),
              ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
          Text(
            value == null || value!.isEmpty ? '-' : value!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileDetailsContent extends StatelessWidget {
  final Student student;
  const _ProfileDetailsContent({required this.student});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ClinicGuardianSection(student: student),
          const SizedBox(height: 32),
          AddressSection(student: student),
          const SizedBox(height: 32),
          AdditionalInformationSection(student: student),
        ],
      ),
    );
  }
}

class _ClinicGuardianSection extends StatelessWidget {
  final Student student;
  const _ClinicGuardianSection({required this.student});

  String? _formatRelation(String? relation) {
    if (relation == null || relation.isEmpty) return null;
    return relation
        .split('_')
        .map((w) =>
            w.isEmpty ? w : w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Guardian details',
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
              child: _GuardianNameRow(
                label: 'First Guardian',
                name: student.firstGuardianName,
                status: student.firstGuardianStatus,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _GuardianNameRow(
                label: 'Second Guardian',
                name: student.secondGuardianName,
                status: student.secondGuardianStatus,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ProfileField(
                label: 'First Guardian relation',
                value: _formatRelation(student.firstGuardianRelation),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: ProfileField(
                label: 'Second Guardian relation',
                value: _formatRelation(student.secondGuardianRelation),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
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
    );
  }
}

class _GuardianNameRow extends StatelessWidget {
  final String label;
  final String? name;
  final String? status;

  const _GuardianNameRow({
    required this.label,
    required this.name,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
          ),
        ),
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  (name == null || name!.isEmpty) ? '-' : name!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _buildStatusBadge(status),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String? status) {
    if (status == 'active' || status == 'online') {
      return const StatusBadge(
        label: 'Online',
        bgColor: Color(0xFFDCFCE7),
        dotColor: Color(0xFF16A34A),
      );
    }
    if (status == 'inactive' || status == 'offline') {
      return const StatusBadge(
        label: 'Offline',
        bgColor: Color(0xFFFEE2E2),
        dotColor: Color(0xFFDC2626),
      );
    }
    return const StatusBadge(
      label: 'Undefined',
      bgColor: Color(0xFFE5E7EB),
      dotColor: Color(0xFF6B7280),
    );
  }
}
