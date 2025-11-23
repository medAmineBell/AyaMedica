import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../models/appointment.dart';

class ApiService extends GetxService {
  static const String baseUrl =
      'https://api.ayamedica.online'; // Ayamedica API endpoint
  static const Duration timeout = Duration(seconds: 30);

  // Headers for API requests
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        // Add authorization header if needed
        // 'Authorization': 'Bearer ${getToken()}',
      };

  // Create appointment API request
  Future<Map<String, dynamic>> createAppointment(
      Appointment appointment) async {
    try {
      final url = Uri.parse('$baseUrl/api/appointments');

      // Convert appointment to JSON
      final appointmentJson = appointment.toJson();

      // Log the request for debugging
      print('Creating appointment: ${jsonEncode(appointmentJson)}');

      final response = await http
          .post(
            url,
            headers: _headers,
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
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (status != null) queryParams['status'] = status;
      if (date != null) queryParams['date'] = date;

      final url = Uri.parse('$baseUrl/api/appointments').replace(
        queryParameters: queryParams,
      );

      final response = await http
          .get(
            url,
            headers: _headers,
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

      final response = await http
          .put(
            url,
            headers: _headers,
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

      final response = await http
          .delete(
            url,
            headers: _headers,
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

  // Helper method to get authentication token (implement based on your auth system)
  String? getToken() {
    // Implement token retrieval logic here
    // This could be from storage, state management, etc.
    return null;
  }
}
