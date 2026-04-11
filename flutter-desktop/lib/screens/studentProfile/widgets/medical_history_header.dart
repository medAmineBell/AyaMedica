import 'package:flutter/material.dart';

class MedicalHistoryHeader extends StatelessWidget {
  const MedicalHistoryHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Medical history',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Color(0xFF111827),
      ),
    );
  }
}