import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_getx_app/config/app_config.dart';
import 'package:flutter_getx_app/controllers/branch_management_controller.dart';
import 'package:flutter_getx_app/models/branch_model.dart';
import 'package:flutter_getx_app/models/clinic_visit_row.dart';
import 'package:flutter_getx_app/utils/app_snackbar.dart';
import 'package:flutter_getx_app/utils/storage_service.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

enum ClinicVisitsState { loading, success, error, empty }

class ClinicVisitsController extends GetxController {
  final StorageService _storageService = Get.find();

  // Reactive data
  final RxList<ClinicVisitRow> allRows = <ClinicVisitRow>[].obs;
  final RxList<ClinicVisitRow> displayedRows = <ClinicVisitRow>[].obs;
  final Rx<ClinicVisitsState> state = ClinicVisitsState.loading.obs;
  final RxBool isLoading = false.obs;

  // Filters
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'all'.obs;

  // Branch + country
  final RxList<BranchModel> accessibleBranches = <BranchModel>[].obs;
  final RxString selectedBranchId = ''.obs;
  final RxString country = ''.obs;

  // Date range — defaults to today
  final Rx<DateTime> startDate = DateTime.now().obs;
  final Rx<DateTime> endDate = DateTime.now().obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt pageSize = 20.obs;
  final RxInt totalPages = 1.obs;
  final RxInt totalCount = 0.obs;

  // Status counts (for tabs)
  final RxInt checkedInCount = 0.obs;
  final RxInt checkedOutCount = 0.obs;
  final RxInt cancelledCount = 0.obs;

  Worker? _branchesWorker;

  @override
  void onInit() {
    super.onInit();
    _loadSelectedBranch();
    _loadAccessibleBranches();
    fetchClinicVisits();
  }

  @override
  void onClose() {
    _branchesWorker?.dispose();
    super.onClose();
  }

  void _loadSelectedBranch() {
    final branchData = _storageService.getSelectedBranchData();
    if (branchData != null) {
      selectedBranchId.value = (branchData['id'] ?? '').toString();
      country.value = (branchData['country'] as String?) ?? 'EG';
    }
  }

  void _loadAccessibleBranches() {
    // Seed with the currently selected branch so the dropdown always has at
    // least one option.
    final branchData = _storageService.getSelectedBranchData();
    if (branchData != null && (branchData['id'] ?? '').toString().isNotEmpty) {
      accessibleBranches.assignAll([
        BranchModel(
          id: branchData['id'].toString(),
          name: (branchData['name'] ?? 'Selected branch').toString(),
          role: '',
          icon: '',
        ),
      ]);
    }

    if (Get.isRegistered<BranchManagementController>()) {
      final branchCtl = Get.find<BranchManagementController>();
      if (branchCtl.branches.isNotEmpty) {
        accessibleBranches.assignAll(branchCtl.branches);
      }
      _branchesWorker = ever<List<BranchModel>>(branchCtl.branches, (list) {
        if (list.isNotEmpty) {
          accessibleBranches.assignAll(list);
        }
      });
    }
  }

