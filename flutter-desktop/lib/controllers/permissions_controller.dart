import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_getx_app/routes/app_pages.dart';
import 'package:flutter_getx_app/utils/storage_service.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();

  // Request location permission
  Future<void> requestLocationPermission() async {
/*
    // First check if permission is already granted
    PermissionStatus status = await Permission.location.status;

    if (status.isDenied) {
      // Request permission - this will show the system dialog
      status = await Permission.location.request();
    }

    // Handle the result
    if (status.isPermanentlyDenied) {
      // User permanently denied - show dialog to open settings
      _showOpenSettingsDialog('Location');
      return;
    }

    // Save permission status
    _storageService.saveLocationPermissionStatus(status.isGranted);
*/
    // Navigate to notification permission screen
    Get.offAllNamed(Routes.NOTIFICATION_PERMISSION);
  }

  // Request notification permission
  Future<void> requestNotificationPermission() async {
/*
    // First check if permission is already granted
    PermissionStatus status = await Permission.notification.status;

    // On iOS, Permission.notification may always be denied if not requested yet, so always request
    if (!status.isGranted) {
      status = await Permission.notification.request();
    }

    // Handle the result
    if (status.isPermanentlyDenied) {
      _showOpenSettingsDialog('Notification');
      return;
    }

    // Save permission status
    _storageService.saveNotificationPermissionStatus(status.isGranted);
*/
    // Check if user is logged in
    final bool isLoggedIn = _storageService.getLoginStatus();

    // Navigate to home screen if logged in, otherwise to login screen
    if (isLoggedIn) {
      Get.offAllNamed(Routes.HOME);
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  // Show dialog to open settings when permission is permanently denied
  void _showOpenSettingsDialog(String permissionType) {
    Get.dialog(
      AlertDialog(
        title: Text('$permissionType Permission Required'),
        content: Text(
            '$permissionType permission is required for this app to function properly. Please enable it in app settings.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              openAppSettings();
            },
            child: Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  // Check if location permission is already granted
  Future<bool> checkLocationPermission() async {
    return await Permission.location.isGranted;
  }

  // Check if notification permission is already granted
  Future<bool> checkNotificationPermission() async {
    return await Permission.notification.isGranted;
  }
}
