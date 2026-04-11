import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/appointment_history_controller.dart';
import 'widgets/appointment_history_table_widget.dart';
import 'widgets/create_appointment_dialog.dart';
import 'widgets/medical_checkup_table_widget.dart';
import 'widgets/vital_signs_table_widget.dart';
import 'widgets/student_table_widget.dart';

class AppointmentHistoryScreen extends StatelessWidget {
  const AppointmentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AppointmentHistoryController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hide title and filters when viewing student table
          Obx(() {
            if (controller.viewingAppointment.value != null) {
              return const SizedBox.shrink();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleSection(controller),
                _buildTabsAndFiltersRow(controller),
              ],
            );
          }),

          // Table content
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Obx(() {
                  // Show student table when viewing an appointment's students
                  if (controller.viewingAppointment.value != null) {
                    final appt = controller.viewingAppointment.value!;
                    // Show hygiene table when disease is Hygiene
                    if (appt.disease.toLowerCase() == 'hygiene') {
                      return MedicalCheckupTableWidget(
                        appointment: appt,
                        onBack: controller.backToList,
                      );
                    }
                    // Show vital signs table for Diabetes, Blood pressure, Cardiovascular, BMI
                    const vitalSignsDiseases = [
                      'diabetes',
                      'blood pressure',
                      'cardiovascular',
                      'bmi'
                    ];
                    if (vitalSignsDiseases
                            .contains(appt.disease.toLowerCase())) {
                      return VitalSignsTableWidget(
                        appointment: appt,
                        onBack: controller.backToList,
                      );
                    }
                    return StudentTableWidget(
                      appointment: appt,
                      onBack: controller.backToList,
                    );
                  }

                  // Show loading spinner for students fetch
                  if (controller.isLoadingStudents.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.state.value ==
                      AppointmentHistoryState.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

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

                  return const AppointmentHistoryTableWidget();
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection(AppointmentHistoryController controller) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Row(
        children: [
          const Text(
            'Appointments',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: Get.context!,
                builder: (context) => const CreateAppointmentDialog(),
              );
            },
            icon: const Icon(
              Icons.add,
              size: 18,
              color: Colors.white,
            ),
            label: const Text(
              'New appointments',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1339FF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabsAndFiltersRow(AppointmentHistoryController controller) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          // Status filter tabs
          Obx(() => _buildStatusTabs(controller)),
          const Spacer(),
          // Download button
          // _buildDownloadButton(),
          // const SizedBox(width: 12),
          // Search field
          _buildSearchField(controller),
          const SizedBox(width: 12),
          // Filters button
          _buildFiltersButton(controller),
        ],
      ),
    );
  }

  Widget _buildStatusTabs(AppointmentHistoryController controller) {
    final radiusStart = const BorderRadius.only(
      topLeft: Radius.circular(8),
      bottomLeft: Radius.circular(8),
    );
    final radiusEnd = const BorderRadius.only(
      topRight: Radius.circular(8),
      bottomRight: Radius.circular(8),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStatusTab(
          'Check In',
          'booked',
          controller.checkedInCount.value,
          controller,
          radiusStart,
        ),
        _buildStatusTab(
          'Checked out',
          'fulfilled',
          controller.checkedOutCount.value,
          controller,
          BorderRadius.zero,
        ),
        _buildStatusTab(
          'Cancelled',
          'cancelled',
          controller.cancelledCount.value,
          controller,
          radiusEnd,
        ),
      ],
    );
  }

  Widget _buildStatusTab(
    String label,
    String filterValue,
    int count,
    AppointmentHistoryController controller,
    BorderRadius borderRadius,
  ) {
    final isSelected = controller.selectedFilter.value == filterValue;

    return GestureDetector(
      onTap: () {
        // Always require one tab selected — don't allow deselecting
        if (!isSelected) {
          controller.filterByStatus(filterValue);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1339FF) : Colors.white,
          border: Border.all(
            color:
                isSelected ? const Color(0xFF1339FF) : const Color(0xFFE5E7EB),
          ),
          borderRadius: borderRadius,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF374151),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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

  Widget _buildDownloadButton() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: IconButton(
        onPressed: () {
          Get.snackbar(
            'Download',
            'Appointments data is being downloaded...',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF10B981),
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        },
        icon: const Icon(
          Icons.download_outlined,
          color: Color(0xFF6B7280),
          size: 20,
        ),
        tooltip: 'Download',
      ),
    );
  }

  Widget _buildSearchField(AppointmentHistoryController controller) {
    return Container(
      width: 200,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextField(
        onChanged: controller.searchAppointments,
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
    );
  }

  Widget _buildFiltersButton(AppointmentHistoryController controller) {
    return Obx(() {
      final filterCount = controller.activeFilterCount;

      return InkWell(
        onTap: () => _showFiltersDialog(controller),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
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
              if (filterCount > 0) ...[
                const SizedBox(width: 6),
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$filterCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  void _showFiltersDialog(AppointmentHistoryController controller) {
    Get.dialog(
      _FiltersDialogContent(controller: controller),
      barrierDismissible: true,
    );
  }
}

class _FiltersDialogContent extends StatefulWidget {
  final AppointmentHistoryController controller;
  const _FiltersDialogContent({required this.controller});

  @override
  State<_FiltersDialogContent> createState() => _FiltersDialogContentState();
}

class _FiltersDialogContentState extends State<_FiltersDialogContent> {
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.controller.startDate.value;
    _endDate = widget.controller.endDate.value;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
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

            // Start date
            const Text(
              'Start date',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 8),
            _buildDateField(
                _startDate, () => _pickDate(context, isStart: true)),

            const SizedBox(height: 16),

            // End date
            const Text(
              'End date',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 8),
            _buildDateField(_endDate, () => _pickDate(context, isStart: false)),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _startDate = DateTime.now();
                      _endDate = DateTime.now();
                    });
                  },
                  child: const Text('Clear'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                    widget.controller.changeDateRange(_startDate, _endDate);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1339FF),
                  ),
                  child: const Text('Apply',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(DateTime date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD1D5DB)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today,
                color: Color(0xFF1339FF), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _formatDate(date),
                style: const TextStyle(color: Color(0xFF111827), fontSize: 14),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down,
                color: Color(0xFF6B7280), size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, {required bool isStart}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: isStart ? DateTime(2020) : _startDate,
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1339FF),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF111827),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }
}
