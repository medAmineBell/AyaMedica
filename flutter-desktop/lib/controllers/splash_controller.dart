import 'package:get/get.dart';
import 'package:flutter_getx_app/routes/app_pages.dart';
import 'package:flutter_getx_app/utils/storage_service.dart';

class SplashController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();

  @override
  void onInit() {
    super.onInit();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    // Simulate loading time
    await Future.delayed(const Duration(seconds: 3));
    
    // Check if onboarding is completed
    final bool onboardingComplete = _storageService.getOnboardingStatus();
    
    if (!onboardingComplete) {
      Get.offAllNamed(Routes.ONBOARDING);
      return;
    }
    
    // Check if location permission is granted
    final bool locationPermissionGranted = _storageService.getLocationPermissionStatus();
    
    if (!locationPermissionGranted) {
      Get.offAllNamed(Routes.LOCATION_PERMISSION);
      return;
    }
    
    // Check if notification permission is granted
    final bool notificationPermissionGranted = _storageService.getNotificationPermissionStatus();
    
    if (!notificationPermissionGranted) {
      Get.offAllNamed(Routes.NOTIFICATION_PERMISSION);
      return;
    }
    
    // Check if user is logged in
    final bool isLoggedIn = _storageService.getLoginStatus();
    
    if (isLoggedIn) {
      // Check if user has selected a branch
      final bool branchSelected = _storageService.getBranchSelectedStatus();
      
      if (branchSelected) {
        Get.offAllNamed(Routes.HOME);
      } else {
        Get.offAllNamed(Routes.ORGANISATION);
      }
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }
}
