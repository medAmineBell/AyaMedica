import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/branch_management_controller.dart';
import 'package:flutter_getx_app/models/branch_model.dart';
import 'package:flutter_getx_app/shared/widgets/dynamic_table_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:flutter_getx_app/controllers/home_controller.dart';

class BranchTableWidget extends StatelessWidget {
  const BranchTableWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BranchManagementController>();
    return Obx(() {
      // Handle different states
      switch (controller.state.value) {
        case BranchState.loading:
          return _buildLoadingState();
        case BranchState.error:
          return _buildErrorState(controller);
        case BranchState.empty:
          return _buildEmptyState(controller);
        case BranchState.success:
          return _buildSuccessState(controller);
      }
    });
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading branches...',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BranchManagementController controller) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load branches',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.red.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => controller.refreshBranches(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BranchManagementController controller) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'No branches found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first branch to get started',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Get.find<HomeController>().navigateToAddBranch(),
              icon: const Icon(Icons.add),
              label: const Text('Add Branch'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState(BranchManagementController controller) {
    return Obx(() {
      final filtered = controller.filteredBranches;

      // Show empty state if filtered list is empty but branches exist
      if (filtered.isEmpty && controller.branches.isNotEmpty) {
        return Container(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No branches match your search',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try adjusting your search or filters',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return SingleChildScrollView(
        child: DynamicTableWidget<BranchModel>(
          items: filtered,
          columns: _buildColumnConfigs(),
          actions: _buildActionConfigs(),
          onRowTap: (branch, index) => _showBranchDetails(branch),
          emptyMessage: 'No branches found',
          headerColor: const Color(0xFFF8FAFC),
          borderColor: const Color(0xFFE2E8F0),
        ),
      );
    });
  }

  List<TableColumnConfig<BranchModel>> _buildColumnConfigs() {
    return [
      // Branch name & AID (ID below name) - Like Screenshot
      TableColumnConfig<BranchModel>(
        header: 'Branch name & AID',
        columnWidth: const FlexColumnWidth(2.5),
        cellBuilder: (branch, index) => Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getBranchColor(branch.name),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getBranchIcon(branch.icon),
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    branch.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    branch.id.substring(0, 12).toUpperCase(), // Short ID
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9CA3AF),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // City & Governorate - Like Screenshot
      TableColumnConfig<BranchModel>(
        header: 'City & Governorate',
        columnWidth: const FlexColumnWidth(2),
        cellBuilder: (branch, index) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${branch.city ?? 'N/A'} , ${branch.governorate ?? 'N/A'}',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),

      // Number of users - Like Screenshot
      TableColumnConfig<BranchModel>(
        header: 'Number of users',
        columnWidth: const FlexColumnWidth(1.2),
        cellBuilder: (branch, index) => Text(
          '${branch.teacherCount ?? 0}', // teacherCount = totalUsers
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
          textAlign: TextAlign.center,
        ),
      ),

      // Number of students - Like Screenshot
      TableColumnConfig<BranchModel>(
        header: 'Number of students',
        columnWidth: const FlexColumnWidth(1.5),
        cellBuilder: (branch, index) => Text(
          '${branch.studentCount ?? 0}', // studentCount = totalStudents
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
          textAlign: TextAlign.center,
        ),
      ),

      // Status - Like Screenshot
      TableColumnConfig<BranchModel>(
        header: 'Status',
        columnWidth: const FlexColumnWidth(1),
        cellBuilder: (branch, index) => TableCellHelpers.badgeCell(
          branch.status?.toLowerCase() == 'active' ? 'Active' : 'Inactive',
          backgroundColor: branch.status?.toLowerCase() == 'active'
              ? const Color(0xFFDCFCE7)
              : const Color(0xFFFEE2E2),
          textColor: branch.status?.toLowerCase() == 'active'
              ? const Color(0xFF059669)
              : const Color(0xFFDC2626),
        ),
      ),
    ];
  }

  List<TableActionConfig<BranchModel>> _buildActionConfigs() {
    return [
      TableActionConfig<BranchModel>(
        icon: Icons.delete_outline,
        color: const Color(0xFFDC2626),
        tooltip: 'Delete branch',
        onPressed: (branch, index) => _showDeleteConfirmation(branch),
      ),
      TableActionConfig<BranchModel>(
        icon: Icons.edit_outlined,
        color: const Color(0xFF747677),
        tooltip: 'Edit branch',
        onPressed: (branch, index) => _showEditBranchDialog(branch),
      ),
      TableActionConfig<BranchModel>(
        icon: Icons.settings_outlined,
        color: const Color(0xFFD6A100),
        tooltip: 'Manage branch',
        onPressed: (branch, index) => _activateDeactivateBranch(branch),
      ),
    ];
  }

  Color _getBranchColor(String branchName) {
    final hash = branchName.hashCode;
    final colors = [
      const Color(0xFF3B82F6), // Blue
      const Color(0xFF059669), // Green
      const Color(0xFF7C3AED), // Purple
      const Color(0xFFDC2626), // Red
      const Color(0xFFD97706), // Orange
      const Color(0xFF0891B2), // Cyan
    ];
    return colors[hash.abs() % colors.length];
  }

  IconData _getBranchIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'clinic':
        return Icons.local_hospital;
      case 'school':
        return Icons.school;
      case 'office':
        return Icons.business;
      default:
        return Icons.business;
    }
  }

  void _showBranchDetails(BranchModel branch) {
    // Optional: Show details on row tap
    print('Branch tapped: ${branch.name}');
  }

  void _activateDeactivateBranch(BranchModel branch) {
    final controller = Get.find<BranchManagementController>();
    final isActive = branch.status?.toLowerCase() == 'active';

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: SizedBox(
          width: Get.width * 0.5,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isActive
                      ? Icons.pause_circle_outline
                      : Icons.check_circle_outline,
                  size: 48,
                  color: isActive ? Colors.amber[700] : Colors.green[600],
                ),
                const SizedBox(height: 24),
                Text(
                  '${isActive ? 'Deactivate' : 'Activate'} ${branch.name}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  isActive
                      ? 'Please confirm that you want to deactivate this branch. The branch will be temporarily disabled.'
                      : 'Please confirm that you want to activate this branch. The branch will be reactivated and accessible.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Get.back();
                        if (isActive) {
                          controller.deactivateBranch(branch.id);
                        } else {
                          controller.activateBranch(branch.id);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isActive ? Colors.amber[100] : Colors.green[100],
                        foregroundColor:
                            isActive ? Colors.brown[700] : Colors.green[800],
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                          '${isActive ? 'Deactivate' : 'Activate'} branch'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditBranchDialog(BranchModel branch) {
    final homeController = Get.find<HomeController>();
    homeController.navigateToEditBranch(branch);
  }

  void _showDeleteConfirmation(BranchModel branch) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: SizedBox(
          width: Get.width * 0.5,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/svg/trash.svg',
                  width: 48,
                  height: 48,
                ),
                const SizedBox(height: 24),
                Text(
                  'Delete ${branch.name}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Please confirm if you want to delete this record. This action cannot be undone.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Get.back();
                        final controller =
                            Get.find<BranchManagementController>();
                        controller.deleteBranch(branch.id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFED1F4F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Delete branch'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
