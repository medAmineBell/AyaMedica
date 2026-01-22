import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/appointment_history_model.dart';
import '../utils/storage_service.dart';

enum AppointmentHistoryState { loading, success, error, empty }

class AppointmentHistoryController extends GetxController {
  final StorageService _storageService = Get.find();

  // Reactive variables
  final RxList<AppointmentHistory> allAppointments = <AppointmentHistory>[].obs;
  final RxList<AppointmentHistory> displayedAppointments =
      <AppointmentHistory>[].obs;
  final Rx<AppointmentHistoryState> state = AppointmentHistoryState.loading.obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'all'.obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt itemsPerPage = 20.obs;
  final RxInt totalItems = 0.obs;
  final RxInt totalPages = 0.obs;

  // Organization and Branch IDs
  final RxString organizationId = ''.obs;
  final RxString branchId = ''.obs;

  // Status counts
  final RxInt checkedInCount = 0.obs;
  final RxInt checkedOutCount = 0.obs;
  final RxInt cancelledCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadIds();
    fetchAppointmentHistory();
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
      print('📍 Organization ID: ${organizationId.value}');
      print('📍 Branch ID: ${branchId.value}');
    }
  }

  /// GET - Fetch appointment history from API
  Future<void> fetchAppointmentHistory({int page = 1}) async {
    if (organizationId.value.isEmpty || branchId.value.isEmpty) {
      print('❌ Cannot load appointments: Missing organization or branch ID');
      Get.snackbar(
        'Error',
        'Please select a branch first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      state.value = AppointmentHistoryState.error;
      return;
    }

    try {
      isLoading.value = true;
      state.value = AppointmentHistoryState.loading;
      print('📡 Fetching appointment history...');

      // Get access token
      final accessToken = await _storageService.getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      // Build API URL
      final url = Uri.parse(
        'https://ayamedica-backend.ayamedica.online/api/school-admin/appointments?organizationId=${organizationId.value}&branchId=${branchId.value}&page=$page&limit=${itemsPerPage.value}',
      );
      print('📡 Request URL: $url');

      // Make API request
      final response = await http.get(
        url,
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
          final historyResponse = AppointmentHistoryResponse.fromJson(jsonData);

          // Update appointments
          allAppointments.assignAll(historyResponse.appointments);
          displayedAppointments.assignAll(historyResponse.appointments);

          // Update pagination
          currentPage.value = historyResponse.pagination.page;
          totalItems.value = historyResponse.pagination.total;
          totalPages.value = historyResponse.pagination.totalPages;

          // Calculate status counts
          _calculateStatusCounts();

          print('✅ Appointment history loaded successfully:');
          print(' - Appointments: ${allAppointments.length}');
          print(' - Total: ${totalItems.value}');
          print(' - Page: ${currentPage.value}/${totalPages.value}');

          // Update state
          state.value = displayedAppointments.isEmpty
              ? AppointmentHistoryState.empty
              : AppointmentHistoryState.success;

          // Reapply filters if any
          if (searchQuery.value.isNotEmpty || selectedFilter.value != 'all') {
            _applySearchAndFilter();
          }
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error fetching appointment history: $e');
      state.value = AppointmentHistoryState.error;
      Get.snackbar(
        'Error',
        'Failed to load appointment history: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      allAppointments.clear();
      displayedAppointments.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// Calculate status counts for the tabs
  void _calculateStatusCounts() {
    checkedInCount.value =
        allAppointments.where((a) => a.status.toLowerCase() == 'booked').length;
    checkedOutCount.value = allAppointments
        .where((a) => a.status.toLowerCase() == 'fulfilled')
        .length;
    cancelledCount.value = allAppointments
        .where((a) => a.status.toLowerCase() == 'cancelled')
        .length;
  }

  /// SEARCH - Filter appointments by query
  void searchAppointments(String query) {
    print('🔍 Searching for: "$query"');
    searchQuery.value = query.trim().toLowerCase();
    _applySearchAndFilter();
  }

  /// FILTER - Filter by status
  void filterByStatus(String filter) {
    print('🔍 Filtering by status: $filter');
    selectedFilter.value = filter;
    _applySearchAndFilter();
  }

  /// Apply search and filter logic
  void _applySearchAndFilter() {
    List<AppointmentHistory> filtered = List.from(allAppointments);

    // Apply status filter
    if (selectedFilter.value != 'all') {
      filtered = filtered.where((appointment) {
        return appointment.status.toLowerCase() ==
            selectedFilter.value.toLowerCase();
      }).toList();
    }

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((appointment) {
        final patientName = appointment.patient.fullName.toLowerCase();
        final studentId = appointment.patient.studentId.toLowerCase();
        final doctor = appointment.doctor.name.toLowerCase();
        final type = appointment.formattedType.toLowerCase();
        final gradeClass = appointment.gradeAndClass.toLowerCase();

        return patientName.contains(searchQuery.value) ||
            studentId.contains(searchQuery.value) ||
            doctor.contains(searchQuery.value) ||
            type.contains(searchQuery.value) ||
            gradeClass.contains(searchQuery.value);
      }).toList();
    }

    displayedAppointments.assignAll(filtered);
    print(
        '✅ Filters applied: ${displayedAppointments.length} appointments found');

    // Update state
    state.value = displayedAppointments.isEmpty
        ? AppointmentHistoryState.empty
        : AppointmentHistoryState.success;
  }

  /// Refresh appointments
  void refreshAppointments() {
    fetchAppointmentHistory(page: currentPage.value);
  }

  /// Pagination methods
  void goToPage(int page) {
    if (page >= 1 && page <= totalPages.value) {
      fetchAppointmentHistory(page: page);
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      fetchAppointmentHistory(page: currentPage.value - 1);
    }
  }

  void nextPage() {
    if (currentPage.value < totalPages.value) {
      fetchAppointmentHistory(page: currentPage.value + 1);
    }
  }

  /// Check if there are any appointments
  bool get hasAppointments => allAppointments.isNotEmpty;

  /// Check if filters are active
  bool get hasActiveFilters =>
      searchQuery.value.isNotEmpty || selectedFilter.value != 'all';
}
