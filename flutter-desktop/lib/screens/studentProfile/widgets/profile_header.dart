import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final VoidCallback onBackPressed;
  final Widget? trailing;

  const ProfileHeader({
    Key? key,
    required this.onBackPressed,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Back Button
        InkWell(
          onTap: onBackPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}
