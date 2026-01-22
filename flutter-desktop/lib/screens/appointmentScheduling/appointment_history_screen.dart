import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/appointment_history_controller.dart';
import 'widgets/appointment_history_table_widget.dart';
import 'widgets/appointment_history_status_tabs_widget.dart';

class AppointmentHistoryScreen extends StatelessWidget {
  const AppointmentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AppointmentHistoryController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Appointment scheduling',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
        actions: [
          // New Appointments Button
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          //   child: ElevatedButton.icon(
          //     onPressed: () {
          //       // Navigate to create new appointment
          //       print('Create new appointment');
          //     },
          //     icon: const Icon(Icons.add, size: 18),
          //     label: const Text(
          //       'New appointments',
          //       style: TextStyle(
          //         fontSize: 14,
          //         fontWeight: FontWeight.w600,
          //       ),
          //     ),
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: const Color(0xFF3B82F6),
          //       foregroundColor: Colors.white,
          //       padding:
          //           const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(8),
          //       ),
          //       elevation: 0,
          //     ),
          //   ),
          // ),
        ],
      ),
      body: Column(
        children: [
          // Status Tabs
          const AppointmentHistoryStatusTabsWidget(),

          // Search and Filters
          _buildSearchAndFilters(controller),

          // Table
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Obx(() {
                // Show loading state
                if (controller.state.value == AppointmentHistoryState.loading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // Show error state
                if (controller.state.value == AppointmentHistoryState.error) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 64, color: Colors.red.shade400),
                        const SizedBox(height: 16),
                        const Text(
                          'Failed to load appointments',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: controller.refreshAppointments,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                }

                // Show empty state
                if (controller.state.value == AppointmentHistoryState.empty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        const Text(
                          'No appointments found',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or filters',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                }

                // Show appointments table
                return const AppointmentHistoryTableWidget();
              }),
            ),
          ),

          // Pagination
          Obx(() => controller.totalPages.value > 1
              ? _buildPagination(controller)
              : const SizedBox()),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(AppointmentHistoryController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          // Export Button
          IconButton(
            onPressed: () {
              print('Export appointments');
            },
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Export',
            style: IconButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Search Field
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'search',
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF3B82F6)),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: controller.searchAppointments,
            ),
          ),
          const SizedBox(width: 12),

          // Filters Button
          OutlinedButton.icon(
            onPressed: () {
              _showFiltersDialog(controller);
            },
            icon: Icon(Icons.tune, color: Colors.grey.shade700),
            label: Obx(() => Text(
                  'Filters ${controller.hasActiveFilters ? "•" : ""}',
                  style: TextStyle(color: Colors.grey.shade700),
                )),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFiltersDialog(AppointmentHistoryController controller) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Appointments',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Status',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 12),
              Obx(() => Wrap(
                    spacing: 8,
                    children: [
                      _buildFilterChip(
                        'All',
                        'all',
                        controller.selectedFilter.value,
                        controller.filterByStatus,
                      ),
                      _buildFilterChip(
                        'Booked',
                        'booked',
                        controller.selectedFilter.value,
                        controller.filterByStatus,
                      ),
                      _buildFilterChip(
                        'Fulfilled',
                        'fulfilled',
                        controller.selectedFilter.value,
                        controller.filterByStatus,
                      ),
                      _buildFilterChip(
                        'Cancelled',
                        'cancelled',
                        controller.selectedFilter.value,
                        controller.filterByStatus,
                      ),
                    ],
                  )),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      controller.filterByStatus('all');
                      Get.back();
                    },
                    child: const Text('Clear'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                    ),
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String value,
    String currentValue,
    Function(String) onSelected,
  ) {
    final isSelected = currentValue == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        onSelected(value);
      },
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF3B82F6).withOpacity(0.1),
      checkmarkColor: const Color(0xFF3B82F6),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF3B82F6) : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? const Color(0xFF3B82F6) : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildPagination(AppointmentHistoryController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: controller.currentPage.value > 1
                ? controller.previousPage
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          const SizedBox(width: 16),
          ...List.generate(
            controller.totalPages.value > 10 ? 10 : controller.totalPages.value,
            (index) {
              final pageNum = index + 1;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  onTap: () => controller.goToPage(pageNum),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: controller.currentPage.value == pageNum
                          ? const Color(0xFF3B82F6)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$pageNum',
                      style: TextStyle(
                        color: controller.currentPage.value == pageNum
                            ? Colors.white
                            : Colors.grey.shade700,
                        fontWeight: controller.currentPage.value == pageNum
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          if (controller.totalPages.value > 10) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('...'),
            ),
          ],
          const SizedBox(width: 16),
          IconButton(
            onPressed:
                controller.currentPage.value < controller.totalPages.value
                    ? controller.nextPage
                    : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
