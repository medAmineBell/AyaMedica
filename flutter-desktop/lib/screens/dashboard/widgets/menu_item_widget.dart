import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class MenuItemWidget extends StatefulWidget {
  final String icon;
  final String title;
  final bool isActive;
  final VoidCallback onTap;
  final String? badge;

  const MenuItemWidget({
    Key? key,
    required this.icon,
    required this.title,
    required this.isActive,
    required this.onTap,
    this.badge,
  }) : super(key: key);

  @override
  State<MenuItemWidget> createState() => _MenuItemWidgetState();
}

class _MenuItemWidgetState extends State<MenuItemWidget> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.isActive
                    ? const Color(0xFF1339FF)
                    : isHovered
                        ? const Color(0xFFEDF1F5)
                        : Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    widget.icon,
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      widget.isActive
                          ? const Color(0xFFCDFF1F)
                          : const Color(0xFF595A5B),
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        color: widget.isActive
                            ? Colors.white
                            : const Color(0xFF595A5B),
                        fontSize: 12,
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight:
                            widget.isActive ? FontWeight.w700 : FontWeight.w500,
                        letterSpacing: 0.28,
                      ),
                    ),
                  ),
                  if (widget.badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFC2E53),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        widget.badge!,
                        style: TextStyle(
                          color: Color(0xFFF9F9F9),
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: widget.isActive
                              ? FontWeight.w700
                              : FontWeight.w500,
                          height: 1.58,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
