class AppConfig {
  // Development mode configuration
  static const bool isDevelopment = true;

  // Development credentials
  static const String devEmail = "weewrrwtt@gmail.com";
  static const String devPassword = "Test1234";

  // NEW Backend API Configuration
  static const String newBackendUrl =
      'https://ayamedica-backend.ayamedica.online';
  static const String newLoginUrl = '$newBackendUrl/api/auth/login';
  static const String newOrganizationsUrl = '$newBackendUrl/api/organizations';

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
