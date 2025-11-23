import 'package:flutter/material.dart';
import 'package:flutter_getx_app/models/student.dart';

class SelectedStudentInfoSidebar extends StatelessWidget {
  final Student student;

  const SelectedStudentInfoSidebar({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.orange.shade300,
              backgroundImage:
                  student.imageUrl != null ? NetworkImage(student.imageUrl!) : null,
              child: student.imageUrl == null
                  ? Text(
                      student.initials,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 16),

            // Name
            Text(
              student.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            // AID Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.lightBlue.shade100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                'AID: ${student.aid ?? 'N/A'}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.blue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              '${student.grade ?? 'N/A'}  ${student.className ?? ''}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 32),

            // Detail rows
            _buildDetailRow('Gender', student.gender ?? 'N/A'),
            _buildDetailRow('Date of Birth', _formatDate(student.dateOfBirth)),
            _buildDetailRow('Blood Type', student.bloodType ?? 'N/A'),
            _buildDetailRow('Height (Cm)', '${student.heightCm?.toStringAsFixed(0) ?? 'N/A'}'),
            _buildDetailRow('Weight (Kg)', '${student.weightKg?.toStringAsFixed(0) ?? 'N/A'}'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
