import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/onboarding_controller.dart';
import 'widgets/onboarding_page.dart';

class OnboardingScreen extends StatelessWidget {
  final OnboardingController controller = Get.put(OnboardingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Page content
            Expanded(
              child: PageView(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                children: [
                  OnboardingPage(
                    title: 'Gateway to Your Adventure',
                    description: 'Enjoy various housing options, from budget to luxury, in Ayamedica.',
                    imagePath: 'assets/images/onboarding1.png',
                  ),
                  OnboardingPage(
                    title: 'Find Your Perfect Match',
                    description: 'Discover healthcare services tailored to your specific needs and preferences.',
                    imagePath: 'assets/images/onboarding2.png',
                  ),
                  OnboardingPage(
                    title: 'Book with Confidence',
                    description: 'Secure appointments with trusted healthcare providers in just a few taps.',
                    imagePath: 'assets/images/onboarding3.png',
                  ),
                ],
              ),
            ),
            
            // Page indicators
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                     width: controller.currentPage.value == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                       borderRadius: BorderRadius.circular(4),
                      color: controller.currentPage.value == index
                          ? const Color(0xFFD0FD0D) // Bright yellow-green color
                          : const Color(0xFFE2E2E2), // Light gray
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Navigation buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  // Skip button
                  TextButton(
                    onPressed: controller.skip,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  
                  
                  // Next button
                  Obx(
                    () => Expanded(
                      child: ElevatedButton(
                        onPressed: controller.currentPage.value == 2
                            ? controller.getStarted
                            : controller.nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D6EFD), // Blue color
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              controller.currentPage.value == 2 ? 'Get Started' : 'Next',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
        
          ],
        ),
      ),
    );
  }
}
