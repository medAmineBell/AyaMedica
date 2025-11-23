// lib/widgets/profile_avatar_widget.dart
import 'package:flutter/material.dart';

class ProfileAvatarWidget extends StatelessWidget {
  final String initials;
  final String? imageUrl;
  final VoidCallback? onTap;

  const ProfileAvatarWidget({
    Key? key,
    required this.initials,
    this.imageUrl,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        padding: const EdgeInsets.all(7.14),
        decoration: const ShapeDecoration(
          color: Color(0xFFEDF1F5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(142.86)),
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        imageUrl!,
                        width: 85.72,
                        height: 85.72,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildInitialsAvatar();
                        },
                      ),
                    )
                  : _buildInitialsAvatar(),
            ),
            Positioned(
              right: 0,
              top: 9.29,
              child: Container(
                padding: const EdgeInsets.all(4.29),
                decoration: const ShapeDecoration(
                  color: Color(0xFFCDF7FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(142.86)),
                  ),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 11.43,
                  color: Color(0xFF0167FF),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialsAvatar() {
    return Container(
      width: 85.72,
      height: 85.72,
      decoration: const ShapeDecoration(
        color: Color(0xFF1339FF),
        shape: OvalBorder(),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontFamily: 'IBM Plex Sans Arabic',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}