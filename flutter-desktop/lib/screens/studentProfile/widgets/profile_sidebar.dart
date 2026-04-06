import 'package:flutter/material.dart';
import 'package:flutter_getx_app/config/app_config.dart';
import 'package:flutter_getx_app/models/student.dart';

import 'sidebar_navigation_menu.dart';

class ProfileSidebar extends StatelessWidget {
  final Student student;

  const ProfileSidebar({
    Key? key,
    required this.student,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          children: [
            // Student Avatar and Info
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildAvatar(),
                  const SizedBox(height: 16),
                  Text(
                    student.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCCF1FF),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      student.aid!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'G4 Lions',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),

            // Navigation Menu
            const SidebarNavigationMenu(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final imageUrl = student.imageUrl;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      final fullUrl = imageUrl.startsWith('http')
          ? imageUrl
          : '${AppConfig.newBackendUrl}$imageUrl';
      return CircleAvatar(
        radius: 50,
        backgroundColor: student.avatarColor,
        backgroundImage: NetworkImage(fullUrl),
        onBackgroundImageError: (_, __) {},
      );
    }
    return CircleAvatar(
      radius: 50,
      backgroundColor: student.avatarColor,
      child: Text(
        _getInitials(student.name),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (words.isNotEmpty) {
      return words[0].substring(0, 1).toUpperCase();
    }
    return 'U';
  }
}
