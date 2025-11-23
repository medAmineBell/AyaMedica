import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/appointment_scheduling_controller.dart';
import '../../../models/appointment_models.dart';
import 'filters_dialog.dart';

class AppointmentFiltersWidget extends StatelessWidget {
  const AppointmentFiltersWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AppointmentSchedulingController>();
    final radiusStart = const BorderRadius.only(
  topLeft: Radius.circular(8),
  bottomLeft: Radius.circular(8),
);

final radiusEnd = const BorderRadius.only(
  topRight: Radius.circular(8),
  bottomRight: Radius.circular(8),
);

final radiusNone = BorderRadius.zero;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
        Obx(
         () {
            return Wrap(
              children: [
                _buildFilterChip(
                  'Check In',
                  AppointmentStatus.notDone,
                  Colors.redAccent,
                  controller,
                  controller.getNotDoneCount(),
                  radiusStart
                ),
                _buildFilterChip(
                  'Checked out',
                  AppointmentStatus.done,
                  Colors.redAccent,
                  controller,
                  controller.getDoneCount(),
            
                  radiusNone
                ),
                _buildFilterChip(
                  'Received records',
                  AppointmentStatus.received, // if you have this status
                  Colors.redAccent,
                  controller,
                  0, // or your controller method
                  radiusNone
                ),
                _buildFilterChip(
                  'Cancelled',
                  AppointmentStatus.cancelled,
                  Colors.redAccent,
                  controller,
                  controller.getCancelledAppointmentsCount(),
                  radiusEnd
                ),
              ],
            );
          }
        )
,
          const Spacer(),
          Row(
            children: [
              // Download Button
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: IconButton(
                  onPressed: () {
                    // Handle download functionality
                    _handleDownload();
                  },
                  icon: const Icon(
                    Icons.download_outlined,
                    color: Color(0xFF6B7280),
                    size: 20,
                  ),
                  tooltip: 'Download',
                ),
              ),
              const SizedBox(width: 12),
              // Search Bar
              Container(
                width: 200,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: TextField(
                  onChanged: controller.updateSearchQuery,
                  decoration: const InputDecoration(
                    hintText: 'search',
                    hintStyle: TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Color(0xFF9CA3AF),
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Filters Button
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Obx(() => InkWell(
                  onTap: () {
                    // Handle filters functionality
                    _showFiltersModal();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      Container(
                        height: 44,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.tune,
                              color: Color(0xFF6B7280),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Filters',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Filter count badge
                      if (_getActiveFiltersCount(controller) > 0)
                        Positioned(
                          right: -4,
                          top: 6,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEF4444),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${_getActiveFiltersCount(controller)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                )),
              ),
            ],
          ),
        ],
      ),
    );
  }

Widget _buildFilterChip(
  String label,
  AppointmentStatus status,
  Color color,
  AppointmentSchedulingController controller,
  int badgeCount,
  BorderRadius borderRadius,
) {
  return Obx(() {
    final bool selected = controller.selectedStatusFilter.value == status;

    return GestureDetector(
      onTap: () => controller.toggleStatusFilter(status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Color(0xFF1339FF) : Colors.white,
          border: Border.all(
            color: selected ? Color(0xFF1339FF) : const Color(0xFFE5E7EB),
            width: 1,
          ),
          borderRadius: borderRadius,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF374151),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            if (badgeCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  });
}

void _handleDownload() {
    // Handle download functionality
    Get.snackbar(
      'Download',
      'Appointments data is being downloaded...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void _showFiltersModal() {
    Get.dialog(
      const FiltersDialog(),
      barrierDismissible: true,
    );
  }

  int _getActiveFiltersCount(AppointmentSchedulingController controller) {
    int count = 0;
    if (controller.selectedStatusFilter.value != AppointmentStatus.notDone) count++;
    if (controller.searchQuery.value.isNotEmpty) count++;
    // Add more filter conditions as needed
    return count;
  }
}