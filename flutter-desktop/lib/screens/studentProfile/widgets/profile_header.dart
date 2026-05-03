import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final VoidCallback onBackPressed;
  final Widget? trailing;
  final String? subtitle;

  const ProfileHeader({
    Key? key,
    required this.onBackPressed,
    this.trailing,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: onBackPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.arrow_back,
                  size: 16,
                  color: Color(0xFF6B7280),
                ),
                SizedBox(width: 8),
                Text(
                  'Back',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(width: 8),
          Text(
            subtitle!,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}
