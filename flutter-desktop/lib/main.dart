import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_getx_app/bindings/app_binding.dart';
import 'package:flutter_getx_app/controllers/auth_controller.dart';
import 'package:flutter_getx_app/controllers/calendar_controller.dart';
import 'package:flutter_getx_app/controllers/communication_controller.dart';
import 'package:flutter_getx_app/controllers/gardes_controller.dart';
import 'package:flutter_getx_app/controllers/users_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_getx_app/routes/app_pages.dart';
import 'package:flutter_getx_app/utils/translation_service.dart';
import 'package:flutter_getx_app/controllers/theme_controller.dart';
import 'package:flutter_getx_app/controllers/language_controller.dart';
import 'package:flutter_getx_app/utils/storage_service.dart';
import 'package:flutter_getx_app/utils/country_service.dart';
import 'package:flutter_getx_app/utils/api_service.dart';
import 'package:flutter_getx_app/utils/medplum_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
  Get.put(MedplumService());

  // Initialize controllers with proper dependency injection
  final themeController = Get.put(ThemeController());
  final languageController = Get.put(LanguageController());
  Get.put(AuthController());
  Get.put(GardesController());
  Get.put(UsersController());
  Get.put(CommunicationController());
  Get.put(CalendarController());

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
