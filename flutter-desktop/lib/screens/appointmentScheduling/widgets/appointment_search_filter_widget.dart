import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/appointment_scheduling_controller.dart';
import '../../../models/appointment_models.dart';

class AppointmentSearchFilterWidget extends StatelessWidget {
  const AppointmentSearchFilterWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AppointmentSchedulingController>();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Search Field
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: TextField(
                    onChanged: (value) => controller.updateSearchQuery(value),
                    decoration: const InputDecoration(
                      hintText: 'search',
                      hintStyle: TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Color(0xFF9CA3AF),
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF374151),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Status Filter Chips
              Obx(() => _buildStatusChip(
                label: '${controller.getDoneCount()} Done',
                isSelected: controller.selectedStatusFilter.value == AppointmentStatus.done,
                color: const Color(0xFF10B981),
                isDone: true,
                onTap: () => controller.toggleStatusFilter(AppointmentStatus.done),
              )),
              const SizedBox(width: 8),
              Obx(() => _buildStatusChip(
                label: '${controller.getNotDoneCount()} Not Done',
                isSelected: controller.selectedStatusFilter.value == AppointmentStatus.notDone,
                color: const Color(0xFFEF4444),
                isDone: false,
                onTap: () => controller.toggleStatusFilter(AppointmentStatus.notDone),
              )),
            ],
          ),
          
          // Clear Filters Button (shown when filters are active)
          Obx(() {
            final hasActiveFilters = controller.searchQuery.value.isNotEmpty || 
                                   controller.selectedStatusFilter.value != null;
            
            if (!hasActiveFilters) return const SizedBox.shrink();
            
            return Container(
              margin: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: () => controller.clearFilters(),
                    icon: const Icon(
                      Icons.clear,
                      size: 16,
                      color: Color(0xFF6B7280),
                    ),
                    label: const Text(
                      'Clear all filters',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${controller.filteredAppointmentStudents.length} results',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

 Widget _buildStatusChip({
  required String label,
  required bool isSelected,
  required Color color,
  required VoidCallback onTap,
  required bool isDone, // Add this parameter to determine which icon to show
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.1) : color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: isSelected ? Border.all(
          color: color,
          width: 1.5,
        ) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDone ? Icons.check : Icons.close,
              size: 14,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    ),
  );
}}