// creating_appointment_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/creating_appointment_controller.dart';
import 'package:get/get.dart';

class CreatingAppointmentDialog extends StatelessWidget {
  const CreatingAppointmentDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreatingAppointmentController>();
    
    return Obx(() => Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_sync_rounded, 
                size: 40, 
                color: Colors.green
              ),
              const SizedBox(height: 18),
              const Text(
                'Creating appointments',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please wait, we are creating the appointment lists',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 18),
              LinearProgressIndicator(
                value: controller.progress,
                minHeight: 8,
                backgroundColor: Colors.green.shade100,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                borderRadius: BorderRadius.circular(6),
              ),
              const SizedBox(height: 8),
              Text(
                '${(controller.progress * 100).toInt()}%', 
                style: const TextStyle(fontSize: 13)
              ),
            ],
          ),
        ),
      ),
    ));
  }
}