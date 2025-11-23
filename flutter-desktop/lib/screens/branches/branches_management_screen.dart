import 'package:flutter/material.dart';
import 'package:flutter_getx_app/models/branch_model.dart';
import 'package:flutter_getx_app/screens/branches/widgets/branch_table_widget.dart';
import 'package:get/get.dart';

import '../../controllers/branch_management_controller.dart';
import '../../controllers/home_controller.dart';

class BranchManagementScreen extends StatelessWidget {
  const BranchManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize the controller
    final controller = Get.put(BranchManagementController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Branch Management',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
        actions: [
          Obx(() => controller.isLoading.value
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  onPressed: () => controller.refreshBranches(),
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh',
                )),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Header with stats and add button
          _buildHeader(controller),
          
          // Main table content
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: const BranchTableWidget(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Obx(() => controller.state.value == BranchState.success
          ? FloatingActionButton.extended(
              onPressed: () => Get.find<HomeController>().navigateToAddBranch(),
              icon: const Icon(Icons.add),
              label: const Text('Add Branch'),
              backgroundColor: const Color(0xFF3B82F6),
            )
          : const SizedBox.shrink()),
    );
  }

  Widget _buildHeader(BranchManagementController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [

          
          // Search and filter bar
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search branches...',
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
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
                      borderSide: const BorderSide(color: Color(0xFF3B82F6)),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    // Implement search functionality
                    _handleSearch(value, controller);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: PopupMenuButton<String>(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.filter_list, color: Colors.grey.shade600),
                        const SizedBox(width: 8),
                        Text(
                          'Filter',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'all',
                      child: Text('All Branches'),
                    ),
                    const PopupMenuItem(
                      value: 'active',
                      child: Text('Active Only'),
                    ),
                    const PopupMenuItem(
                      value: 'inactive',
                      child: Text('Inactive Only'),
                    ),
                  ],
                  onSelected: (value) {
                    _handleFilter(value, controller);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _handleSearch(String query, BranchManagementController controller) {
    // Implement search logic here
    // You could filter the branches list based on the search query
    // For now, just print the search query
    print('Searching for: $query');
  }

  void _handleFilter(String filter, BranchManagementController controller) {
    // Implement filter logic here
    // You could filter the branches list based on status
    print('Applying filter: $filter');
  }
}