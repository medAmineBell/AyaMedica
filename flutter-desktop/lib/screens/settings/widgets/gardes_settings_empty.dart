import 'package:flutter/material.dart';
import 'package:flutter_getx_app/screens/appointmentScheduling/widgets/create_appointment_dialog.dart';
import 'package:flutter_getx_app/screens/settings/widgets/create_class_grade.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class GardesSettingsEmpty extends StatelessWidget {
  const GardesSettingsEmpty({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/svg/teacher.svg',
            width: 120,
            height: 120,
            colorFilter: const ColorFilter.mode(
              Color(0xFFE5E7EB),
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No records',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF858789) /* Text-Text-70 */,
              fontSize: 32,
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w700,
              height: 1.25,
              letterSpacing: -0.24,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'There  are no grades available ',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF858789),
              fontSize: 14,
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w400,
              height: 1.43,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              side: const BorderSide(
                width: 1,
                color: Color(0xFF595A5B), // Stroke-Stroke-90
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              shadowColor: const Color(0x0C101828),
              elevation: 2, // BoxShadow blurRadius: 2 equivalent
              backgroundColor: Colors.transparent,
            ),
            onPressed: () {
              Get.dialog(
                CreateClassScreen(),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/svg/plus-square.svg',
                  width: 16,
                  height: 16,
                ),
                const SizedBox(width: 8),
                const Text(
                  'New garde',
                  style: TextStyle(
                    color: Color(0xFF747677), // Text-Text-80
                    fontSize: 14,
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.w500,
                    height: 1.43,
                    letterSpacing: 0.28,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
