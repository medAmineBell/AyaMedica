import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_getx_app/routes/app_pages.dart';
import 'package:flutter_getx_app/utils/storage_service.dart';

class OnboardingController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;

  void onPageChanged(int page) {
    currentPage.value = page;
  }

  void nextPage() {
    if (currentPage.value < 2) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void skip() {
    _completeOnboarding();
  }

  void getStarted() {
    _completeOnboarding();
  }
  
  void _completeOnboarding() {
    _storageService.saveOnboardingStatus(true);
    Get.offAllNamed(Routes.LOCATION_PERMISSION);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
