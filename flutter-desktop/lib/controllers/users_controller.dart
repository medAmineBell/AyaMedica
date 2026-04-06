import 'package:flutter/material.dart';
import 'package:flutter_getx_app/config/app_config.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user_model.dart';
import '../utils/storage_service.dart';
import 'branch_management_controller.dart';

enum UsersState { loading, success, error, empty }

class UsersController extends GetxController {
  final StorageService _storageService = Get.find();

  var users = <UserModel>[].obs;
  var filteredUsers = <UserModel>[].obs;
  final Rx<UsersState> state = UsersState.loading.obs;

  var searchQuery = ''.obs;
  final searchController = TextEditingController();

  var isSubmitting = false.obs;

  var selectedRole = ''.obs;
  var selectedPosition = ''.obs;

  final roles = ['Doctor - Extended', 'Admin', 'Viewer'];
  final staffRoles = ['SchoolAdmin', 'Doctor', 'Nurse', 'Teacher'];
  final positions = ['Position 1', 'Position 2'];

  var selectedUser = Rxn<UserModel>();
  final emailController = TextEditingController();

  // Multi-campus support
  var selectedCampusIds = <String>[].obs;
  var campusAssignments = <String, CampusAssignment>{}.obs;

  // Get branches from BranchManagementController
  List<DropdownMenuEntry<String>> get listCompus {
    final branchController = Get.find<BranchManagementController>();
    return branchController.branches
        .where((branchItem) => branchItem.status == 'active')
        .map((branchItem) => DropdownMenuEntry(
              value: branchItem.id,
              label: branchItem.name,
            ))
        .toList();
  }

