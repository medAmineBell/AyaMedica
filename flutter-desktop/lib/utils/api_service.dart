import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../models/appointment.dart';
import '../models/login_response.dart';
import '../models/organization_model.dart';
import '../config/app_config.dart';
import '../utils/storage_service.dart';

class ApiService extends GetxService {
  static const String baseUrl = 'https://api.ayamedica.online';
  static const Duration timeout = Duration(seconds: 30);

  // Storage service for token management
  final StorageService _storageService = Get.find<StorageService>();

  // Headers for API requests
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': '*/*',
      };

  // Headers with authorization token
  Map<String, String> _headersWithAuth(String token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  // NEW: Login with email/phone and password
  Future<Map<String, dynamic>> loginWithCredentials({
    required String emailOrPhone,
    required String password,
  }) async {
    try {
      final url = Uri.parse(AppConfig.newLoginUrl);

      final requestBody = {
        'emailOrPhone': emailOrPhone,
        'password': password,
      };

      print('🔐 API Service: Logging in with: $emailOrPhone');
      print('📤 API Service: Request URL: ${url.toString()}');
      print('📤 API Service: Request Body: ${jsonEncode(requestBody)}');

      final response = await http
          .post(
            url,
            headers: _headers,
            body: jsonEncode(requestBody),
          )
          .timeout(timeout);

      print('📥 API Service: Response Status: ${response.statusCode}');
      print('📥 API Service: Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final loginResponse = LoginResponse.fromJson(jsonDecode(response.body));

        if (loginResponse.success && loginResponse.data != null) {
          print('✅ API Service: Login successful');
          return {
            'success': true,
            'message': loginResponse.message,
            'accessToken': loginResponse.data!.tokens.accessToken,
            'refreshToken': loginResponse.data!.tokens.refreshToken,
          };
        } else {
          print('❌ API Service: Login failed - ${loginResponse.message}');
          return {
            'success': false,
            'error': loginResponse.message,
          };
        }
      } else {
        try {
          final errorData = jsonDecode(response.body);
          print('❌ API Service: Error response - ${errorData['message']}');
          return {
            'success': false,
            'error': errorData['message'] ?? 'Login failed',
            'statusCode': response.statusCode,
          };
        } catch (e) {
          return {
            'success': false,
            'error': 'Login failed with status ${response.statusCode}',
            'statusCode': response.statusCode,
          };
        }
      }
    } catch (e) {
      print('💥 API Service: Login Error: $e');
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  // NEW: Fetch organizations with branches
  Future<Map<String, dynamic>> fetchOrganizations() async {
    try {
      final token = _storageService.getAccessToken();

      if (token == null || token.isEmpty) {
        print('❌ API Service: No access token available');
        return {
          'success': false,
          'error': 'No access token available. Please login again.',
        };
      }

      final url = Uri.parse('${AppConfig.newBackendUrl}/api/organizations');

      print('🏢 API Service: Fetching organizations...');
      print('📤 API Service: Request URL: ${url.toString()}');
      print('🔑 API Service: Using token: ${token.substring(0, 20)}...');

      final response = await http
          .get(
            url,
            headers: _headersWithAuth(token),
          )
          .timeout(timeout);

      print('📥 API Service: Response Status: ${response.statusCode}');
      print(
          '📥 API Service: Response Body: ${response.body.substring(0, 500)}...');

      if (response.statusCode == 200) {
        // final orgResponse =
        //     OrganizationResponse.fromJson(jsonDecode(response.body));

        // if (orgResponse.success) {
        //   print('✅ API Service: Organizations fetched successfully');
        //   print(
        //       '📊 API Service: Found ${orgResponse.data.length} organizations');

        //   // Count total branches
        //   int totalBranches = 0;
        //   for (var org in orgResponse.data) {
        //     // totalBranches += org.branches.length;
        //   }
        //   print('📊 API Service: Total branches: $totalBranches');

        //   return {
        //     'success': true,
        //     'organizations': orgResponse.data,
        //     'total': orgResponse.data.length,
        //     'totalBranches': totalBranches,
        //   };
        // } else {
        return {
          'success': false,
          'error': 'Failed to fetch organizations',
        };
        // }
      } else if (response.statusCode == 401) {
        print('❌ API Service: Unauthorized - Token may be expired');
        return {
          'success': false,
          'error': 'Session expired. Please login again.',
          'statusCode': response.statusCode,
        };
      } else {
        try {
          final errorData = jsonDecode(response.body);
          print('❌ API Service: Error - ${errorData['message']}');
          return {
            'success': false,
            'error': errorData['message'] ?? 'Failed to fetch organizations',
            'statusCode': response.statusCode,
          };
        } catch (e) {
          return {
            'success': false,
            'error':
                'Failed to fetch organizations with status ${response.statusCode}',
            'statusCode': response.statusCode,
          };
        }
      }
    } catch (e) {
      print('💥 API Service: Fetch Organizations Error: $e');
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  // NEW: Refresh access token using refresh token
  Future<Map<String, dynamic>> refreshAccessToken(String refreshToken) async {
    try {
      final url = Uri.parse('${AppConfig.newBackendUrl}/api/auth/refresh');

      print('🔄 API Service: Refreshing access token...');

      final response = await http
          .post(
            url,
            headers: _headers,
            body: jsonEncode({'refreshToken': refreshToken}),
          )
          .timeout(timeout);

      print('📥 API Service: Refresh Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          print('✅ API Service: Token refresh successful');
          return {
            'success': true,
            'accessToken': responseData['data']['tokens']['accessToken'],
            'refreshToken': responseData['data']['tokens']['refreshToken'],
          };
        } else {
          return {
            'success': false,
            'error': responseData['message'] ?? 'Failed to refresh token',
          };
        }
      } else {
        return {
          'success': false,
          'error': 'Failed to refresh token',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('💥 API Service: Token Refresh Error: $e');
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  // Helper method to get authentication token
  Future<String?> getToken() async {
    final token = _storageService.getAccessToken();
    return token;
  }

  // Create appointment API request
  Future<Map<String, dynamic>> createAppointment(
      Appointment appointment) async {
    try {
      final url = Uri.parse('$baseUrl/api/appointments');

      // Get auth token
      final token = await getToken();
      final headers = token != null ? _headersWithAuth(token) : _headers;

      // Convert appointment to JSON
      final appointmentJson = appointment.toJson();

      // Log the request for debugging
      print('Creating appointment: ${jsonEncode(appointmentJson)}');

      final response = await http
          .post(
            url,
            headers: headers,
            body: jsonEncode(appointmentJson),
          )
          .timeout(timeout);

      // Log the response for debugging
      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData,
          'message': 'Appointment created successfully',
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorData['message'] ?? 'Failed to create appointment',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('API Error: $e');
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  // Get appointments API request
  Future<Map<String, dynamic>> getAppointments({
    int page = 1,
    int limit = 10,
    String? status,
    String? date,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (status != null) queryParams['status'] = status;
      if (date != null) queryParams['date'] = date;

      final url = Uri.parse('$baseUrl/api/appointments').replace(
        queryParameters: queryParams,
      );

      // Get auth token
      final token = await getToken();
      final headers = token != null ? _headersWithAuth(token) : _headers;

      final response = await http
          .get(
            url,
            headers: headers,
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to fetch appointments',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  // Update appointment status API request
  Future<Map<String, dynamic>> updateAppointmentStatus(
    String appointmentId,
    String status,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/api/appointments/$appointmentId/status');

      // Get auth token
      final token = await getToken();
      final headers = token != null ? _headersWithAuth(token) : _headers;

      final response = await http
          .put(
            url,
            headers: headers,
            body: jsonEncode({'status': status}),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to update appointment status',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  // Delete appointment API request
  Future<Map<String, dynamic>> deleteAppointment(String appointmentId) async {
    try {
      final url = Uri.parse('$baseUrl/api/appointments/$appointmentId');

      // Get auth token
      final token = await getToken();
      final headers = token != null ? _headersWithAuth(token) : _headers;

      final response = await http
          .delete(
            url,
            headers: headers,
          )
          .timeout(timeout);

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {
          'success': true,
          'message': 'Appointment deleted successfully',
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to delete appointment',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }
}
