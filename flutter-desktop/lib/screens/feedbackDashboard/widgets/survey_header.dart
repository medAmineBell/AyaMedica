import 'package:flutter/material.dart';

class SurveyHeader extends StatelessWidget {
  const SurveyHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 64,
      padding: const EdgeInsets.only(
        top: 12,
        left: 24,
        right: 48,
        bottom: 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back to Surveys
          Row(
            children: [
              Icon(Icons.arrow_back_ios, size: 20, color: Color(0xFF2D2E2E)),
              const SizedBox(width: 12),
              Text(
                'Back  ',
                style: const TextStyle(
                  color: Color(0xFF2D2E2E),
                  fontSize: 14,
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.w700,
                  height: 1.43,
                  letterSpacing: 0.28,
                ),
              ),
              Text(
                'To surveys',
                style: const TextStyle(
                  color: Color(0xFF747677),
                  fontSize: 14,
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.w400,
                  height: 1.43,
                ),
              ),
            ],
          ),

          // Actions
          Row(
            children: [
              // Notify Button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(
                      color: Color(0xFFA6A9AC),
                      width: 1,
                    ),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x0C101828),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.notifications_none, size: 20, color: Color(0xFF747677)),
                    const SizedBox(width: 8),
                    Text(
                      'Notify All pending parents',
                      style: const TextStyle(
                        color: Color(0xFF747677),
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
              const SizedBox(width: 24),

              // Export Button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: ShapeDecoration(
                  color: const Color(0xFF1339FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x0C101828),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  'Export data',
                  style: const TextStyle(
                    color: Color(0xFFCDF7FF),
                    fontSize: 14,
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.w500,
                    height: 1.43,
                    letterSpacing: 0.28,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
