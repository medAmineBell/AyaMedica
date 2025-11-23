import 'package:flutter/material.dart';

class UserProfileWidget extends StatefulWidget {
  final String initials;
  final String name;
  final String role;
  final Color avatarColor;
  final Widget? trailingIcon;

  const UserProfileWidget({
    super.key,
    required this.initials,
    required this.name,
    required this.role,
    this.avatarColor = const Color(0xFF1339FF),
    this.trailingIcon,
  });

  @override
  State<UserProfileWidget> createState() => _UserProfileWidgetState();
}

class _UserProfileWidgetState extends State<UserProfileWidget> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
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
            _buildAvatar(),
            const SizedBox(width: 6),
            _buildUserInfo(),
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

  Widget _buildAvatar() {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: widget.avatarColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          widget.initials,
          style: const TextStyle(
            color: Color(0xFFF9F9F9),
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
            letterSpacing: -0.20,
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.name,
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
          widget.role,
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
}
