import 'package:flutter/material.dart';
import 'package:flutter_getx_app/models/appointment_models.dart';

class AppointmentStatusBadgeWidget extends StatelessWidget {
  final AppointmentStatus status;

  const AppointmentStatusBadgeWidget({
    Key? key,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status == AppointmentStatus.done
            ? const Color(0xFFDCFCE7)
            : const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status == AppointmentStatus.done ? 'Done' : 'Not Done',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: status == AppointmentStatus.done
              ? const Color(0xFF059669)
              : const Color(0xFFDC2626),
        ),
      ),
    );
  }
}