import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/branch_selection_controller.dart';
import 'package:flutter_getx_app/screens/auth/widgets/language_dropdown_widget.dart';
import 'package:flutter_getx_app/screens/organisation/widgets/branch_item.dart';
import 'package:flutter_getx_app/screens/organisation/widgets/organization_card.dart';
import 'package:get/get.dart';

class BranchSelectionScreen extends StatelessWidget {
  const BranchSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BranchSelectionController());

    return Scaffold(
      body: Center(
        child: Container(
          width: 566,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height - 100,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLanguageSection(),
              const SizedBox(height: 32),
              _buildWelcomeSection(),
              const SizedBox(height: 32),
              Expanded(
                child: _buildBranchSection(controller),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSection() {
    return LanguageDropdownWidget();
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'welcome_back'.tr,
          style: const TextStyle(
            color: Color(0xFF2D2E2E),
            fontSize: 20,
            fontFamily: 'IBM Plex Sans Arabic',
            fontWeight: FontWeight.w700,
            height: 1.40,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'choose_branch'.tr,
          style: const TextStyle(
            color: Color(0xFF858789),
            fontSize: 12,
            fontFamily: 'IBM Plex Sans Arabic',
            fontWeight: FontWeight.w400,
            height: 1.33,
          ),
        ),
      ],
    );
  }

  Widget _buildBranchSection(BranchSelectionController controller) {
    return _buildOrganizationsSection(controller);
  }

  Widget _buildOrganizationsSection(BranchSelectionController controller) {
    return Obx(() {
      if (controller.isLoadingBranches.value) {
        return Container(
          width: double.infinity,
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: ShapeDecoration(
            color: const Color(0xFFF5F5F5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (controller.rawOrganizations.isEmpty) {
        return Container(
          width: double.infinity,
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: ShapeDecoration(
            color: const Color(0xFFF5F5F5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
          ),
          child: const Center(
            child: Text(
              'No organizations available',
              style: TextStyle(
                color: Color(0xFF858789),
                fontSize: 14,
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        );
      }

      return SingleChildScrollView(
        child: Column(
          children: controller.rawOrganizations.asMap().entries.map((orgEntry) {
            final organization = orgEntry.value;
            final orgId = organization['id'] as String?;
            final organizationBranches = orgId != null
                ? controller.getBranchesForOrganization(orgId)
                : <dynamic>[];

            return _buildOrganizationWithBranches(
              organization,
              organizationBranches,
              controller,
            );
          }).toList(),
        ),
      );
    });
  }

  Widget _buildOrganizationWithBranches(
    Map<String, dynamic> organization,
    List<dynamic> branches,
    BranchSelectionController controller,
  ) {
    final orgId = organization['id'] as String?;
    if (orgId == null) return const SizedBox.shrink();

    return Obx(() {
      final isExpanded = controller.isOrganizationExpanded(orgId);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Organization card with conditional styling
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: OrganizationCard(
              organizationData: organization,
              isExpanded: isExpanded,
              onTap: () => controller.toggleOrganization(orgId),
            ),
          ),

          // Branches for this organization (only shown when expanded)
          if (isExpanded && branches.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.only(left: 20, bottom: 16),
              child: Column(
                children: branches.asMap().entries.map((branchEntry) {
                  final branchIndex = branchEntry.key;
                  final branch = branchEntry.value;
                  final isFirst = branchIndex == 0;
                  final isLast = branchIndex == branches.length - 1;

                  return BranchItem(
                    branch: branch,
                    onTap: () => controller.selectBranch(branch),
                    isFirst: isFirst,
                    isLast: isLast,
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      );
    });
  }
}
