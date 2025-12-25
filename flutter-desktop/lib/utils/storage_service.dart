import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class StorageService extends GetxService {
  late GetStorage _box;

  Future<StorageService> init() async {
    await GetStorage.init();
    _box = GetStorage();
    return this;
  }

  // Theme
  bool getThemeMode() => _box.read('darkMode') ?? false;
  Future<void> saveThemeMode(bool isDarkMode) =>
      _box.write('darkMode', isDarkMode);

  // Language
  String getLanguage() => _box.read('language') ?? 'en';
  Future<void> saveLanguage(String language) =>
      _box.write('language', language);

  // Onboarding
  bool getOnboardingStatus() => _box.read('onboardingComplete') ?? false;
  Future<void> saveOnboardingStatus(bool status) =>
      _box.write('onboardingComplete', status);

  // Location Permission
  bool getLocationPermissionStatus() =>
      _box.read('locationPermissionGranted') ?? false;
  Future<void> saveLocationPermissionStatus(bool status) =>
      _box.write('locationPermissionGranted', status);

  // Notification Permission
  bool getNotificationPermissionStatus() =>
      _box.read('notificationPermissionGranted') ?? false;
  Future<void> saveNotificationPermissionStatus(bool status) =>
      _box.write('notificationPermissionGranted', status);

  // Login Status
  bool getLoginStatus() => _box.read('isLoggedIn') ?? false;
  Future<void> saveLoginStatus(bool status) => _box.write('isLoggedIn', status);

  // User Data
  Map<String, dynamic>? getUserData() => _box.read('userData');
  Future<void> saveUserData(Map<String, dynamic> userData) =>
      _box.write('userData', userData);
  Future<void> clearUserData() => _box.remove('userData');

  // Medplum Access Token
  String? getAccessToken() => _box.read('medplum_access_token');
  Future<void> saveAccessToken(String token) =>
      _box.write('medplum_access_token', token);
  Future<void> clearAccessToken() => _box.remove('medplum_access_token');

  // Medplum Login Session
  Map<String, dynamic>? getLoginSession() => _box.read('medplum_login_session');
  Future<void> saveLoginSession(Map<String, dynamic> session) =>
      _box.write('medplum_login_session', session);
  Future<void> clearLoginSession() => _box.remove('medplum_login_session');

  // Branch Selection
  bool getBranchSelectedStatus() => _box.read('branchSelected') ?? false;
  Future<void> saveBranchSelectedStatus(bool status) =>
      _box.write('branchSelected', status);
  Future<void> clearBranchSelectedStatus() => _box.remove('branchSelected');

  // Selected Branch Data
  Map<String, dynamic>? getSelectedBranchData() =>
      _box.read('selectedBranchData');
  Future<void> saveSelectedBranchData(Map<String, dynamic> branchData) =>
      _box.write('selectedBranchData', branchData);
  Future<void> clearSelectedBranchData() => _box.remove('selectedBranchData');

  // Organization ID
  String? getOrganizationId() => _box.read('organizationId');
  Future<void> saveOrganizationId(String organizationId) =>
      _box.write('organizationId', organizationId);
  Future<void> clearOrganizationId() => _box.remove('organizationId');

  // Organization Type Flags
  bool getIsSchool() => _box.read('isSchool') ?? false;
  Future<void> saveIsSchool(bool isSchool) => _box.write('isSchool', isSchool);
  Future<void> clearIsSchool() => _box.remove('isSchool');

  bool getIsClinic() => _box.read('isClinic') ?? false;
  Future<void> saveIsClinic(bool isClinic) => _box.write('isClinic', isClinic);
  Future<void> clearIsClinic() => _box.remove('isClinic');

  // Add these methods to your StorageService class

// Refresh Token
  String? getRefreshToken() => _box.read('refresh_token');

  Future<void> saveRefreshToken(String token) =>
      _box.write('refresh_token', token);

  Future<void> clearRefreshToken() => _box.remove('refresh_token');
}
