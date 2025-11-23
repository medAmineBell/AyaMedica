import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/appointment_scheduling_controller.dart';
import 'appointment_confirmation_dialog.dart';

class AppointmentBulkActionsWidget extends StatelessWidget {
  const AppointmentBulkActionsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AppointmentSchedulingController>();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: Row(
        children: [
          Obx(() => Text(
            '${controller.selectedAppointments.length} selected',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
          )),
          const Spacer(),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => _showBulkConfirmationDialog(
                  context, 
                  true, // for done
                  controller
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text('Mark as done', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _showBulkConfirmationDialog(
                  context, 
                  false, // for not done
                  controller
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text('Mark as not done', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showBulkConfirmationDialog(
    BuildContext context, 
    bool markAsDone, 
    AppointmentSchedulingController controller
  ) {
    final selectedCount = controller.selectedAppointments.length;
    final action = markAsDone ? 'done' : 'not done';
    
    showDialog(
      context: context,
      builder: (context) => AppointmentConfirmationDialog(
        title: 'Mark all as $action',
        message: 'By clicking proceed, all selected appointments will be marked $action for all the patients',
        onConfirm: () {
          if (markAsDone) {
            controller.markSelectedAsDone();
          } else {
            controller.markSelectedAsNotDone();
          }
          Get.back();
        },
        onCancel: () => Get.back(),
      ),
    );
  }
}