  Future<void> fetchClinicVisits() async {
    if (selectedBranchId.value.isEmpty) {
      state.value = ClinicVisitsState.empty;
      return;
    }

    try {
      isLoading.value = true;
      state.value = ClinicVisitsState.loading;

      final accessToken = _storageService.getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      final sd = startDate.value;
      final ed = endDate.value;
      final startStr =
          '${sd.year}-${sd.month.toString().padLeft(2, '0')}-${sd.day.toString().padLeft(2, '0')}';
      final endStr =
          '${ed.year}-${ed.month.toString().padLeft(2, '0')}-${ed.day.toString().padLeft(2, '0')}';

      final url = Uri.parse(
        '${AppConfig.newBackendUrl}/api/appointment-sessions/clinic-visits'
        '?country=${country.value}'
        '&branchId=${selectedBranchId.value}'
        '&startAfter=${startStr}T00:00:00Z'
        '&startBefore=${endStr}T23:59:59Z'
        '&page=${currentPage.value}'
        '&limit=${pageSize.value}',
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        if (jsonData['success'] == true || jsonData['data'] != null) {
          final parsed = ClinicVisitsResponse.fromJson(jsonData);
          allRows.assignAll(parsed.rows);
          currentPage.value = parsed.meta.page;
          pageSize.value = parsed.meta.limit;
          totalPages.value =
              parsed.meta.totalPages < 1 ? 1 : parsed.meta.totalPages;
          totalCount.value = parsed.meta.totalCount;
          _calculateStatusCounts();
          _applySearchAndFilter();
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      state.value = ClinicVisitsState.error;
      allRows.clear();
      displayedRows.clear();
      appSnackbar(
        'Error',
        'Failed to load visits: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateStatusCounts() {
    checkedInCount.value = allRows.where((r) {
      final s = r.status.toLowerCase();
      return s == 'booked';
    }).length;
    checkedOutCount.value = allRows.where((r) {
      final s = r.status.toLowerCase();
      return s == 'fulfilled' || s == 'completed' || s == 'checked';
    }).length;
    cancelledCount.value = allRows.where((r) {
      final s = r.status.toLowerCase();
      return s == 'cancelled' || s == 'canceled';
    }).length;
  }

  void searchAppointments(String query) {
    searchQuery.value = query.trim().toLowerCase();
    _applySearchAndFilter();
  }

  void filterByStatus(String filter) {
    selectedFilter.value = filter;
    _applySearchAndFilter();
  }

  void _applySearchAndFilter() {
    Iterable<ClinicVisitRow> filtered = allRows;

    // Status filter — match the source controller's three-tab semantics
    final f = selectedFilter.value.toLowerCase();
    if (f != 'all') {
      filtered = filtered.where((r) {
        final s = r.status.toLowerCase();
        if (f == 'booked') return s == 'booked';
        if (f == 'fulfilled') {
          return s == 'fulfilled' || s == 'completed' || s == 'checked';
        }
        if (f == 'cancelled') return s == 'cancelled' || s == 'canceled';
        return s == f;
      });
    }

    final q = searchQuery.value;
    if (q.isNotEmpty) {
      filtered = filtered.where((r) {
        return r.studentName.toLowerCase().contains(q) ||
            r.studentAid.toLowerCase().contains(q) ||
            r.gradeName.toLowerCase().contains(q) ||
            r.className.toLowerCase().contains(q) ||
            r.disease.toLowerCase().contains(q) ||
            (r.doctor ?? '').toLowerCase().contains(q);
      });
    }

    displayedRows.assignAll(filtered.toList());
    state.value = displayedRows.isEmpty
        ? ClinicVisitsState.empty
        : ClinicVisitsState.success;
  }

  Future<void> changeDateRange(DateTime start, DateTime end) async {
    startDate.value = start;
    endDate.value = end;
    currentPage.value = 1;
    await fetchClinicVisits();
  }

  Future<void> changeBranch(String branchId) async {
    if (branchId.isEmpty || branchId == selectedBranchId.value) return;
    selectedBranchId.value = branchId;
    final match = accessibleBranches.firstWhereOrNull((b) => b.id == branchId);
    if (match != null) {
      // BranchModel doesn't carry country directly; keep current country
      // unless the storage service has a fresher value for this branch.
    }
    currentPage.value = 1;
    await fetchClinicVisits();
  }

  Future<void> goToPage(int page) async {
    if (page < 1 || page > totalPages.value || page == currentPage.value) {
      return;
    }
    currentPage.value = page;
    await fetchClinicVisits();
  }

  Future<void> nextPage() => goToPage(currentPage.value + 1);
  Future<void> previousPage() => goToPage(currentPage.value - 1);

  void refreshAppointments() {
    fetchClinicVisits();
  }

  bool get hasActiveFilters =>
      searchQuery.value.isNotEmpty || selectedFilter.value != 'all';

  int get activeFilterCount {
    int count = 0;
    if (selectedFilter.value != 'all') count++;
    if (searchQuery.value.isNotEmpty) count++;
    return count;
  }

  String get selectedBranchName {
    final match =
        accessibleBranches.firstWhereOrNull((b) => b.id == selectedBranchId.value);
    return match?.name ?? 'Select branch';
  }
}
