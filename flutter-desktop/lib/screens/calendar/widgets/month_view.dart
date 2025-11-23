import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/calendar_controller.dart';
import 'package:flutter_getx_app/models/appointment_models.dart';
import 'package:flutter_getx_app/theme/app_theme.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class MonthView extends GetView<CalendarController> {
  const MonthView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Month Header with Days of Week
        Container(
          decoration: BoxDecoration(
            color: AppTheme.colorPalette['neutral']!['10']!,
            border: Border(
              bottom: BorderSide(
                color: AppTheme.colorPalette['neutral']!['30']!,
              ),
            ),
          ),
          child: Row(
            children:
                ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((day) {
              return Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      day,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.colorPalette['neutral']!['70']!,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // Calendar Grid
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(1),
            child: Obx(() {
              final monthDates = controller.getMonthDates();
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1.2,
                ),
                itemCount: 42, // 6 weeks
                itemBuilder: (context, index) {
                  final date = monthDates[index];
                  final isCurrentMonth =
                      date.month == controller.monthDate.value.month;
                  final isToday = _isToday(date);
                  final dayAppointments =
                      controller.getAppointmentsForDate(date);

                  return Container(
                    margin: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: isToday
                          ? AppTheme.colorPalette['info']!['surface']!
                              .withOpacity(0.3)
                          : Colors.white,
                      border: Border.all(
                        color: AppTheme.colorPalette['neutral']!['20']!,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date number
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            DateFormat('d').format(date),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isCurrentMonth
                                  ? (isToday
                                      ? AppTheme.colorPalette['info']!['main']!
                                      : AppTheme
                                          .colorPalette['neutral']!['90']!)
                                  : AppTheme.colorPalette['neutral']!['40']!,
                            ),
                          ),
                        ),

                        // Appointments indicators
                        if (dayAppointments.isNotEmpty)
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: Column(
                                children:
                                    dayAppointments.take(3).map((appointment) {
                                  final status = controller.appointmentStatuses[
                                          appointment.id] ??
                                      AppointmentStatus.notDone;
                                  return Container(
                                    width: double.infinity,
                                    height: 16,
                                    margin: const EdgeInsets.only(bottom: 2),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(status),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _getStatusText(status),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),

                        // More appointments indicator
                        if (dayAppointments.length > 3)
                          Padding(
                            padding: const EdgeInsets.only(left: 8, bottom: 4),
                            child: Text(
                              '+${dayAppointments.length - 3} more',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.colorPalette['neutral']!['60']!,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ),
      ],
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.done:
        return AppTheme.colorPalette['success']!['main']!;
      case AppointmentStatus.notDone:
        return AppTheme.colorPalette['danger']!['main']!;
      case AppointmentStatus.cancelled:
        return AppTheme.colorPalette['danger']!['main']!;
      case AppointmentStatus.received:
        return const Color(0xFFF59E0B); // Yellow
      default:
        return Colors.transparent;
    }
  }

  String _getStatusText(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.done:
        return 'Paid';
      case AppointmentStatus.notDone:
        return 'Urgent';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      case AppointmentStatus.received:
        return 'Visit Finalized';
      default:
        return 'Unknown';
    }
  }
}
