import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/language_controller.dart';

class LanguageDropdownWidget extends StatefulWidget {
  const LanguageDropdownWidget({Key? key}) : super(key: key);

  @override
  State<LanguageDropdownWidget> createState() => _LanguageDropdownWidgetState();
}

class _LanguageDropdownWidgetState extends State<LanguageDropdownWidget> {
  final LanguageController languageController = Get.find<LanguageController>();
  bool isExpanded = false;
  
  // Define languages with their display names as translation keys
  final List<Map<String, dynamic>> languages = [
    {'key': 'english', 'displayKey': 'language_english', 'code': 'en', 'icon': Icons.language},
    {'key': 'arabic', 'displayKey': 'language_arabic', 'code': 'ar', 'icon': Icons.language},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 164,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: ShapeDecoration(
                color: const Color(0xFFFBFCFD),
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1,
                    color: const Color(0xFFE9E9E9),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                shadows: [
                  BoxShadow(
                    color: Color(0x0C101828),
                    blurRadius: 2,
                    offset: Offset(0, 1),
                    spreadRadius: 0,
                  )
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    child: Icon(
                      Icons.language,
                      size: 20,
                      color: const Color(0xFF595A5B),
                    ),
                  ),
                  SizedBox(width: 8),
                  GetBuilder<LanguageController>(
                    builder: (controller) => Expanded(
                      child: Text(
                        controller.locale.languageCode == 'en' 
                            ? 'english'.tr 
                            : 'arabic'.tr,
                        style: const TextStyle(
                          color: Color(0xFF2D2E2E),
                          fontSize: 14,
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.w500,
                          height: 1.43,
                          letterSpacing: 0.28,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    child: Icon(
                      isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      size: 20,
                      color: const Color(0xFF1339FF),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            SizedBox(height: 4),
            Container(
              width: double.infinity,
              decoration: ShapeDecoration(
                color: const Color(0xFFFBFCFD),
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1,
                    color: const Color(0xFFE9E9E9),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                shadows: [
                  BoxShadow(
                    color: Color(0x14101828),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Color(0x0C101828),
                    blurRadius: 2,
                    offset: Offset(0, 1),
                    spreadRadius: 0,
                  )
                ],
              ),
              child: Column(
                children: languages.map((language) {
                  return GetBuilder<LanguageController>(
                    builder: (controller) {
                      bool isSelected = controller.locale.languageCode == language['code'];
                      return GestureDetector(
                        onTap: () {
                          languageController.changeLanguage(language['code']);
                          setState(() {
                            isExpanded = false;
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFF0F4FF) : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                child: Icon(
                                  language['icon'],
                                  size: 20,
                                  color: isSelected
                                      ? const Color(0xFF1339FF)
                                      : const Color(0xFF595A5B),
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  language['key'] == 'english' 
                                      ? 'English'.tr
                                      : 'العربية'.tr,
                                  style: TextStyle(
                                    color: isSelected
                                        ? const Color(0xFF1339FF)
                                        : const Color(0xFF2D2E2E),
                                    fontSize: 14,
                                    fontFamily: 'IBM Plex Sans Arabic',
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                    height: 1.43,
                                    letterSpacing: 0.28,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Container(
                                  width: 24,
                                  height: 24,
                                  child: Icon(
                                    Icons.check,
                                    size: 18,
                                    color: const Color(0xFF1339FF),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
