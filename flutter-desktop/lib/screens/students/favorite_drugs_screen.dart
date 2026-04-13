import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/favorite_drugs_controller.dart';
import 'package:flutter_getx_app/controllers/home_controller.dart';
import 'package:flutter_getx_app/shared/widgets/dynamic_table_widget.dart';
import 'package:get/get.dart';

class FavoriteDrugsScreen extends StatelessWidget {
  const FavoriteDrugsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    final controller = Get.find<FavoriteDrugsController>();

    return Container(
      color: const Color(0xFFFBFCFD),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          InkWell(
            onTap: () => homeController.exitFavoriteDrugs(),
            borderRadius: BorderRadius.circular(4),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back, size: 20, color: Color(0xFF374151)),
                  SizedBox(width: 8),
                  Text(
                    'Back',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                      fontFamily: 'IBM Plex Sans Arabic',
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'To student list',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF6B7280),
                      fontFamily: 'IBM Plex Sans Arabic',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Add new drug section
          const Text(
            'Add new drug',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
              fontFamily: 'IBM Plex Sans Arabic',
            ),
          ),
          const SizedBox(height: 12),
          _buildAddDrugRow(controller),
          const SizedBox(height: 32),

          // Favorite drug white list section
          const Text(
            'Favorite drug white list',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
              fontFamily: 'IBM Plex Sans Arabic',
            ),
          ),
          const SizedBox(height: 12),

          // Favorites table
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade100,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Obx(() {
                if (controller.isLoadingFavorites.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF1339FF),
                    ),
                  );
                }
                return DynamicTableWidget<Map<String, dynamic>>(
                  items: controller.favoriteDrugs.toList(),
                  columns: [
                    TableColumnConfig<Map<String, dynamic>>(
                      header: 'Drug name',
                      columnWidth: const FlexColumnWidth(2),
                      cellBuilder: (drug, _) => TableCellHelpers.textCell(
                        drug['drug_name']?.toString() ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ),
                    TableColumnConfig<Map<String, dynamic>>(
                      header: 'Ingredients',
                      columnWidth: const FlexColumnWidth(2),
                      cellBuilder: (drug, _) => TableCellHelpers.textCell(
                        drug['ingredients']?.toString() ?? '',
                      ),
                    ),
                    TableColumnConfig<Map<String, dynamic>>(
                      header: 'Manufacturer',
                      columnWidth: const FlexColumnWidth(2),
                      cellBuilder: (drug, _) => TableCellHelpers.textCell(
                        drug['manufacturer']?.toString() ?? '',
                      ),
                    ),
                    TableColumnConfig<Map<String, dynamic>>(
                      header: 'Pharmacology',
                      columnWidth: const FlexColumnWidth(1.5),
                      cellBuilder: (drug, _) => TableCellHelpers.textCell(
                        drug['pharmacology']?.toString() ?? '',
                      ),
                    ),
                  ],
                  actions: [
                    TableActionConfig<Map<String, dynamic>>(
                      icon: Icons.delete_outline,
                      color: const Color(0xFFEF4444),
                      tooltip: 'Remove from favorites',
                      onPressed: (drug, _) => controller.removeFavorite(drug),
                    ),
                  ],
                  emptyMessage: 'No favorite drugs added yet',
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddDrugRow(FavoriteDrugsController controller) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search field with dropdown
        Expanded(
          child: Column(
            children: [
              TextField(
                controller: controller.drugSearchController,
                onChanged: controller.onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Add new drug',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  prefixIcon:
                      Icon(Icons.search, color: Colors.grey.shade400),
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
                    borderSide: const BorderSide(color: Color(0xFF1339FF)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              // Search results dropdown
              Obx(() {
                if (controller.drugSearchResults.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: controller.drugSearchResults.length,
                    itemBuilder: (context, index) {
                      final drug = controller.drugSearchResults[index];
                      final drugName =
                          drug['drug_name']?.toString() ?? 'Unknown';
                      final ingredients =
                          drug['ingredients']?.toString() ?? '';
                      return InkWell(
                        onTap: () => controller.selectDrug(drug),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey.shade200,
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                drugName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF374151),
                                ),
                              ),
                              if (ingredients.isNotEmpty)
                                Text(
                                  ingredients,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Add button
        Obx(() => InkWell(
              onTap: controller.isAddingFavorite.value
                  ? null
                  : () => controller.addSelectedToFavorites(),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFF1339FF),
                  shape: BoxShape.circle,
                ),
                child: controller.isAddingFavorite.value
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.add, color: Colors.white, size: 24),
              ),
            )),
      ],
    );
  }
}
