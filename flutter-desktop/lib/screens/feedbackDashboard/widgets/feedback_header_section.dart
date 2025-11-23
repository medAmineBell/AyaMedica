import 'package:flutter/material.dart';

class FeedbackHeaderSection extends StatelessWidget {
  const FeedbackHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 32),
 
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'How was the new year scholar session?',
                style: TextStyle(
                  color: Color(0xFF2D2E2E), // Text-100
                  fontSize: 24,
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.w700,
                  height: 1.33,
                  letterSpacing: -0.06,
                ),
              ),
              const SizedBox(height: 24),

              // Row with stars + rating text
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
                      color: Color(0xFF595A5B), // Text-90
                      fontSize: 12,
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.w400,
                      height: 1.33,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Text(
                'Based on 147 / 872 reviews',
                style: TextStyle(
                  color: Color(0xFF747677), // Text-80
                  fontSize: 14,
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
