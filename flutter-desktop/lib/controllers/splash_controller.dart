import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_getx_app/controllers/update_controller.dart';
import 'package:flutter_getx_app/routes/app_pages.dart';
import 'package:flutter_getx_app/utils/api_service.dart';
import 'package:flutter_getx_app/utils/storage_service.dart';

class SplashController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  final UpdateController _updateController = Get.find<UpdateController>();

  bool get _isDesktop =>
      Platform.isMacOS || Platform.isWindows || Platform.isLinux;

  @override
  void onInit() {
    super.onInit();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    // Check for updates on desktop while showing splash
    if (_isDesktop) {
      await _updateController.checkForUpdate();

      if (_updateController.isUpdateAvailable.value) {
        final shouldUpdate = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Update Available'),
            content: const Text(
                'A new version of Ayamedica is available. Would you like to update now?'),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              ElevatedButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Update Now'),
              ),
            ],
          ),
          barrierDismissible: false,
        );

        if (shouldUpdate == true) {
          await _updateController.applyUpdate();
          return; // App will restart after update
        }
      }
    }

    // Simulate loading time
    await Future.delayed(const Duration(seconds: 3));

    // Check if onboarding is completed
    final bool onboardingComplete = _storageService.getOnboardingStatus();

    if (!onboardingComplete) {
      // Skip onboarding on desktop
      if (_isDesktop) {
        await _storageService.saveOnboardingStatus(true);
      } else {
        Get.offAllNamed(Routes.ONBOARDING);
        return;
      }
    }

    // Skip location/notification permission screens on desktop
    if (!_isDesktop) {
      // Check if location permission is granted
      final bool locationPermissionGranted =
          _storageService.getLocationPermissionStatus();

      if (!locationPermissionGranted) {
        Get.offAllNamed(Routes.LOCATION_PERMISSION);
        return;
      }

      // Check if notification permission is granted
      final bool notificationPermissionGranted =
          _storageService.getNotificationPermissionStatus();

      if (!notificationPermissionGranted) {
        Get.offAllNamed(Routes.NOTIFICATION_PERMISSION);
        return;
      }
    } else {
      // Auto-grant on desktop so they never show again
      await _storageService.saveLocationPermissionStatus(true);
      await _storageService.saveNotificationPermissionStatus(true);
    }

    // Check if user is logged in
    final bool isLoggedIn = _storageService.getLoginStatus();

    if (isLoggedIn) {
      // Check if user has selected a branch
      final bool branchSelected = _storageService.getBranchSelectedStatus();

      if (branchSelected) {
        // Pre-fetch and cache user profile so home screen loads instantly
        await _fetchAndCacheUserProfile();
        Get.offAllNamed(Routes.HOME);
      } else {
        Get.offAllNamed(Routes.ORGANISATION);
      }
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  Future<void> _fetchAndCacheUserProfile() async {
    final apiService = Get.find<ApiService>();
    final result = await apiService.fetchUserProfile();
    if (result['success'] == true) {
      final data = result['data'] as Map<String, dynamic>;
      await _storageService.saveUserProfile(data);
    }
  }
}
