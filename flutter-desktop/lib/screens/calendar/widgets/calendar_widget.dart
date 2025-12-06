import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/calendar_controller.dart';
import 'package:flutter_getx_app/screens/calendar/widgets/calendar_header.dart';
import 'package:flutter_getx_app/screens/calendar/widgets/appointments_list.dart';
import 'package:flutter_getx_app/screens/calendar/widgets/appointment_details_widget.dart';
import 'package:get/get.dart';

class CalendarWidget extends GetView<CalendarController> {
  const CalendarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isShowingDetails = controller.isShowingDetails;
      
      return Column(
        children: [
          // Calendar Header - only show when not in details view
          if (!isShowingDetails) const CalendarHeader(),

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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: isShowingDetails && controller.selectedAppointmentForDetails.value != null
                    ? AppointmentDetailsWidget(
                        appointment: controller.selectedAppointmentForDetails.value!,
                      )
                    : const AppointmentsList(),
              ),
            ),
          ),
        ],
      );
    });
  }
}
