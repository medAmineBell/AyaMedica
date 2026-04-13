import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/resources_controller.dart';
import 'package:flutter_getx_app/screens/settings/widgets/gardes_search_filter_widget.dart';
import 'package:flutter_getx_app/screens/settings/widgets/gardes_settings_datatable.dart';
import 'package:flutter_getx_app/screens/settings/widgets/gardes_settings_empty.dart';
import 'package:get/get.dart';

class GardSettingsScreen extends StatelessWidget {
  const GardSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ResourcesController>(
      builder: (controller) {
        return Container(
          color: const Color(0xFFF8FAFC),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Classes Settings',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Ayamedica portal',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.chevron_right,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          'Resources',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.chevron_right,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        const Text(
                          'Classes settings',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF0066FF),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Obx(() {
                  // Show loading
                  if (controller.isLoading.value &&
                      controller.classes.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF1339FF),
                      ),
                    );
                  }

                  // Show empty state
                  if (controller.classes.isEmpty) {
                    return const GardesSettingsEmpty();
                  }

                  // Show list
                  return Column(
                    children: [
                      const GardesFiltersWidget(),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: const GardesSettingsDatatable(),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}
