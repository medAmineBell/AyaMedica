import 'package:flutter/material.dart';
import 'package:flutter_getx_app/config/app_config.dart';
import 'package:flutter_getx_app/models/appointment.dart';
import 'package:flutter_getx_app/models/appointment_models.dart';
import 'package:flutter_getx_app/models/health_status.dart';
import 'package:flutter_getx_app/models/vital_signs_data.dart';
import 'package:flutter_getx_app/models/student.dart';
import 'package:flutter_getx_app/controllers/appointment_scheduling_controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/appointment_history_model.dart';
import '../utils/storage_service.dart';
import 'package:flutter_getx_app/utils/app_snackbar.dart';

enum AppointmentHistoryState { loading, success, error, empty }

class AppointmentHistoryController extends GetxController {
  final StorageService _storageService = Get.find();

  // Reactive variables
  final RxList<AppointmentHistory> allAppointments =
      <AppointmentHistory>[].obs;
  final RxList<AppointmentHistory> displayedAppointments =
      <AppointmentHistory>[].obs;
  final Rx<AppointmentHistoryState> state =
      AppointmentHistoryState.loading.obs;
  final RxBool isLoading = false.obs;
  var isSubmitting = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'booked'.obs;

  // Country and Branch IDs
  final RxString country = ''.obs;
  final RxString branchId = ''.obs;

  // Date filter - defaults to today
  final Rx<DateTime> startDate = DateTime.now().obs;
  final Rx<DateTime> endDate = DateTime.now().obs;

  // Status counts
  final RxInt checkedInCount = 0.obs;
  final RxInt checkedOutCount = 0.obs;
  final RxInt cancelledCount = 0.obs;

