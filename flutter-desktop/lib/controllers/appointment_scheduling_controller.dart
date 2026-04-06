import 'package:flutter/material.dart';
import 'package:flutter_getx_app/config/app_config.dart';
import 'package:flutter_getx_app/models/appointment.dart';
import 'package:flutter_getx_app/models/appointment_models.dart';
import 'package:flutter_getx_app/models/health_status.dart';
import 'package:flutter_getx_app/models/student.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/storage_service.dart';

enum AppointmentScreenState { loading, error, success, empty }

enum TableViewMode {
  appointments, // Show appointments as rows
  appointmentStudents, // Show individual appointment-student combinations
  appointmentStudentsNotify, // Show individual appointment-student combinations
  medicalCheckup, // Show medical checkup table
  chronicDiseases, // Show chronic diseases table
}

class AppointmentSchedulingController extends GetxController {
  static String get _baseUrl => AppConfig.newBackendUrl;

  final Rxn<Appointment> selectedAppointmentForStudents = Rxn<Appointment>();
  final StorageService _storageService = Get.find();

  // Organization and Branch IDs
  final RxString organizationId = ''.obs;
  final RxString branchId = ''.obs;

  /// Get authorization headers for API requests
  Map<String, String> _getHeaders(String accessToken) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
  }

  /// Get a valid access token or throw
  String _getAccessTokenOrThrow() {
    final accessToken = _storageService.getAccessToken();
    if (accessToken == null) {
      throw Exception('No access token found. Please log in again.');
    }
    return accessToken;
  }

  final Rx<AppointmentScreenState> screenState =
      AppointmentScreenState.loading.obs;
  final RxString errorMessage = ''.obs;
  final RxList<Appointment> appointments = <Appointment>[].obs;
  final RxList<AppointmentStudent> selectedAppointments =
      <AppointmentStudent>[].obs;
  final RxList<AppointmentStudent> selectedAppointmentStudents =
      <AppointmentStudent>[].obs;
  final RxList<String> selectedAppointmentIds = <String>[].obs;

  final RxMap<String, AppointmentStatus> appointmentStatuses =
      <String, AppointmentStatus>{}.obs;
  final RxMap<String, String> appointmentNotes = <String, String>{}.obs;
  final RxString studentSearchQuery = ''.obs;
  final Rx<TableViewMode> currentViewMode = TableViewMode.appointments.obs;
  final RxSet<String> loadingAppointmentStudentKeys = <String>{}.obs;
  final RxBool showChronicDiseases = false.obs;
  bool isLoadingStudent(String appointmentId, String studentId) {
    final key = '${appointmentId}_$studentId';
    return loadingAppointmentStudentKeys.contains(key);
  }

