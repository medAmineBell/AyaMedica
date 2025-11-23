class AppConfig {
  // Development mode configuration
  static const bool isDevelopment = true; // Set to false for production

  // Development credentials (for testing only)

  static const String devEmail = 'admin@example.com';
  static const String devPassword = 'medplum_admin';
/*
  static const String devEmail = 'devops@ayamedica.com';
  static const String devPassword = 'o\$dgm7Dd';
*/
  // API Configuration
  static const String baseUrl = 'https://api.ayamedica.online';
  static const String authUrl = 'https://api.ayamedica.online/auth/login';
  static const String oauth2TokenUrl =
      'https://api.ayamedica.online/oauth2/token';
  static const String userProfileUrl = 'https://api.ayamedica.online/auth/me';
  static const String redirectUri = 'https://app.ayamedica.online/';

  // Use the first client ID for now, can be changed for testing
  static const String clientId = 'flutter-app';
  static const String clientSecret =
      'CLIENT_SECRET_NOT_SET'; // Should be loaded from environment

  // PKCE Configuration
  static const int codeVerifierLength = 128; // Length of code verifier for PKCE
  static const int codeChallengeLength =
      43; // Length of code challenge for PKCE

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
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
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
