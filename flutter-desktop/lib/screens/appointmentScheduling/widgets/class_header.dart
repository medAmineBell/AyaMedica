import 'package:flutter/material.dart';

class ClassHeader extends StatelessWidget {
  final String className;
  final String grade;
  final int studentCount;
  final String subtitle;
  
  const ClassHeader({
    super.key,
    required this.className,
    required this.grade,
    required this.studentCount,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Section
          _buildClassInfo(),
          
          // Right Section
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildClassInfo() {
    return Row(
      children: [
        const SizedBox(width: 24), // Placeholder for potential icon
        const SizedBox(width: 12),
        _buildAvatar(),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '$className | $grade',
                  style: _titleStyle,
                ),
                const SizedBox(width: 8),
                _buildStudentChip(),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: _subtitleStyle,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    // Get first 2 characters safely
    final initials = className.length >= 2 
        ? className.substring(0, 2).toUpperCase()
        : className.toUpperCase();

    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        color: Color(0xFF1339FF),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          color: Color(0xFFEDEEF0),
          fontSize: 14,
          fontFamily: 'IBM Plex Sans Arabic',
          fontWeight: FontWeight.w400,
          height: 1.43,
        ),
      ),
    );
  }

  Widget _buildStudentChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFCDF7FF),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        '$studentCount Students',
        style: const TextStyle(
          color: Color(0xFF0167FF),
          fontSize: 14,
          fontFamily: 'IBM Plex Sans Arabic',
          fontWeight: FontWeight.w700,
          height: 1.43,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        _buildOutlinedButton(),
        const SizedBox(width: 24),
        _buildFilledButton(),
      ],
    );
  }

  Widget _buildOutlinedButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFA6A9AC)),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C101828),
            blurRadius: 2,
            offset: Offset(0, 1),
          )
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 24), // Icon placeholder
          const SizedBox(width: 8),
          Text(
            'Notify All pending parents',
            style: _buttonTextStyle.copyWith(
              color: const Color(0xFF747677),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilledButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1339FF),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C101828),
            blurRadius: 2,
            offset: Offset(0, 1),
          )
        ],
      ),
      child: Text(
        'Go to appointment',
        style: _buttonTextStyle.copyWith(
          color: const Color(0xFFCDF7FF),
        ),
      ),
    );
  }

  // Text styles
  static const _titleStyle = TextStyle(
    color: Color(0xFF2D2E2E),
    fontSize: 14,
    fontFamily: 'IBM Plex Sans Arabic',
    fontWeight: FontWeight.w700,
    height: 1.43,
    letterSpacing: 0.28,
  );

  static const _subtitleStyle = TextStyle(
    color: Color(0xFF747677),
    fontSize: 14,
    fontFamily: 'IBM Plex Sans Arabic',
    fontWeight: FontWeight.w400,
    height: 1.43,
  );

  static const _buttonTextStyle = TextStyle(
    fontSize: 14,
    fontFamily: 'IBM Plex Sans Arabic',
    fontWeight: FontWeight.w500,
    height: 1.43,
    letterSpacing: 0.28,
  );
}