import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_getx_app/routes/app_pages.dart';
import 'package:flutter_getx_app/utils/storage_service.dart';
import 'package:flutter_getx_app/utils/country_service.dart';
import 'package:flutter_getx_app/utils/api_service.dart';
import 'package:flutter_getx_app/config/app_config.dart';

enum LoginMethod { phone, email }

enum LoginButtonState { disabled, loading, valid }

class AuthController extends GetxController {
  // Storage service
  final StorageService _storageService = Get.find<StorageService>();

  // Country service
  final CountryService countryService = Get.find<CountryService>();

  // API service for new login
  final ApiService _apiService = Get.find<ApiService>();

  // Observable for selected login method
  RxString selectedLoginMethod = 'email'.obs;

  // Text editing controllers
  final TextEditingController primaryFieldController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Observable for password visibility
  RxBool obscurePassword = true.obs;

  // Observable for login button state
  Rx<LoginButtonState> loginButtonState = LoginButtonState.disabled.obs;

  // Observable for form validation
  RxBool get isFormValid => _validateForm().obs;

  // Observable for error message
  final RxString loginErrorMessage = ''.obs;
  final RxString fieldErrorMessage = ''.obs;
  final RxBool showLoginError = false.obs;
  final RxBool isFieldInvalid = false.obs;

  // Development credentials from configuration
  static bool get isDevelopment => AppConfig.isDevelopment;
  static String get devEmail => AppConfig.devEmail;
  static String get devPassword => AppConfig.devPassword;

  // Method to auto-fill development credentials
  void _fillDevelopmentCredentials() {
    if (isDevelopment) {
      primaryFieldController.text = devEmail;
      passwordController.text = devPassword;
      // Trigger validation update
      updateLoginButtonState();
    }
  }

  // Method to clear development credentials
  void clearDevelopmentCredentials() {
    primaryFieldController.clear();
    passwordController.clear();
    updateLoginButtonState();
  }

  // Method to refill development credentials (useful for testing)
  void refillDevelopmentCredentials() {
    if (isDevelopment) {
      _fillDevelopmentCredentials();
    }
  }

  // Method to update selected login method
  void selectLoginMethod(String method) {
    selectedLoginMethod.value = method;
    // Clear field when switching methods
    primaryFieldController.clear();
    _clearErrors();
    // Re-fill development credentials if in dev mode
    if (isDevelopment && method == 'email') {
      _fillDevelopmentCredentials();
    }
  }

  // Method to validate form based on selected login method
  bool _validateForm() {
    final primaryField = primaryFieldController.text.trim();
    final password = passwordController.text.trim();

    if (!AppConfig.isValidPassword(password)) return false;

    switch (selectedLoginMethod.value) {
      case 'aid':
        return AppConfig.isValidAid(primaryField);
      case 'phone':
        return AppConfig.isValidPhone(primaryField);
      case 'email':
        return AppConfig.isValidEmail(primaryField);
      case 'nid_ppn':
        return AppConfig.isValidNid(primaryField);
      default:
        return primaryField.length >= 8;
    }
  }

  // Clear error states
  void _clearErrors() {
    isFieldInvalid.value = false;
    fieldErrorMessage.value = '';
    showLoginError.value = false;
    loginErrorMessage.value = '';
  }

