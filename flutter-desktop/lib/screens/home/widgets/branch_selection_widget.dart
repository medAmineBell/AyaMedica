import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/branch_management_controller.dart';

class BranchSelectionWidget extends StatefulWidget {
  final Widget? trailingIcon;

  const BranchSelectionWidget({
    super.key,
    this.trailingIcon,
  });

  @override
  State<BranchSelectionWidget> createState() => _BranchSelectionWidgetState();
}

class _BranchSelectionWidgetState extends State<BranchSelectionWidget> {
  bool isHovered = false;
  String? selectedBranchId;

  @override
  void initState() {
    super.initState();
    // Set default selected branch to the first active branch
    try {
      final branchController = Get.find<BranchManagementController>();
      final activeBranches = branchController.branches
          .where((branch) => branch.status == 'active')
          .toList();
      if (activeBranches.isNotEmpty) {
        selectedBranchId = activeBranches.first.id;
      }
    } catch (e) {
      // Controller not found, will be handled in build method
      print('BranchManagementController not found: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BranchManagementController>(
      builder: (branchController) {
        print(
            'BranchSelectionWidget: Building with ${branchController.branches.length} branches');

        // Check if controller is initialized and has branches
        if (branchController.branches.isEmpty) {
          print('BranchSelectionWidget: No branches available');
          return _buildFallbackWidget();
        }

        final activeBranches = branchController.branches
            .where((branch) => branch.status == 'active')
            .toList();

        print(
            'BranchSelectionWidget: ${activeBranches.length} active branches');

        if (activeBranches.isEmpty) {
          return _buildFallbackWidget();
        }

        final selectedBranch = activeBranches
                .firstWhereOrNull((branch) => branch.id == selectedBranchId) ??
            activeBranches.first;

        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: GestureDetector(
            onTap: () => _showBranchSelectionDialog(activeBranches),
            child: Container(
              padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
              decoration: BoxDecoration(
                color: isHovered
                    ? const Color(0xFFE5E7EB)
                    : const Color(0xFFEDF1F5),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildBranchIcon(),
                  const SizedBox(width: 6),
                  _buildBranchInfo(selectedBranch),
                  if (widget.trailingIcon != null) ...[
                    const SizedBox(width: 6),
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: widget.trailingIcon!,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBranchIcon() {
    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        color: Color(0xFF1F62E8),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(
          Icons.business,
          color: Color(0xFFF9F9F9),
          size: 16,
        ),
      ),
    );
  }

  Widget _buildBranchInfo(branch) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          selectedBranchId != null ? branch.name : 'Select Branch',
          style: const TextStyle(
            color: Color(0xFF2D2E2E),
            fontSize: 12,
            fontFamily: 'IBM Plex Sans Arabic',
            fontWeight: FontWeight.w700,
            height: 1.43,
            letterSpacing: 0.28,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          selectedBranchId != null ? 'Active Branch' : 'Choose Branch',
          style: const TextStyle(
            color: Color(0xFFA6A9AC),
            fontSize: 10,
            fontFamily: 'IBM Plex Sans Arabic',
            fontWeight: FontWeight.w500,
            height: 1.33,
            letterSpacing: 0.36,
          ),
        ),
      ],
    );
  }

  void _showBranchSelectionDialog(List<dynamic> branches) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Select Branch',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          content: SizedBox(
            width: 300,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: branches.length,
              itemBuilder: (context, index) {
                final branch = branches[index];
                final isSelected = branch.id == selectedBranchId;

                return ListTile(
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF1F62E8)
                          : const Color(0xFFE5E7EB),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.business,
                        color:
                            isSelected ? Colors.white : const Color(0xFF6B7280),
                        size: 18,
                      ),
                    ),
                  ),
                  title: Text(
                    branch.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? const Color(0xFF1F62E8)
                          : const Color(0xFF1F2937),
                    ),
                  ),
                  subtitle: Text(
                    branch.address ?? 'No address',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_circle,
                          color: Color(0xFF1F62E8),
                          size: 20,
                        )
                      : null,
                  onTap: () {
                    setState(() {
                      selectedBranchId = branch.id;
                    });
                    Navigator.of(context).pop();
                    // You can add additional logic here to handle branch selection
                    Get.snackbar(
                      'Branch Selected',
                      'Switched to ${branch.name}',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: const Color(0xFF1F62E8),
                      colorText: Colors.white,
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFallbackWidget() {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: Container(
        padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
        decoration: BoxDecoration(
          color: isHovered ? const Color(0xFFE5E7EB) : const Color(0xFFEDF1F5),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Color(0xFF1F62E8),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.business,
                  color: Color(0xFFF9F9F9),
                  size: 16,
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Loading...',
                  style: TextStyle(
                    color: Color(0xFF2D2E2E),
                    fontSize: 12,
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.w700,
                    height: 1.43,
                    letterSpacing: 0.28,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Branch',
                  style: TextStyle(
                    color: Color(0xFFA6A9AC),
                    fontSize: 10,
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.w500,
                    height: 1.33,
                    letterSpacing: 0.36,
                  ),
                ),
              ],
            ),
            if (widget.trailingIcon != null) ...[
              const SizedBox(width: 6),
              SizedBox(
                width: 16,
                height: 16,
                child: widget.trailingIcon!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
