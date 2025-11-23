import 'package:flutter/material.dart';

class FeedbackItemDetails extends StatelessWidget {
  const FeedbackItemDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 136,
      width: double.infinity,
      padding: const EdgeInsets.only(right: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left section (rating + clinic info)
          SizedBox(
            width: 261,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rating stars
                Row(
                  children: [
                    Row(
                      children: List.generate(
                        5,
                        (index) => const Icon(
                          Icons.star,
                          size: 16,
                          color: Color(0xFFFFD700), // Gold
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '4.9 out of 5',
                      style: TextStyle(
                        color: Color(0xFF595A5B),
                        fontSize: 12,
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.w400,
                        height: 1.33,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Clinic info
                Row(
                  children: [
                    ClipOval(
                      child: Image.asset(
                        "assets/images/student_avatar_male.png",
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Al Riyadh School clinic',
                          style: TextStyle(
                            color: Color(0xFF2D2E2E),
                            fontSize: 14,
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontWeight: FontWeight.w700,
                            height: 1.43,
                            letterSpacing: 0.28,
                          ),
                        ),
                        Text(
                          'SCEG23CYBM',
                          style: TextStyle(
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
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 62),

          // Right section (feedback content)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Feedback title goes here',
                  style: TextStyle(
                    color: Color(0xFF2D2E2E),
                    fontSize: 18,
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.w700,
                    height: 1.56,
                    letterSpacing: 0.09,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'I just started using the Ayamedica parent school health application, and it has truly impressed me! The interface is user-friendly, making it easy to navigate through the features. I love how it keeps me updated on my child\'s health records and school health activities. The notifications for upcoming health check-ups are super helpful, and the resources provided for health education are top-notch. Overall, Ayamedica has made managing my child\'s health at school a breeze!',
                  style: TextStyle(
                    color: Color(0xFF595A5B),
                    fontSize: 14,
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.w400,
                    height: 1.43,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
