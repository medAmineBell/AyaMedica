import 'package:flutter/material.dart';
import 'package:flutter_getx_app/models/student.dart';
import 'package:get/get.dart';

class StudentDetailsSheet extends StatelessWidget {
  final Student student;

  const StudentDetailsSheet({Key? key, required this.student}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Hero(
                  tag: 'student_avatar_${student.id}',
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: student.avatarColor,
                    child: Text(
                      student.name.isNotEmpty
                          ? student.name[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'ID: ${student.id}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
          ),
          // Details
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection('Personal Information', [
                    _buildDetailRow('Age', '${student.dateOfBirth!.difference(DateTime.now()).inDays ~/ 365} years old'),
                    _buildDetailRow('Gender', student.gender ?? ''),
                    _buildDetailRow('Blood Type', student.bloodType?? ''),
                    _buildDetailRow('Weight', '${student.weightKg} kg'),
                    _buildDetailRow('Height', '${student.heightCm} cm'),
                    _buildDetailRow('Hospital', student.goToHospital?? ''),
                  ]),
                  _buildSection('Contact Information', [
                    _buildDetailRow('Phone', student.phoneNumber?? ''),
                    _buildDetailRow('Email', student.email?? ''),
                  ]),
                  _buildSection('Address', [
                    _buildDetailRow('Street', student.street?? ''),
                    _buildDetailRow('City', student.city?? ''),
                    _buildDetailRow('Province', student.province?? ''),
                    _buildDetailRow('Zip Code', student.zipCode?? ''),
                  ]),
                  _buildSection('Guardian Information', [
                    _buildDetailRow('First Guardian', student.firstGuardianName ?? ''),
                    _buildDetailRow('Guardian Phone', student.firstGuardianPhone ?? ''),
                    _buildDetailRow('Guardian Email', student.firstGuardianEmail ?? ''),
                    _buildDetailRow('Second Guardian', student.secondGuardianName ?? ''),
                  ]),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12),
        ...children,
        SizedBox(height: 24),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}