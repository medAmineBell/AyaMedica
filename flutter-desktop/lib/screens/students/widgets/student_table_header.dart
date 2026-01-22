import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/student_controller.dart';

class StudentTableHeader extends StatelessWidget {
  final StudentController controller;
  final VoidCallback onAddStudent;

  const StudentTableHeader({
    Key? key,
    required this.controller,
    required this.onAddStudent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Expanded(child: _buildSearchField()),
          SizedBox(width: 16),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      onChanged: controller.searchStudents,
      decoration: InputDecoration(
        hintText: 'search',
        hintStyle: TextStyle(color: Colors.grey.shade500),
        prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blue.shade400),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        _ActionButton(
          icon: Icons.download_outlined,
          onTap: _handleExport,
        ),
        SizedBox(width: 12),
        _ActionButton(
          icon: Icons.add,
          label: 'Add student(s)',
          onTap: onAddStudent,
        ),
        SizedBox(width: 12),
        _ActionButton(
          icon: Icons.tune,
          label: 'Filters',
          onTap: () {},
        ),
      ],
    );
  }

  void _handleExport() {
    Get.snackbar(
      'Export',
      'Export functionality coming soon',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String? label;
  final VoidCallback onTap;

  const _ActionButton({
    Key? key,
    required this.icon,
    this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: Colors.grey.shade700),
            if (label != null) ...[
              SizedBox(width: 8),
              Text(
                label!,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
