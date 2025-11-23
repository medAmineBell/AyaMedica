import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_getx_app/controllers/auth_controller.dart';
import 'package:flutter_getx_app/controllers/home_controller.dart';
import 'widgets/left_sidebar.dart';
import 'widgets/second_sidebar.dart';
import 'widgets/top_navbar.dart';
import 'widgets/main_content_layout.dart';

class HomeScreen extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());
  final HomeController homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const LeftSidebar(),
          Obx(() => homeController.isSecondSidebarVisible.value
              ?  SecondSidebar()
              : const SizedBox()),
          Expanded(
            child: Column(
              children: const [
                TopNavbar(),
                Expanded(
                  child: MainContentLayout(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
