import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/calendar_controller.dart';
import 'package:flutter_getx_app/shared/widgets/breadcrumb_widget.dart';
import 'package:flutter_getx_app/shared/widgets/primary_button.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'create_appointment_dialog.dart';
import 'filter_dialog.dart';

class CalendarHeader extends GetView<CalendarController> {
  const CalendarHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GlobalKey filterButtonKey = GlobalKey();
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Appointment scheduling',
            style: TextStyle(
              color: Color(0xFF2D2E2E),
              fontSize: 20,
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w700,
              height: 1.40,
            ),
          ),
          // Breadcrumb and New Appointments Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const BreadcrumbWidget(
                items: [
                  BreadcrumbItem(label: 'Ayamedica portal'),
                  BreadcrumbItem(label: 'Appointment scheduling'),
                ],
              ),
              PrimaryButton(
                text: 'New appointments',
                onPressed: () {
                  Get.dialog(
                    const CreateAppointmentDialog(),
                    barrierDismissible: false,
                  );
                },
                icon: Icons.add,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Single Row with Status Tabs on left and buttons on right
          Row(
            children: [
              // Status Tabs - Segmented Control
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: Obx(() => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildStatusTab('Check In', controller.checkInCount, 
                        controller.selectedStatusFilter.value == 'checkIn', isFirst: true),
                    _buildStatusTab('Checked out', controller.checkedOutCount,
                        controller.selectedStatusFilter.value == 'checkedOut'),
                    _buildStatusTab('Cancelled', controller.cancelledCount,
                        controller.selectedStatusFilter.value == 'cancelled', isLast: true),
                  ],
                )),
              ),
              const Spacer(),
              // Export Button
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
                    print('Export data pressed');
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/svg/download.svg',
                        width: 18,
                        height: 18,
                        color: const Color(0xFF7A7A7A),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Search Field
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: _buildSearchField(),
              ),
              const SizedBox(width: 12),
              // Filter Button
              Container(
                key: filterButtonKey,
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: InkWell(
                  onTap: () {
                    _showFilterDialog(context);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/svg/filter-2.svg',
                        width: 18,
                        height: 18,
                        color: const Color(0xFF7A7A7A),
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
                      const SizedBox(width: 8),
                      Obx(() {
                        final filterCount = controller.activeFilterCount;
                        if (filterCount == 0) return const SizedBox.shrink();
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFC2E53),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            filterCount.toString(),
                            style: const TextStyle(
                              color: Color(0xFFF9F9F9),
                              fontSize: 12,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              height: 1.58,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      onChanged: (value) {
        controller.setSearchQuery(value);
      },
      decoration: InputDecoration(
        hintText: 'search',
        hintStyle: TextStyle(color: Colors.grey.shade500),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SvgPicture.asset(
            'assets/svg/search-normal.svg',
            width: 20,
            height: 20,
            color: const Color(0xFF7A7A7A),
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0066FF)),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildStatusTab(String label, int count, bool isActive,
      {bool isFirst = false, bool isLast = false}) {
    return InkWell(
      onTap: () {
        String status;
        switch (label) {
          case 'Check In':
            status = 'checkIn';
            break;
          case 'Checked out':
            status = 'checkedOut';
            break;
          case 'Cancelled':
            status = 'cancelled';
            break;
          default:
            status = 'checkIn';
        }
        controller.setStatusFilter(status);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF0066FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isActive ? Colors.white : const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFC2E53),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1.58,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const FilterDialog(),
    );
  }
}
/*
  Widget _buildViewModeButton(String text, CalendarViewMode mode) {
    return Obx(() {
      final isSelected = controller.currentViewMode.value == mode;
      return GestureDetector(
        onTap: () {
          switch (mode) {
            case CalendarViewMode.day:
              controller.switchToDay();
              break;
            case CalendarViewMode.week:
              controller.switchToWeek();
              break;
            case CalendarViewMode.month:
              controller.switchToMonth();
              break;
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.colorPalette['info']!['main']!
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected
                  ? Colors.white
                  : AppTheme.colorPalette['neutral']!['70']!,
            ),
          ),
        ),
      );
    });
  }

  VoidCallback _getPreviousAction() {
    return () {
      switch (controller.currentViewMode.value) {
        case CalendarViewMode.day:
          controller.goToPreviousDay();
          break;
        case CalendarViewMode.week:
          controller.goToPreviousWeek();
          break;
        case CalendarViewMode.month:
          controller.goToPreviousMonth();
          break;
      }
    };
  }

  VoidCallback _getNextAction() {
    return () {
      switch (controller.currentViewMode.value) {
        case CalendarViewMode.day:
          controller.goToNextDay();
          break;
        case CalendarViewMode.week:
          controller.goToNextWeek();
          break;
        case CalendarViewMode.month:
          controller.goToNextMonth();
          break;
      }
    };
  }

  String _getCurrentDateText() {
    switch (controller.currentViewMode.value) {
      case CalendarViewMode.day:
        return DateFormat('EEEE, d MMMM yyyy')
            .format(controller.selectedDate.value);
      case CalendarViewMode.week:
        final weekDates = controller.getWeekDates();
        final startDate = weekDates.first;
        final endDate = weekDates.last;
        return '${DateFormat('d').format(startDate)} - ${DateFormat('d MMMM yyyy').format(endDate)}';
      case CalendarViewMode.month:
        return DateFormat('MMMM yyyy').format(controller.monthDate.value);
    }
  }
}
*/
