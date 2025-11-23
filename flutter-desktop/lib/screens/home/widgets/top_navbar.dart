import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../../controllers/home_controller.dart';
import 'action_item.dart';
import 'user_profile_widget.dart';
import 'branch_selection_widget.dart';

class TopNavbar extends GetView<HomeController> {
  const TopNavbar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: Row(
        children: [
          Obx(() => GestureDetector(
                onTap: () => controller.toggleSecondSidebar(),
                child: Transform.rotate(
                  angle: controller.isSecondSidebarVisible.value
                      ? 0
                      : 3.14159, // 180 degrees in radians
                  child: SvgPicture.asset(
                    'assets/svg/arrow-square-left.svg',
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF595A5B),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              )),
          const Spacer(),
          ActionItem(
            icon: SvgPicture.asset(
              'assets/svg/mail.svg',
              width: 20, // reduced from 32
              height: 20, // reduced from 32
            ),
            onTap: () {},
            hasBadge: true,
            badgeText: '3',
          ),
          const SizedBox(width: 6),
          ActionItem(
            icon: SvgPicture.asset(
              'assets/svg/notification-bing.svg',
              width: 20, // reduced from 32
              height: 20, // reduced from 32
            ),
            onTap: () {},
            hasBadge: true,
            badgeText: '5',
          ),
          const SizedBox(width: 6),
          ActionItem(
            icon: SvgPicture.asset(
              'assets/svg/setting-2.svg',
              width: 20, // reduced from 32
              height: 20, // reduced from 32
            ),
            onTap: () {},
          ),
          const SizedBox(width: 16),
          const VerticalDivider(
            color: Color(0xFFE5E7EB),
            width: 1,
            thickness: 1,
            indent: 16,
            endIndent: 16,
          ),
          const SizedBox(width: 16),
          UserProfileWidget(
            initials: 'SD',
            name: 'John Smith',
            role: 'Appointment Coordinator',
            trailingIcon: const Icon(
              Icons.arrow_drop_down_sharp,
              color: Color(0xFF595A5B),
              size: 20,
            ),
          ),
          // const SizedBox(width: 12),
          // BranchSelectionWidget(
          //   trailingIcon: const Icon(
          //     Icons.arrow_drop_down_sharp,
          //     color: Color(0xFF595A5B),
          //     size: 20,
          //   ),
          // ),
        ],
      ),
    );
  }
}
