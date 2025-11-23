import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/communication_controller.dart';
import 'package:get/get.dart';
import '../../../controllers/appointment_scheduling_controller.dart';
import '../../../models/appointment_models.dart';

class CommunicationFiltersWidget extends StatelessWidget {
  const CommunicationFiltersWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CommunicationController>();

    // corner radii for the chip group
    final radiusStart = BorderRadius.only(
      topLeft: Radius.circular(8),
      bottomLeft: Radius.circular(8),
    );
    final radiusMiddle = BorderRadius.zero;
    final radiusEnd = BorderRadius.only(
      topRight: Radius.circular(8),
      bottomRight: Radius.circular(8),
    );

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          // status chips
          Obx(() {
            return Wrap(
              children: [
                _buildFilterChip(
                  label: 'Inbox',
                  status: 'Inbox',
                  controller: controller,
                  badgeCount: 0,
                  borderRadius: radiusStart,
                ),
                _buildFilterChip(
                  label: 'Sent',
                  status: 'Sent',
                  controller: controller,
                  badgeCount: 0,
                  borderRadius: radiusMiddle,
                ),
                _buildFilterChip(
                  label: 'Received records',
                  status: 'Received records',
                  controller: controller,
                  badgeCount: 0,
                  borderRadius: radiusMiddle,
                ),
                _buildFilterChip(
                  label: 'Vaccination requests',
                  status: 'Vaccination requests',
                  controller: controller,
                  badgeCount: 0,
                  borderRadius: radiusEnd,
                ),
              ],
            );
          }),

          Spacer(),
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
          // search bar
          Container(
            width: 400,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFFE5E7EB)),
            ),
            child: TextField(
              onChanged: controller.updateSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search, color: Color(0xFF9CA3AF)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
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
              child: InkWell(
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
                    // if (_getActiveFiltersCount(controller) > 0)
                    //   Positioned(
                    //     right: -4,
                    //     top: 6,
                    //     child: Container(
                    //       width: 20,
                    //       height: 20,
                    //       decoration: const BoxDecoration(
                    //         color: Color(0xFFEF4444),
                    //         shape: BoxShape.circle,
                    //       ),
                    //       child: Center(
                    //         child: Text(
                    //           '',
                    //           style: const TextStyle(
                    //             color: Colors.white,
                    //             fontSize: 11,
                    //             fontWeight: FontWeight.w600,
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String status,
    required CommunicationController controller,
    required int badgeCount,
    required BorderRadius borderRadius,
  }) {
    final selected = controller.selectedStatusFilter.value == status;

    return GestureDetector(
      onTap: () => controller.toggleStatusFilter(status),
      child: Container(
        margin: EdgeInsets.only(right: 1),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Color(0xFF274CD2) : Colors.white,
          border: Border.all(
            color: selected ? Color(0xFF274CD2) : Color(0xFFE5E7EB),
          ),
          borderRadius: borderRadius,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Color(0xFF374151),
                fontWeight: FontWeight.w600,
              ),
            ),
            if (badgeCount > 0) ...[
              SizedBox(width: 6),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$badgeCount',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
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
  Get.bottomSheet(
    Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filters',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Date Range',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          // Add your filter options here
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // Handle date picker
                  },
                  child: const Text('Start Date'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // Handle date picker
                  },
                  child: const Text('End Date'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // Clear filters
                    Get.back();
                  },
                  child: const Text('Clear'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Apply filters
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                  ),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    isScrollControlled: true,
  );
}

int _getActiveFiltersCount(AppointmentSchedulingController controller) {
  int count = 0;
  if (controller.selectedStatusFilter.value != null) count++;
  if (controller.searchQuery.value.isNotEmpty) count++;
  // Add more filter conditions as needed
  return count;
}
