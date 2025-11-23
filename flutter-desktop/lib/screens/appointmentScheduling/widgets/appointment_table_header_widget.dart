import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/appointment_scheduling_controller.dart';

class AppointmentTableHeaderWidget {
  const AppointmentTableHeaderWidget();

  TableRow buildHeaderRow() {
    final controller = Get.find<AppointmentSchedulingController>();
    
    return TableRow(
      decoration: const BoxDecoration(
        color: Color(0xFFF9FAFB),
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      children: [
        _buildHeaderCell(
          child: Obx(() => Checkbox(
            value: controller.isAllSelected,
            onChanged: (value) => controller.toggleSelectAll(),
            activeColor: const Color(0xFF1339FF),
          )),
        ),
        _buildHeaderCell(child: const SizedBox()),
        _buildHeaderCell(
          child: const Text(
            'Student full name',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
        _buildHeaderCell(
          child: Row(
            children: [
              const Text(
                'AID',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.help_outline,
                size: 14,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
        _buildHeaderCell(
          child: const Text(
            'Status',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
        _buildHeaderCell(
          child: const Text(
            'Bulk action',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCell({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: child,
    );
  }
}