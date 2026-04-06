import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/home_controller.dart';

class SidebarNavigationMenu extends StatelessWidget {
  const SidebarNavigationMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();

    final menuItems = [
      {'icon': Icons.person_outline, 'label': 'Profile'},
      {'icon': Icons.medical_services_outlined, 'label': 'Medical history'},
      {'icon': Icons.assignment_outlined, 'label': 'Medical records'},
      {'icon': Icons.monitor_heart_outlined, 'label': 'Monitoring signs'},
      {'icon': Icons.assessment_outlined, 'label': 'Assessment'},
      {'icon': Icons.event_note_outlined, 'label': 'Plans'},
    ];

    return Obx(() {
      return Column(
        children: menuItems.map((item) {
          final isActive =
              homeController.selectedProfileMenuItem.value == item['label'];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFF3F4F6) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              leading: Icon(
                item['icon'] as IconData,
                color: isActive
                    ? const Color(0xFF2563EB)
                    : const Color(0xFF6B7280),
                size: 20,
              ),
              title: Text(
                item['label'] as String,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                  color: isActive
                      ? const Color(0xFF2563EB)
                      : const Color(0xFF6B7280),
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: Color(0xFF9CA3AF),
                size: 16,
              ),
              onTap: () {
                homeController.selectedProfileMenuItem.value =
                    item['label'] as String;

                // Reset all view states first
                homeController.isMedicalHistoryView.value = false;
                homeController.isMedicalRecordsView.value = false;
                homeController.isSummaryMode.value = false;
                homeController.isAssessmentView.value = false;
                homeController.isMonitoringSignsView.value = false;
                homeController.isPlansView.value = false;

                // Set appropriate view based on selection
                if (item['label'] == 'Medical history') {
                  homeController.isMedicalHistoryView.value = true;
                } else if (item['label'] == 'Medical records') {
                  homeController.isMedicalRecordsView.value = true;
                } else if (item['label'] == 'Assessment') {
                  homeController.isAssessmentView.value = true;
                } else if (item['label'] == 'Monitoring signs') {
                  homeController.isMonitoringSignsView.value = true;
                } else if (item['label'] == 'Plans') {
                  homeController.isPlansView.value = true;
                }
              },
            ),
          );
        }).toList(),
      );
    });
  }
}
