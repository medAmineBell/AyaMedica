import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/calendar_controller.dart';
import 'package:flutter_getx_app/screens/calendar/widgets/calendar_header.dart';
import 'package:flutter_getx_app/screens/calendar/widgets/day_view.dart';
import 'package:flutter_getx_app/screens/calendar/widgets/week_view.dart';
import 'package:flutter_getx_app/screens/calendar/widgets/month_view.dart';
import 'package:get/get.dart';

class CalendarWidget extends GetView<CalendarController> {
  const CalendarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Calendar Header
        const CalendarHeader(),

        // Calendar Content
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Obx(() {
              switch (controller.currentViewMode.value) {
                case CalendarViewMode.day:
                  return const DayView();
                case CalendarViewMode.week:
                  return const WeekView();
                case CalendarViewMode.month:
                  return const MonthView();
              }
            }),
          ),
        ),
      ],
    );
  }
}
