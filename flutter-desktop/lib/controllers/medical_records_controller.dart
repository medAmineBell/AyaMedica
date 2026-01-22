import 'package:flutter/material.dart';
import 'package:flutter_getx_app/models/medicalRecord.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/medical_student.dart';
import '../utils/storage_service.dart';

enum MedicalRecordsState { loading, success, error, empty }

class MedicalRecordsController extends GetxController {
  // Services
  final StorageService _storageService = Get.find();

  // Reactive variables
  final RxList<MedicalStudent> allStudents = <MedicalStudent>[].obs;
  final RxList<MedicalStudent> displayedStudents = <MedicalStudent>[].obs;
  final Rx<MedicalStudent?> selectedStudent = Rx<MedicalStudent?>(null);

  final Rx<MedicalRecordsState> state = MedicalRecordsState.loading.obs;
  final RxBool isLoading = false.obs;
  final RxString selectedFilter = 'all'.obs;
  final RxString searchQuery = ''.obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt itemsPerPage = 20.obs;
  final RxInt totalStudents = 0.obs;
  final RxInt totalPages = 0.obs;

  // Branch ID (used as organizationId in API)
  final RxString branchId = ''.obs;

  // Add these properties at the top with other reactive variables
  final Rx<StudentDetails?> selectedStudentDetails = Rx<StudentDetails?>(null);
  final RxList<MedicalRecord> studentRecords = <MedicalRecord>[].obs;
  final RxBool isLoadingStudentDetails = false.obs;
  final RxInt studentRecordsPage = 1.obs;
  final RxInt studentRecordsTotalPages = 0.obs;

