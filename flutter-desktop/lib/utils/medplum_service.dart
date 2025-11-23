import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/home_controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_getx_app/utils/storage_service.dart';
import 'package:flutter_getx_app/models/oauth2_response.dart';
import 'package:flutter_getx_app/models/user_profile.dart';
import 'package:flutter_getx_app/models/fhir_organization.dart';
import 'package:flutter_getx_app/routes/app_pages.dart';
import 'package:flutter_getx_app/config/app_config.dart';

class MedplumService extends GetxService {
  final StorageService _storageService = Get.find<StorageService>();

  // Observable for authentication state
  final RxBool isAuthenticated = false.obs;
  final Rx<Map<String, dynamic>?> currentUser = Rx<Map<String, dynamic>?>(null);
  final RxString accessToken = ''.obs;
  final Rx<OAuth2Response?> oauth2Response = Rx<OAuth2Response?>(null);
  final Rx<UserProfile?> userProfile = Rx<UserProfile?>(null);

  // Organizations observable
  final Rx<List<FhirOrganization>> organizations =
      Rx<List<FhirOrganization>>([]);

  // PKCE parameters
  String? _currentCodeVerifier;

  // Ayamedica API configuration from AppConfig
  static String get baseUrl => AppConfig.baseUrl;
  static String get authUrl => AppConfig.authUrl;
  static String get oauth2TokenUrl => AppConfig.oauth2TokenUrl;
  static String get userProfileUrl => AppConfig.userProfileUrl;
  static String get clientId => AppConfig.clientId;
  static String get clientSecret => AppConfig.clientSecret;
  static String get redirectUri => AppConfig.redirectUri;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _checkExistingAuth();
  }

  Future<void> _checkExistingAuth() async {
    try {
      final token = await _storageService.getAccessToken();
      final loginSession = await _storageService.getLoginSession();

      if (token != null && token.isNotEmpty && loginSession != null) {
        accessToken.value = token;
        isAuthenticated.value = true;
        await _loadCurrentUser();
      }
    } catch (e) {
      print('Error checking existing auth: $e');
    }
  }

  Future<void> _loadCurrentUser() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/User/me'),
        headers: {
          'Authorization': 'Bearer ${accessToken.value}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        currentUser.value = userData;
      } else if (response.statusCode == 401) {
        print(
            '🔒 Unauthorized (401) in _loadCurrentUser - Token expired or invalid');
        await _handleUnauthorized();
      }
    } catch (e) {
      print('Error loading current user: $e');
    }
  }

  // Login with username and password
  Future<Map<String, dynamic>> loginWithPassword({
    required String username,
    required String password,
  }) async {
    try {
      print('🔐 Starting login process...');
      print('📧 Username: $username');
      print(
          '🔑 Password: ${password.replaceRange(0, password.length, '*' * password.length)}');
      print('🌐 Auth URL: $authUrl');

      // Generate PKCE parameters for the login request
      final codeVerifier = _generateCodeVerifier();
      final codeChallenge = _generateCodeChallenge(codeVerifier);

      // Store code verifier for later use in OAuth2 exchange
      _currentCodeVerifier = codeVerifier;

      final requestBody = {
        'email': username,
        'password': password,
        'remember': false,
        'codeChallengeMethod': 'S256',
        'codeChallenge': codeChallenge,
        'clientId': '',
      };

      print('🔐 Generated Code Verifier: ${codeVerifier.substring(0, 8)}...');
      print('🔑 Generated Code Challenge: ${codeChallenge.substring(0, 8)}...');

      print('📤 Request Body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse(authUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('📡 Response Status: ${response.statusCode}');
      print('📡 Response Headers: ${response.headers}');
      print('📡 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Login successful! Status: 200');
        final loginData = jsonDecode(response.body);
        print('📋 Parsed Login Data: $loginData');

        // Check if login was successful (has login and code fields)
        if (loginData.containsKey('login') && loginData.containsKey('code')) {
          print('🎉 Login response contains required fields');

          // Store the login session data
          final loginId = loginData['login'] as String;
          final code = loginData['code'] as String;

          print('🆔 Login ID: $loginId');
          print('🔐 Code: $code');

          // Store login session for further authentication steps
          await _storageService.saveLoginSession({
            'login': loginId,
            'code': code,
          });
          print('💾 Login session saved to storage');

          // For now, we'll use the login ID as our access token
          // In a real implementation, you might need to exchange this for an access token
          accessToken.value = loginId;
          await _storageService.saveAccessToken(loginId);
          isAuthenticated.value = true;
          print('🔑 Access token set: $loginId');
          print('✅ Authentication state: ${isAuthenticated.value}');

          await _loadCurrentUser();
          print('👤 Current user loaded: ${currentUser.value}');

          return {
            'success': true,
            'message': 'Login successful',
            'user': currentUser.value,
            'loginData': loginData,
          };
        } else {
          print('❌ Login response missing required fields (login/code)');
          print('📋 Available keys: ${loginData.keys.toList()}');
          return {
            'success': false,
            'message': 'Invalid response format - missing login or code field',
          };
        }
      } else {
        print('❌ Login failed! Status: ${response.statusCode}');

        // Check if response is HTML (like 502 Bad Gateway)
        if (response.body.trim().startsWith('<html>') ||
            response.body.trim().startsWith('<!DOCTYPE')) {
          print('🌐 Server returned HTML error page');
          return {
            'success': false,
            'message':
                'Server error (${response.statusCode}): ${_extractHtmlError(response.body)}',
          };
        }

        // Try to parse as JSON
        try {
          final errorData = jsonDecode(response.body);
          print('📋 Error Data: $errorData');

          // Handle OperationOutcome error format
          if (errorData.containsKey('resourceType') &&
              errorData['resourceType'] == 'OperationOutcome') {
            print('🔍 Detected OperationOutcome error format');
            final issues = errorData['issue'] as List<dynamic>;
            if (issues.isNotEmpty) {
              final firstIssue = issues[0] as Map<String, dynamic>;
              final details = firstIssue['details'] as Map<String, dynamic>;
              final errorMessage = details['text'] as String;

              print('💬 Error message: $errorMessage');
              return {
                'success': false,
                'message': errorMessage,
              };
            }
          }

          print('⚠️ Unknown JSON error format');
          return {
            'success': false,
            'message': 'Login failed with status: ${response.statusCode}',
          };
        } catch (jsonError) {
          print('❌ Failed to parse error response as JSON: $jsonError');
          return {
            'success': false,
            'message':
                'Server error (${response.statusCode}): Unable to parse response',
          };
        }
      }
    } catch (e) {
      print('💥 Exception occurred during login: $e');
      print('📋 Exception type: ${e.runtimeType}');
      print('📋 Stack trace: ${StackTrace.current}');
      return {
        'success': false,
        'message': 'Login error: ${e.toString()}',
      };
    }
  }

  // Login with OAuth (for different login methods)
  Future<Map<String, dynamic>> loginWithOAuth({
    required String loginType,
    required String identifier,
    String? password,
  }) async {
    try {
      // For now, use the same password-based login for all types
      // In a real implementation, you would handle different OAuth flows
      return await loginWithPassword(
        username: identifier,
        password: password ?? '',
      );
    } catch (e) {
      return {
        'success': false,
        'message': 'Login error: ${e.toString()}',
      };
    }
  }

  // Exchange authorization code for OAuth2 tokens
  Future<Map<String, dynamic>> exchangeAuthorizationCode({
    required String code,
    String?
        codeVerifier, // Optional code verifier, will use stored one if not provided
    String? loginId, // Optional login ID that might be used as client_id
  }) async {
    try {
      // Use provided code verifier or fall back to stored one
      final actualCodeVerifier = codeVerifier ?? _currentCodeVerifier;
      if (actualCodeVerifier == null) {
        return {
          'success': false,
          'message': 'No code verifier available for OAuth2 exchange',
        };
      }

      print('🔄 Starting OAuth2 token exchange...');
      print('🔐 Code: ${code.substring(0, 8)}...');
      print('🔑 Code Verifier: ${actualCodeVerifier.substring(0, 8)}...');
      print('🆔 Client ID: "" (empty)');
      print('🌐 Redirect URI: $redirectUri');
      if (loginId != null) {
        print('🔍 Login ID: $loginId');
      }

      final requestBody = <String, String>{
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': redirectUri,
        'code_verifier': actualCodeVerifier,
        'client_id': '', // Always use empty client_id
      };

      print('📤 OAuth2 Request Body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse(oauth2TokenUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: requestBody,
      );

      print('📡 OAuth2 Response Status: ${response.statusCode}');
      print('📡 OAuth2 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ OAuth2 token exchange successful!');
        final oauth2Data = jsonDecode(response.body);
        final oauth2ResponseData = OAuth2Response.fromJson(oauth2Data);

        // Store OAuth2 response
        oauth2Response.value = oauth2ResponseData;

        // Store access token
        accessToken.value = oauth2ResponseData.accessToken;
        await _storageService.saveAccessToken(oauth2ResponseData.accessToken);

        // Set authentication state
        isAuthenticated.value = true;

        print(
            '🔑 Access token stored: ${oauth2ResponseData.accessToken.substring(0, 20)}...');
        print('✅ Authentication state: ${isAuthenticated.value}');

        // Load user profile
        await _loadUserProfile();

        return {
          'success': true,
          'message': 'OAuth2 token exchange successful',
          'oauth2Response': oauth2ResponseData,
          'userProfile': userProfile.value,
        };
      } else if (response.statusCode == 401) {
        print(
            '🔒 Unauthorized (401) in OAuth2 token exchange - Token expired or invalid');
        await _handleUnauthorized();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
          'statusCode': response.statusCode,
        };
      } else {
        print('❌ OAuth2 token exchange failed! Status: ${response.statusCode}');

        try {
          final errorData = jsonDecode(response.body);
          return {
            'success': false,
            'message': errorData['error_description'] ??
                errorData['error'] ??
                'OAuth2 token exchange failed',
            'statusCode': response.statusCode,
          };
        } catch (jsonError) {
          return {
            'success': false,
            'message':
                'OAuth2 token exchange failed with status: ${response.statusCode}',
            'statusCode': response.statusCode,
          };
        }
      }
    } catch (e) {
      print('💥 Exception during OAuth2 token exchange: $e');
      return {
        'success': false,
        'message': 'OAuth2 token exchange error: ${e.toString()}',
      };
    }
  }

  // Load user profile from /auth/me endpoint
  Future<void> _loadUserProfile() async {
    try {
      print('👤 Loading user profile...');

      final response = await http.get(
        Uri.parse(userProfileUrl),
        headers: {
          'Authorization': 'Bearer ${accessToken.value}',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('📡 User Profile Response Status: ${response.statusCode}');
      print('📡 User Profile Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ User profile loaded successfully!');
        final profileData = jsonDecode(response.body);
        final userProfileData = UserProfile.fromJson(profileData);

        // Store user profile
        userProfile.value = userProfileData;
        currentUser.value = profileData;

        print('👤 User: ${userProfileData.user.email}');
        print('🏢 Project: ${userProfileData.project.name}');
        print('👨‍⚕️ Profile: ${userProfileData.profile.name.first.family}');
      } else if (response.statusCode == 401) {
        print('🔒 Unauthorized (401) - Token expired or invalid');
        await _handleUnauthorized();
      } else {
        print('❌ Failed to load user profile! Status: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Error loading user profile: $e');
    }
  }

  // Handle unauthorized access (401)
  Future<void> _handleUnauthorized() async {
    try {
      print('🔒 Handling unauthorized access...');

      // Clear all authentication data
      await logout();

      // Show unauthorized dialog
      _showUnauthorizedDialog();
    } catch (e) {
      print('💥 Error handling unauthorized access: $e');
    }
  }

  // Show unauthorized dialog
  void _showUnauthorizedDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFFFE6E6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.security,
                color: Colors.red,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Session Expired',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: const Text(
          'Your session has expired. Please log in again to continue.',
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.offAllNamed(Routes.LOGIN);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text(
              'Login Again',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false, // Prevent dismissing by tapping outside
    );
  }

  // Get user profile (public method)
  Future<UserProfile?> getCurrentUserProfile() async {
    if (isAuthenticated.value && userProfile.value == null) {
      await _loadUserProfile();
    }
    return userProfile.value;
  }

  // Logout
  Future<void> logout() async {
    try {
      await _storageService.clearAccessToken();
      await _storageService.clearLoginSession();
      accessToken.value = '';
      isAuthenticated.value = false;
      currentUser.value = null;
      oauth2Response.value = null;
      userProfile.value = null;
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  // Get current user profile
  Future<Map<String, dynamic>?> getCurrentUser() async {
    if (isAuthenticated.value) {
      return currentUser.value;
    }
    return null;
  }

  // Check if user is authenticated
  bool get isLoggedIn => isAuthenticated.value;

  // Get access token
  String? get token => accessToken.value.isNotEmpty ? accessToken.value : null;

  // Generate a random code verifier for PKCE
  String _generateCodeVerifier() {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final random = DateTime.now().millisecondsSinceEpoch;
    final codeVerifier = StringBuffer();

    // Generate a 128-character code verifier as per PKCE spec
    for (int i = 0; i < 128; i++) {
      // Use a more random approach with multiple sources
      final seed = (random + i * 1000) % chars.length;
      codeVerifier.write(chars[seed]);
    }

    return codeVerifier.toString();
  }

  // Generate code challenge from code verifier using SHA256
  String _generateCodeChallenge(String codeVerifier) {
    // Create SHA256 hash of the code verifier
    final bytes = utf8.encode(codeVerifier);
    final digest = sha256.convert(bytes);

    // Encode as base64url (RFC 4648)
    final base64String = base64.encode(digest.bytes);

    // Remove padding and replace characters as per PKCE spec
    return base64String
        .replaceAll('+', '-')
        .replaceAll('/', '_')
        .replaceAll('=', '');
  }

  // Helper method to extract error message from HTML
  String _extractHtmlError(String htmlBody) {
    try {
      // Look for common error patterns in HTML
      if (htmlBody.contains('502 Bad Gateway')) {
        return 'Bad Gateway - Server is temporarily unavailable';
      } else if (htmlBody.contains('503 Service Unavailable')) {
        return 'Service Unavailable - Server is down for maintenance';
      } else if (htmlBody.contains('404 Not Found')) {
        return 'Not Found - API endpoint does not exist';
      } else if (htmlBody.contains('500 Internal Server Error')) {
        return 'Internal Server Error - Server encountered an error';
      } else {
        return 'Server error - Check server status';
      }
    } catch (e) {
      return 'Unknown server error';
    }
  }

  // Fetch child organizations from FHIR API using partof parameter
  Future<Map<String, dynamic>> fetchChildOrganizations({
    required String parentOrganizationId,
    int count = 20,
    String sort = '-_lastUpdated',
    String total = 'accurate',
  }) async {
    try {
      print('🏢 Starting child organizations fetch...');
      print('🔑 Access token: ${accessToken.value.substring(0, 20)}...');
      print('👨‍👩‍👧‍👦 Parent Organization ID: $parentOrganizationId');

      final uri = Uri.parse(
          '$baseUrl/fhir/R4/Organization?partof=Organization%2F$parentOrganizationId');

      print('🌐 Child Organizations URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${accessToken.value}',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      print('📡 Child Organizations Response Status: ${response.statusCode}');
      print('📡 Child Organizations Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print('🔍 Parsing FHIR Bundle for child organizations...');

        try {
          // Parse the JSON response directly
          final List<dynamic> entries = jsonData['entry'] ?? [];
          final List<FhirOrganization> organizationList = [];

          for (final entry in entries) {
            if (entry['resource'] != null) {
              final organization = FhirOrganization.fromJson(entry['resource']);
              organizationList.add(organization);
            }
          }

          print('✅ FHIR Bundle parsed successfully for child organizations');

          // Update organizations observable
          organizations.value = organizationList;

          print(
              '✅ Child organizations fetched successfully: ${organizations.value.length} organizations');

          return {
            'success': true,
            'message': 'Child organizations fetched successfully',
            'organizations': organizations.value,
            'total': jsonData['total'] ?? organizationList.length,
            'parentId': parentOrganizationId,
          };
        } catch (parseError) {
          print(
              '❌ Error parsing FHIR Bundle for child organizations: $parseError');
          return {
            'success': false,
            'message':
                'Failed to parse child organizations data: ${parseError.toString()}',
          };
        }
      } else if (response.statusCode == 401) {
        print(
            '🔒 Unauthorized (401) in child organizations fetch - Token expired or invalid');
        await _handleUnauthorized();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
          'statusCode': response.statusCode,
        };
      } else {
        print(
            '❌ Child organizations fetch failed! Status: ${response.statusCode}');

        try {
          final errorData = jsonDecode(response.body);
          return {
            'success': false,
            'message': errorData['issue']?[0]?['diagnostics'] ??
                'Failed to fetch child organizations',
            'statusCode': response.statusCode,
          };
        } catch (jsonError) {
          return {
            'success': false,
            'message':
                'Failed to fetch child organizations with status: ${response.statusCode}',
            'statusCode': response.statusCode,
          };
        }
      }
    } catch (e) {
      print('💥 Exception during child organizations fetch: $e');
      return {
        'success': false,
        'message': 'Child organizations fetch error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> fetchOrganizationLocation() async {
    // get the organisation id from homecontroller obranch data
    final homeController = Get.find<HomeController>();
    final organizationId =
        homeController.selectedBranchData.value?['organizationId'];
    if (organizationId == null) {
      return {
        'success': false,
        'message': 'Organization ID not found',
      };
    }

    // get url :baseurl/fhir/R4/Location?organization=Organization%orgID
    try {
      final uri = Uri.parse(
          '$baseUrl/fhir/R4/Location?organization=Organization%2F$organizationId');
      print('🌐 Organization Location URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${accessToken.value}',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      print('📡 Organization Location Response Status: ${response.statusCode}');
      print('📡 Organization Location Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print('🔍 Parsing FHIR Bundle for organization location...');

        try {
          // Check if it's a valid FHIR Bundle
          if (jsonData['resourceType'] == 'Bundle' &&
              jsonData['entry'] != null) {
            final List<dynamic> entries = jsonData['entry'];

            if (entries.isNotEmpty) {
              // Get the first entry's resource ID
              final firstEntry = entries[0];
              final resource = firstEntry['resource'];

              if (resource != null && resource['id'] != null) {
                final locationId = resource['id'] as String;
                print('✅ Location ID extracted: $locationId');

                return {
                  'success': true,
                  'message': 'Organization location fetched successfully',
                  'locationId': locationId,
                  'organizationId': organizationId,
                  'fullResponse': jsonData,
                };
              } else {
                print('❌ No resource or ID found in first entry');
                return {
                  'success': false,
                  'message': 'No location resource found in response',
                };
              }
            } else {
              print('❌ No entries found in FHIR Bundle');
              return {
                'success': false,
                'message': 'No location entries found for organization',
              };
            }
          } else {
            print('❌ Invalid FHIR Bundle format');
            return {
              'success': false,
              'message': 'Invalid FHIR response format',
            };
          }
        } catch (parseError) {
          print(
              '❌ Error parsing FHIR Bundle for organization location: $parseError');
          return {
            'success': false,
            'message':
                'Failed to parse location data: ${parseError.toString()}',
          };
        }
      } else if (response.statusCode == 401) {
        print(
            '🔒 Unauthorized (401) in organization location fetch - Token expired or invalid');
        await _handleUnauthorized();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
          'statusCode': response.statusCode,
        };
      } else {
        print(
            '❌ Organization location fetch failed! Status: ${response.statusCode}');

        try {
          final errorData = jsonDecode(response.body);
          return {
            'success': false,
            'message': errorData['issue']?[0]?['diagnostics'] ??
                'Failed to fetch organization location',
            'statusCode': response.statusCode,
          };
        } catch (jsonError) {
          return {
            'success': false,
            'message':
                'Failed to fetch organization location with status: ${response.statusCode}',
            'statusCode': response.statusCode,
          };
        }
      }
    } catch (e) {
      print('💥 Exception during organization location fetch: $e');
      return {
        'success': false,
        'message': 'Organization location fetch error: ${e.toString()}',
      };
    }
  }

  // Get appointments by location ID with date range
  Future<Map<String, dynamic>> getAppointmentsByLocation({
    required String locationId,
    String? startDate, // Format: 2025-09-24T21:00:00.000Z
    String? endDate, // Format: 2025-09-25T20:59:59.000Z
    int count = 20,
    String sort = '-_lastUpdated',
    String total = 'accurate',
  }) async {
    try {
      print('📅 Starting appointments fetch by location...');
      print('🔑 Access token: ${accessToken.value.substring(0, 20)}...');
      print('📍 Location ID: $locationId');
      print('📅 Start Date: $startDate');
      print('📅 End Date: $endDate');

      // Build the URL with location parameter
      String url =
          '$baseUrl/fhir/R4/Appointment?location=Location%2F$locationId';

      // Add date parameters if provided
      if (startDate != null) {
        url += '&date=ge${Uri.encodeComponent(startDate)}';
      }
      if (endDate != null) {
        url += '&date=le${Uri.encodeComponent(endDate)}';
      }

      // Add other parameters
      url += '&_count=$count&_sort=$sort&_total=$total';

      final uri = Uri.parse(url);
      print('🌐 Appointments URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${accessToken.value}',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      print('📡 Appointments Response Status: ${response.statusCode}');
      print('📡 Appointments Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print('🔍 Parsing FHIR Bundle for appointments...');

        try {
          // Check if it's a valid FHIR Bundle
          if (jsonData['resourceType'] == 'Bundle' &&
              jsonData['entry'] != null) {
            final List<dynamic> entries = jsonData['entry'];
            final List<Map<String, dynamic>> appointmentList = [];

            for (final entry in entries) {
              if (entry['resource'] != null) {
                appointmentList.add(entry['resource'] as Map<String, dynamic>);
              }
            }

            print('✅ FHIR Bundle parsed successfully for appointments');
            print('📅 Found ${appointmentList.length} appointments');

            return {
              'success': true,
              'message': 'Appointments fetched successfully',
              'appointments': appointmentList,
              'total': jsonData['total'] ?? appointmentList.length,
              'locationId': locationId,
              'startDate': startDate,
              'endDate': endDate,
              'fullResponse': jsonData,
            };
          } else {
            print('❌ Invalid FHIR Bundle format');
            return {
              'success': false,
              'message': 'Invalid FHIR response format',
            };
          }
        } catch (parseError) {
          print('❌ Error parsing FHIR Bundle for appointments: $parseError');
          return {
            'success': false,
            'message':
                'Failed to parse appointments data: ${parseError.toString()}',
          };
        }
      } else if (response.statusCode == 401) {
        print(
            '🔒 Unauthorized (401) in appointments fetch - Token expired or invalid');
        await _handleUnauthorized();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
          'statusCode': response.statusCode,
        };
      } else {
        print('❌ Appointments fetch failed! Status: ${response.statusCode}');

        try {
          final errorData = jsonDecode(response.body);
          return {
            'success': false,
            'message': errorData['issue']?[0]?['diagnostics'] ??
                'Failed to fetch appointments',
            'statusCode': response.statusCode,
          };
        } catch (jsonError) {
          return {
            'success': false,
            'message':
                'Failed to fetch appointments with status: ${response.statusCode}',
            'statusCode': response.statusCode,
          };
        }
      }
    } catch (e) {
      print('💥 Exception during appointments fetch: $e');
      return {
        'success': false,
        'message': 'Appointments fetch error: ${e.toString()}',
      };
    }
  }

  // Fetch a specific organization by ID
  Future<Map<String, dynamic>> fetchOrganizationById({
    required String organizationId,
  }) async {
    try {
      print('🏢 Fetching organization by ID: $organizationId');
      print('🔑 Access token: ${accessToken.value.substring(0, 20)}...');

      final uri = Uri.parse('$baseUrl/fhir/R4/Organization/$organizationId');

      print('🌐 Organization URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${accessToken.value}',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      print('📡 Organization Response Status: ${response.statusCode}');
      print('📡 Organization Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print('🔍 Parsing organization data...');

        try {
          final organization = FhirOrganization.fromJson(jsonData);

          print('✅ Organization fetched successfully: ${organization.name}');

          return {
            'success': true,
            'message': 'Organization fetched successfully',
            'organization': organization,
            'id': organizationId,
          };
        } catch (parseError) {
          print('❌ Error parsing organization data: $parseError');
          return {
            'success': false,
            'message':
                'Failed to parse organization data: ${parseError.toString()}',
          };
        }
      } else if (response.statusCode == 401) {
        print(
            '🔒 Unauthorized (401) in organization fetch - Token expired or invalid');
        await _handleUnauthorized();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
          'statusCode': response.statusCode,
        };
      } else {
        print('❌ Organization fetch failed! Status: ${response.statusCode}');

        try {
          final errorData = jsonDecode(response.body);
          return {
            'success': false,
            'message': errorData['issue']?[0]?['diagnostics'] ??
                'Failed to fetch organization',
            'statusCode': response.statusCode,
          };
        } catch (jsonError) {
          return {
            'success': false,
            'message':
                'Failed to fetch organization with status: ${response.statusCode}',
            'statusCode': response.statusCode,
          };
        }
      }
    } catch (e) {
      print('💥 Exception during organization fetch: $e');
      return {
        'success': false,
        'message': 'Organization fetch error: ${e.toString()}',
      };
    }
  }

  // Fetch organizations from FHIR API
  Future<Map<String, dynamic>> fetchOrganizations({
    int count = 20,
    String sort = '-_lastUpdated',
    String total = 'accurate',
  }) async {
    try {
      print('🏢 Starting organizations fetch...');
      print('🔑 Access token: ${accessToken.value.substring(0, 20)}...');

      final uri = Uri.parse('$baseUrl/fhir/R4/Organization?type=Root%20Org');

      print('🌐 Organizations URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${accessToken.value}',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );
      print('access token: ${accessToken.value}');
      print('📡 Organizations Response Status: ${response.statusCode}');
      print('📡 Organizations Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print('🔍 Parsing FHIR Bundle...');

        try {
          // Parse the JSON response directly
          final List<dynamic> entries = jsonData['entry'] ?? [];
          final List<FhirOrganization> organizationList = [];

          for (final entry in entries) {
            if (entry['resource'] != null) {
              final organization = FhirOrganization.fromJson(entry['resource']);
              organizationList.add(organization);
            }
          }

          print('✅ FHIR Bundle parsed successfully');

          // Update organizations observable
          organizations.value = organizationList;

          print(
              '✅ Organizations fetched successfully: ${organizations.value.length} organizations');

          return {
            'success': true,
            'message': 'Organizations fetched successfully',
            'organizations': organizations.value,
            'total': jsonData['total'] ?? organizationList.length,
          };
        } catch (parseError) {
          print('❌ Error parsing FHIR Bundle: $parseError');
          return {
            'success': false,
            'message':
                'Failed to parse organizations data: ${parseError.toString()}',
          };
        }
      } else if (response.statusCode == 401) {
        print(
            '🔒 Unauthorized (401) in organizations fetch - Token expired or invalid');
        await _handleUnauthorized();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
          'statusCode': response.statusCode,
        };
      } else {
        print('❌ Organizations fetch failed! Status: ${response.statusCode}');

        try {
          final errorData = jsonDecode(response.body);
          return {
            'success': false,
            'message': errorData['issue']?[0]?['diagnostics'] ??
                'Failed to fetch organizations',
            'statusCode': response.statusCode,
          };
        } catch (jsonError) {
          return {
            'success': false,
            'message':
                'Failed to fetch organizations with status: ${response.statusCode}',
            'statusCode': response.statusCode,
          };
        }
      }
    } catch (e) {
      print('💥 Exception during organizations fetch: $e');
      return {
        'success': false,
        'message': 'Organizations fetch error: ${e.toString()}',
      };
    }
  }
}
