import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrganizationCard extends StatelessWidget {
  final Map<String, dynamic> organizationData;
  final VoidCallback? onTap;
  final bool isExpanded;

  const OrganizationCard({
    Key? key,
    required this.organizationData,
    this.onTap,
    this.isExpanded = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define colors based on expansion state
    final backgroundColor =
        isExpanded ? const Color(0xFF1339FF) : const Color(0xFFF5F5F5);
    final iconBackgroundColor =
        isExpanded ? const Color(0xFFCDFF1F) : const Color(0xFFE5F66E);
    final iconTextColor =
        isExpanded ? const Color(0xFF1339FF) : const Color(0xFF2D2E2E);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: ShapeDecoration(
          color: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
        child: Row(
          children: [
            _buildOrganizationIcon(iconBackgroundColor, iconTextColor),
            const SizedBox(width: 12),
            Expanded(child: _buildOrganizationInfo()),
            const SizedBox(width: 8),
            _buildChevronIcon(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrganizationIcon(Color backgroundColor, Color textColor) {
    // Get the first letter of the organization name for the icon
    final orgName = organizationData['name'] as String? ?? '';
    final orgInitial = orgName.isNotEmpty ? orgName[0].toUpperCase() : 'O';

    return Container(
      width: 40,
      height: 40,
      decoration: ShapeDecoration(
        color: backgroundColor,
        shape: const OvalBorder(),
      ),
      child: Center(
        child: Text(
          orgInitial,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontFamily: 'IBM Plex Sans Arabic',
            fontWeight: FontWeight.w700,
            height: 1.43,
            letterSpacing: 0.28,
          ),
        ),
      ),
    );
  }

  Widget _buildOrganizationInfo() {
    final orgName =
        organizationData['name'] as String? ?? 'Unknown Organization';
    final orgType = _getOrganizationType();
    final orgId = organizationData['id'] as String? ?? '';

    // Define text colors based on expansion state
    final primaryTextColor =
        isExpanded ? Colors.white : const Color(0xFF2D2E2E);
    final secondaryTextColor =
        isExpanded ? const Color(0xFFE4E9ED) : const Color(0xFF858789);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          orgName,
          style: TextStyle(
            color: primaryTextColor,
            fontSize: 16,
            fontFamily: 'IBM Plex Sans Arabic',
            fontWeight: FontWeight.w600,
            height: 1.43,
            letterSpacing: 0.28,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$orgType • ID: ${orgId.length > 8 ? orgId.substring(0, 8) : orgId}...',
          style: TextStyle(
            color: secondaryTextColor,
            fontSize: 13,
            fontFamily: 'IBM Plex Sans Arabic',
            fontWeight: FontWeight.w400,
            height: 1.33,
            letterSpacing: 0.36,
          ),
        ),
      ],
    );
  }

  Widget _buildChevronIcon() {
    final iconColor = isExpanded ? Colors.white : const Color(0xFF858789);

    return Icon(
      isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
      color: iconColor,
      size: 24,
    );
  }

  String _getOrganizationType() {
    try {
      final types = organizationData['type'] as List<dynamic>?;
      if (types != null && types.isNotEmpty) {
        final firstType = types.first as Map<String, dynamic>;
        final coding = firstType['coding'] as List<dynamic>?;
        if (coding != null && coding.isNotEmpty) {
          final firstCoding = coding.first as Map<String, dynamic>;
          return firstCoding['display'] ?? 'Organization';
        }
      }
    } catch (e) {
      print('Error extracting organization type: $e');
    }
    return 'Organization';
  }
}
