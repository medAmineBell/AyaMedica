import 'package:flutter/material.dart';
import 'package:flutter_getx_app/models/student.dart';
import 'package:flutter_getx_app/controllers/student_controller.dart';
import 'package:flutter_getx_app/controllers/home_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class StudentDetailsSheet extends StatelessWidget {
  final Student student;

  const StudentDetailsSheet({
    Key? key,
    required this.student,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StudentController>();
    final homeController = Get.find<HomeController>();

    return Container(
      height: Get.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Text(
                  'Student Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // Edit Button
                IconButton(
                  onPressed: () {
                    Get.back(); // Close bottom sheet first
                    homeController.navigateToEditStudent(student);
                  },
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit Student',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.blue.shade50,
                    foregroundColor: Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                // Delete Button
                IconButton(
                  onPressed: () {
                    Get.back();
                    controller.showDeleteConfirmation(student);
                  },
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete Student',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red,
                  ),
                ),
                const SizedBox(width: 8),
                // Close Button
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                  tooltip: 'Close',
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileSection(),
                  const SizedBox(height: 24),
                  _buildPersonalInfoSection(),
                  const SizedBox(height: 24),
                  _buildAcademicInfoSection(),
                  const SizedBox(height: 24),
                  _buildContactInfoSection(),
                  const SizedBox(height: 24),
                  _buildGuardianInfoSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: student.avatarColor,
            child: Text(
              student.initials,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            student.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            student.gradeAndClass,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          if (student.studentId != null) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'ID: ${student.studentId}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return _buildSection(
      'Personal Information',
      [
        if (student.dateOfBirth != null)
          _buildInfoRow(
            'Date of Birth',
            DateFormat('dd MMM yyyy').format(student.dateOfBirth!),
            Icons.cake_outlined,
          ),
        if (student.gender != null)
          _buildInfoRow('Gender', student.gender!, Icons.person_outline),
        if (student.nationalId != null)
          _buildInfoRow(
              'National ID', student.nationalId!, Icons.badge_outlined),
        if (student.passportIdNumber != null)
          _buildInfoRow('Passport Number', student.passportIdNumber!,
              Icons.document_scanner_outlined),
        if (student.bloodType != null)
          _buildInfoRow(
              'Blood Type', student.bloodType!, Icons.bloodtype_outlined),
      ],
    );
  }

  Widget _buildAcademicInfoSection() {
    return _buildSection(
      'Academic Information',
      [
        if (student.grade != null)
          _buildInfoRow('Grade', student.grade!, Icons.school_outlined),
        if (student.className != null)
          _buildInfoRow('Class', student.className!, Icons.class_outlined),
        if (student.lastAppointmentDate != null)
          _buildInfoRow(
            'Last Appointment',
            student.formattedAppointmentDate,
            Icons.calendar_today_outlined,
          ),
      ],
    );
  }

  Widget _buildContactInfoSection() {
    return _buildSection(
      'Contact Information',
      [
        if (student.email != null)
          _buildInfoRow('Email', student.email!, Icons.email_outlined),
        if (student.phoneNumber != null)
          _buildInfoRow('Phone', student.phoneNumber!, Icons.phone_outlined),
        if (student.formattedAddress != 'No address')
          _buildInfoRow(
              'Address', student.formattedAddress, Icons.location_on_outlined),
      ],
    );
  }

  Widget _buildGuardianInfoSection() {
    final hasGuardianInfo = student.hasGuardianInfo;

    if (!hasGuardianInfo) {
      return const SizedBox.shrink();
    }

    return _buildSection(
      'Guardian Information',
      [
        if (student.firstGuardianName != null) ...[
          _buildGuardianCard(
            'Primary Guardian',
            student.firstGuardianName!,
            student.firstGuardianPhone,
            student.firstGuardianEmail,
          ),
          const SizedBox(height: 12),
        ],
        if (student.secondGuardianName != null) ...[
          _buildGuardianCard(
            'Secondary Guardian',
            student.secondGuardianName!,
            student.secondGuardianPhone,
            student.secondGuardianEmail,
          ),
        ],
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    if (children.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuardianCard(
    String role,
    String name,
    String? phone,
    String? email,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            role,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 18,
                color: Colors.grey.shade700,
              ),
              const SizedBox(width: 8),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (phone != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.phone_outlined,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  phone,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ],
          if (email != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.email_outlined,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    email,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
