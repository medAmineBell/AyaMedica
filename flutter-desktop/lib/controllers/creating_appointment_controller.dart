// creating_appointment_controller.dart
import 'package:get/get.dart';

class CreatingAppointmentController extends GetxController {
  final RxDouble _progress = 0.0.obs;
  
  double get progress => _progress.value;
  
  void updateProgress(double value) {
    _progress.value = value.clamp(0.0, 1.0);
  }
}