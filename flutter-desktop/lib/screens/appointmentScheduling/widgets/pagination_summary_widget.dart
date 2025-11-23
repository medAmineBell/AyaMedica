import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/appointment_scheduling_controller.dart';

class PaginationSummaryWidget extends StatelessWidget {
  const PaginationSummaryWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AppointmentSchedulingController>();
    
    return Obx(() {
      final totalItems = controller.allAppointmentStudents.length;
      final currentPage = controller.currentPage.value;
      final itemsPerPage = controller.itemsPerPage;
      
      if (totalItems == 0) {
        return const SizedBox.shrink();
      }
      
      final startItem = ((currentPage - 1) * itemsPerPage) + 1;
      final endItem = (currentPage * itemsPerPage).clamp(0, totalItems);
      
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: const BoxDecoration(
          color: Color(0xFFF9FAFB),
          border: Border(
            bottom: BorderSide(color: Color(0xFFE5E7EB)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Showing $startItem-$endItem of $totalItems appointments',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
            Text(
              'Page $currentPage of ${controller.totalPages}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151),
              ),
            ),
          ],
        ),
      );
    });
  }
}