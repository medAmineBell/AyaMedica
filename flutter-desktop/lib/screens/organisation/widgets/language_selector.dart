import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/branch_selection_controller.dart';
import 'package:get/get.dart';

class LanguageSelector extends StatelessWidget {
  final BranchSelectionController controller = Get.find();

  LanguageSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 164,
      child: Obx(() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: ShapeDecoration(
          color: const Color(0xFFFBFCFD),
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              width: 1,
              color: Color(0xFFE9E9E9),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          shadows: const [
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
            Expanded(
              child: Row(
                children: [
                  const SizedBox(width: 24, height: 24),
                  const SizedBox(width: 8),
                  Text(
                    controller.selectedLanguage.value,
                    style: const TextStyle(
                      color: Color(0xFF2D2E2E),
                      fontSize: 14,
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.w500,
                      height: 1.43,
                      letterSpacing: 0.28,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 24,
              height: 24,
              child: Icon(Icons.keyboard_arrow_down),
            ),
          ],
        ),
      )),
    );
  }
}