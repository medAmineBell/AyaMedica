import 'package:flutter_getx_app/config/app_config.dart';
import 'package:flutter_getx_app/utils/storage_service.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';

class ResourcesController extends GetxController {
  final StorageService storageService = Get.find<StorageService>();

  final RxList<Map<String, dynamic>> classes = <Map<String, dynamic>>[].obs;
  final Rx<Map<String, dynamic>?> selectedClassDetails =
      Rx<Map<String, dynamic>?>(null);

  final RxBool isLoading = false.obs;
  final RxBool isLoadingClassDetails = false.obs;
  final RxString selectedBranchId = ''.obs;
  final RxString searchQuery = ''.obs;

  static String get baseUrl => AppConfig.newBackendUrl;

  @override
  void onInit() {
    super.onInit();
    loadBranchData();
    loadClasses();
  }

  // Load branch data from storage
  void loadBranchData() {
    final branchData = storageService.getSelectedBranchData();
    if (branchData != null) {
      selectedBranchId.value = branchData['id'] ?? '';
      print('Loaded branch ID: ${selectedBranchId.value}');
    }
  }

  // Filtered classes based on search
  List<Map<String, dynamic>> get filteredClasses {
    if (searchQuery.value.isEmpty) {
      return classes;
    }
    final query = searchQuery.value.toLowerCase();
    return classes.where((classItem) {
      final name = classItem['name']?.toString().toLowerCase() ?? '';
      final grade = classItem['grade']?.toString().toLowerCase() ?? '';
      return name.contains(query) || grade.contains(query);
    }).toList();
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  // GET /api/classes
  // List classes for a branch
  Future<void> loadClasses() async {
    if (selectedBranchId.value.isEmpty) {
      print('Cannot load classes: Missing branch ID');
      return;
    }

    isLoading.value = true;
    try {
      final accessToken = await storageService.getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      final queryParams = {
        'branchId': selectedBranchId.value,
      };

      final uri = Uri.parse('$baseUrl/api/classes')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('Classes Response Status: ${response.statusCode}');
      print('Classes Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          classes.value = List<Map<String, dynamic>>.from(jsonData['data']);
          print('Classes loaded: ${classes.length}');
        }
      } else {
        throw Exception('Failed to load classes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading classes: $e');
      Get.snackbar(
        'Error',
        'Failed to load classes: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // POST /api/classes
  // Create a new class
  Future<bool> createClass(Map<String, dynamic> classData) async {
    // Use branchId from payload if provided, otherwise fall back to selectedBranchId
    final branchId = classData['branchId'] ?? selectedBranchId.value;
    if (branchId == null || (branchId is String && branchId.isEmpty)) {
      print('Cannot create class: Missing branch ID');
      Get.snackbar(
        'Error',
        'Branch ID is missing',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    isLoading.value = true;
    try {
      final accessToken = await storageService.getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      // Ensure branchId is set in the request data
      classData['branchId'] = branchId;

      print('Creating class with data: ${jsonEncode(classData)}');

      final response = await http.post(
        Uri.parse('$baseUrl/api/classes'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(classData),
      );

      print('Create Class Response Status: ${response.statusCode}');
      print('Create Class Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          Get.snackbar(
            'Success',
            'Class created successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          // Reload classes list
          await loadClasses();
          return true;
        }
      }

      throw Exception('Failed to create class: ${response.statusCode}');
    } catch (e) {
      print('Error creating class: $e');
      Get.snackbar(
        'Error',
        'Failed to create class: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // PUT /api/classes/{classId}
  // Update class
  Future<bool> updateClass(
      String classId, Map<String, dynamic> classData) async {
    if (selectedBranchId.value.isEmpty) {
      print('Cannot update class: Missing branch ID');
      return false;
    }

    isLoading.value = true;
    try {
      final accessToken = await storageService.getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      final queryParams = {
        'branchId': selectedBranchId.value,
      };

      final uri = Uri.parse('$baseUrl/api/classes/$classId')
          .replace(queryParameters: queryParams);

      print('Updating class $classId with data: ${jsonEncode(classData)}');

      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(classData),
      );

      print('Update Class Response Status: ${response.statusCode}');
      print('Update Class Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          Get.snackbar(
            'Success',
            'Class updated successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          // Reload classes list
          await loadClasses();
          return true;
        }
      }

      throw Exception('Failed to update class: ${response.statusCode}');
    } catch (e) {
      print('Error updating class: $e');
      Get.snackbar(
        'Error',
        'Failed to update class: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // DELETE /api/classes/{classId}
  // Delete class
  Future<bool> deleteClass(String classId) async {
    if (selectedBranchId.value.isEmpty) {
      print('Cannot delete class: Missing branch ID');
      return false;
    }

    try {
      final accessToken = await storageService.getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      final queryParams = {
        'branchId': selectedBranchId.value,
      };

      final uri = Uri.parse('$baseUrl/api/classes/$classId')
          .replace(queryParameters: queryParams);

      print('Deleting class: $classId');

      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('Delete Class Response Status: ${response.statusCode}');
      print('Delete Class Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        classes.removeWhere((classItem) => classItem['id'] == classId);
        classes.refresh();

        Get.snackbar(
          'Success',
          'Class deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      }

      throw Exception('Failed to delete class: ${response.statusCode}');
    } catch (e) {
      print('Error deleting class: $e');
      Get.snackbar(
        'Error',
        'Failed to delete class: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  // GET /api/classes/{classId}
  // Get class details with students
  Future<Map<String, dynamic>?> loadClassDetails(String classId) async {
    if (selectedBranchId.value.isEmpty) {
      print('Cannot load class details: Missing branch ID');
      return null;
    }

    isLoadingClassDetails.value = true;
    try {
      final accessToken = await storageService.getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      final queryParams = {
        'branchId': selectedBranchId.value,
      };

      final uri = Uri.parse('$baseUrl/api/classes/$classId')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('Class Details Response Status: ${response.statusCode}');
      print('Class Details Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          selectedClassDetails.value = jsonData['data'];
          print('Class details loaded for class ID: $classId');
          return jsonData['data'];
        }
      } else {
        throw Exception('Failed to load class details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading class details: $e');
      Get.snackbar(
        'Error',
        'Failed to load class details: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    } finally {
      isLoadingClassDetails.value = false;
    }

    return null;
  }

  // Helper method to get class by ID from the loaded classes list
  Map<String, dynamic>? getClassById(String classId) {
    try {
      return classes.firstWhere((classItem) => classItem['id'] == classId);
    } catch (e) {
      print('Class not found with ID: $classId');
      return null;
    }
  }

  // Clear selected class details
  void clearSelectedClass() {
    selectedClassDetails.value = null;
  }

  // Refresh classes list
  Future<void> refreshClasses() async {
    await loadClasses();
  }
}
