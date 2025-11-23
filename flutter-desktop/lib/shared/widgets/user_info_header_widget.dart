// lib/widgets/user_info_header_widget.dart
import 'package:flutter/material.dart';
import 'custom_dropdown.dart';

class UserInfoHeaderWidget extends StatelessWidget {
  final String name;
  final String aid;
  final String initials;
  final String selectedLanguage;
  final List<String> languages;
  final Function(String?) onLanguageChanged;

  const UserInfoHeaderWidget({
    Key? key,
    required this.name,
    required this.aid,
    required this.initials,
    required this.selectedLanguage,
    required this.languages,
    required this.onLanguageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // User Info Section
        Container(
          padding: const EdgeInsets.only(top: 8, left: 12, right: 16, bottom: 8),
          decoration: const ShapeDecoration(
            color: Color(0xFF1339FF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(124)),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar
              Container(
                width: 32,
                height: 32,
                decoration: const ShapeDecoration(
                  color: Color(0xFFCDFF1F),
                  shape: OvalBorder(),
                ),
                child: Center(
                  child: Text(
                    initials,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF1339FF),
                      fontSize: 14,
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.w700,
                      height: 1.43,
                      letterSpacing: 0.28,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // User Details
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.w700,
                      height: 1.43,
                      letterSpacing: 0.28,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'AID $aid',
                    style: const TextStyle(
                      color: Color(0xFFE4E9ED),
                      fontSize: 12,
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.w500,
                      height: 1.33,
                      letterSpacing: 0.36,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Language Selector
        SizedBox(
          width: 164,
          child: CustomDropdown(
            value: selectedLanguage,
            items: languages,
            hint: 'Select Language',
            onChanged: onLanguageChanged,
            prefixIcon: const SizedBox(
              width: 24,
              height: 24,
              child: Icon(
                Icons.language,
                size: 16,
                color: Color(0xFF2D2E2E),
              ),
            ),
          ),
        ),
      ],
    );
  }
}