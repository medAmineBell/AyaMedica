import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/reports_controller.dart';
import 'package:flutter_getx_app/screens/reports/widgets/generate_report_dialog.dart';
import 'package:flutter_getx_app/screens/reports/widgets/reports_list_widget.dart';
import 'package:get/get.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize controller if not already initialized
    if (!Get.isRegistered<ReportsController>()) {
      Get.put(ReportsController());
    }
    final controller = Get.find<ReportsController>();

    return Container(
      color: const Color(0xFFF8FAFC),
      child: Column(
        children: [
          // Header with breadcrumb
          _buildHeader(),
          
          // Content - either empty state or list
          Expanded(
            child: Obx(() {
              if (controller.reports.isEmpty) {
                return Center(
                  child: _buildEmptyState(),
                );
              }
              return const ReportsListWidget();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reports',
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
              Icon(Icons.chevron_right, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                'Students',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              const Text(
                'Reports',
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
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Folder icon
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.folder_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
        ),
        const SizedBox(height: 32),
        
        // Title
        const Text(
          'Generate reports',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 16),
        
        // Description
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'There is no available reports click on the button bellow to generate a new report',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ),
        const SizedBox(height: 32),
        
        // Generate report button
        ElevatedButton.icon(
          onPressed: () {
            Get.dialog(
              const GenerateReportDialog(),
              barrierDismissible: false,
            );
          },
          icon: const Icon(Icons.add, size: 20),
          label: const Text(
            'Generate report',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF374151),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey[300]!),
            ),
            elevation: 0,
          ),
        ),
      ],
    );
  }
}

