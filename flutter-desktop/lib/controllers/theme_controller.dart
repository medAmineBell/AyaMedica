import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_theme.dart';
import '../../utils/storage_service.dart';


class ThemeController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  
  late ThemeMode _themeMode;
  
  ThemeMode get themeMode => _themeMode;
  ThemeData get lightTheme => AppTheme.light;
  ThemeData get darkTheme => AppTheme.dark;
  
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  @override
  void onInit() {
    super.onInit();
    _loadThemeMode();
  }

  void _loadThemeMode() {
    _themeMode = _storageService.getThemeMode() ? ThemeMode.dark : ThemeMode.light;
    update();
  }

  void changeThemeMode() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _storageService.saveThemeMode(_themeMode == ThemeMode.dark);
    update();
  }

  void setLightMode() {
    _themeMode = ThemeMode.light;
    _storageService.saveThemeMode(false);
    update();
  }

  void setDarkMode() {
    _themeMode = ThemeMode.dark;
    _storageService.saveThemeMode(true);
    update();
  }
}
