import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/calendar_controller.dart';
import 'package:flutter_getx_app/shared/widgets/breadcrumb_widget.dart';
import 'package:flutter_getx_app/shared/widgets/primary_button.dart';
import 'package:flutter_getx_app/theme/app_theme.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'create_appointment_dialog.dart';

class CalendarHeader extends GetView<CalendarController> {
  const CalendarHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Breadcrumb and New Appointments Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const BreadcrumbWidget(
                items: [
                  BreadcrumbItem(label: 'Ayamedica portal'),
                  BreadcrumbItem(label: 'Scheduling calendar'),
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

          // Calendar Controls
          Row(
            children: [
              // Appointments Count
              Obx(() {
                final appointmentsCount = controller.appointments.length;
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.colorPalette['neutral']!['20']!,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: AppTheme.colorPalette['neutral']!['70']!,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$appointmentsCount Appointments',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.colorPalette['neutral']!['70']!,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const Spacer(),

              // View Mode Buttons
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.colorPalette['neutral']!['10']!,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.colorPalette['neutral']!['30']!,
                  ),
                ),
                child: Row(
                  children: [
                    _buildViewModeButton('Day', CalendarViewMode.day),
                    _buildViewModeButton('Week', CalendarViewMode.week),
                    _buildViewModeButton('Month', CalendarViewMode.month),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Date Navigation
              Row(
                children: [
                  // Today Button
                  TextButton(
                    onPressed: controller.goToToday,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      backgroundColor: AppTheme.colorPalette['neutral']!['10']!,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: AppTheme.colorPalette['neutral']!['30']!,
                        ),
                      ),
                    ),
                    child: Text(
                      'Today',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.colorPalette['neutral']!['70']!,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Previous Button
                  IconButton(
                    onPressed: _getPreviousAction(),
                    icon: const Icon(Icons.chevron_left),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.colorPalette['neutral']!['10']!,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: AppTheme.colorPalette['neutral']!['30']!,
                        ),
                      ),
                    ),
                  ),

                  // Current Date Display
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Obx(() {
                      return Text(
                        _getCurrentDateText(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      );
                    }),
                  ),

                  // Next Button
                  IconButton(
                    onPressed: _getNextAction(),
                    icon: const Icon(Icons.chevron_right),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.colorPalette['neutral']!['10']!,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: AppTheme.colorPalette['neutral']!['30']!,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 16),

              // Filters Button
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.colorPalette['neutral']!['10']!,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.colorPalette['neutral']!['30']!,
                  ),
                ),
                child: Row(
                  children: [
                    // All Doctors Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 16,
                            color: AppTheme.colorPalette['neutral']!['70']!,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'All Doctors',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.colorPalette['neutral']!['70']!,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.keyboard_arrow_down,
                            size: 16,
                            color: AppTheme.colorPalette['neutral']!['70']!,
                          ),
                        ],
                      ),
                    ),

                    Container(
                      width: 1,
                      height: 32,
                      color: AppTheme.colorPalette['neutral']!['30']!,
                    ),

                    // Filters Button
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.filter_list,
                            size: 16,
                            color: AppTheme.colorPalette['neutral']!['70']!,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Filters',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.colorPalette['neutral']!['70']!,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.colorPalette['danger']!['main']!,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              '1',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