  // Method to handle login button press with NEW API
  Future<void> login() async {
    print('🚀 AuthController: Login button pressed');

    if (loginButtonState.value == LoginButtonState.disabled) {
      print('❌ AuthController: Login button is disabled');
      return;
    }

    // Set button to loading state
    loginButtonState.value = LoginButtonState.loading;
    print('⏳ AuthController: Button state set to loading');

    try {
      // Get form data
      final primaryField = primaryFieldController.text.trim();
      final password = passwordController.text.trim();

      print(
          '📝 AuthController: Form data - Field: $primaryField, Method: ${selectedLoginMethod.value}');

      // Validate based on selected method
      if (!_validateForm()) {
        print('❌ AuthController: Form validation failed');
        _setFieldError(_getValidationErrorMessage());
        loginButtonState.value = LoginButtonState.valid;
        return;
      }

      print('✅ AuthController: Form validation passed');

      // Clear any previous error
      _clearErrors();

      // Call NEW login API
      print('🔄 AuthController: Calling NEW login API...');
      final loginResult = await _apiService.loginWithCredentials(
        emailOrPhone: primaryField,
        password: password,
      );

      print('📋 AuthController: Login result received: $loginResult');

      if (loginResult['success'] == true) {
        print('✅ AuthController: Login successful!');

        // Store tokens and user data
        final accessToken = loginResult['accessToken'] as String;
        final refreshToken = loginResult['refreshToken'] as String;

        await _storageService.saveAccessToken(accessToken);
        await _storageService.saveRefreshToken(refreshToken);
        await _storageService.saveLoginStatus(true);
        await _storageService.saveUserData({
          'login_method': selectedLoginMethod.value,
          'primary_field': primaryField,
          'last_login': DateTime.now().toIso8601String(),
        });

        print('💾 AuthController: Tokens and data saved to storage');
        print('🏢 AuthController: Navigating to organization selection...');

        // Navigate to organization selection screen
        Get.offAllNamed(Routes.ORGANISATION);
      } else {
        print('❌ AuthController: Login failed - ${loginResult['error']}');
        _setFieldError(loginResult['error'] ?? 'Login failed');
        loginButtonState.value = LoginButtonState.valid;
      }
    } catch (e) {
      // Handle login error
      print('💥 AuthController: Exception occurred: $e');
      print('📋 AuthController: Exception type: ${e.runtimeType}');
      _setFieldError('Login error: ${e.toString()}');
      loginButtonState.value = LoginButtonState.valid;
    }
  }

  // Set field error
  void _setFieldError(String message) {
    isFieldInvalid.value = true;
    fieldErrorMessage.value = message;
  }

  // Get validation error message
  String _getValidationErrorMessage() {
    switch (selectedLoginMethod.value) {
      case 'aid':
        return 'aid_invalid'.tr;
      case 'phone':
        return 'phone_invalid'.tr;
      case 'email':
        return 'email_invalid'.tr;
      case 'nid_ppn':
        return 'nid_invalid'.tr;
      default:
        return 'field_invalid'.tr;
    }
  }

  // Listen for changes in form fields to update button state
  void updateLoginButtonState() {
    final isValid = _validateForm();
    loginButtonState.value =
        isValid ? LoginButtonState.valid : LoginButtonState.disabled;

    // Clear error message and validation states when user starts typing
    if (showLoginError.value || isFieldInvalid.value) {
      _clearErrors();
    }
  }

  @override
  void onInit() {
    super.onInit();

    // Add listeners to text controllers
    primaryFieldController.addListener(updateLoginButtonState);
    passwordController.addListener(updateLoginButtonState);

    // Auto-fill development credentials
    _fillDevelopmentCredentials();

    // Initial validation check
    updateLoginButtonState();
  }

  // Logout the user and clear any session data
  Future<void> logout() async {
    try {
      // Clear all cached user/session data
      await _storageService.saveLoginStatus(false);
      await _storageService.clearAll();

      // Clear the form fields
      primaryFieldController.clear();
      passwordController.clear();

      // Reset the login button state
      loginButtonState.value = LoginButtonState.disabled;

      // Show logout success message
      Get.snackbar(
        'logout_success'.tr,
        'logged_out'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Navigate to login screen and remove all previous routes
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      Get.snackbar(
        'error_occurred'.tr,
        'logout_error'.tr + ': ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    primaryFieldController.removeListener(updateLoginButtonState);
    passwordController.removeListener(updateLoginButtonState);
    primaryFieldController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
