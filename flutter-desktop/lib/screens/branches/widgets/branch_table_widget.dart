import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/branch_management_controller.dart';
import 'package:flutter_getx_app/models/branch_model.dart';
import 'package:flutter_getx_app/shared/widgets/dynamic_table_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:flutter_getx_app/controllers/home_controller.dart'; // Added import for HomeController

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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState(BranchManagementController controller) {
    return DynamicTableWidget<BranchModel>(
      items: controller.branches,
      columns: _buildColumnConfigs(),
      actions: _buildActionConfigs(),
      onRowTap: (branch, index) => _activateDeactivateBranch(branch),
      emptyMessage: 'No branches found',
      headerColor: const Color(0xFFF8FAFC),
      borderColor: const Color(0xFFE2E8F0),
    );
  }

  List<TableColumnConfig<BranchModel>> _buildColumnConfigs() {
    return [
      // Branch Icon & Name
      TableColumnConfig<BranchModel>(
        header: 'Branch',
        columnWidth: const FlexColumnWidth(3),
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
                children: [
                  Text(
                    branch.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    branch.principalName!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Contact Information
      TableColumnConfig<BranchModel>(
        header: 'Contact',
        columnWidth: const FlexColumnWidth(2.5),
        cellBuilder: (branch, index) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.phone_outlined,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    branch.phone!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF374151),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.email_outlined,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    branch.email!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF374151),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      // Address
      TableColumnConfig<BranchModel>(
        header: 'Address',
        columnWidth: const FlexColumnWidth(2),
        cellBuilder: (branch, index) => Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 14,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                branch.address!,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF374151),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),

      // Statistics
      TableColumnConfig<BranchModel>(
        header: 'Statistics',
        columnWidth: const FlexColumnWidth(1.5),
        cellBuilder: (branch, index) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.school_outlined,
                  size: 14,
                  color: Colors.blue.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  '${branch.studentCount} students',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 14,
                  color: Colors.green.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  '${branch.teacherCount} teachers',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      // Status
      TableColumnConfig<BranchModel>(
        header: 'Status',
        columnWidth: const FlexColumnWidth(1),
        cellBuilder: (branch, index) => TableCellHelpers.badgeCell(
          branch.status!.toLowerCase() == 'active' ? 'Active' : 'Inactive',
          backgroundColor: branch.status!.toLowerCase() == 'active'
              ? const Color(0xFFDCFCE7)
              : const Color(0xFFFEE2E2),
          textColor: branch.status!.toLowerCase() == 'active'
              ? const Color(0xFF059669)
              : const Color(0xFFDC2626),
        ),
      ),

      // Created Date
      TableColumnConfig<BranchModel>(
        header: 'Created',
        columnWidth: const FlexColumnWidth(1),
        cellBuilder: (branch, index) => TableCellHelpers.textCell(
          _formatDate(branch.createdAt!),
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
          ),
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
        icon: Icons.airplanemode_active,
        color: const Color(0xFFD6A100),
        tooltip: 'Activate/Deactivate branch',
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

void _activateDeactivateBranch(BranchModel branch) {
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
              // Airplane icon
              Icon(Icons.flight, size: 48, color: Colors.amber[700]),
        
              const SizedBox(height: 24),
        
              // Title
              Text(
                'Deactivate ${branch.name}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
        
              const SizedBox(height: 12),
        
              // Subtitle
              const Text(
                'Please confirm that you want to deactivate this branch.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
        
              const SizedBox(height: 32),
        
              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Cancel Button
                  OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
        
                  // Deactivate Button
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                      final controller = Get.find<BranchManagementController>();
                      controller.deactivateBranch(branch.id); // Adjust if you use a different method
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[100],
                      foregroundColor: Colors.brown[700],
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Deactivate branch'),
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


  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditBranchDialog(BranchModel branch) {
    // Navigate to branch form for editing
    final homeController = Get.find<HomeController>();
    homeController.navigateToEditBranch(branch);
  }

 void _showDeleteConfirmation(BranchModel branch) {
  Get.dialog(
    Dialog(
      
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,

      child: SizedBox(
        width: Get.width *0.5 ,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Trash icon
        SvgPicture.asset('assets/svg/trash.svg', width: 48, height: 48,),
              const SizedBox(height: 24),
        
              // Bold title with branch name
              Text(
                'Delete ${branch.name}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
        
              const SizedBox(height: 12),
        
              // Subtitle
              const Text(
                'Please confirm if you want to delete this record. This action cannot be undone.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
        
              const SizedBox(height: 32),
        
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Cancel Button
                  OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
        
                  // Delete Button
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                      final controller = Get.find<BranchManagementController>();
                      controller.deleteBranch(branch.id);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFED1F4F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

// Compact view for dashboard or smaller screens
class CompactBranchTableWidget extends StatelessWidget {
  const CompactBranchTableWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BranchManagementController>();
    
    return Obx(() {
      if (controller.state.value != BranchState.success) {
        return const SizedBox.shrink();
      }

      return DynamicTableWidget<BranchModel>(
        items: controller.branches,
        columns: [
          TableColumnConfig<BranchModel>(
            header: 'Branch',
            columnWidth: const FlexColumnWidth(2),
            cellBuilder: (branch, index) => Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _getBranchColor(branch.name),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.business,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    branch.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          TableColumnConfig<BranchModel>(
            header: 'Students',
            columnWidth: const FlexColumnWidth(1),
            cellBuilder: (branch, index) => TableCellHelpers.badgeCell(
              '${branch.studentCount}',
              backgroundColor: Colors.blue.shade100,
              textColor: Colors.blue.shade800,
            ),
          ),
          TableColumnConfig<BranchModel>(
            header: 'Status',
            columnWidth: const FlexColumnWidth(1),
            cellBuilder: (branch, index) => TableCellHelpers.badgeCell(
              branch.status!.toLowerCase() == 'active' ? 'Active' : 'Inactive',
              backgroundColor: branch.status!.toLowerCase() == 'active'
                  ? Colors.green.shade100
                  : Colors.red.shade100,
              textColor: branch.status!.toLowerCase() == 'active'
                  ? Colors.green.shade800
                  : Colors.red.shade800,
            ),
          ),
        ],
        actions: [
          TableActionConfig<BranchModel>(
            icon: Icons.visibility,
            onPressed: (branch, index) {
              // Show branch details
            },
          ),
        ],
        showActions: true,
        actionColumnWidth: 60,
        emptyMessage: 'No branches',
      );
    });
  }

  Color _getBranchColor(String branchName) {
    final hash = branchName.hashCode;
    final colors = [
      const Color(0xFF3B82F6),
      const Color(0xFF059669),
      const Color(0xFF7C3AED),
      const Color(0xFFDC2626),
      const Color(0xFFD97706),
      const Color(0xFF0891B2),
    ];
    return colors[hash.abs() % colors.length];
  }
}