import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/svg.dart';

import '../../../controllers/home_controller.dart';

class LeftSidebar extends GetView<HomeController> {
  const LeftSidebar({Key? key}) : super(key: key);

  static const Color _activeBackground = Color(0xFF1339FF);
  static const Color _activeIcon = Color(0xFFCDFF1F);
  static const Color _inactiveBackground = Color(0xFFEDF1F5);
  static const Color _inactiveIcon = Color(0xFF595A5B);

  Widget _buildIconButton({
    required String svgPath,
    required int index,
  }) {
    return _SidebarIconButton(
      svgPath: svgPath,
      index: index,
      controller: controller,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      color: const Color(0xFFFBFCFD),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildIconButton(
            svgPath: 'assets/svg/dashboard.svg',
            index: 0,
          ),
          const SizedBox(height: 16),
          _buildIconButton(
            svgPath: 'assets/svg/setting-3.svg',
            index: 1,
          ),
          const SizedBox(height: 16),
          _buildIconButton(
            svgPath: 'assets/svg/credit-card.svg',
            index: 2,
          ),
        ],
      ),
    );
  }
}

class _SidebarIconButton extends StatefulWidget {
  final String svgPath;
  final int index;
  final HomeController controller;

  const _SidebarIconButton({
    required this.svgPath,
    required this.index,
    required this.controller,
  });

  @override
  State<_SidebarIconButton> createState() => _SidebarIconButtonState();
}

class _SidebarIconButtonState extends State<_SidebarIconButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isActive = widget.controller.selectedSideIndex.value == widget.index;
      return MouseRegion(
        onEnter: (_) => setState(() => isHovered = true),
        onExit: (_) => setState(() => isHovered = false),
        child: GestureDetector(
          onTap: () {
            if (widget.index == 1) {
              widget.controller.isSecondSidebarVisible.value = false;
              widget.controller.changeSideIndex(widget.index);
              widget.controller.changeContent(ContentType.settings);
            } else {
              widget.controller.isSecondSidebarVisible.value = true;
              widget.controller.changeSideIndex(widget.index);
              // Optionally set content for other indexes if needed
              if (widget.index == 0) {
                widget.controller.changeContent(ContentType.dashboard);
              } else if (widget.index == 2) {
                widget.controller.changeContent(ContentType.studentsOverview);
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: ShapeDecoration(
              color: isActive 
                ? LeftSidebar._activeBackground 
                : isHovered 
                  ? const Color(0xFFE5E7EB)  // lighter hover color
                  : LeftSidebar._inactiveBackground,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Center(
              child: SvgPicture.asset(
                widget.svgPath,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  isActive ? LeftSidebar._activeIcon : LeftSidebar._inactiveIcon,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
