import 'package:flutter_getx_app/controllers/appointment_history_controller.dart';
import 'package:flutter_getx_app/controllers/notification_controller.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../controllers/appointment_scheduling_controller.dart';
import '../controllers/branch_management_controller.dart';
import '../controllers/mobile_app_user_controller.dart';
import '../controllers/users_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BranchManagementController(), fenix: true); // Lazy init: recreated if disposed
    Get.lazyPut(() => HomeController(), fenix: true);
    Get.lazyPut(() => AppointmentSchedulingController(), fenix: true); // Lazy init: recreated if disposed
    Get.lazyPut(() => AppointmentHistoryController(), fenix: true); // Lazy init: recreated if disposed
    Get.lazyPut(() => MobileAppUserController(), fenix: true); // Lazy init: recreated if disposed
    Get.lazyPut(() => UsersController(), fenix: true);
    Get.lazyPut(() => NotificationController(), fenix: true);
  }
}
