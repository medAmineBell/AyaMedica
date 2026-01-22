import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/medical_records_controller.dart';
import '../../../models/medicalRecord.dart';

class SelectedStudentInfoSidebar extends StatelessWidget {
  const SelectedStudentInfoSidebar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MedicalRecordsController>();

    return Obx(() {
      final studentDetails = controller.selectedStudentDetails.value;
      final isLoading = controller.isLoadingStudentDetails.value;

      if (isLoading) {
        return Container(
          width: 320,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              left: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (studentDetails == null) {
        return Container(
          width: 320,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              left: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          child: const Center(
            child: Text('No student selected'),
          ),
        );
      }

      return Container(
        width: 320,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            left: BorderSide(color: Colors.grey.shade200),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(-2, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header with avatar and basic info
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Column(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: _getAvatarColor(studentDetails.id),
                    child: Text(
                      studentDetails.initials,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Name
                  Text(
                    studentDetails.fullName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Student ID Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF3B82F6).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      'AID: ${studentDetails.studentId}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF3B82F6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Grade and Class
                  Text(
                    '${studentDetails.grade} ${studentDetails.className}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Student Details Section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Personal Information
                    _buildSectionHeader('Personal Information'),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                        'Gender', _capitalizeFirst(studentDetails.gender)),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                        'Date of Birth', studentDetails.formattedDateOfBirth),

                    const SizedBox(height: 24),

                    // Medical Information
                    _buildSectionHeader('Medical Information'),
                    const SizedBox(height: 12),
                    _buildInfoRow('Blood Type', studentDetails.bloodType),
                    const SizedBox(height: 12),
                    _buildInfoRow('Height (Cm)', '${studentDetails.height}'),
                    const SizedBox(height: 12),
                    _buildInfoRow('Weight (Kg)', '${studentDetails.weight}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF6B7280),
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  Color _getAvatarColor(String id) {
    final hash = id.hashCode;
    final colors = [
      const Color(0xFFEF4444), // Red
      const Color(0xFF3B82F6), // Blue
      const Color(0xFF10B981), // Green
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFFF59E0B), // Orange
      const Color(0xFF06B6D4), // Cyan
    ];
    return colors[hash.abs() % colors.length];
  }
}