  // Permissions map (module -> permission -> bool)
  final permissions = <String, Map<String, bool>>{
    'School dashboard': {
      'View': true,
      'Update': false,
      'Create': false,
      'Delete': false
    },
    'Students Overview Dashboard': {
      'View': true,
      'Update': false,
      'Create': false,
      'Delete': false
    },
    'Students profile and details': {
      'View': true,
      'Update': true,
      'Create': true,
      'Delete': true
    },
    'Students medical details and records': {
      'View': true,
      'Update': true,
      'Create': true,
      'Delete': true
    },
    'Checkup - all types': {
      'View': true,
      'Update': true,
      'Create': true,
      'Delete': true
    },
    'Hygiene checkup': {
      'View': true,
      'Update': true,
      'Create': true,
      'Delete': true
    },
    'Follow-up appointments': {
      'View': true,
      'Update': true,
      'Create': true,
      'Delete': true
    },
    'Vaccination': {
      'View': true,
      'Update': false,
      'Create': false,
      'Delete': false
    },
    'Walk in': {
      'View': true,
      'Update': false,
      'Create': false,
      'Delete': false
    },
  }.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  /// Fetch users from API
  Future<void> fetchUsers() async {
    final branchData = _storageService.getSelectedBranchData();
    final branchId = branchData?['id'] ?? '';

    if (branchId.isEmpty) {
      state.value = UsersState.empty;
      return;
    }

    try {
      state.value = UsersState.loading;

      final accessToken = _storageService.getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      final url = Uri.parse(
        '${AppConfig.newBackendUrl}/api/school-admin/users?branchId=$branchId',
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          final data = jsonData['data'];
          final usersList = (data['users'] as List<dynamic>?)
                  ?.map((u) =>
                      UserModel.fromJson(u as Map<String, dynamic>))
                  .toList() ??
              [];

          users.assignAll(usersList);
          _applyFilters();
          state.value =
              users.isEmpty ? UsersState.empty : UsersState.success;
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      state.value = UsersState.error;
      Get.snackbar(
        'Error',
        'Failed to load users: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void _applyFilters() {
    var result = users.toList();
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      result = result.where((u) =>
        u.name.toLowerCase().contains(q) ||
        u.email.toLowerCase().contains(q) ||
        (u.aid ?? '').toLowerCase().contains(q)
      ).toList();
    }
    filteredUsers.assignAll(result);
  }

  void selectUser(UserModel user) {
    selectedUser.value = user;
    emailController.text = user.email;
    selectedRole.value = user.role;
    selectedPosition.value = '';

    // Load existing campus assignments
    selectedCampusIds.clear();
    campusAssignments.clear();

    for (final assignment in user.campusAssignments) {
      selectedCampusIds.add(assignment.campusId);
      campusAssignments[assignment.campusId] = assignment;
    }
  }

  void clearSelection() {
    selectedUser.value = null;
    emailController.clear();
    selectedRole.value = '';
    selectedPosition.value = '';
    selectedCampusIds.clear();
    campusAssignments.clear();
  }

  void onRoleSelected(String? role) {
    if (role != null) selectedRole.value = role;
  }

  void onPositionSelected(String? pos) {
    if (pos != null) selectedPosition.value = pos;
  }

  void togglePermission(String module, String perm, bool value) {
    final mod = permissions[module];
    if (mod != null) {
      mod[perm] = value;
      permissions[module] = Map<String, bool>.from(mod);
    }
  }

  void saveAssignedRole() {
    final user = selectedUser.value;
    if (user != null && selectedCampusIds.isNotEmpty) {
      final updatedAssignments = campusAssignments.values.toList();
      final updatedUser = user.copyWith(campusAssignments: updatedAssignments);

      final index = users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        users[index] = updatedUser;
      }

      Get.snackbar('Success', 'Campus assignments saved successfully');
    } else {
      Get.snackbar('Error', 'Please select at least one campus');
    }
  }

  /// Create a new staff user via API
  Future<bool> createUser({
    required String email,
    required String givenName,
    required String familyName,
    required String role,
    String? phone,
  }) async {
    try {
      isSubmitting.value = true;

      final accessToken = _storageService.getAccessToken();
      if (accessToken == null) throw Exception('No access token found');

      final branchData = _storageService.getSelectedBranchData();
      final branchId = branchData?['id'] ?? '';
      final organizationId = branchData?['id'] ?? '';

      final url = Uri.parse(
        '${AppConfig.newBackendUrl}/api/school-admin/users',
      );

      final body = {
        'email': email,
        'name': {'given': givenName, 'family': familyName},
        'role': role,
        'organizationId': organizationId,
        'branchId': branchId,
      };
      if (phone != null && phone.isNotEmpty) {
        body['phone'] = phone;
      }

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        Get.snackbar(
          'Success',
          'User created successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
        );
        await fetchUsers();
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'HTTP ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create user: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Update a staff user via API
  Future<bool> updateUser(
    String practitionerId, {
    required String givenName,
    required String familyName,
    required String email,
    String? phone,
    String? gender,
  }) async {
    try {
      isSubmitting.value = true;

      final accessToken = _storageService.getAccessToken();
      if (accessToken == null) throw Exception('No access token found');

      final url = Uri.parse(
        '${AppConfig.newBackendUrl}/api/school-admin/users/$practitionerId',
      );

      final body = <String, dynamic>{
        'name': {'given': givenName, 'family': familyName},
        'email': email,
      };
      if (phone != null && phone.isNotEmpty) body['phone'] = phone;
      if (gender != null && gender.isNotEmpty) body['gender'] = gender;

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        Get.snackbar(
          'Success',
          'User updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
        );
        await fetchUsers();
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'HTTP ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update user: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Delete a staff user's role via API
  Future<bool> deleteUserApi(UserModel user) async {
    try {
      isSubmitting.value = true;

      final accessToken = _storageService.getAccessToken();
      if (accessToken == null) throw Exception('No access token found');

      final organizationId =
          user.roles.isNotEmpty ? user.roles.first.organizationId : '';

      var urlStr =
          '${AppConfig.newBackendUrl}/api/school-admin/users/${user.id}';
      if (organizationId.isNotEmpty) {
        urlStr += '?organizationId=$organizationId';
      }
      final url = Uri.parse(urlStr);

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        Get.snackbar(
          'Success',
          'User removed successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
        );
        if (selectedUser.value?.id == user.id) clearSelection();
        await fetchUsers();
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'HTTP ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete user: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // Multi-campus management methods
  void toggleCampusSelection(String campusId) {
    if (selectedCampusIds.contains(campusId)) {
      selectedCampusIds.remove(campusId);
      campusAssignments.remove(campusId);
    } else {
      selectedCampusIds.add(campusId);
      final campusName =
          listCompus.firstWhere((c) => c.value == campusId).label;
      campusAssignments[campusId] = CampusAssignment(
        campusId: campusId,
        campusName: campusName,
        role: '',
        position: '',
        permissions: Map<String, Map<String, bool>>.from(permissions),
      );
    }
  }

  void updateCampusRole(String campusId, String role) {
    final assignment = campusAssignments[campusId];
    if (assignment != null) {
      campusAssignments[campusId] = assignment.copyWith(role: role);
    }
  }

  void updateCampusPosition(String campusId, String position) {
    final assignment = campusAssignments[campusId];
    if (assignment != null) {
      campusAssignments[campusId] = assignment.copyWith(position: position);
    }
  }

  void updateCampusPermission(
      String campusId, String module, String permission, bool value) {
    final assignment = campusAssignments[campusId];
    if (assignment != null) {
      final updatedPermissions =
          Map<String, Map<String, bool>>.from(assignment.permissions);
      if (updatedPermissions[module] != null) {
        updatedPermissions[module] =
            Map<String, bool>.from(updatedPermissions[module]!);
        updatedPermissions[module]![permission] = value;
      }
      campusAssignments[campusId] =
          assignment.copyWith(permissions: updatedPermissions);
    }
  }

  CampusAssignment? getCampusAssignment(String campusId) {
    return campusAssignments[campusId];
  }

  bool isCampusSelected(String campusId) {
    return selectedCampusIds.contains(campusId);
  }
}
