import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/calendar_controller.dart';
import 'package:flutter_getx_app/screens/calendar/widgets/calendar_widget.dart';
import 'package:get/get.dart';

class CalendarBase extends StatefulWidget {
  const CalendarBase({super.key});

  @override
  State<CalendarBase> createState() => _CalendarBaseState();
}

class _CalendarBaseState extends State<CalendarBase> {
  @override
  void initState() {
    super.initState();
    // Initialize the calendar controller
    Get.put(CalendarController());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFC), // Light background
      child: const CalendarWidget(),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed
    Get.delete<CalendarController>();
    super.dispose();
  }
}
