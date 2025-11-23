import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/appointment_scheduling_controller.dart';
import 'table_view_switcher_widget.dart';

class AppointmentSuccessWidget extends StatelessWidget {
  const AppointmentSuccessWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AppointmentSchedulingController>();
    
    return Obx(() {
      if (controller.screenState.value == AppointmentScreenState.success) {
        return Column(
          children: [
           // Table View Switcher (this will handle all view modes)
            const TableViewSwitcherWidget(),
          ],
        );
      } else {
        return const Center(child: Text('No appointments to display'));
      }
    });
  }
}