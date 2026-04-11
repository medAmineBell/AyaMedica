import 'package:flutter/material.dart';

class MedicalRecordsHeader extends StatelessWidget {
  const MedicalRecordsHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Medical records',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Color(0xFF111827),
      ),
    );
  }
}