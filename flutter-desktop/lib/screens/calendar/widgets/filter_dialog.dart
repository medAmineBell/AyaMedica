import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/calendar_controller.dart';
import 'package:get/get.dart';

class FilterDialog extends GetView<CalendarController> {
  const FilterDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Filter Sections
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFilterSection(
                      'Appointment Type',
                      ['Checkup', 'Follow up', 'Vaccination', 'Walk-In'],
                      controller.selectedAppointmentTypes,
                    ),
                    const SizedBox(height: 24),
                    _buildFilterSection(
                      'Disease Type',
                      ['Disease type', 'Type A', 'Type B', 'Type C'],
                      controller.selectedDiseaseTypes,
                    ),
                    const SizedBox(height: 24),
                    _buildFilterSection(
                      'Grade',
                      ['G4', 'G5', 'G6', 'G7'],
                      controller.selectedGrades,
                    ),
                    const SizedBox(height: 24),
                    _buildFilterSection(
                      'Class',
                      ['Lion Class', 'Tiger Class', 'Eagle Class'],
                      controller.selectedClasses,
                    ),
                    const SizedBox(height: 24),
                    _buildFilterSection(
                      'Doctor',
                      ['Dr. Salem Said Al Ali', 'Dr. Ahmad Samir'],
                      controller.selectedDoctors,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    controller.clearFilters();
                  },
                  child: const Text(
                    'Clear All',
                    style: TextStyle(
                      color: Color(0xFF0066FF),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066FF),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Apply',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(
    String title,
    List<String> options,
    RxSet<String> selectedItems,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selectedItems.contains(option);
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  selectedItems.add(option);
                } else {
                  selectedItems.remove(option);
                }
              },
              selectedColor: const Color(0xFF0066FF),
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF374151),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              side: BorderSide(
                color: isSelected 
                    ? const Color(0xFF0066FF) 
                    : const Color(0xFFE5E7EB),
              ),
            );
          }).toList(),
        )),
      ],
    );
  }
}