// Add this method to your AppointmentSchedulingController class
  Map<String, int> getStatusCounts(String appointmentId) {
    // Find the appointment
    final appt = appointments.firstWhereOrNull((a) => a.id == appointmentId);
    if (appt == null) {
      return {'done': 0, 'pending': 0, 'declined': 0};
    }

    int done = 0;
    int pending = 0;
    int declined = 0;

    for (var student in appt.selectedStudents) {
      final status = getAppointmentStatus(appointmentId, student.id);
      if (status == AppointmentStatus.done) {
        done++;
      } else if (status == AppointmentStatus.notDone) {
        pending++;
      } else if (status == AppointmentStatus.cancelled) {
        declined++;
      } else {
        // For notDone status, we'll count as pending since it hasn't been processed yet
        pending++;
      }
    }

    return {
      'done': done,
      'pending': pending,
      'declined': declined,
    };
  }

  void setLoadingForStudent(
      String appointmentId, String studentId, bool isLoading) {
    final key = '${appointmentId}_$studentId';
    if (isLoading) {
      loadingAppointmentStudentKeys.add(key);
    } else {
      loadingAppointmentStudentKeys.remove(key);
    }
  }

  /// PATCH /api/appointment-sessions/{id}/patients/{patientAid}
  /// Updates hygiene inspection fields for a patient in a hygiene appointment.
  Future<void> updatePatientHygieneStatus({
    required String sessionId,
    required String patientAid,
    required String studentId,
    required Map<String, HealthStatusData?> categoryStatuses,
  }) async {
    try {
      final accessToken = _getAccessTokenOrThrow();
      final url = Uri.parse(
          '$_baseUrl/api/appointment-sessions/$sessionId/patients/$patientAid');

      // Build hygiene body from category statuses
      final body = <String, dynamic>{
        'patientStatus': 'checked',
      };

      const categoryToField = {
        'Hair': 'hair',
        'Ears': 'ears',
        'Nails': 'nails',
        'Teeth': 'teeth',
        'Uniform': 'uniform',
      };

      for (final entry in categoryToField.entries) {
        final status = categoryStatuses[entry.key];
        if (status != null) {
          body['${entry.value}Status'] =
              status.status == HealthStatus.good ? 'good' : 'issue';
          body['${entry.value}Reason'] =
              status.status == HealthStatus.good
                  ? ''
                  : (status.issueDescription ?? '');
        }
      }

      final response = await http.patch(
        url,
        headers: _getHeaders(accessToken),
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error updating hygiene status: $e');
      Get.snackbar(
        'Error',
        'Failed to update hygiene status: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }

  /// PATCH /api/appointment-sessions/{id}/patients/{patientAid}
  Future<void> updatePatientStatus({
    required String sessionId,
    required String patientAid,
    required String patientStatus,
    String patientNote = '',
    required String studentId,
  }) async {
    final key = '${sessionId}_$studentId';
    try {
      setLoadingForStudent(sessionId, studentId, true);

      final accessToken = _getAccessTokenOrThrow();
      final url = Uri.parse(
          '$_baseUrl/api/appointment-sessions/$sessionId/patients/$patientAid');

      final response = await http.patch(
        url,
        headers: _getHeaders(accessToken),
        body: jsonEncode({
          'patientNote': patientNote,
          'patientStatus': patientStatus,
        }),
      );

      if (response.statusCode == 200) {
        switch (patientStatus) {
          case 'checked':
            appointmentStatuses[key] = AppointmentStatus.done;
            break;
          case 'absent':
            appointmentStatuses[key] = AppointmentStatus.absent;
            break;
          case 'issue':
            appointmentStatuses[key] = AppointmentStatus.notDone;
            break;
          case 'pending':
            appointmentStatuses.remove(key);
            break;
        }
        appointmentNotes[key] = patientNote;
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error updating patient status: $e');
      Get.snackbar(
        'Error',
        'Failed to update status: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      setLoadingForStudent(sessionId, studentId, false);
    }
  }

  /// POST /api/appointment-sessions/{id}/checkout
  Future<bool> checkoutAppointmentSession(String sessionId) async {
    try {
      final accessToken = _getAccessTokenOrThrow();
      final url =
          Uri.parse('$_baseUrl/api/appointment-sessions/$sessionId/checkout');

      final response = await http.post(
        url,
        headers: _getHeaders(accessToken),
      );

      if (response.statusCode == 200) {
        markAppointmentAsCompleted(sessionId);
        return true;
      }
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    } catch (e) {
      print('Error checking out appointment: $e');
      Get.snackbar(
        'Error',
        'Failed to complete appointment: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return false;
    }
  }

  final RxInt currentPage = 1.obs;
  final int itemsPerPage = 10;
  final RxString searchQuery = ''.obs;

  final selectedStatusFilter = Rx<AppointmentStatus>(AppointmentStatus.notDone);

  List<Appointment> get filteredAppointments {
    List<Appointment> filtered = appointments.toList();

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((appointment) {
        return appointment.className.toLowerCase().contains(query) ||
            appointment.grade.toLowerCase().contains(query) ||
            appointment.type.toLowerCase().contains(query) ||
            appointment.disease.toLowerCase().contains(query) ||
            appointment.doctor.toLowerCase().contains(query);
      }).toList();
    }

    // Apply status filter
    filtered = filtered.where((appointment) {
      final status = getAppointmentOverallStatus(appointment.id ?? '');
      return status == selectedStatusFilter.value;
    }).toList();

    return filtered;
  }

  List<Appointment> get paginatedAppointments {
    final filtered = filteredAppointments;
    final startIndex = (currentPage.value - 1) * itemsPerPage;
    final endIndex = (startIndex + itemsPerPage).clamp(0, filtered.length);

    if (startIndex >= filtered.length) {
      return [];
    }

    return filtered.sublist(startIndex, endIndex);
  }

  void showStudentsForAppointment(Appointment appointment) {
    selectedAppointmentForStudents.value = appointment;
    currentViewMode.value = TableViewMode.appointmentStudents;

    clearSelections();
  }

  void showStudentsForAppointmentNotify(Appointment appointment) {
    selectedAppointmentForStudents.value = appointment;
    currentViewMode.value = TableViewMode.appointmentStudentsNotify;

    clearSelections();
  }

  void showMedicalCheckupView(Appointment appointment) {
    selectedAppointmentForStudents.value = appointment;
    currentViewMode.value = TableViewMode.medicalCheckup;
    clearSelections();
  }

  void switchToAppointmentView() {
    currentViewMode.value = TableViewMode.appointments;
    selectedAppointmentForStudents.value = null;
    clearSelections();
  }

  void clearSelections() {
    selectedAppointmentStudents.clear();
    selectedAppointmentIds.clear();
  }

// Update totalPages getter to work with appointments
  int get totalPages {
    return (filteredAppointments.length / itemsPerPage).ceil();
  }

  Future<void> deleteAppointment(Appointment appointment) async {
    try {
      final id = appointment.id;
      if (id == null) return;

      // 1. Remove the appointment from the list
      appointments.removeWhere((a) => a.id == id);

      // 2. Remove all associated statuses
      appointment.selectedStudents.forEach((student) {
        final key = '${id}_${student.id}';
        appointmentStatuses.remove(key);
      });

      // 3. Clear selection if needed
      if (selectedAppointmentForStudents.value?.id == id) {
        switchToAppointmentView();
      }

      // ✅ 4. Trigger refresh so .obs-based widgets update
      appointments.refresh();
      appointmentStatuses.refresh();

      // 5. Refresh pagination (if needed)
      if (paginatedAppointments.isEmpty && currentPage.value > 1) {
        goToPreviousPage();
      }
    } catch (e) {
      errorMessage.value = 'Failed to delete appointment: $e';
    }
  }

  AppointmentStatus getAppointmentOverallStatus(String appointmentId) {
    final appointment =
        appointments.firstWhereOrNull((app) => app.id == appointmentId);

    if (appointment == null) return AppointmentStatus.notDone;

    final studentStatuses = appointment.selectedStudents.map((student) {
      return getAppointmentStatus(appointmentId, student.id);
    }).toList();

    if (studentStatuses.isEmpty) return AppointmentStatus.notDone;

    // If all students are done, appointment is done
    if (studentStatuses.every((status) => status == AppointmentStatus.done)) {
      return AppointmentStatus.done;
    }

    // If any student is cancelled, check if all are cancelled
    if (studentStatuses
        .any((status) => status == AppointmentStatus.cancelled)) {
      if (studentStatuses
          .every((status) => status == AppointmentStatus.cancelled)) {
        return AppointmentStatus.cancelled;
      }
    }

    // Otherwise, appointment is in progress
    return AppointmentStatus.notDone;
  }

// Get count methods for filter chips
  int getDoneAppointmentsCount() {
    return appointments.where((appointment) {
      final status = getAppointmentOverallStatus(appointment.id ?? '');
      return status == AppointmentStatus.done;
    }).length;
  }

  int getInProgressAppointmentsCount() {
    return appointments.where((appointment) {
      final status = getAppointmentOverallStatus(appointment.id ?? '');
      return status == AppointmentStatus.notDone;
    }).length;
  }

  int getCancelledAppointmentsCount() {
    return appointments.where((appointment) {
      final status = getAppointmentOverallStatus(appointment.id ?? '');
      return status == AppointmentStatus.cancelled;
    }).length;
  }

  void switchToAppointmentStudentView() {
    currentViewMode.value = TableViewMode.appointmentStudents;
    clearSelections();
    resetPagination();
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    currentPage.value = 1; // Reset to first page when searching
    selectedAppointments.clear(); // Clear selections
  }

  void toggleAppointmentStudentSelection(
      AppointmentStudent appointmentStudent) {
    final index = selectedAppointmentStudents.indexWhere((selected) =>
        selected.appointmentId == appointmentStudent.appointmentId &&
        selected.student.id == appointmentStudent.student.id);

    if (index != -1) {
      selectedAppointmentStudents.removeAt(index);
    } else {
      selectedAppointmentStudents.add(appointmentStudent);
    }
  }

  void toggleAppointmentStudentStatus(AppointmentStudent appointmentStudent) {
    final key =
        '${appointmentStudent.appointmentId}_${appointmentStudent.student.id}';
    final currentStatus = appointmentStatuses[key] ?? AppointmentStatus.notDone;
    appointmentStatuses[key] = currentStatus == AppointmentStatus.done
        ? AppointmentStatus.notDone
        : AppointmentStatus.done;
  }

  void toggleStatusFilter(AppointmentStatus status) {
    if (selectedStatusFilter.value == status) {
      selectedStatusFilter.value =
          AppointmentStatus.notDone; // Remove filter if already selected
    } else {
      selectedStatusFilter.value = status; // Apply filter
    }
    currentPage.value = 1; // Reset to first page when filtering
    selectedAppointments.clear(); // Clear selections
  }

  List<AppointmentStudent> get filteredAppointmentStudents {
    List<AppointmentStudent> students = allAppointmentStudents;

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      students = students.where((student) {
        return student.student.name.toLowerCase().contains(query) ||
            student.student.id.toLowerCase().contains(query) ||
            getAppointmentType(student.appointmentId)
                .toLowerCase()
                .contains(query);
      }).toList();
    }

    // Apply status filter
    students = students.where((student) {
      final status =
          getAppointmentStatus(student.appointmentId, student.student.id);
      return status == selectedStatusFilter.value;
    }).toList();

    return students;
  }

  @override
  void onInit() {
    super.onInit();
    _loadIds();
    loadAppointments();
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
      print(
          '📍 AppointmentScheduling - Organization ID: ${organizationId.value}');
      print('📍 AppointmentScheduling - Branch ID: ${branchId.value}');
    }
  }

  List<AppointmentStudent> get paginatedAppointmentStudents {
    final filteredStudents = filteredAppointmentStudents;
    final startIndex = (currentPage.value - 1) * itemsPerPage;
    final endIndex =
        (startIndex + itemsPerPage).clamp(0, filteredStudents.length);

    if (startIndex >= filteredStudents.length) {
      return [];
    }

    return filteredStudents.sublist(startIndex, endIndex);
  }

  int getDoneCount() {
    return allAppointmentStudents.where((student) {
      final status =
          getAppointmentStatus(student.appointmentId, student.student.id);
      return status == AppointmentStatus.done;
    }).length;
  }

  // Get count of not done appointments (for filter chip)
  int getNotDoneCount() {
    return allAppointmentStudents.where((student) {
      final status =
          getAppointmentStatus(student.appointmentId, student.student.id);
      return status == AppointmentStatus.notDone;
    }).length;
  }

  // Check if we can go to previous page
  bool get canGoPrevious => currentPage.value > 1;

  // Check if we can go to next page
  bool get canGoNext => currentPage.value < totalPages;

  // Navigate to specific page
  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      currentPage.value = page;
      // Clear selections when changing page
      selectedAppointments.clear();
    }
  }

  // Go to previous page
  void goToPreviousPage() {
    if (canGoPrevious) {
      currentPage.value--;
      selectedAppointments.clear();
    }
  }

  // Go to next page
  void goToNextPage() {
    if (canGoNext) {
      currentPage.value++;
      selectedAppointments.clear();
    }
  }

  // Reset pagination when appointments change
  void resetPagination() {
    currentPage.value = 1;
    selectedAppointments.clear();
    // Don't clear search/filters here, let user decide
  }

  bool get isAllSelected {
    final currentPageStudents = paginatedAppointmentStudents;
    return currentPageStudents.isNotEmpty &&
        selectedAppointments.length == currentPageStudents.length &&
        currentPageStudents.every((student) => selectedAppointments.any(
            (selected) =>
                selected.appointmentId == student.appointmentId &&
                selected.student.id == student.student.id));
  }

  void toggleSelectAll() {
    final currentPageStudents = paginatedAppointmentStudents;

    if (isAllSelected) {
      // Remove all current page students from selection
      selectedAppointments.removeWhere((selected) => currentPageStudents.any(
          (pageStudent) =>
              pageStudent.appointmentId == selected.appointmentId &&
              pageStudent.student.id == selected.student.id));
    } else {
      // Add all current page students to selection (avoid duplicates)
      for (var student in currentPageStudents) {
        if (!selectedAppointments.any((selected) =>
            selected.appointmentId == student.appointmentId &&
            selected.student.id == student.student.id)) {
          selectedAppointments.add(student);
        }
      }
    }
  }

  // Get appointment status for a specific appointment-student combination
  AppointmentStatus getAppointmentStatus(
      String appointmentId, String studentId) {
    final key = '${appointmentId}_$studentId';
    return appointmentStatuses[key] ?? AppointmentStatus.notDone;
  }

  // Get all appointment students for table display
  List<AppointmentStudent> get allAppointmentStudents {
    List<AppointmentStudent> result = [];
    for (var appointment in appointments) {
      for (var student in appointment.selectedStudents) {
        final status = getAppointmentStatus(appointment.id ?? '', student.id);
        result.add(AppointmentStudent(
          appointmentId: appointment.id ?? '',
          student: student,
          status: status,
        ));
      }
    }
    return result;
  }

  Future<void> loadAppointments({
    String? startDate,
    String? endDate,
  }) async {
    try {
      screenState.value = AppointmentScreenState.loading;
      errorMessage.value = '';

      if (organizationId.value.isEmpty || branchId.value.isEmpty) {
        _loadIds();
        if (organizationId.value.isEmpty || branchId.value.isEmpty) {
          throw Exception(
              'No organization or branch selected. Please select a branch first.');
        }
      }

      print('🔄 Loading appointments from API...');

      final accessToken = _getAccessTokenOrThrow();
      final branchData = _storageService.getSelectedBranchData();
      final country = branchData?['country'] as String? ?? 'EG';

      // Build API URL using appointment-sessions endpoint
      var urlString = '$_baseUrl/api/appointment-sessions?country=$country&branchId=${branchId.value}';
      if (startDate != null) urlString += '&startDate=$startDate';
      if (endDate != null) urlString += '&endDate=$endDate';

      final url = Uri.parse(urlString);
      print('📡 Request URL: $url');

      // Make API request
      final response = await http.get(
        url,
        headers: _getHeaders(accessToken),
      );

      print('📡 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          final apiAppointments = jsonData['data'] as List<dynamic>;
          print('📅 Found ${apiAppointments.length} appointments from API');

          // Convert API appointments to our Appointment model
          appointments.clear();
          for (final apiAppt in apiAppointments) {
            try {
              final appointment =
                  _convertApiToAppointment(apiAppt as Map<String, dynamic>);
              if (appointment != null) {
                appointments.add(appointment);
              }
            } catch (e) {
              print('⚠️ Error converting appointment: $e');
            }
          }

          print('✅ Successfully loaded ${appointments.length} appointments');

          if (appointments.isNotEmpty) {
            screenState.value = AppointmentScreenState.success;
          } else {
            screenState.value = AppointmentScreenState.empty;
          }
        } else {
          throw Exception('API returned success: false');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please log in again.');
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error loading appointments: $e');
      errorMessage.value = e.toString();
      screenState.value = AppointmentScreenState.error;
    }
  }

  /// Convert API appointment-session response to our Appointment model
  Appointment? _convertApiToAppointment(Map<String, dynamic> apiAppt) {
    try {
      final id = apiAppt['id'] as String?;
      if (id == null) return null;

      // Parse appointmentDate
      final dateStr = apiAppt['appointmentDate'] as String?;
      final dateTime = dateStr != null ? DateTime.tryParse(dateStr) : null;

      // Format time from appointmentDate
      String timeString = '';
      if (dateTime != null) {
        timeString =
            '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      }

      // Format appointment type for display
      final apiType = (apiAppt['appointmentType'] as String?) ?? '';
      String displayType;
      switch (apiType.toLowerCase()) {
        case 'walkin':
          displayType = 'Walk-In';
          break;
        case 'checkup':
          displayType = 'Checkup';
          break;
        case 'followup':
          displayType = 'Follow-Up';
          break;
        case 'vaccination':
          displayType = 'Vaccination';
          break;
        default:
          displayType = apiType;
      }

      // For walk-in, create a single student from fullName/onePatientAid
      final List<Student> selectedStudents = [];
      final isWalkIn = apiType.toLowerCase() == 'walkin';
      if (isWalkIn) {
        final fullName = apiAppt['fullName'] as String?;
        if (fullName != null && fullName.isNotEmpty) {
          selectedStudents.add(Student(
            id: apiAppt['onePatientAid'] ?? '',
            name: fullName,
            avatarColor: const Color(0xFF6366F1),
          ));
        }
      }

      // Convert API status to AppointmentStatus
      final statusStr = (apiAppt['appointmentStatus'] as String?)?.toLowerCase() ?? '';
      AppointmentStatus appointmentStatus;
      switch (statusStr) {
        case 'fulfilled':
        case 'completed':
        case 'done':
          appointmentStatus = AppointmentStatus.done;
          break;
        case 'cancelled':
          appointmentStatus = AppointmentStatus.cancelled;
          break;
        case 'booked':
        case 'pending':
        default:
          appointmentStatus = AppointmentStatus.notDone;
          break;
      }

      return Appointment(
        id: id,
        type: displayType,
        allStudents: !isWalkIn,
        date: dateTime ?? DateTime.now(),
        time: timeString,
        disease: apiAppt['reason'] ?? '',
        diseaseType: '',
        grade: apiAppt['gradeName'] ?? '',
        className: apiAppt['className'] ?? '',
        doctor: '',
        selectedStudents: selectedStudents,
        status: appointmentStatus,
      );
    } catch (e) {
      print('❌ Error converting appointment: $e');
      return null;
    }
  }

  void retryLoading() {
    loadAppointments();
  }

  // Refresh appointments with date filters
  Future<void> refreshAppointments({
    String? startDate,
    String? endDate,
  }) async {
    await loadAppointments(
      startDate: startDate,
      endDate: endDate,
    );
  }

  // Chronic disease methods
  void showChronicDiseasesTable() {
    currentViewMode.value = TableViewMode.chronicDiseases;
    showChronicDiseases.value = true;
  }

  void hideChronicDiseasesTable() {
    currentViewMode.value = TableViewMode.appointments;
    showChronicDiseases.value = false;
  }

  void toggleChronicDiseasesTable() {
    if (currentViewMode.value == TableViewMode.chronicDiseases) {
      hideChronicDiseasesTable();
    } else {
      showChronicDiseasesTable();
    }
  }

  // Get all students with chronic diseases
  List<Student> getStudentsWithChronicDiseases() {
    return appointments
        .expand((appointment) => appointment.selectedStudents)
        .where((student) => student.chronicDiseases?.isNotEmpty == true)
        .toSet() // Remove duplicates
        .toList();
  }

  void toggleAppointmentSelection(AppointmentStudent appointmentStudent) {
    final index = selectedAppointments.indexWhere((selected) =>
        selected.appointmentId == appointmentStudent.appointmentId &&
        selected.student.id == appointmentStudent.student.id);

    if (index != -1) {
      selectedAppointments.removeAt(index);
    } else {
      selectedAppointments.add(appointmentStudent);
    }
  }

  // Toggle appointment status
  void toggleAppointmentStatus(AppointmentStudent appointmentStudent) {
    final key =
        '${appointmentStudent.appointmentId}_${appointmentStudent.student.id}';
    final currentStatus = appointmentStatuses[key] ?? AppointmentStatus.notDone;
    appointmentStatuses[key] = currentStatus == AppointmentStatus.done
        ? AppointmentStatus.notDone
        : AppointmentStatus.done;
  }

  // Mark selected appointments as done
  void markSelectedAsDone() {
    for (var appointmentStudent in selectedAppointments) {
      final key =
          '${appointmentStudent.appointmentId}_${appointmentStudent.student.id}';
      appointmentStatuses[key] = AppointmentStatus.done;
    }
    selectedAppointments.clear();
  }

  // Mark selected appointments as not done
  void markSelectedAsNotDone() {
    for (var appointmentStudent in selectedAppointments) {
      final key =
          '${appointmentStudent.appointmentId}_${appointmentStudent.student.id}';
      appointmentStatuses[key] = AppointmentStatus.notDone;
    }
    selectedAppointments.clear();
  }

  String getAppointmentType(String appointmentId) {
    final appointment = appointments
        .firstWhereOrNull((appointment) => appointment.id == appointmentId);
    return appointment?.type ?? 'Appointment';
  }

  /// POST /api/appointments - Create a new appointment
  Future<Map<String, dynamic>> createAppointmentApi({
    required String start,
    required String end,
    String? patientId,
    List<String>? studentIds,
    String? type,
    String? practitionerId,
    String? locationId,
    String? status,
    bool? walkin,
    String? previousAppointmentId,
    Map<String, dynamic>? preVisit,
    String? diseaseTypeId,
    String? diseaseId,
    Map<String, dynamic>? specialCases,
  }) async {
    try {
      final accessToken = _getAccessTokenOrThrow();

      final body = <String, dynamic>{
        'start': start,
        'end': end,
      };
      if (patientId != null) body['patientId'] = patientId;
      if (studentIds != null) body['studentIds'] = studentIds;
      if (type != null) body['type'] = type;
      if (practitionerId != null) body['practitionerId'] = practitionerId;
      if (organizationId.value.isNotEmpty)
        body['organizationId'] = organizationId.value;
      if (branchId.value.isNotEmpty) body['branchId'] = branchId.value;
      if (locationId != null) body['locationId'] = locationId;
      if (status != null) body['status'] = status;
      if (walkin != null) body['walkin'] = walkin;
      if (previousAppointmentId != null)
        body['previousAppointmentId'] = previousAppointmentId;
      if (preVisit != null) body['preVisit'] = preVisit;
      if (diseaseTypeId != null) body['diseaseTypeId'] = diseaseTypeId;
      if (diseaseId != null) body['diseaseId'] = diseaseId;
      if (specialCases != null) body['specialCases'] = specialCases;

      final url = Uri.parse('$_baseUrl/api/appointments');
      final response = await http.post(
        url,
        headers: _getHeaders(accessToken),
        body: jsonEncode(body),
      );

      print('📡 Create Appointment Response: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          // Reload appointments to reflect the new one
          await loadAppointments();
          return jsonData;
        } else {
          throw Exception(
              jsonData['message'] ?? 'Failed to create appointment');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please log in again.');
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error creating appointment: $e');
      errorMessage.value = e.toString();
      rethrow;
    }
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedStatusFilter.value = AppointmentStatus.notDone;
    currentPage.value = 1;
    selectedAppointments.clear();
  }

  // Health status methods for medical checkups
  final RxMap<String, HealthStatusData> healthStatuses =
      <String, HealthStatusData>{}.obs;

  void setHealthStatus(String key, HealthStatus status) {
    healthStatuses[key] = HealthStatusData(status: status);
  }

  void setHealthStatusWithIssue(
      String key, HealthStatus status, String issueDescription) {
    healthStatuses[key] = HealthStatusData(
      status: status,
      issueDescription: issueDescription,
    );
  }

  void clearHealthStatus(String key) {
    healthStatuses.remove(key);
  }

  HealthStatusData? getHealthStatus(String key) {
    return healthStatuses[key];
  }

  // Track completed appointments with timestamps
  final RxMap<String, DateTime> completedAppointments =
      <String, DateTime>{}.obs;

  void markAppointmentAsCompleted(String appointmentId) {
    completedAppointments[appointmentId] = DateTime.now();
    completedAppointments.refresh();
  }

  bool isAppointmentCompleted(String appointmentId) {
    return completedAppointments.containsKey(appointmentId);
  }

  DateTime? getAppointmentCompletionTime(String appointmentId) {
    return completedAppointments[appointmentId];
  }

  List<Appointment> get completedAppointmentsList {
    return appointments
        .where(
            (appointment) => completedAppointments.containsKey(appointment.id))
        .toList();
  }

  List<Appointment> get pendingAppointmentsList {
    return appointments
        .where(
            (appointment) => !completedAppointments.containsKey(appointment.id))
        .toList();
  }

  // Medical checkup data storage
  final RxMap<String, Map<String, Map<String, HealthStatusData>>>
      medicalCheckupData =
      <String, Map<String, Map<String, HealthStatusData>>>{}.obs;

  // Save medical checkup data for an appointment
  void saveMedicalCheckupData(String appointmentId, List<Student> students) {
    final appointmentData = <String, Map<String, HealthStatusData>>{};

    for (var student in students) {
      final studentData = <String, HealthStatusData>{};
      final categories = ['Hair', 'Ears', 'Nails', 'Teeth', 'Uniform'];

      for (var category in categories) {
        final key = '${appointmentId}_${student.id}_$category';
        final status = healthStatuses[key];
        if (status != null) {
          studentData[category] = status;
        }
      }

      if (studentData.isNotEmpty) {
        appointmentData[student.id] = studentData;
      }
    }

    if (appointmentData.isNotEmpty) {
      medicalCheckupData[appointmentId] = appointmentData;
      medicalCheckupData.refresh();
    }
  }

  // Get medical checkup data for an appointment
  Map<String, Map<String, HealthStatusData>>? getMedicalCheckupData(
      String appointmentId) {
    return medicalCheckupData[appointmentId];
  }

  // Get medical checkup data for a specific student in an appointment
  Map<String, HealthStatusData>? getStudentMedicalCheckupData(
      String appointmentId, String studentId) {
    return medicalCheckupData[appointmentId]?[studentId];
  }

  // Check if medical checkup data exists for an appointment
  bool hasMedicalCheckupData(String appointmentId) {
    return medicalCheckupData.containsKey(appointmentId);
  }

  // Get all medical checkup appointments
  List<Appointment> get medicalCheckupAppointments {
    return appointments
        .where((appointment) =>
            appointment.type.toLowerCase().contains('medical') ||
            appointment.type.toLowerCase().contains('checkup'))
        .toList();
  }

  // Get completed medical checkup appointments
  List<Appointment> get completedMedicalCheckupAppointments {
    return medicalCheckupAppointments
        .where(
            (appointment) => completedAppointments.containsKey(appointment.id))
        .toList();
  }

  // Export medical checkup data for reporting
  Map<String, dynamic> exportMedicalCheckupData(String appointmentId) {
    final data = medicalCheckupData[appointmentId];
    if (data == null) return {};

    final exportData = <String, dynamic>{
      'appointmentId': appointmentId,
      'completedAt': completedAppointments[appointmentId]?.toIso8601String(),
      'students': <String, dynamic>{},
    };

    data.forEach((studentId, categories) {
      exportData['students'][studentId] = <String, dynamic>{};
      categories.forEach((category, status) {
        exportData['students'][studentId][category] = {
          'status': status.status.toString(),
          'issueDescription': status.issueDescription,
        };
      });
    });

    return exportData;
  }

  // ============================================================
  // Clinic Portal API Methods
  // ============================================================

  /// GET /api/appointments - List appointments with clinic portal filters
  Future<Map<String, dynamic>> fetchClinicAppointments({
    String? patientId,
    String? practitionerId,
    String? status,
    String? type,
    String? startAfter,
    String? startBefore,
    String? country,
  }) async {
    try {
      final accessToken = _getAccessTokenOrThrow();

      final queryParams = <String, String>{};
      if (organizationId.value.isNotEmpty)
        queryParams['organizationId'] = organizationId.value;
      if (branchId.value.isNotEmpty) queryParams['branchId'] = branchId.value;
      if (patientId != null) queryParams['patientId'] = patientId;
      if (practitionerId != null)
        queryParams['practitionerId'] = practitionerId;
      if (status != null) queryParams['status'] = status;
      if (type != null) queryParams['type'] = type;
      if (startAfter != null) queryParams['startAfter'] = startAfter;
      if (startBefore != null) queryParams['startBefore'] = startBefore;
      if (country != null) queryParams['country'] = country;

      final url = Uri.parse('$_baseUrl/api/appointments')
          .replace(queryParameters: queryParams);
      final response = await http.get(url, headers: _getHeaders(accessToken));

      print('📡 Fetch Clinic Appointments Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please log in again.');
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error fetching clinic appointments: $e');
      rethrow;
    }
  }

  /// GET /api/appointments/{id} - Get a single appointment
  Future<Map<String, dynamic>> getAppointmentById(String id,
      {String? country}) async {
    try {
      final accessToken = _getAccessTokenOrThrow();

      final queryParams = <String, String>{};
      if (country != null) queryParams['country'] = country;

      final url = Uri.parse('$_baseUrl/api/appointments/$id').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final response = await http.get(url, headers: _getHeaders(accessToken));

      print('📡 Get Appointment Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please log in again.');
      } else if (response.statusCode == 404) {
        throw Exception('Appointment not found.');
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error getting appointment: $e');
      rethrow;
    }
  }

  /// PUT /api/appointments/{id} - Update an appointment
  Future<Map<String, dynamic>> updateAppointmentApi(
    String id, {
    String? start,
    String? end,
    String? status,
    String? type,
    String? description,
    String? reasonCode,
    String? locationId,
    bool? walkin,
    String? previousAppointmentId,
    Map<String, dynamic>? preVisit,
    String? country,
  }) async {
    try {
      final accessToken = _getAccessTokenOrThrow();

      final body = <String, dynamic>{};
      if (start != null) body['start'] = start;
      if (end != null) body['end'] = end;
      if (status != null) body['status'] = status;
      if (type != null) body['type'] = type;
      if (description != null) body['description'] = description;
      if (reasonCode != null) body['reasonCode'] = reasonCode;
      if (organizationId.value.isNotEmpty)
        body['organizationId'] = organizationId.value;
      if (locationId != null) body['locationId'] = locationId;
      if (walkin != null) body['walkin'] = walkin;
      if (previousAppointmentId != null)
        body['previousAppointmentId'] = previousAppointmentId;
      if (preVisit != null) body['preVisit'] = preVisit;
      if (country != null) body['country'] = country;

      final url = Uri.parse('$_baseUrl/api/appointments/$id');
      final response = await http.put(
        url,
        headers: _getHeaders(accessToken),
        body: jsonEncode(body),
      );

      print('📡 Update Appointment Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        await loadAppointments();
        return jsonData;
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please log in again.');
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error updating appointment: $e');
      rethrow;
    }
  }

  /// POST /api/appointments/{id}/cancel - Cancel an appointment
  Future<Map<String, dynamic>> cancelAppointmentApi(String id,
      {String? reason, String? country}) async {
    try {
      final accessToken = _getAccessTokenOrThrow();

      final body = <String, dynamic>{};
      if (reason != null) body['reason'] = reason;
      if (country != null) body['country'] = country;

      final url = Uri.parse('$_baseUrl/api/appointments/$id/cancel');
      final response = await http.post(
        url,
        headers: _getHeaders(accessToken),
        body: jsonEncode(body),
      );

      print('📡 Cancel Appointment Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        await loadAppointments();
        return jsonData;
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please log in again.');
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error cancelling appointment: $e');
      rethrow;
    }
  }

  /// POST /api/appointments/{id}/reschedule - Reschedule an appointment
  Future<Map<String, dynamic>> rescheduleAppointmentApi(
    String id, {
    required String start,
    required String end,
    String? country,
  }) async {
    try {
      final accessToken = _getAccessTokenOrThrow();

      final body = <String, dynamic>{
        'start': start,
        'end': end,
      };
      if (country != null) body['country'] = country;

      final url = Uri.parse('$_baseUrl/api/appointments/$id/reschedule');
      final response = await http.post(
        url,
        headers: _getHeaders(accessToken),
        body: jsonEncode(body),
      );

      print('📡 Reschedule Appointment Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        await loadAppointments();
        return jsonData;
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please log in again.');
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error rescheduling appointment: $e');
      rethrow;
    }
  }

  /// GET /api/appointments/available-slots - Get occupied slots for a practitioner on a date
  Future<Map<String, dynamic>> getAvailableSlots({
    required String practitionerId,
    required String date,
    String? country,
  }) async {
    try {
      final accessToken = _getAccessTokenOrThrow();

      final queryParams = <String, String>{
        'practitionerId': practitionerId,
        'date': date,
      };
      if (country != null) queryParams['country'] = country;

      final url = Uri.parse('$_baseUrl/api/appointments/available-slots')
          .replace(queryParameters: queryParams);
      final response = await http.get(url, headers: _getHeaders(accessToken));

      print('📡 Available Slots Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please log in again.');
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error fetching available slots: $e');
      rethrow;
    }
  }

  /// POST /api/appointments/{id}/approve - Approve an appointment request
  Future<Map<String, dynamic>> approveAppointment(String id,
      {String? country}) async {
    try {
      final accessToken = _getAccessTokenOrThrow();

      final body = <String, dynamic>{};
      if (country != null) body['country'] = country;

      final url = Uri.parse('$_baseUrl/api/appointments/$id/approve');
      final response = await http.post(
        url,
        headers: _getHeaders(accessToken),
        body: jsonEncode(body),
      );

      print('📡 Approve Appointment Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        await loadAppointments();
        return jsonData;
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please log in again.');
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error approving appointment: $e');
      rethrow;
    }
  }

  /// POST /api/appointments/{id}/reject - Reject an appointment request
  Future<Map<String, dynamic>> rejectAppointment(String id,
      {String? reason, String? country}) async {
    try {
      final accessToken = _getAccessTokenOrThrow();

      final body = <String, dynamic>{};
      if (reason != null) body['reason'] = reason;
      if (country != null) body['country'] = country;

      final url = Uri.parse('$_baseUrl/api/appointments/$id/reject');
      final response = await http.post(
        url,
        headers: _getHeaders(accessToken),
        body: jsonEncode(body),
      );

      print('📡 Reject Appointment Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        await loadAppointments();
        return jsonData;
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please log in again.');
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error rejecting appointment: $e');
      rethrow;
    }
  }

  /// GET /api/appointments/{id}/students - List students in a group appointment
  Future<Map<String, dynamic>> getAppointmentStudentsApi(String id,
      {String? country}) async {
    try {
      final accessToken = _getAccessTokenOrThrow();

      final queryParams = <String, String>{};
      if (country != null) queryParams['country'] = country;

      final url = Uri.parse('$_baseUrl/api/appointments/$id/students').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final response = await http.get(url, headers: _getHeaders(accessToken));

      print('📡 Get Appointment Students Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please log in again.');
      } else if (response.statusCode == 404) {
        throw Exception('Appointment not found.');
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error fetching appointment students: $e');
      rethrow;
    }
  }

  /// POST /api/appointments/{id}/students/{studentId}/complete - Mark a student as complete
  Future<Map<String, dynamic>> completeStudentInAppointment(
    String appointmentId,
    String studentId, {
    String? assessment,
    String? plan,
    String? country,
  }) async {
    try {
      final accessToken = _getAccessTokenOrThrow();

      final body = <String, dynamic>{};
      if (assessment != null) body['assessment'] = assessment;
      if (plan != null) body['plan'] = plan;
      if (country != null) body['country'] = country;

      final url = Uri.parse(
          '$_baseUrl/api/appointments/$appointmentId/students/$studentId/complete');
      final response = await http.post(
        url,
        headers: _getHeaders(accessToken),
        body: jsonEncode(body),
      );

      print('📡 Complete Student Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        // Update local status
        final key = '${appointmentId}_$studentId';
        appointmentStatuses[key] = AppointmentStatus.done;
        return jsonData;
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please log in again.');
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error completing student in appointment: $e');
      rethrow;
    }
  }

  /// GET /api/appointments/{id}/print - Get printable appointment summary
  Future<Map<String, dynamic>> getAppointmentPrintData(String id,
      {String? country}) async {
    try {
      final accessToken = _getAccessTokenOrThrow();

      final queryParams = <String, String>{};
      if (country != null) queryParams['country'] = country;

      final url = Uri.parse('$_baseUrl/api/appointments/$id/print').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final response = await http.get(url, headers: _getHeaders(accessToken));

      print('📡 Print Appointment Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please log in again.');
      } else if (response.statusCode == 404) {
        throw Exception('Appointment not found.');
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error getting appointment print data: $e');
      rethrow;
    }
  }

  /// POST /api/appointments/{id}/check-in - Check-in an appointment
  Future<Map<String, dynamic>> checkInAppointment(String id,
      {String? country}) async {
    try {
      final accessToken = _getAccessTokenOrThrow();

      final body = <String, dynamic>{};
      if (country != null) body['country'] = country;

      final url = Uri.parse('$_baseUrl/api/appointments/$id/check-in');
      final response = await http.post(
        url,
        headers: _getHeaders(accessToken),
        body: jsonEncode(body),
      );

      print('📡 Check-in Appointment Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        await loadAppointments();
        return jsonData;
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please log in again.');
      } else if (response.statusCode == 404) {
        throw Exception('Appointment not found.');
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error checking in appointment: $e');
      rethrow;
    }
  }

  /// GET /api/appointments/export - Export appointments as CSV, Excel, or PDF
  Future<List<int>> exportAppointments({
    String format = 'excel',
    String? patientId,
    String? practitionerId,
    String? status,
    String? type,
    String? startAfter,
    String? startBefore,
    String? country,
  }) async {
    try {
      final accessToken = _getAccessTokenOrThrow();

      final queryParams = <String, String>{
        'format': format,
      };
      if (organizationId.value.isNotEmpty)
        queryParams['organizationId'] = organizationId.value;
      if (patientId != null) queryParams['patientId'] = patientId;
      if (practitionerId != null)
        queryParams['practitionerId'] = practitionerId;
      if (status != null) queryParams['status'] = status;
      if (type != null) queryParams['type'] = type;
      if (startAfter != null) queryParams['startAfter'] = startAfter;
      if (startBefore != null) queryParams['startBefore'] = startBefore;
      if (country != null) queryParams['country'] = country;

      final url = Uri.parse('$_baseUrl/api/appointments/export')
          .replace(queryParameters: queryParams);
      final response = await http.get(url, headers: _getHeaders(accessToken));

      print('📡 Export Appointments Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return response.bodyBytes.toList();
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please log in again.');
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error exporting appointments: $e');
      rethrow;
    }
  }
}
