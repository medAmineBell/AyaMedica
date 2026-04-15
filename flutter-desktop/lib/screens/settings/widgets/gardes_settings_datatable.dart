import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/resources_controller.dart';
import 'package:flutter_getx_app/screens/settings/widgets/create_class_grade.dart';
import 'package:get/get.dart';

class GardesSettingsDatatable extends StatelessWidget {
  const GardesSettingsDatatable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ResourcesController>();

    return Obx(() {
      final classes = controller.filteredClasses;

      if (controller.isLoading.value) {
        return Container(
          padding: const EdgeInsets.all(64),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (classes.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(32),
          child: const Center(
            child: Text(
              'No classes found',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        );
      }

      return Container(
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
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(3), // Name
            1: FlexColumnWidth(2), // Grade
            2: FlexColumnWidth(2), // Max Capacity
            3: FlexColumnWidth(2), // Current Capacity
            4: FlexColumnWidth(2), // Actions
          },
          children: [
            // Header
            _buildHeaderRow(),
            // Data rows
            ...classes.map((classItem) {
              return _buildDataRow(classItem, controller);
            }).toList(),
          ],
        ),
      );
    });
  }

  TableRow _buildHeaderRow() {
    return TableRow(
      decoration: const BoxDecoration(
        color: Color(0xFFF9FAFB),
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      children: [
        _buildHeaderCell(
          child: const Text(
            'Class Name',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
        ),
        _buildHeaderCell(
          child: const Text(
            'Grade',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
        ),
        _buildHeaderCell(
          child: const Text(
            'Maximum Capacity',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
        ),
        _buildHeaderCell(
          child: const Text(
            'Current Students',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
        ),
        _buildHeaderCell(
          child: const Text(
            'Actions',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
        ),
      ],
    );
  }

  TableRow _buildDataRow(
      Map<String, dynamic> classItem, ResourcesController controller) {
    final currentStudents = classItem['studentCount'] ?? 0;
    final maxCapacity = classItem['maximumCapacity'] ?? 0;

    return TableRow(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      children: [
        // Class Name with Avatar
        _buildDataCell(
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: _getClassColor(classItem['name'] ?? ''),
                child: Text(
                  (classItem['name'] ?? 'CL')
                      .split(' ')
                      .take(2)
                      .map((word) => word.isNotEmpty ? word[0] : '')
                      .join()
                      .toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      classItem['name'] ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                    // const SizedBox(height: 2),
                    // Text(
                    //   classItem['classType'] ?? 'Offline',
                    //   style: const TextStyle(
                    //     fontSize: 12,
                    //     color: Color(0xFF6B7280),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Grade
        _buildDataCell(
          child: Text(
            classItem['grade'] ?? '-',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
        // Max Capacity
        _buildDataCell(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$maxCapacity Students',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF059669),
              ),
            ),
          ),
        ),
        // Current Students
        _buildDataCell(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: currentStudents > (maxCapacity * 0.8)
                  ? const Color(0xFFFEF3C7)
                  : const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$currentStudents Students',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: currentStudents > (maxCapacity * 0.8)
                    ? const Color(0xFFD97706)
                    : const Color(0xFF059669),
              ),
            ),
          ),
        ),
        // Actions
        _buildDataCell(
          child: _buildActionButtons(classItem, controller),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
      Map<String, dynamic> classItem, ResourcesController controller) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () {
            _showDeleteConfirmation(classItem, controller);
          },
          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          tooltip: 'Delete',
        ),
        IconButton(
          onPressed: () {
            _showEditDialog(classItem);
          },
          icon: const Icon(Icons.edit_outlined,
              color: Color(0xFF6B7280), size: 18),
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          tooltip: 'Edit',
        ),
        IconButton(
          onPressed: () {
            controller.loadClassDetails(classItem['id']);
          },
          icon: const Icon(Icons.visibility_outlined,
              color: Color(0xFF6B7280), size: 18),
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          tooltip: 'View Details',
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

  Widget _buildDataCell({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: child,
    );
  }

  Color _getClassColor(String className) {
    // Generate a color based on class name hash
    final hash = className.hashCode;
    final colors = [
      const Color(0xFF1339FF),
      const Color(0xFF10B981),
      const Color(0xFFEF4444),
      const Color(0xFF8B5CF6),
      const Color(0xFFF59E0B),
      const Color(0xFF06B6D4),
    ];
    return colors[hash.abs() % colors.length];
  }

  void _showDeleteConfirmation(
      Map<String, dynamic> classItem, ResourcesController controller) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: Color(0xFFFC2E53), size: 28),
            SizedBox(width: 12),
            Text(
              'Delete Class',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${classItem['name']}"? This action cannot be undone.',
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF6B7280),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back(); // Close dialog
              await controller.deleteClass(classItem['id']);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFC2E53),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Delete',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  void _showEditDialog(Map<String, dynamic> classItem) {
    Get.dialog(
      CreateClassScreen(classToEdit: classItem),
    );
  }
}
