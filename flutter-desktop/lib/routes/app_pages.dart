
import 'package:flutter_getx_app/screens/auth/login_screen.dart';
import 'package:flutter_getx_app/screens/organisation/branch_selection_screen.dart';
import 'package:flutter_getx_app/screens/organisation/create_organization_screen.dart';
import 'package:get/get.dart';
import 'package:flutter_getx_app/screens/splash/splash_screen.dart';
import 'package:flutter_getx_app/screens/onboarding/onboarding_screen.dart';
import 'package:flutter_getx_app/screens/home/home_screen.dart';
import 'package:flutter_getx_app/screens/settings/settings_screen.dart';

import 'package:flutter_getx_app/screens/permissions/location_permission_screen.dart';
import 'package:flutter_getx_app/screens/permissions/notification_permission_screen.dart';

part 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => SplashScreen(),
      transition: Transition.fade,
    ),
    GetPage(
      name: Routes.ONBOARDING,
      page: () => OnboardingScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.LOCATION_PERMISSION,
      page: () => LocationPermissionScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.NOTIFICATION_PERMISSION,
      page: () => NotificationPermissionScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => LoginScreen(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: Routes.HOME,
      page: () => HomeScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.SETTINGS,
      page: () => SettingsScreen(),
      transition: Transition.rightToLeft,
    ),
    
  GetPage(
      name: Routes.ORGANISATION,
      page: () => BranchSelectionScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.CREATE_ORGANIZATION,
      page: () => CreateOrganizationScreen(),
      transition: Transition.rightToLeft,
    ),


  ];
}
