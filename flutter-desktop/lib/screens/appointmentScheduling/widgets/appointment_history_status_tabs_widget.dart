import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/appointment_history_controller.dart';

class AppointmentHistoryStatusTabsWidget extends StatelessWidget {
  const AppointmentHistoryStatusTabsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AppointmentHistoryController>();

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Obx(() => _buildStatusTab(
                'Check in',
                controller.checkedInCount.value,
                'booked',
                controller.selectedFilter.value,
                controller.filterByStatus,
              )),
          const SizedBox(width: 12),
          Obx(() => _buildStatusTab(
                'Checked out',
                controller.checkedOutCount.value,
                'fulfilled',
                controller.selectedFilter.value,
                controller.filterByStatus,
              )),
          const SizedBox(width: 12),
          Obx(() => _buildStatusTab(
                'Cancelled',
                controller.cancelledCount.value,
                'cancelled',
                controller.selectedFilter.value,
                controller.filterByStatus,
              )),
        ],
      ),
    );
  }

  Widget _buildStatusTab(
    String label,
    int count,
    String value,
    String currentValue,
    Function(String) onTap,
  ) {
    final isSelected = currentValue == value;
    return InkWell(
      onTap: () => onTap(isSelected ? 'all' : value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3B82F6) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF3B82F6) : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.red.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? const Color(0xFF3B82F6)
                      : Colors.red.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
