import 'package:flutter/material.dart';
import 'package:flutter_getx_app/screens/feedbackDashboard/widgets/feedback_header_section.dart';
import 'package:flutter_getx_app/screens/feedbackDashboard/widgets/feedback_item_details.dart';
import 'package:get/get.dart';
import '../../controllers/feedback_controller.dart';
import '../../controllers/home_controller.dart';

class FeedbackDetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FeedbackController>();
    final feedback = controller.selectedFeedback.value;

    if (feedback == null) {
      return const Center(child: Text('No feedback selected.'));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _FeedbackDetailsHeader(),
              SizedBox(height: 24),
             FeedbackHeaderSection(),
             Divider( height: 1, color: Color(0xFFE9E9E9)),
                           SizedBox(height: 24),

             FeedbackItemDetails(),
                SizedBox(height: 16),
                  FeedbackItemDetails(),
                SizedBox(height: 16),
                  FeedbackItemDetails(),
                SizedBox(height: 16),
                  FeedbackItemDetails(),
                SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedbackDetailsHeader extends StatelessWidget {
  const _FeedbackDetailsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,

      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back to Surveys
          GestureDetector(
            onTap: () {
              final homeController = Get.find<HomeController>();
              homeController.changeContent(ContentType.settings);
            },
            child: Row(
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
          ),

          // Action buttons
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
