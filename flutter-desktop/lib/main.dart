import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_getx_app/bindings/app_binding.dart';
import 'package:flutter_getx_app/controllers/auth_controller.dart';
import 'package:flutter_getx_app/controllers/calendar_controller.dart';
import 'package:flutter_getx_app/controllers/communication_controller.dart';
import 'package:flutter_getx_app/controllers/gardes_controller.dart';
import 'package:flutter_getx_app/controllers/update_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_getx_app/routes/app_pages.dart';
import 'package:flutter_getx_app/utils/translation_service.dart';
import 'package:flutter_getx_app/controllers/theme_controller.dart';
import 'package:flutter_getx_app/controllers/language_controller.dart';
import 'package:flutter_getx_app/utils/storage_service.dart';
import 'package:flutter_getx_app/utils/country_service.dart';
import 'package:flutter_getx_app/utils/api_service.dart';
import 'package:flutter_getx_app/utils/location_service.dart';
import 'package:velopack_flutter/velopack_flutter.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Velopack Rust bridge
  await RustLib.init();

  // Handle velopack installer/updater lifecycle hooks
  // Only exit on install/uninstall — NOT on --veloapp-updated (app should keep running)
  const velopackExitCommands = [
    '--veloapp-install',
    '--veloapp-obsolete',
    '--veloapp-uninstall',
  ];
  if (velopackExitCommands.any((cmd) => args.contains(cmd))) {
    exit(0);
  }

  // Set system UI overlay style for status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  // Initialize services
  await Get.putAsync(() => StorageService().init());
  Get.put(CountryService());
  Get.put(ApiService());
  await Get.putAsync(() => LocationService().init());
  //Get.put(MedplumService());

  // Initialize controllers with proper dependency injection
  final themeController = Get.put(ThemeController());
  final languageController = Get.put(LanguageController());
  Get.put(AuthController());
  Get.put(GardesController());
  // UsersController is registered via lazyPut in AppBinding
  Get.put(CommunicationController());
  Get.put(CalendarController());
  Get.put(UpdateController());

  runApp(
    GetMaterialApp(
      title: 'Ayamedica',
      debugShowCheckedModeBanner: false,
      theme: themeController.lightTheme,
      darkTheme: themeController.darkTheme,
      themeMode: themeController.themeMode,
      locale: languageController.locale,
      fallbackLocale: TranslationService.fallbackLocale,
      translations: TranslationService(),
      initialRoute: Routes.SPLASH,
      getPages: AppPages.routes,
      initialBinding: AppBinding(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeController) => GetBuilder<LanguageController>(
        builder: (languageController) => GetMaterialApp(
          title: 'Ayamedica',
          debugShowCheckedModeBanner: false,
          theme: themeController.lightTheme,
          darkTheme: themeController.darkTheme,
          themeMode: themeController.themeMode,
          locale: languageController.locale,
          fallbackLocale: TranslationService.fallbackLocale,
          translations: TranslationService(),
          initialRoute: Routes.HOME,
          getPages: AppPages.routes,
        ),
      ),
    );
  }
}
