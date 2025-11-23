import 'package:flutter/material.dart';

class AppointmentTypeCard extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Color activeColor;
  final Color inactiveColor;
  final Widget icon;

  const AppointmentTypeCard({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.icon,
    this.activeColor = const Color(0xFF1339FF),
    this.inactiveColor = const Color(0xFFEDF1F5),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? activeColor : inactiveColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFFCDFF1F)
                    : const Color(0xFFDCE0E4),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: IconTheme(
                  data: IconThemeData(
                    size: 16, // Set appropriate icon size
                    color: isActive ? const Color(0xFF1339FF) : const Color(0xFF747677),
                  ),
                  child: icon,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : const Color(0xFF2D2E2E),
                fontSize: 12,
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.w600,
                letterSpacing: 0.24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}