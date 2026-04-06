import 'package:flutter_getx_app/config/app_config.dart';
import 'package:get/get.dart';
import 'package:velopack_flutter/velopack_flutter.dart' as velopack;

class UpdateController extends GetxController {
  final isUpdateAvailable = false.obs;
  final isUpdating = false.obs;

  Future<void> checkForUpdate() async {
    try {
      final hasUpdate =
          await velopack.isUpdateAvailable(url: AppConfig.updateUrl);
      isUpdateAvailable.value = hasUpdate;
    } catch (e) {
      // Update check fails gracefully in dev mode (not packaged with vpk)
      print('Update check skipped: $e');
    }
  }

  Future<void> applyUpdate() async {
    try {
      isUpdating.value = true;
      // Download and apply update, then restart
      await velopack.updateAndRestart(url: AppConfig.updateUrl);
    } catch (e) {
      isUpdating.value = false;
      print('Update failed: $e');
    }
  }
}
