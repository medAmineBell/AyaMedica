import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/home_controller.dart';
import 'package:flutter_getx_app/screens/students/widgets/student_data_table.dart';
import 'package:flutter_getx_app/shared/widgets/breadcrumb_widget.dart';
import 'package:get/get.dart';

class StudentsListScreen extends StatelessWidget {
  const StudentsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFBFCFD),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Students List',
                    style: TextStyle(
                      color: Color(0xFF2D2E2E),
                      fontSize: 20,
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.w700,
                      height: 1.40,
                    ),
                  ),
                  BreadcrumbWidget(
                    items: [
                      BreadcrumbItem(label: 'Ayamedica portal'),
                      BreadcrumbItem(label: 'Students'),
                      BreadcrumbItem(label: 'Students List'),
                    ],
                  ),
                ],
              ),
              _buildFavoriteDrugsButton(),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(child: StudentDataTable()),
        ],
      ),
    );
  }

  Widget _buildFavoriteDrugsButton() {
    final homeController = Get.find<HomeController>();
    return InkWell(
      onTap: () => homeController.navigateToFavoriteDrugs(),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: const Color(0xFF1339FF),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.archive_outlined,
                color: Color(0xFFFFFFFF), size: 18),
            const SizedBox(width: 8),
            const Text(
              'Favorites drugs list',
              style: TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 13,
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
