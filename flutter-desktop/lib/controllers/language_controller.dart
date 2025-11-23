import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/storage_service.dart';

class LanguageController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  
  late Locale _locale;

  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';

  @override
  void onInit() {
    super.onInit();
    _locale = const Locale('en'); // Set default locale
    _loadLanguage();
  }

  void _loadLanguage() {
    final String languageCode = _storageService.getLanguage();
    _locale = Locale(languageCode);
    update();
  }

  void changeLanguage(String languageCode) {
    _locale = Locale(languageCode);
    _storageService.saveLanguage(languageCode);
    Get.updateLocale(_locale);
    update();
  }

  void toggleLanguage() {
    final String newLanguageCode = _locale.languageCode == 'en' ? 'ar' : 'en';
    changeLanguage(newLanguageCode);
  }
}
