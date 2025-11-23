import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_getx_app/controllers/theme_controller.dart';
import 'package:flutter_getx_app/controllers/language_controller.dart';
import 'package:flutter_getx_app/controllers/auth_controller.dart';
import 'package:flutter_getx_app/routes/app_pages.dart';
import 'package:flutter_getx_app/theme/app_typography.dart';

class SettingsScreen extends StatelessWidget {
  final ThemeController themeController = Get.find<ThemeController>();
  final LanguageController languageController = Get.find<LanguageController>();
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr),
      ),
      body: ListView(
        children: [
          // Theme section
          ListTile(
            title: Text('theme'.tr, style: AppTypography.heading5),
          ),
          GetBuilder<ThemeController>(
            builder: (controller) => SwitchListTile(
              title: Text('dark_mode'.tr, style: AppTypography.bodyMediumRegular),
              value: controller.isDarkMode,
              onChanged: (value) => controller.changeThemeMode(),
              secondary: Icon(
                controller.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          ListTile(
            title: Text('View Color Palette', style: AppTypography.bodyMediumRegular),
            trailing: Icon(Icons.palette, color: Theme.of(context).colorScheme.primary),
            onTap: () => Get.toNamed(Routes.COLOR_PALETTE),
          ),
          ListTile(
            title: Text('View Typography', style: AppTypography.bodyMediumRegular),
            trailing: Icon(Icons.text_fields, color: Theme.of(context).colorScheme.primary),
            onTap: () => Get.toNamed(Routes.TYPOGRAPHY),
          ),
          const Divider(),
          
          // Language section
          ListTile(
            title: Text('language'.tr, style: AppTypography.heading5),
          ),
          GetBuilder<LanguageController>(
            builder: (controller) => RadioListTile<String>(
              title: Text('english'.tr, style: AppTypography.bodyMediumRegular),
              value: 'en',
              groupValue: controller.locale.languageCode,
              onChanged: (value) => controller.changeLanguage(value!),
              secondary: const Icon(Icons.language),
            ),
          ),
          GetBuilder<LanguageController>(
            builder: (controller) => RadioListTile<String>(
              title: Text('arabic'.tr, style: AppTypography.bodyMediumRegular),
              value: 'ar',
              groupValue: controller.locale.languageCode,
              onChanged: (value) => controller.changeLanguage(value!),
              secondary: const Icon(Icons.language),
            ),
          ),
          const Divider(),
          
          // Account section
          ListTile(
            title: Text('account'.tr, style: AppTypography.heading5),
          ),
          ListTile(
            title: Text(
              'logout'.tr,
              style: AppTypography.bodyMediumRegular.copyWith(color: Colors.red),
            ),
            leading: const Icon(Icons.logout, color: Colors.red),
            onTap: () async {
              final confirmed = await Get.dialog<bool>(
                AlertDialog(
                  title: Text('confirm_logout'.tr),
                  content: Text('are_you_sure_logout'.tr),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(result: false),
                      child: Text('cancel'.tr),
                    ),
                    TextButton(
                      onPressed: () => Get.back(result: true),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: Text('logout'.tr),
                    ),
                  ],
                ),
              );
              
              if (confirmed == true) {
                await authController.logout();
              }
            },
          ),
        ],
      ),
    );
  }
}
