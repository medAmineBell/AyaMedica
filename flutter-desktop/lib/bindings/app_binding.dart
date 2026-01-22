import 'package:flutter_getx_app/controllers/appointment_history_controller.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../controllers/appointment_scheduling_controller.dart';
import '../controllers/branch_management_controller.dart';
import '../controllers/users_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(HomeController());
    Get.put(AppointmentSchedulingController()); // Add appointment controller
    Get.put(AppointmentHistoryController()); // Add appointment controller
    Get.put(BranchManagementController()); // Add branch management controller
    Get.put(UsersController()); // Add users controller
  }
}
