import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrganizationCard extends StatelessWidget {
  final Map<String, dynamic> organizationData;
  final VoidCallback? onTap;

  const OrganizationCard({
    Key? key,
    required this.organizationData,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, // Full width for vertical layout
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: ShapeDecoration(
          color: const Color(0xFF1339FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
        child: Row(
          children: Get.locale?.languageCode == 'ar' ? [
            _buildOrganizationIcon(),
            const SizedBox(width: 12),
            Expanded(child: _buildOrganizationInfo()),
          ] : [
            _buildOrganizationIcon(),
            const SizedBox(width: 12),
            Expanded(child: _buildOrganizationInfo()),
          ],
        ),
      ),
    );
  }

  Widget _buildOrganizationIcon() {
    // Get the first letter of the organization name for the icon
    final orgName = organizationData['name'] as String? ?? '';
    final orgInitial = orgName.isNotEmpty ? orgName[0].toUpperCase() : 'O';
    
    return Container(
      width: 40,
      height: 40,
      decoration: const ShapeDecoration(
        color: Color(0xFFCDFF1F),
        shape: OvalBorder(),
      ),
      child: Center(
        child: Text(
          orgInitial,
          style: const TextStyle(
            color: Color(0xFF1339FF),
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
    final orgName = organizationData['name'] as String? ?? 'Unknown Organization';
    final orgType = _getOrganizationType();
    final orgId = organizationData['id'] as String? ?? '';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          orgName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'IBM Plex Sans Arabic',
            fontWeight: FontWeight.w600,
            height: 1.43,
            letterSpacing: 0.28,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$orgType • ID: ${orgId.substring(0, 8)}...',
          style: const TextStyle(
            color: Color(0xFFE4E9ED),
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
