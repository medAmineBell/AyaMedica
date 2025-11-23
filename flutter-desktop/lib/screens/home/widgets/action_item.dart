import 'package:flutter/material.dart';

class ActionItem extends StatelessWidget {
  final dynamic icon;
  final VoidCallback onTap;
  final bool hasBadge;
  final String? badgeText;

  const ActionItem({
    Key? key,
    required this.icon,
    required this.onTap,
    this.hasBadge = false,
    this.badgeText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40, // reduced from 56
      height: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      child: Stack(
        children: [
          Material(
            color: const Color(0xFFEDF1F5),
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: Container(
                padding: const EdgeInsets.all(4), // reduced from 6
                child: Center(
                  child: icon is IconData
                      ? Icon(icon as IconData, size: 20) // reduced from default size
                      : icon is Widget
                          ? icon
                          : const SizedBox(),
                ),
              ),
            ),
          ),
          if (hasBadge)
            Positioned(
              right: 0,
              top: 16, // adjusted from 12
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1), // reduced padding
                decoration: BoxDecoration(
                  color: const Color(0xFFFC2E53),
                  borderRadius: BorderRadius.circular(8), // reduced from 10
                ),
                child: Text(
                  badgeText ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10, // reduced from 12
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
