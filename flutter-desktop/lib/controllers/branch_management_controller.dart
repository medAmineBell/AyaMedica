import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/branch_model.dart';
import '../models/create_branch_request.dart';
import '../utils/storage_service.dart';

enum BranchState { loading, success, error, empty }

class BranchManagementController extends GetxController {
  final StorageService _storageService = Get.find();

  final RxList<BranchModel> branches = <BranchModel>[].obs;
  final RxList<BranchModel> filteredBranches = <BranchModel>[].obs;
  final Rx<BranchState> state = BranchState.loading.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final Rx<BranchModel> selectedBranch =
      BranchModel(name: '', role: '', icon: '').obs;

  // Filter and search
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBranches();
  }

  /// CENTRALIZED METHOD: Get Organization ID
  String? getOrganizationId() {
    // Try multiple sources in priority order
    // 1. Direct organization ID
    String? orgId = _storageService.getOrganizationId();
    if (orgId != null) {
      print('📍 Got organization ID from storage: $orgId');
      return orgId;
    }

    // 2. From selected branch data
    final branchData = _storageService.getSelectedBranchData();
    if (branchData != null) {
      orgId = branchData['organizationId'] ?? branchData['parentId'];
      if (orgId != null) {
        print('📍 Got organization ID from branch data: $orgId');
        // Save it for future use
        _storageService.saveOrganizationId(orgId);
        return orgId;
      }
    }

    print('❌ No organization ID found in storage');
    return null;
  }

  /// CENTRALIZED METHOD: Get Branch ID
  String? getBranchId() {
    final branchData = _storageService.getSelectedBranchData();
    if (branchData != null) {
      final branchId = branchData['id'];
      print('📍 Got branch ID from storage: $branchId');
      return branchId;
    }

    print('❌ No branch ID found in storage');
    return null;
  }

  // GET branches from API
  Future<void> fetchBranches() async {
    try {
      state.value = BranchState.loading;
      isLoading.value = true;
      print('📡 Fetching branches from API...');

      // Use centralized method to get organization ID
      final organizationId = getOrganizationId();
      if (organizationId == null) {
        throw Exception(
            'No organization selected. Please select a branch first.');
      }

      print('📍 Using organization ID: $organizationId');

      // Get access token
      final accessToken = await _storageService.getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      // Make API request
      final response = await http.get(
        Uri.parse(
            'https://ayamedica-backend.ayamedica.online/api/organizations/$organizationId/branches'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('📡 Response Status: ${response.statusCode}');
      print('📡 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          final branchesJson = jsonData['data'] as List;

          // Convert API response to BranchModel and REMOVE DUPLICATES by ID
          final branchesList =
              branchesJson.map((json) => _parseBranchFromApi(json)).toList();

          // Remove duplicates based on ID
          final uniqueBranches = <String, BranchModel>{};
          for (var branch in branchesList) {
            uniqueBranches[branch.id] = branch;
          }

          branches.value = uniqueBranches.values.toList();

          print(
              '✅ Branches loaded successfully: ${branches.length} unique branches');
          print('📋 Branch IDs: ${branches.map((b) => b.id).toList()}');

          // Reapply current filters after fetching
          _applyFilters();

          if (branches.isEmpty) {
            state.value = BranchState.empty;
          } else {
            state.value = BranchState.success;
          }
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error fetching branches: $e');
      state.value = BranchState.error;
      errorMessage.value = 'Failed to load branches: ${e.toString()}';
      Get.snackbar(
        'Error',
        'Failed to load branches: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Parse branch from API response
  BranchModel _parseBranchFromApi(Map<String, dynamic> json) {
    final branchResponse = BranchApiResponse.fromJson(json);
    return BranchModel(
      id: branchResponse.id,
      name: branchResponse.name,
      role: branchResponse.accountType,
      icon: 'school',
      address:
          '${branchResponse.address.street}, ${branchResponse.address.city}, ${branchResponse.address.governorate}',
      phone: branchResponse.phone ?? '',
      email: '',
      principalName: 'N/A',
      studentCount: branchResponse.totalStudents, // ✅ Updated
      teacherCount: branchResponse.totalUsers, // ✅ Updated
      status: branchResponse.status,
      createdAt: DateTime.now(),
      // Add fields for editing
      educationType: branchResponse.educationType,
      grades: branchResponse.grades,
      governorate: branchResponse.address.governorate,
      city: branchResponse.address.city,
      street: branchResponse.address.street,
      isHeadquarters: branchResponse.isHeadquarters,
      website: branchResponse.website,
      accountType: branchResponse.accountType,
    );
  }

  // POST - Create new branch
  Future<bool> createBranch(CreateBranchRequest request) async {
    isSaving.value = true;

    try {
      print('📤 Creating branch...');
      print('📤 Request body: ${jsonEncode(request.toJson())}');

      // Use centralized method to get organization ID
      final organizationId = getOrganizationId();
      if (organizationId == null) {
        throw Exception(
            'No organization selected. Please select a branch first.');
      }

      print('📍 Using organization ID: $organizationId');

      // Get access token
      final accessToken = await _storageService.getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      // Make API request
      final response = await http.post(
        Uri.parse(
            'https://ayamedica-backend.ayamedica.online/api/organizations/$organizationId/branches'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(request.toJson()),
      );

      print('📡 Response Status: ${response.statusCode}');
      print('📡 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          print('✅ Branch created successfully');

          Get.snackbar(
            'Success',
            'Branch created successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );

          // Refresh branches list
          await fetchBranches();

          return true;
        } else {
          throw Exception(responseData['message'] ?? 'Failed to create branch');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error creating branch: $e');
      Get.snackbar(
        'Error',
        'Failed to create branch: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // PUT - Update branch
  Future<bool> updateBranch(
      String branchId, CreateBranchRequest request) async {
    isSaving.value = true;

    try {
      print('✏️ Updating branch...');
      print('📤 Request body: ${jsonEncode(request.toJson())}');

      // Use centralized method to get organization ID
      final organizationId = getOrganizationId();
      if (organizationId == null) {
        throw Exception(
            'No organization selected. Please select a branch first.');
      }

      print('📍 Using organization ID: $organizationId');
      print('📍 Branch ID: $branchId');

      // Get access token
      final accessToken = await _storageService.getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      // Prepare update request body (accountType is immutable, so exclude it)
      final updateBody = {
        'name': request.name,
        'isHeadquarters': request.isHeadquarters,
        'educationType': request.educationType,
        'grades': request.grades,
        'address': {
          'governorate': request.address.governorate,
          'city': request.address.city,
          'street': request.address.street,
        },
        if (request.phone != null) 'phone': request.phone,
        if (request.website != null) 'website': request.website,
      };

      // Make API request
      final response = await http.put(
        Uri.parse(
            'https://ayamedica-backend.ayamedica.online/api/organizations/$organizationId/branches/$branchId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(updateBody),
      );

      print('📡 Response Status: ${response.statusCode}');
      print('📡 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          print('✅ Branch updated successfully');

          Get.snackbar(
            'Success',
            'Branch updated successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );

          // Refresh branches list
          await fetchBranches();

          return true;
        } else {
          throw Exception(responseData['message'] ?? 'Failed to update branch');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error updating branch: $e');
      Get.snackbar(
        'Error',
        'Failed to update branch: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // Search branches - FIXED
  void searchBranches(String query) {
    print('🔍 Searching for: $query');
    searchQuery.value = query;
    _applyFilters();
  }

  // Filter branches - FIXED
  void filterBranches(String filter) {
    print('🔍 Filtering by status: $filter');
    selectedFilter.value = filter;
    _applyFilters();
  }

  // Apply filters - FIXED with detailed logging
  void _applyFilters() {
    print('🔍 Applying filters...');
    print('📊 Total branches: ${branches.length}');
    print('📊 Search query: "${searchQuery.value}"');
    print('📊 Filter: ${selectedFilter.value}');

    // Start with all branches
    var filtered = branches.toList();

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((branch) {
        final searchLower = searchQuery.value.toLowerCase();
        final matchesName = branch.name.toLowerCase().contains(searchLower);
        final matchesAddress =
            branch.address?.toLowerCase().contains(searchLower) ?? false;
        final matchesPhone =
            branch.phone?.toLowerCase().contains(searchLower) ?? false;

        return matchesName || matchesAddress || matchesPhone;
      }).toList();

      print('📊 After search filter: ${filtered.length} branches');
    }

    // Apply status filter
    if (selectedFilter.value != 'all') {
      filtered = filtered.where((branch) {
        final matches =
            branch.status?.toLowerCase() == selectedFilter.value.toLowerCase();
        return matches;
      }).toList();

      print('📊 After status filter: ${filtered.length} branches');
    }

    // Update filtered list
    filteredBranches.value = filtered;

    print('✅ Filters applied: ${filtered.length} branches found');
    print('📋 Filtered branch names: ${filtered.map((b) => b.name).toList()}');
  }

  // POST - Activate branch (reactivate deactivated branch)
  Future<void> activateBranch(String branchId) async {
    try {
      isLoading.value = true;
      print('▶️ Activating branch...');

      final organizationId = getOrganizationId();
      if (organizationId == null) {
        throw Exception(
            'No organization selected. Please select a branch first.');
      }

      print('📍 Using organization ID: $organizationId');
      print('📍 Branch ID: $branchId');

      final accessToken = await _storageService.getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      final response = await http.post(
        Uri.parse(
            'https://ayamedica-backend.ayamedica.online/api/organizations/$organizationId/branches/$branchId/activate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('📡 Response Status: ${response.statusCode}');
      print('📡 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          print('✅ Branch activated successfully');

          Get.snackbar(
            'Success',
            'Branch activated successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );

          await fetchBranches();
        } else {
          throw Exception(
              responseData['message'] ?? 'Failed to activate branch');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error activating branch: $e');
      Get.snackbar(
        'Error',
        'Failed to activate branch: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // POST - Deactivate branch (soft delete)
  Future<void> deactivateBranch(String branchId) async {
    try {
      isLoading.value = true;
      print('⏸️ Deactivating branch...');

      final organizationId = getOrganizationId();
      if (organizationId == null) {
        throw Exception(
            'No organization selected. Please select a branch first.');
      }

      print('📍 Using organization ID: $organizationId');
      print('📍 Branch ID: $branchId');

      final accessToken = await _storageService.getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      final response = await http.post(
        Uri.parse(
            'https://ayamedica-backend.ayamedica.online/api/organizations/$organizationId/branches/$branchId/deactivate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('📡 Response Status: ${response.statusCode}');
      print('📡 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          print('✅ Branch deactivated successfully');

          Get.snackbar(
            'Success',
            'Branch deactivated successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFFFC107),
            colorText: Colors.black,
            duration: const Duration(seconds: 2),
          );

          await fetchBranches();
        } else {
          throw Exception(
              responseData['message'] ?? 'Failed to deactivate branch');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error deactivating branch: $e');
      Get.snackbar(
        'Error',
        'Failed to deactivate branch: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // DELETE - Delete branch (hard delete)
  Future<void> deleteBranch(String branchId) async {
    try {
      isLoading.value = true;
      print('🗑️ Deleting branch (hard delete)...');

      final organizationId = getOrganizationId();
      if (organizationId == null) {
        throw Exception(
            'No organization selected. Please select a branch first.');
      }

      print('📍 Using organization ID: $organizationId');
      print('📍 Branch ID: $branchId');

      final accessToken = await _storageService.getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      final response = await http.delete(
        Uri.parse(
            'https://ayamedica-backend.ayamedica.online/api/organizations/$organizationId/branches/$branchId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'force': true, // Hard delete
        }),
      );

      print('📡 Response Status: ${response.statusCode}');
      print('📡 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Branch deleted successfully (hard delete)');

        Get.snackbar(
          'Success',
          'Branch permanently deleted',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        await fetchBranches();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error deleting branch: $e');
      Get.snackbar(
        'Error',
        'Failed to delete branch: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void refreshBranches() {
    fetchBranches();
  }

  void clearError() {
    errorMessage.value = '';
    state.value = BranchState.loading;
  }
}
