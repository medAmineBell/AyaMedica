import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/gardes_controller.dart';
import 'package:flutter_getx_app/screens/appointmentScheduling/widgets/appointment_empty_widget.dart';
import 'package:flutter_getx_app/screens/appointmentScheduling/widgets/appointment_error_widget.dart';
import 'package:flutter_getx_app/screens/appointmentScheduling/widgets/appointment_loading_widget.dart';
import 'package:flutter_getx_app/screens/appointmentScheduling/widgets/appointment_success_widget.dart';
import 'package:flutter_getx_app/screens/appointmentScheduling/widgets/create_appointment_dialog.dart';
import 'package:flutter_getx_app/screens/settings/widgets/gardes_search_filter_widget.dart';
import 'package:flutter_getx_app/screens/settings/widgets/gardes_settings_datatable.dart';
import 'package:flutter_getx_app/screens/settings/widgets/gardes_settings_empty.dart';
import 'package:flutter_getx_app/shared/widgets/primary_button.dart';
import 'package:flutter_getx_app/theme/app_theme.dart';
import 'package:get/get.dart';
import '../../../shared/widgets/breadcrumb_widget.dart';
import '../../../controllers/appointment_scheduling_controller.dart';
// import 'widgets/appointment_error_widget.dart';
// import 'widgets/appointment_loading_widget.dart';
// import 'widgets/appointment_success_widget.dart';
// import 'widgets/appointment_empty_widget.dart';

class GardSettingsScreen extends GetView<GardesController> {
  const GardSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFBFCFD),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height -
                80, // Subtract navbar height
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Gardes Setting',
                        style: TextStyle(
                          color: Color(0xFF2D2E2E) /* Text-Text-100 */,
                          fontSize: 20,
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.w700,
                          height: 1.40,
                        ),
                      ),
                      const BreadcrumbWidget(
                        items: [
                          BreadcrumbItem(label: 'Ayamedica portal'),
                          BreadcrumbItem(label: 'Ressources'),
                          BreadcrumbItem(label: 'Gardes settings'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Obx(() {
                return controller.gardes.isEmpty
                    ? GardesSettingsEmpty()
                    : Column(
                        children: [
                          GardesFiltersWidget(),
                          const SizedBox(height: 16),
                          GardesSettingsDatatable(),
                        ],
                      );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // void _showCreateAppointmentDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => const CreateAppointmentDialog(),
  //   );
  // }
}
