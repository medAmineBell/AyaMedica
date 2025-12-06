import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/branch_management_controller.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../controllers/home_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../../utils/medplum_service.dart';
import '../../../models/fhir_organization.dart';
import 'expandable_menu_item.dart';
import 'menu_item_widget.dart';
import '../../../screens/organisation/widgets/tree_connector_painter.dart';

class SecondSidebar extends GetView<HomeController> {
  SecondSidebar({Key? key}) : super(key: key);

  // Observable for child organizations
  final RxList<FhirOrganization> childOrganizations = <FhirOrganization>[].obs;
  final RxBool isLoadingChildOrganizations = false.obs;
  final RxString selectedChildOrganizationId = ''.obs;

  // Observable for main organization
  final Rxn<FhirOrganization> mainOrganization = Rxn<FhirOrganization>();
  final RxBool isLoadingMainOrganization = false.obs;

  Widget _buildSectionTitle({required String title}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 16),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFC3C7CA),
          fontSize: 12,
          fontFamily: 'IBM Plex Sans Arabic',
          fontWeight: FontWeight.w400,
          height: 1.33,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 275,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            right: BorderSide(
              color: Color(0xFFE5E7EB),
              width: 1,
            ),
          ),
        ),
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pin the campus info to top
                      Container(
                        color: Colors.white,
                        child: _buildCampusInfo(context),
                      ),
                      // Scrollable content
                      Obx(() => _buildConditionalMenuItems()),
                    ],
                  ),
                ),
              ),
            ),
            // Logout button at the bottom
            _buildLogoutButton(),
          ],
        ));
  }

  Widget _buildSubMenuItem(
    String title, {
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return SizedBox(
      height: 32,
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 32,
            child: CustomPaint(
              painter: TreeConnectorPainter(
                isFirst: isFirst,
                isLast: isLast,
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: InkWell(
              onTap: onTap,
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF595A5B),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampusInfo(BuildContext context) {
    return SizedBox(
      width: 230,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: ShapeDecoration(
              color: const Color(0xFFDCE0E4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SvgPicture.asset(
                'assets/svg/buliding.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF595A5B),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Al Riyadh Campus",
                style: TextStyle(
                  color: Color(0xFF2D2E2E),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "School management ",
                style: TextStyle(
                  color: Color(0xFF595A5B),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ) // _buildCampusInfoDropdown(context),
              ),
        ],
      ),
    );
  }

  Widget _buildConditionalMenuItems() {
    final selectedBranchData = controller.selectedBranchData.value;
    final isSchool = true; // selectedBranchData?['isSchool'] ?? false;
    final isClinic = selectedBranchData?['isClinic'] ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Common items for both School and Clinic
        _buildSectionTitle(title: "School dashboard"),
        MenuItemWidget(
          icon: 'assets/svg/chart-square.svg',
          title: 'Dashboard',
          isActive: controller.selectedIndex.value == 0,
          onTap: () {
            controller.changeIndex(0);
            controller.changeContent(ContentType.dashboard);
          },
          badge: '1',
        ),

        /*_buildSectionTitle(title: "Communication"),
        MenuItemWidget(
          icon: 'assets/svg/direct-notification.svg',
          title: 'Communication',
          isActive: controller.selectedIndex.value == 2,
          onTap: () {
            controller.changeIndex(2);
            controller.changeContent(ContentType.communication);
          },
        ),*/

        _buildSectionTitle(title: "Appointments management"),
        MenuItemWidget(
          icon: 'assets/svg/calendar.svg',
          title: 'Appointment scheduling',
          isActive: controller.selectedIndex.value == 5,
          onTap: () {
            controller.changeIndex(5);
            controller.changeContent(ContentType.calendar);
          },
          // badge: '1',
        ),

        // School-specific items
        if (isSchool) ...[
          /*_buildSectionTitle(title: "School Management"),
          MenuItemWidget(
            icon: 'assets/svg/calendar.svg',
            title: 'Appointment scheduling',
            isActive: controller.selectedIndex.value == 1,
            onTap: () {
              controller.changeIndex(1);
              controller.changeContent(ContentType.appointmentScheduling);
            },
          ),*/
          _buildSectionTitle(title: "School & students details"),
          ExpandableMenuItem(
            icon: 'assets/svg/teacher.svg',
            title: 'Students',
            isActive: controller.selectedIndex.value == 3,
            isExpanded: controller.expandedMenuItems.contains(3),
            onTap: () {
              controller.changeIndex(3);
              controller.changeContent(ContentType.studentsOverview);
            },
            onExpandTap: () => controller.toggleMenuExpansion(3),
            badge: '1',
            children: [
              _buildSubMenuItem('Overview',
                  onTap: () =>
                      controller.changeContent(ContentType.studentsOverview),
                  isFirst: true),
              _buildSubMenuItem('Students list',
                  onTap: () =>
                      controller.changeContent(ContentType.studentsList)),
              _buildSubMenuItem('Medical records',
                  onTap: () =>
                      controller.changeContent(ContentType.medicalCheckups)),
              _buildSubMenuItem('Reports',
                  onTap: () => controller.changeContent(ContentType.reports),
                  isLast: true),
            ],
          ),
          _buildSectionTitle(title: "Resources"),
          ExpandableMenuItem(
            icon: 'assets/svg/data.svg',
            title: 'Resources',
            isActive: controller.selectedIndex.value == 4,
            isExpanded: controller.expandedMenuItems.contains(4),
            onTap: () {
              controller.changeIndex(4);
              controller.changeContent(ContentType.branches);
            },
            onExpandTap: () => controller.toggleMenuExpansion(4),
            badge: '1',
            children: [
              _buildSubMenuItem('Branches',
                  onTap: () => controller.changeContent(ContentType.branches),
                  isFirst: true),
              _buildSubMenuItem('Classes setting',
                  onTap: () =>
                      controller.changeContent(ContentType.gradesSettings)),
              _buildSubMenuItem('Users',
                  onTap: () => controller.changeContent(ContentType.users),
                  isLast: true),
            ],
          ),
        ],

        // Clinic-specific items
        if (isClinic) ...[
          _buildSectionTitle(title: "Medical Management"),
          MenuItemWidget(
            icon: 'assets/svg/calendar.svg',
            title: 'Patient Appointments',
            isActive: controller.selectedIndex.value == 1,
            onTap: () {
              controller.changeIndex(1);
              controller.changeContent(ContentType.appointmentScheduling);
            },
          ),
          _buildSectionTitle(title: "Patient Management"),
          ExpandableMenuItem(
            icon: 'assets/svg/teacher.svg',
            title: 'Patients',
            isActive: controller.selectedIndex.value == 3,
            isExpanded: controller.expandedMenuItems.contains(3),
            onTap: () {
              controller.changeIndex(3);
              controller.changeContent(ContentType.studentsOverview);
            },
            onExpandTap: () => controller.toggleMenuExpansion(3),
            badge: '1',
            children: [
              _buildSubMenuItem('Patient Overview',
                  onTap: () =>
                      controller.changeContent(ContentType.studentsOverview),
                  isFirst: true),
              _buildSubMenuItem('Patient Records',
                  onTap: () =>
                      controller.changeContent(ContentType.studentsList)),
              _buildSubMenuItem('Medical Records',
                  onTap: () =>
                      controller.changeContent(ContentType.medicalCheckups),
                  isLast: true),
            ],
          ),
          _buildSectionTitle(title: "Medical Resources"),
          ExpandableMenuItem(
            icon: 'assets/svg/data.svg',
            title: 'Resources',
            isActive: controller.selectedIndex.value == 4,
            isExpanded: controller.expandedMenuItems.contains(4),
            onTap: () {
              controller.changeIndex(4);
              controller.changeContent(ContentType.branches);
            },
            onExpandTap: () => controller.toggleMenuExpansion(4),
            badge: '1',
            children: [
              _buildSubMenuItem('Departments',
                  onTap: () => controller.changeContent(ContentType.branches),
                  isFirst: true),
              _buildSubMenuItem('Medical Staff',
                  onTap: () =>
                      controller.changeContent(ContentType.gradesSettings)),
              _buildSubMenuItem('Staff Management',
                  onTap: () => controller.changeContent(ContentType.users),
                  isLast: true),
            ],
          ),
        ],

        // Show default items if neither school nor clinic is selected
        if (!isSchool && !isClinic) ...[
          _buildSectionTitle(title: "General Management"),
          MenuItemWidget(
            icon: 'assets/svg/calendar.svg',
            title: 'Appointments',
            isActive: controller.selectedIndex.value == 1,
            onTap: () {
              controller.changeIndex(1);
              controller.changeContent(ContentType.appointmentScheduling);
            },
          ),
          _buildSectionTitle(title: "Resources"),
          ExpandableMenuItem(
            icon: 'assets/svg/data.svg',
            title: 'Resources',
            isActive: controller.selectedIndex.value == 4,
            isExpanded: controller.expandedMenuItems.contains(4),
            onTap: () {
              controller.changeIndex(4);
              controller.changeContent(ContentType.branches);
            },
            onExpandTap: () => controller.toggleMenuExpansion(4),
            badge: '1',
            children: [
              _buildSubMenuItem('Branches',
                  onTap: () => controller.changeContent(ContentType.branches),
                  isFirst: true),
              _buildSubMenuItem('Settings',
                  onTap: () =>
                      controller.changeContent(ContentType.gradesSettings)),
              _buildSubMenuItem('Users',
                  onTap: () => controller.changeContent(ContentType.users),
                  isLast: true),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildCampusInfoDropdown(BuildContext context) {
    return Obx(() {
      final selectedBranchData = controller.selectedBranchData.value;
      final organizationId = selectedBranchData?['organizationId'] ?? '';

      // Load main organization when organization ID is available
      if (organizationId.isNotEmpty &&
          mainOrganization.value == null &&
          !isLoadingMainOrganization.value) {
        _loadMainOrganization(organizationId);
      }

      // Load child organizations when organization ID is available
      if (organizationId.isNotEmpty &&
          childOrganizations.isEmpty &&
          !isLoadingChildOrganizations.value) {
        _loadChildOrganizations(organizationId);
      }

      // Show loading skeleton if loading main organization
      if (isLoadingMainOrganization.value) {
        return _buildLoadingSkeleton();
      }

      // Get organization type flags from stored data
      final isSchool = true; // selectedBranchData?['isSchool'] ?? false;
      final isClinic = selectedBranchData?['isClinic'] ?? false;

      // Find the main branch organization (the one with "Main Branch" type)
      final mainBranchOrg = childOrganizations.firstWhereOrNull(
        (org) => _getOrganizationTypeDisplay(org) == 'Main Branch',
      );

      // If no main branch found, use the first organization as main branch
      final defaultMainBranch = mainBranchOrg ??
          (childOrganizations.isNotEmpty ? childOrganizations.first : null);

      // Set default selection to main branch if nothing is selected
      if (selectedChildOrganizationId.value.isEmpty &&
          defaultMainBranch != null) {
        selectedChildOrganizationId.value = defaultMainBranch.id;
      }

      // Find the selected organization
      final selectedOrg = childOrganizations.firstWhereOrNull(
        (org) => org.id == selectedChildOrganizationId.value,
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Organizations popup menu (showing branches)
          if (childOrganizations.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: InkWell(
                onTap: () => _showBranchPopupMenu(context),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedOrg?.name ?? 'Select Branch',
                        style: const TextStyle(
                          color: Color(0xFF2D2E2E),
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_drop_down_sharp,
                      size: 32,
                      color: const Color(0xFF595A5B),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Add specific indicators for School and Clinic
          /*if (isSchool || isClinic) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isSchool
                    ? const Color(0xFFE8F5E8) // Light green background
                    : const Color(0xFFE3F2FD), // Light blue background
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSchool ? Icons.school : Icons.local_hospital,
                    size: 12,
                    color: isSchool
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFF2196F3),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isSchool ? 'School' : 'Clinic',
                    style: TextStyle(
                      color: isSchool
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFF2196F3),
                      fontSize: 10,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],*/
        ],
      );
    });
  }

  Future<void> _loadMainOrganization(String organizationId) async {
    try {
      isLoadingMainOrganization.value = true;

      final medplumService = Get.find<MedplumService>();
      final result = await medplumService.fetchOrganizationById(
        organizationId: organizationId,
      );

      if (result['success'] == true) {
        final organization = result['organization'] as FhirOrganization;
        mainOrganization.value = organization;
        print('✅ Loaded main organization: ${organization.name}');
      } else {
        print('❌ Failed to load main organization: ${result['message']}');
      }
    } catch (e) {
      print('💥 Error loading main organization: $e');
    } finally {
      isLoadingMainOrganization.value = false;
    }
  }

  Future<void> _loadChildOrganizations(String parentOrganizationId) async {
    try {
      isLoadingChildOrganizations.value = true;

      final medplumService = Get.find<MedplumService>();
      final result = await medplumService.fetchChildOrganizations(
        parentOrganizationId: parentOrganizationId,
      );

      if (result['success'] == true) {
        final organizations = result['organizations'] as List<FhirOrganization>;
        childOrganizations.value = organizations;
        print('✅ Loaded ${organizations.length} child organizations');
        for (final org in organizations) {
          print('   - ${org.name} (${_getOrganizationTypeDisplay(org)})');
        }
      } else {
        print('❌ Failed to load child organizations: ${result['message']}');
      }
    } catch (e) {
      print('💥 Error loading child organizations: $e');
    } finally {
      isLoadingChildOrganizations.value = false;
    }
  }

  Widget _buildLoadingSkeleton() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1500),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: 0.3 + (0.7 * value),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              // Popup menu skeleton
              SizedBox(
                width: double.infinity,
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSkeletonBox(height: 12, width: 100),
                    ),
                    const SizedBox(width: 8),
                    _buildSkeletonBox(height: 32, width: 32, borderRadius: 4),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSkeletonBox({
    required double height,
    required double width,
    double borderRadius = 4,
  }) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  String _getOrganizationTypeDisplay(FhirOrganization org) {
    if (org.type == null || org.type!.isEmpty) {
      return 'Branch';
    }

    // Look for "Main Branch" first, then "Branch"
    for (final type in org.type!) {
      for (final coding in type.coding) {
        if (coding.code == 'Main Branch') {
          return 'Main Branch';
        }
      }
    }

    for (final type in org.type!) {
      for (final coding in type.coding) {
        if (coding.code == 'Branch') {
          return 'Branch';
        }
      }
    }

    // Fallback to first available display
    if (org.type!.isNotEmpty && org.type![0].coding.isNotEmpty) {
      return org.type![0].coding[0].display;
    }

    return 'Branch';
  }

  Color _getOrganizationTypeColor(FhirOrganization org) {
    final typeDisplay = _getOrganizationTypeDisplay(org);

    switch (typeDisplay) {
      case 'Main Branch':
        return const Color(0xFF4CAF50); // Green
      case 'Branch':
        return const Color(0xFF2196F3); // Blue
      default:
        return const Color(0xFF9E9E9E); // Gray
    }
  }

  void _onChildOrganizationChanged(String? childOrganizationId) {
    if (childOrganizationId == null || childOrganizationId.isEmpty) {
      // Selected main organization
      final mainOrg = mainOrganization.value;
      if (mainOrg != null) {
        print('🏢 Selected main organization: ${mainOrg.name}');
        // Here you can add logic to update the UI or perform actions
        // based on the selected main organization
      }
    } else {
      // Selected child organization
      final selectedChildOrg = childOrganizations.firstWhereOrNull(
        (org) => org.id == childOrganizationId,
      );
      if (selectedChildOrg != null) {
        print('🏢 Selected child organization: ${selectedChildOrg.name}');
        // Here you can add logic to update the UI or perform actions
        // based on the selected child organization
      }
    }
  }

  void _showBranchPopupMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 8,
      items: childOrganizations.map((org) {
        return PopupMenuItem<String>(
          value: org.id,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    org.name,
                    style: const TextStyle(
                      color: Color(0xFF2D2E2E),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getOrganizationTypeColor(org),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getOrganizationTypeDisplay(org),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    ).then((String? selectedId) {
      if (selectedId != null) {
        selectedChildOrganizationId.value = selectedId;
        _onChildOrganizationChanged(selectedId);
      }
    });
  }

  Widget _buildLogoutButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
      ),
      child: InkWell(
        onTap: () async {
          final authController = Get.find<AuthController>();
          final confirmed = await Get.dialog<bool>(
            AlertDialog(
              title: const Text('Confirm Logout'),
              content: const Text('Are you sure you want to logout?'),
              actions: [
                TextButton(
                  onPressed: () => Get.back(result: false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Get.back(result: true),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('Logout'),
                ),
              ],
            ),
          );

          if (confirmed == true) {
            await authController.logout();
          }
        },
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.logout,
                size: 12,
                color: Color(0xFFDC2626),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Logout',
              style: TextStyle(
                color: Color(0xFFDC2626),
                fontSize: 14,
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
