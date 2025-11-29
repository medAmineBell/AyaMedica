import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../controllers/home_controller.dart';
import 'expandable_menu_item.dart';
import 'menu_item_widget.dart';
import '../../../screens/organisation/widgets/tree_connector_painter.dart';

class SecondSidebar extends GetView<HomeController> {
  const SecondSidebar({Key? key}) : super(key: key);

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
        width: 250,
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
        child: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pin the campus info to top
                    Container(
                      color: Colors.white,
                      child: _buildCampusInfo(),
                    ),
                    // Scrollable content
                    _buildSectionTitle(title: "School Management"),
                    Obx(() => MenuItemWidget(
                          icon: 'assets/svg/chart-square.svg',
                          title: 'Dashboard',
                          isActive: controller.selectedIndex.value == 0,
                          onTap: () {
                            controller.changeIndex(0);
                            controller.changeContent(ContentType.dashboard);
                          },
                          badge: '1',
                        )),
                    _buildSectionTitle(title: "Appointments management"),
                    Obx(() => MenuItemWidget(
                          icon: 'assets/svg/calendar.svg',
                          title: 'Appointment scheduling',
                          isActive: controller.selectedIndex.value == 1,
                          onTap: () {
                            controller.changeIndex(1);
                            controller.changeContent(
                                ContentType.appointmentScheduling);
                          },
                        )),

                    _buildSectionTitle(title: "Communication"),
                    Obx(() => MenuItemWidget(
                          icon: 'assets/svg/calendar.svg',
                          title: 'Communication',
                          isActive: controller.selectedIndex.value == 2,
                          onTap: () {
                            controller.changeIndex(2);
                            controller.changeContent(ContentType.communication);
                          },
                        )),
                    _buildSectionTitle(title: "School & students details"),
                    Obx(() => ExpandableMenuItem(
                          icon: 'assets/svg/teacher.svg',
                          title: 'Students',
                          isActive: controller.selectedIndex.value == 3,
                          isExpanded: controller.expandedMenuItems.contains(3),
                          onTap: () {
                            controller.changeIndex(3);
                            controller
                                .changeContent(ContentType.studentsOverview);
                          },
                          onExpandTap: () => controller.toggleMenuExpansion(3),
                          badge: '1',
                          children: [
                            _buildSubMenuItem('Overview',
                                onTap: () => controller.changeContent(
                                    ContentType.studentsOverview),
                                isFirst: true),
                            _buildSubMenuItem('Students list',
                                onTap: () => controller
                                    .changeContent(ContentType.studentsList)),
                            _buildSubMenuItem('Medical checkups records',
                                onTap: () => controller
                                    .changeContent(ContentType.medicalCheckups),
                                isLast: true),
                          ],
                        )),
                    _buildSectionTitle(title: "Resources"),
                    Obx(() => ExpandableMenuItem(
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
                                onTap: () => controller
                                    .changeContent(ContentType.branches),
                                isFirst: true),
                            _buildSubMenuItem('Grades setting',
                                onTap: () => controller
                                    .changeContent(ContentType.gradesSettings)),
                            _buildSubMenuItem('users',
                                onTap: () =>
                                    controller.changeContent(ContentType.users),
                                isLast: true),
                          ],
                        )),
                  ],
                ))));
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

  Widget _buildCampusInfo() {
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
          const SizedBox(width: 12),
          Expanded(
            child: _buildCampusInfoText(),
          ),
        ],
      ),
    );
  }

  Widget _buildCampusInfoText() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Al Riyadh Campus',
            style: TextStyle(
              color: Color(0xFF2D2E2E),
              fontSize: 16,
              fontFamily: 'Flama',
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            'School management',
            style: TextStyle(
              color: Color(0xFF595A5B),
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
