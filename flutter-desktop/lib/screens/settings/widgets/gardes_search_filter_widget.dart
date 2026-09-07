import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/resources_controller.dart';
import 'package:flutter_getx_app/screens/settings/widgets/create_class_grade.dart';
import 'package:get/get.dart';

class GardesFiltersWidget extends StatelessWidget {
  const GardesFiltersWidget({Key? key}) : super(key: key);

  Widget _buildCountBadge({
    required IconData icon,
    required String label,
    required int count,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF1339FF)),
          const SizedBox(width: 6),
          Text(
            '$count $label',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ResourcesController>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          // Search Text Field
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.3,
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: TextField(
                controller: controller.searchTextController,
                onChanged: controller.setSearchQuery,
                decoration: const InputDecoration(
                  hintText: 'Search classes...',
                  hintStyle: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Color(0xFF9CA3AF),
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF111827),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Counters
          Obx(() {
            final filtered = controller.filteredClasses;
            final classesCount = filtered.length;
            final gradesCount = filtered
                .map((c) => c['grade'] as String?)
                .where((g) => g != null && g.isNotEmpty)
                .toSet()
                .length;
            return Row(
              children: [
                _buildCountBadge(
                  icon: Icons.class_outlined,
                  label: 'Classes',
                  count: classesCount,
                ),
                const SizedBox(width: 8),
                _buildCountBadge(
                  icon: Icons.grade_outlined,
                  label: 'Grades',
                  count: gradesCount,
                ),
              ],
            );
          }),

          const Spacer(),

          // Add Class Button
          ElevatedButton.icon(
            onPressed: () {
              Get.dialog(
                const CreateClassScreen(),
                barrierDismissible: false,
              );
            },
            icon: const Icon(
              Icons.add,
              size: 20,
              color: Colors.white,
            ),
            label: const Text(
              'Add Class',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1339FF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              minimumSize: const Size(0, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}
