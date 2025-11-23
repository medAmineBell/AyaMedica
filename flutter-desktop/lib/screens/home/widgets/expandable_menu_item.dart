import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ExpandableMenuItem extends StatefulWidget {
  final String icon;
  final String title;
  final bool isActive;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onExpandTap;
  final String? badge;
  final List<Widget>? children;

  const ExpandableMenuItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.isActive,
    required this.isExpanded,
    required this.onTap,
    required this.onExpandTap,
    this.badge,
    this.children,
  }) : super(key: key);

  @override
  State<ExpandableMenuItem> createState() => _ExpandableMenuItemState();
}

class _ExpandableMenuItemState extends State<ExpandableMenuItem> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: widget.children != null && widget.isExpanded ? 4 : 0),
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
                          widget.isActive ? const Color(0xFFCDFF1F) : const Color(0xFF595A5B),
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: TextStyle(
                            color: widget.isActive ? Colors.white : const Color(0xFF595A5B),
                            fontSize: 12,
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontWeight:widget.isActive ? FontWeight.w700:FontWeight.w500,
                            letterSpacing: 0.28,
                          ),
                        ),
                      ),
                      if (widget.badge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFC2E53),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            widget.badge!,
                            style: const TextStyle(
                              color: Color(0xFFF9F9F9),
                              fontSize: 12,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              height: 1.58,
                            ),
                          ),
                        ),
                      if (widget.children != null)
                        GestureDetector(
                          onTap: widget.onExpandTap,
                          child: Icon(
                            widget.isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            color: widget.isActive ? Colors.white : const Color(0xFF595A5B),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (widget.children != null && widget.isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.children!,
            ),
          ),
      ],
    );
  }
}