  // View students state
  final Rxn<Appointment> viewingAppointment = Rxn<Appointment>();
  final RxBool isLoadingStudents = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadIds();
    fetchAppointmentHistory();
  }

  /// Load country and branch ID from storage
  void _loadIds() {
    final branchData = _storageService.getSelectedBranchData();
    if (branchData != null) {
      branchId.value = branchData['id'] ?? '';
      country.value = branchData['country'] as String? ?? 'EG';
    }
  }

  /// GET - Fetch appointment history from API
  Future<void> fetchAppointmentHistory() async {
    if (branchId.value.isEmpty) {
      state.value = AppointmentHistoryState.empty;
      return;
    }

    try {
      isLoading.value = true;
      state.value = AppointmentHistoryState.loading;

      final accessToken = _storageService.getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      final sd = startDate.value;
      final ed = endDate.value;
      final startStr = '${sd.year}-${sd.month.toString().padLeft(2, '0')}-${sd.day.toString().padLeft(2, '0')}';
      final endStr = '${ed.year}-${ed.month.toString().padLeft(2, '0')}-${ed.day.toString().padLeft(2, '0')}';
      final url = Uri.parse(
        '${AppConfig.newBackendUrl}/api/appointment-sessions?country=${country.value}&branchId=${branchId.value}&startAfter=${startStr}T00:00:00Z&startBefore=${endStr}T23:59:59Z',
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
          final historyResponse =
              AppointmentHistoryResponse.fromJson(jsonData);

          allAppointments.assignAll(historyResponse.appointments);
          displayedAppointments.assignAll(historyResponse.appointments);

          _calculateStatusCounts();

          state.value = displayedAppointments.isEmpty
              ? AppointmentHistoryState.empty
              : AppointmentHistoryState.success;

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
      state.value = AppointmentHistoryState.error;
      appSnackbar(
        'Error',
        'Failed to load appointments: ${e.toString()}',
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
    checkedInCount.value = allAppointments
        .where((a) => a.appointmentStatus.toLowerCase() == 'booked')
        .length;
    checkedOutCount.value = allAppointments
        .where((a) => a.appointmentStatus.toLowerCase() == 'fulfilled')
        .length;
    cancelledCount.value = allAppointments
        .where((a) => a.appointmentStatus.toLowerCase() == 'cancelled')
        .length;
  }

  /// SEARCH - Filter appointments by query
  void searchAppointments(String query) {
    searchQuery.value = query.trim().toLowerCase();
    _applySearchAndFilter();
  }

  /// FILTER - Filter by status
  void filterByStatus(String filter) {
    selectedFilter.value = filter;
    _applySearchAndFilter();
  }

  /// Apply search and filter logic
  void _applySearchAndFilter() {
    List<AppointmentHistory> filtered = List.from(allAppointments);

    // Apply status filter
    if (selectedFilter.value != 'all') {
      filtered = filtered.where((appointment) {
        return appointment.appointmentStatus.toLowerCase() ==
            selectedFilter.value.toLowerCase();
      }).toList();
    }

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((appointment) {
        final grade = appointment.gradeName.toLowerCase();
        final className = appointment.className.toLowerCase();
        final type = appointment.formattedType.toLowerCase();
        final patientAid = (appointment.onePatientAid ?? '').toLowerCase();
        final disease = (appointment.disease ?? '').toLowerCase();

        return grade.contains(searchQuery.value) ||
            className.contains(searchQuery.value) ||
            type.contains(searchQuery.value) ||
            patientAid.contains(searchQuery.value) ||
            disease.contains(searchQuery.value);
      }).toList();
    }

    displayedAppointments.assignAll(filtered);

    state.value = displayedAppointments.isEmpty
        ? AppointmentHistoryState.empty
        : AppointmentHistoryState.success;
  }

  /// Delete an appointment session via API
  Future<bool> deleteAppointment(String id) async {
    try {
      isSubmitting.value = true;

      final accessToken = _storageService.getAccessToken();
      if (accessToken == null) throw Exception('No access token found');

      final url = Uri.parse(
        '${AppConfig.newBackendUrl}/api/appointment-sessions/$id',
      );

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        appSnackbar(
          'Success',
          'Appointment deleted successfully',
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
        );
        await fetchAppointmentHistory();
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'HTTP ${response.statusCode}');
      }
    } catch (e) {
      appSnackbar(
        'Error',
        'Failed to delete appointment: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Update an appointment session via API
  Future<bool> updateAppointment(
      String id, Map<String, dynamic> body) async {
    try {
      isSubmitting.value = true;

      final accessToken = _storageService.getAccessToken();
      if (accessToken == null) throw Exception('No access token found');

      final url = Uri.parse(
        '${AppConfig.newBackendUrl}/api/appointment-sessions/$id',
      );

      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        appSnackbar(
          'Success',
          'Appointment updated successfully',
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
        );
        await fetchAppointmentHistory();
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'HTTP ${response.statusCode}');
      }
    } catch (e) {
      appSnackbar(
        'Error',
        'Failed to update appointment: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Cancel an appointment session via API
  Future<bool> cancelAppointment(String id, String reason) async {
    try {
      isSubmitting.value = true;

      final accessToken = _storageService.getAccessToken();
      if (accessToken == null) throw Exception('No access token found');

      final url = Uri.parse(
        '${AppConfig.newBackendUrl}/api/appointment-sessions/$id/cancel',
      );

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'reason': reason}),
      );

      if (response.statusCode == 200) {
        appSnackbar(
          'Success',
          'Appointment cancelled successfully',
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
        );
        await fetchAppointmentHistory();
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'HTTP ${response.statusCode}');
      }
    } catch (e) {
      appSnackbar(
        'Error',
        'Failed to cancel appointment: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Change date range and reload appointments
  Future<void> changeDateRange(DateTime start, DateTime end) async {
    startDate.value = start;
    endDate.value = end;
    await fetchAppointmentHistory();
  }

  /// Refresh appointments
  void refreshAppointments() {
    fetchAppointmentHistory();
  }

  /// Check if filters are active
  bool get hasActiveFilters =>
      searchQuery.value.isNotEmpty || selectedFilter.value != 'all';

  /// Get active filter count for badge
  int get activeFilterCount {
    int count = 0;
    if (selectedFilter.value != 'all') count++;
    if (searchQuery.value.isNotEmpty) count++;
    return count;
  }

  /// Fetch patients for an appointment session and show the student table
  Future<void> viewAppointmentStudents(AppointmentHistory appointment) async {
    try {
      isLoadingStudents.value = true;

      final accessToken = _storageService.getAccessToken();
      if (accessToken == null) throw Exception('No access token found');

      // Fetch patients from API
      final url = Uri.parse(
        '${AppConfig.newBackendUrl}/api/appointment-sessions/${appointment.id}/patients',
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }

      final jsonData = jsonDecode(response.body);
      if (jsonData['success'] != true) {
        throw Exception('API returned success: false');
      }

      final patients = jsonData['data'] as List;

      // Build students directly from patient data
      final students = patients.map((patient) {
        final given = patient['nameGiven'] as String? ?? '';
        final family = patient['nameFamily'] as String? ?? '';
        final fullName = '$given $family'.trim();
        final aid = patient['patientAid'] as String? ?? '';
        final photo = patient['photo'] as String?;

        return Student(
          id: patient['id'] ?? aid,
          name: fullName.isNotEmpty ? fullName : aid,
          imageUrl: photo,
          avatarColor: Color((fullName.hashCode & 0x00FFFFFF) | 0xFF000000),
          aid: aid,
          grade: appointment.gradeName,
          className: appointment.className,
          classId: appointment.classId,
        );
      }).toList();

      // Set initial statuses from API data into the scheduling controller
      final schedulingController = Get.find<AppointmentSchedulingController>();
      for (final patient in patients) {
        final studentId = patient['id'] ?? '';
        final patientStatus = patient['patientStatus'] as String? ?? '';
        final patientNote = patient['patientNote'] as String? ?? '';
        final key = '${appointment.id}_$studentId';

        if (patientStatus == 'checked') {
          schedulingController.appointmentStatuses[key] = AppointmentStatus.done;
        } else if (patientStatus == 'absent') {
          schedulingController.appointmentStatuses[key] = AppointmentStatus.absent;
        } else if (patientStatus == 'issue') {
          schedulingController.appointmentStatuses[key] = AppointmentStatus.notDone;
        }
        if (patientNote.isNotEmpty) {
          schedulingController.appointmentNotes[key] = patientNote;
        }

        // Restore hygiene statuses for hygiene appointments
        const hygieneFields = {
          'Hair': 'hair',
          'Ears': 'ears',
          'Nails': 'nails',
          'Teeth': 'teeth',
          'Uniform': 'uniform',
        };
        for (final entry in hygieneFields.entries) {
          final statusVal = patient['${entry.value}Status'] as String?;
          if (statusVal != null && statusVal.isNotEmpty) {
            final reasonVal = patient['${entry.value}Reason'] as String? ?? '';
            final hKey = '${appointment.id}_${studentId}_${entry.key}';
            if (statusVal == 'good') {
              schedulingController.setHealthStatus(hKey, HealthStatus.good);
            } else if (statusVal == 'issue') {
              schedulingController.setHealthStatusWithIssue(
                  hKey, HealthStatus.issue, reasonVal);
            }
          }
        }

        // Restore vital signs data
        schedulingController.vitalSignsData[key] = VitalSignsData.fromJson(patient);
      }

      schedulingController.vitalSignsData.refresh();
      schedulingController.healthStatuses.refresh();
      schedulingController.appointmentStatuses.refresh();

      // Map appointment type for display
      String displayType;
      switch (appointment.appointmentType.toLowerCase()) {
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
          displayType = appointment.formattedType;
      }

      // Convert to Appointment model for StudentTableWidget
      viewingAppointment.value = Appointment(
        id: appointment.id,
        type: displayType,
        allStudents: true,
        date: appointment.appointmentDate,
        time: '${appointment.appointmentDate.hour.toString().padLeft(2, '0')}:${appointment.appointmentDate.minute.toString().padLeft(2, '0')}',
        disease: appointment.disease ?? '',
        diseaseType: '',
        grade: appointment.gradeName,
        className: appointment.className,
        doctor: '',
        selectedStudents: students,
        status: appointment.appointmentStatus.toLowerCase() == 'fulfilled'
            ? AppointmentStatus.done
            : AppointmentStatus.notDone,
      );
    } catch (e) {
      appSnackbar(
        'Error',
        'Failed to load appointment students: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingStudents.value = false;
    }
  }

  /// Go back from student view to appointment list
  void backToList() {
    viewingAppointment.value = null;
  }
}