  /// GET - Fetch individual student details with medical records
  Future<void> fetchStudentDetails(String studentId, {int page = 1}) async {
    if (branchId.value.isEmpty) {
      print('❌ Cannot load student details: No branch ID available');
      return;
    }

    try {
      isLoadingStudentDetails.value = true;
      print('📡 Fetching student details for ID: $studentId');

      // Get access token
      final accessToken = await _storageService.getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      // Build API URL
      final url = Uri.parse(
        'https://ayamedica-backend.ayamedica.online/api/school-admin/medical-records/students/$studentId?organizationId=${branchId.value}&page=$page&limit=20',
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
          final studentDetailResponse =
              StudentDetailResponse.fromJson(jsonData);

          // Update student details
          selectedStudentDetails.value = studentDetailResponse.student;

          // Update records
          studentRecords.assignAll(studentDetailResponse.records);

          // Update pagination
          studentRecordsPage.value = studentDetailResponse.pagination.page;
          studentRecordsTotalPages.value =
              studentDetailResponse.pagination.totalPages;

          print('✅ Student details loaded successfully:');
          print(' - Student: ${studentDetailResponse.student.fullName}');
          print(' - Records: ${studentDetailResponse.records.length}');
          print(
              ' - Page: ${studentRecordsPage.value}/${studentRecordsTotalPages.value}');
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error fetching student details: $e');
      Get.snackbar(
        'Error',
        'Failed to load student details: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoadingStudentDetails.value = false;
    }
  }

  /// Select student and load their details
  void selectStudentWithDetails(MedicalStudent student) {
    selectedStudent.value = student;
    fetchStudentDetails(student.id);
    print('📋 Selected student: ${student.fullName}');
  }

  /// Clear student details
  void clearStudentDetails() {
    selectedStudent.value = null;
    selectedStudentDetails.value = null;
    studentRecords.clear();
    print('🔄 Cleared student details');
  }

  @override
  void onInit() {
    super.onInit();
    _loadBranchId();
    fetchRecords();
  }

  /// CENTRALIZED METHOD: Get Branch ID
  void _loadBranchId() {
    // Get branch ID from selected branch data
    final branchData = _storageService.getSelectedBranchData();
    if (branchData != null) {
      final id = branchData['id'];
      if (id != null) {
        branchId.value = id;
        print('📍 Got branch ID from storage: $id');
        return;
      }
    }

    print('❌ No branch ID found in storage');
  }

  /// GET - Fetch medical records from API
  Future<void> fetchRecords({int page = 1}) async {
    if (branchId.value.isEmpty) {
      print('❌ Cannot load medical records: No branch ID available');
      Get.snackbar(
        'Error',
        'Please select a branch first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      state.value = MedicalRecordsState.error;
      return;
    }

    try {
      isLoading.value = true;
      state.value = MedicalRecordsState.loading;

      print('📡 Fetching medical records for branch: ${branchId.value}');

      // Get access token
      final accessToken = await _storageService.getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      // Build API URL - Using branchId as organizationId parameter
      final url = Uri.parse(
        'https://ayamedica-backend.ayamedica.online/api/school-admin/medical-records/students?organizationId=${branchId.value}&page=$page&limit=${itemsPerPage.value}',
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
          final data = jsonData['data'];
          final studentsJson = data['students'] as List;
          final paginationJson = data['pagination'] as Map<String, dynamic>;

          // Parse students
          final students = studentsJson
              .map((json) =>
                  MedicalStudent.fromJson(json as Map<String, dynamic>))
              .toList();

          // Update pagination data
          currentPage.value = paginationJson['page'] as int;
          totalStudents.value = paginationJson['total'] as int;
          totalPages.value = paginationJson['totalPages'] as int;

          // Update student lists
          allStudents.assignAll(students);
          displayedStudents.assignAll(students);

          print('✅ Medical records loaded successfully:');
          print('   - Students: ${students.length}');
          print('   - Total: ${totalStudents.value}');
          print('   - Page: ${currentPage.value}/${totalPages.value}');

          // Update state
          state.value = displayedStudents.isEmpty
              ? MedicalRecordsState.empty
              : MedicalRecordsState.success;

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
      print('❌ Error fetching medical records: $e');
      state.value = MedicalRecordsState.error;

      Get.snackbar(
        'Error',
        'Failed to load medical records: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // Clear data on error
      allStudents.clear();
      displayedStudents.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// SEARCH - Filter students by query
  void searchRecords(String query) {
    print('🔍 Searching for: "$query"');
    searchQuery.value = query.trim().toLowerCase();
    _applySearchAndFilter();
  }

  /// FILTER - Filter by visit status
  void filterByStatus(String filter) {
    print('🔍 Filtering by status: $filter');
    selectedFilter.value = filter;
    _applySearchAndFilter();
  }

  /// Apply search and filter logic
  void _applySearchAndFilter() {
    List<MedicalStudent> filtered = List.from(allStudents);

    // Apply status filter
    if (selectedFilter.value == 'visited') {
      filtered = filtered.where((student) => student.hasVisited).toList();
    } else if (selectedFilter.value == 'not_visited') {
      filtered = filtered.where((student) => !student.hasVisited).toList();
    }

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((student) {
        final name = student.fullName.toLowerCase();
        final sid = student.studentId.toLowerCase();
        final grade = student.grade?.toLowerCase() ?? '';
        final className = student.className?.toLowerCase() ?? '';

        return name.contains(searchQuery.value) ||
            sid.contains(searchQuery.value) ||
            grade.contains(searchQuery.value) ||
            className.contains(searchQuery.value);
      }).toList();
    }

    displayedStudents.assignAll(filtered);

    print('✅ Filters applied: ${displayedStudents.length} students found');

    // Update state
    state.value = displayedStudents.isEmpty
        ? MedicalRecordsState.empty
        : MedicalRecordsState.success;
  }

  /// Refresh records
  void refreshRecords() {
    fetchRecords(page: currentPage.value);
  }

  /// Pagination methods
  void goToPage(int page) {
    if (page >= 1 && page <= totalPages.value) {
      fetchRecords(page: page);
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      fetchRecords(page: currentPage.value - 1);
    }
  }

  void nextPage() {
    if (currentPage.value < totalPages.value) {
      fetchRecords(page: currentPage.value + 1);
    }
  }

  /// Select student for detailed view
  void selectStudent(MedicalStudent student) {
    selectedStudent.value = student;
    print('📋 Selected student: ${student.fullName}');
  }

  /// Clear selected student
  void clearSelectedStudent() {
    selectedStudent.value = null;
    print('🔄 Cleared selected student');
  }

  /// Statistics getters
  int get visitedCount => allStudents.where((s) => s.hasVisited).length;
  int get notVisitedCount => allStudents.where((s) => !s.hasVisited).length;

  double get visitedPercentage {
    if (allStudents.isEmpty) return 0.0;
    return (visitedCount / allStudents.length) * 100;
  }

  int get totalRecordsCount {
    return allStudents.fold(0, (sum, student) => sum + student.numberOfRecords);
  }

  /// Check if there are any students
  bool get hasStudents => allStudents.isNotEmpty;

  /// Check if filters are active
  bool get hasActiveFilters =>
      searchQuery.value.isNotEmpty || selectedFilter.value != 'all';
}
