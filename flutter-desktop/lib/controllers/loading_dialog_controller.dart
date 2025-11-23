import 'package:get/get.dart';

class LoadingDialogController extends GetxController {
  var progress = 0.0.obs;
  var progressText = '0%'.obs;
  
  void updateProgress(double value) {
    progress.value = value;
    progressText.value = '${(value * 100).round()}%';
  }
  void reset() {
    progress.value = 0.0;
    progressText.value = '0%';
  }
}