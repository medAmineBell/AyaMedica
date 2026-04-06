import 'package:flutter/material.dart';
import 'package:flutter_getx_app/config/app_config.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/userAppItem.dart';
import '../utils/storage_service.dart';

enum MobileAppUserState { loading, success, error, empty }

class MobileAppUserController extends GetxController {
  static String get _baseUrl => AppConfig.newBackendUrl;

  final StorageService _storageService = Get.find();

  // Reactive state
  final Rx<MobileAppUserState> state = MobileAppUserState.loading.obs;
  final RxBool isLoading = false.obs;
  final RxBool isSendingReminder = false.obs;
  final RxString errorMessage = ''.obs;

  // Data
  final RxList<MobileAppUser> rawUsers = <MobileAppUser>[].obs;
  final RxList<UserAppItem> users = <UserAppItem>[].obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt itemsPerPage = 20.obs;
  final RxInt totalItems = 0.obs;
  final RxInt totalPages = 0.obs;

  // Filters
  final RxString searchQuery = ''.obs;
  final RxString selectedStatus = ''.obs; // '', 'active', 'inactive', 'offline', 'unverified'

  // Organization and Branch IDs
  final RxString organizationId = ''.obs;
  final RxString branchId = ''.obs;

  // Summary counts from API
  final RxInt totalCount = 0.obs;
  final RxInt activeCount = 0.obs;
  final RxInt inactiveCount = 0.obs;
  final RxInt offlineCount = 0.obs;
  final RxInt unverifiedCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadIds();
    fetchUsers();
  }

  /// Load organization and branch IDs from storage
  void _loadIds() {
    final branchData = _storageService.getSelectedBranchData();
    if (branchData != null) {
      branchId.value = branchData['id'] ?? '';
      organizationId.value = branchData['organizationId'] ??
          branchData['parentId'] ??
          _storageService.getOrganizationId() ??
          '';
    }
  }

  Map<String, String> _getHeaders(String accessToken) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
  }

  String _getAccessTokenOrThrow() {
    final accessToken = _storageService.getAccessToken();
    if (accessToken == null) {
      throw Exception('No access token found. Please log in again.');
    }
    return accessToken;
  }

  /// GET /api/mobile-app/users - Fetch mobile app users
  Future<void> fetchUsers({int page = 1}) async {
    if (organizationId.value.isEmpty || branchId.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select a branch first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      state.value = MobileAppUserState.error;
      return;
    }

    try {
      isLoading.value = true;
      state.value = MobileAppUserState.loading;

      final accessToken = _getAccessTokenOrThrow();

      // Build query parameters
      final queryParams = <String, String>{
        'organizationId': organizationId.value,
        'branchId': branchId.value,
        'page': page.toString(),
        'limit': itemsPerPage.value.toString(),
      };
      if (selectedStatus.value.isNotEmpty) {
        queryParams['status'] = selectedStatus.value;
      }

      final uri = Uri.parse('$_baseUrl/api/mobile-app/users')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _getHeaders(accessToken));

      if (response.statusCode == 200) {
        final body = json.decode(response.body) as Map<String, dynamic>;
        final data = body['data'] as Map<String, dynamic>;

        // Parse users list
        final usersJson = data['users'] as List<dynamic>? ?? [];
        final apiUsers = usersJson
            .map((u) => MobileAppUser.fromJson(u as Map<String, dynamic>))
            .toList();

        // Parse pagination
        final pagination =
            data['pagination'] as Map<String, dynamic>? ?? {};
        currentPage.value = pagination['page'] ?? page;
        totalItems.value = pagination['total'] ?? 0;
        totalPages.value = pagination['totalPages'] ?? 0;

        // Parse summary counts
        final summary = data['summary'] as Map<String, dynamic>? ?? {};
        totalCount.value = summary['total'] ?? 0;
        activeCount.value = summary['active'] ?? 0;
        inactiveCount.value = summary['inactive'] ?? 0;
        offlineCount.value = summary['offline'] ?? 0;
        unverifiedCount.value = summary['unverified'] ?? 0;

        // Store raw users and group by student
        rawUsers.value = apiUsers;
        users.value = UserAppItem.groupByStudent(apiUsers);

        state.value =
            users.isEmpty ? MobileAppUserState.empty : MobileAppUserState.success;
      } else if (response.statusCode == 401) {
        throw Exception('Token expired. Please log in again.');
      } else {
        throw Exception(
            'Failed to fetch users: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      errorMessage.value = e.toString();
      state.value = MobileAppUserState.error;
      Get.snackbar(
        'Error',
        'Failed to load mobile app users: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// POST /api/mobile-app/users/notify-unverified - Send email reminders
  Future<bool> notifyUnverifiedUsers() async {
    if (organizationId.value.isEmpty || branchId.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select a branch first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    try {
      isSendingReminder.value = true;

      final accessToken = _getAccessTokenOrThrow();

      final response = await http.post(
        Uri.parse('$_baseUrl/api/mobile-app/users/notify-unverified'),
        headers: _getHeaders(accessToken),
        body: json.encode({
          'organizationId': organizationId.value,
          'branchId': branchId.value,
        }),
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body) as Map<String, dynamic>;
        final data = body['data'] as Map<String, dynamic>? ?? {};
        final notifiedCount = data['notifiedCount'] ?? 0;

        Get.snackbar(
          'Success',
          'Email reminders sent to $notifiedCount unverified users',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Refresh the users list to get updated delivery statuses
        await fetchUsers(page: currentPage.value);
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('Token expired. Please log in again.');
      } else {
        throw Exception(
            'Failed to send reminders: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send email reminders: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSendingReminder.value = false;
    }
  }

  /// Filter users by status
  void filterByStatus(String status) {
    selectedStatus.value = status;
    fetchUsers();
  }

  /// Search users locally (client-side filtering on grouped items)
  void searchUsers(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      users.value = UserAppItem.groupByStudent(rawUsers);
    } else {
      final lower = query.toLowerCase();
      final allGrouped = UserAppItem.groupByStudent(rawUsers);
      users.value = allGrouped.where((item) {
        return item.fullName.toLowerCase().contains(lower) ||
            item.classGroup.toLowerCase().contains(lower) ||
            item.firstGuardian.name.toLowerCase().contains(lower) ||
            item.secondGuardian.name.toLowerCase().contains(lower) ||
            item.firstGuardian.email.toLowerCase().contains(lower) ||
            item.secondGuardian.email.toLowerCase().contains(lower);
      }).toList();
    }
  }

  /// Go to specific page
  void goToPage(int page) {
    if (page >= 1 && page <= totalPages.value) {
      fetchUsers(page: page);
    }
  }

  /// Next page
  void nextPage() {
    if (currentPage.value < totalPages.value) {
      goToPage(currentPage.value + 1);
    }
  }

  /// Previous page
  void previousPage() {
    if (currentPage.value > 1) {
      goToPage(currentPage.value - 1);
    }
  }
}
