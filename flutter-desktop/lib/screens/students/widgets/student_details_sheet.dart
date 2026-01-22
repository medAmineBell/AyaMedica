import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/student.dart';

class StudentDetailsSheet extends StatelessWidget {
  final Student student;

  const StudentDetailsSheet({Key? key, required this.student})
      : super(key: key);

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
          _SheetHandle(),
          _StudentDetailsHeader(student: student),
          Expanded(
            child: _StudentDetailsContent(student: student),
          ),
        ],
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _StudentDetailsHeader extends StatelessWidget {
  final Student student;

  const _StudentDetailsHeader({required this.student});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: student.avatarColor,
            child: Text(
              student.initials,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
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
                  'ID: ${student.aid ?? 'No ID'}',
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
    );
  }
}

class _StudentDetailsContent extends StatelessWidget {
  final Student student;

  const _StudentDetailsContent({required this.student});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailRow('Grade & Class', student.gradeAndClass),
          _DetailRow('AID', student.aid ?? 'N/A'),
          _DetailRow('Last Appointment', student.formattedAppointmentDate),
          _DetailRow('Appointment Type', student.lastAppointmentType ?? 'N/A'),
          _DetailRow('EMR Number', student.emrNumber?.toString() ?? 'N/A'),
          _DetailRow('Age', '${student.age} years old'),
          _DetailRow('Gender', student.gender ?? 'N/A'),
          _DetailRow('Blood Type', student.bloodType ?? 'N/A'),
          _DetailRow('Phone', student.phoneNumber ?? 'N/A'),
          _DetailRow('Email', student.email ?? 'N/A'),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
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
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
