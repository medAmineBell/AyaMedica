import 'package:package_info_plus/package_info_plus.dart';

class AppConfig {
  static PackageInfo? _packageInfo;

  static Future<void> init() async {
    _packageInfo = await PackageInfo.fromPlatform();
  }

  static String get appVersion => _packageInfo?.version ?? '0.0.0';

  // Velopack update configuration (private release repo)
  static const String updateUrl =
      'https://github.com/Ayamedica-MP/DesktopApp/releases/latest/download/';
  // Token injected at build time: --dart-define=UPDATE_TOKEN=ghp_xxx
  static const String updateToken =
      String.fromEnvironment('UPDATE_TOKEN', defaultValue: '');

  // Development mode configuration
  static const bool isDevelopment = true;

  // Development credentials
  static const String devEmail = "ahmed@ayamedica.com";
  static const String devPassword = "22001018888818";

  // static const String newBackendUrl = 'http://localhost:3000';
  // NEW Backend API Configuration
  static const String newBackendUrl =
      'https://ayamedica-backend.ayamedica.online';

  static const String newLoginUrl = '$newBackendUrl/api/auth/login';
  static const String newOrganizationsUrl = '$newBackendUrl/api/organizations';
  static const String forgotPasswordUrl =
      '$newBackendUrl/api/auth/forgot-password';
  static const String verifyResetOtpUrl =
      '$newBackendUrl/api/auth/verify-reset-otp';
  static const String resetPasswordUrl =
      '$newBackendUrl/api/auth/reset-password';

  // Original Medplum API Configuration (keep for backwards compatibility)
  static const String baseUrl = 'https://api.ayamedica.online';
  static const String authUrl = '$baseUrl/auth/login';
  static const String oauth2TokenUrl = '$baseUrl/oauth2/token';
  static const String userProfileUrl = '$baseUrl/auth/me';
  static const String redirectUri = 'https://app.ayamedica.online';
  static const String clientId = 'flutter-app';
  static const String clientSecret = 'CLIENTSECRET_NOTSET';

  // PKCE Configuration
  static const int codeVerifierLength = 128;
  static const int codeChallengeLength = 43;

  // Validation Rules
  static const int minPasswordLength = 6;
  static const int minAidLength = 8;
  static const int minPhoneLength = 8;
  static const int minNidLength = 10;

  // UI Configuration
  static const int maxLoginAttempts = 3;
  static const int sessionTimeoutMinutes = 30;

  // Environment-specific configuration
  static bool get isProduction => !isDevelopment;
  static bool get isDebug => isDevelopment;

  // Validation methods
  static bool isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]{2,4}$').hasMatch(email);
  }

  static bool isValidPassword(String password) {
    return password.length >= minPasswordLength;
  }

  static bool isValidAid(String aid) {
    return aid.length >= minAidLength;
  }

  static bool isValidPhone(String phone) {
    return phone.length >= minPhoneLength;
  }

  static bool isValidNid(String nid) {
    return nid.length >= minNidLength;
  }
}
