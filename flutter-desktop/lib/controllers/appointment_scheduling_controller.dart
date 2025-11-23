import 'package:flutter/material.dart';
import 'package:flutter_getx_app/models/appointment.dart';
import 'package:flutter_getx_app/models/appointment_models.dart';
import 'package:flutter_getx_app/models/health_status.dart';
import 'package:flutter_getx_app/models/student.dart';
import 'package:flutter_getx_app/utils/medplum_service.dart';
import 'package:get/get.dart';

enum AppointmentScreenState { loading, error, success, empty }

enum TableViewMode {
  appointments, // Show appointments as rows
  appointmentStudents, // Show individual appointment-student combinations
  appointmentStudentsNotify, // Show individual appointment-student combinations
  medicalCheckup, // Show medical checkup table
  chronicDiseases, // Show chronic diseases table
}

class AppointmentSchedulingController extends GetxController {
  final Rxn<Appointment> selectedAppointmentForStudents = Rxn<Appointment>();
  final MedplumService _medplumService = Get.find<MedplumService>();

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
    loadAppointments();
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

      print('🔄 Loading appointments from API...');

      // Step 1: Get organization location
      final locationResult = await _medplumService.fetchOrganizationLocation();
      if (!locationResult['success']) {
        throw Exception(
            'Failed to get organization location: ${locationResult['message']}');
      }

      final locationId = locationResult['locationId'] as String;
      print('📍 Location ID: $locationId');

      // Step 2: Get appointments by location
      final appointmentsResult =
          await _medplumService.getAppointmentsByLocation(
        locationId: locationId,
        startDate: startDate,
        endDate: endDate,
      );

      if (!appointmentsResult['success']) {
        throw Exception(
            'Failed to get appointments: ${appointmentsResult['message']}');
      }

      final fhirAppointments =
          appointmentsResult['appointments'] as List<dynamic>;
      print('📅 Found ${fhirAppointments.length} appointments from API');

      // Step 3: Convert FHIR appointments to our Appointment model
      appointments.clear();
      for (final fhirAppointment in fhirAppointments) {
        try {
          final appointment = _convertFhirToAppointment(fhirAppointment);
          if (appointment != null) {
            appointments.add(appointment);
          }
        } catch (e) {
          print('⚠️ Error converting FHIR appointment: $e');
        }
      }

      print('✅ Successfully loaded ${appointments.length} appointments');

      final bool hasAppointments = appointments.isNotEmpty;
      if (hasAppointments) {
        screenState.value = AppointmentScreenState.success;
      } else {
        screenState.value = AppointmentScreenState.empty;
      }
    } catch (e) {
      print('❌ Error loading appointments: $e');
      errorMessage.value = e.toString();
      screenState.value = AppointmentScreenState.error;
    }
  }

  // Convert FHIR appointment to our Appointment model
  Appointment? _convertFhirToAppointment(Map<String, dynamic> fhirAppointment) {
    try {
      final id = fhirAppointment['id'] as String?;
      final status = fhirAppointment['status'] as String?;
      final start = fhirAppointment['start'] as String?;
      final participants = fhirAppointment['participant'] as List<dynamic>?;

      if (id == null) return null;

      // Parse start and end times
      DateTime? startDateTime;
      String timeString = '';

      if (start != null) {
        startDateTime = DateTime.tryParse(start);
        if (startDateTime != null) {
          timeString =
              '${startDateTime.hour.toString().padLeft(2, '0')}:${startDateTime.minute.toString().padLeft(2, '0')}';
        }
      }

      // Extract appointment type from coding
      String appointmentType = 'General';
      final appointmentTypeData = fhirAppointment['appointmentType'];
      if (appointmentTypeData != null &&
          appointmentTypeData['coding'] != null) {
        final coding = appointmentTypeData['coding'] as List<dynamic>;
        if (coding.isNotEmpty) {
          final firstCoding = coding[0] as Map<String, dynamic>;
          appointmentType =
              firstCoding['display'] ?? firstCoding['code'] ?? 'General';
        }
      }

      // Extract participants (patients, practitioners, etc.)
      final List<Student> selectedStudents = [];
      String doctorName = 'Unknown Doctor';

      if (participants != null) {
        for (final participant in participants) {
          final actor = participant['actor'];
          if (actor != null) {
            final reference = actor['reference'] as String?;
            final display = actor['display'] as String?;

            if (reference != null) {
              if (reference.startsWith('Patient/')) {
                // Create a student from patient data
                final student = Student(
                  id: reference.replaceFirst('Patient/', ''),
                  name: display ?? 'Unknown Patient',
                  avatarColor: Color(0xFF6366F1),
                  dateOfBirth: DateTime.now()
                      .subtract(const Duration(days: 365 * 10)), // Default age
                  bloodType: 'Unknown',
                  weightKg: 0,
                  heightCm: 0,
                  goToHospital: 'Unknown',
                  firstGuardianName: 'Unknown',
                  firstGuardianPhone: 'Unknown',
                  firstGuardianEmail: 'Unknown',
                  firstGuardianStatus: 'Unknown',
                  secondGuardianName: 'Unknown',
                  secondGuardianPhone: 'Unknown',
                  secondGuardianEmail: 'Unknown',
                  secondGuardianStatus: 'Unknown',
                  city: 'Unknown',
                  street: 'Unknown',
                  zipCode: 'Unknown',
                  province: 'Unknown',
                  insuranceCompany: 'Unknown',
                  policyNumber: 'Unknown',
                  passportIdNumber: 'Unknown',
                  nationality: 'Unknown',
                  nationalId: 'Unknown',
                  gender: 'Unknown',
                  phoneNumber: 'Unknown',
                  email: 'Unknown',
                );
                selectedStudents.add(student);
              } else if (reference.startsWith('Practitioner/')) {
                doctorName = display ?? 'Unknown Doctor';
              }
            }
          }
        }
      }

      // Convert FHIR status to our AppointmentStatus
      AppointmentStatus appointmentStatus;
      switch (status?.toLowerCase()) {
        case 'confirmed':
        case 'arrived':
          appointmentStatus = AppointmentStatus.notDone;
          break;
        case 'fulfilled':
        case 'completed':
          appointmentStatus = AppointmentStatus.done;
          break;
        case 'cancelled':
          appointmentStatus = AppointmentStatus.cancelled;
          break;
        case 'pending':
        default:
          appointmentStatus = AppointmentStatus.notDone;
          break;
      }

      return Appointment(
        id: id,
        type: appointmentType,
        allStudents: false,
        date: startDateTime ?? DateTime.now(),
        time: timeString,
        disease: appointmentType,
        grade: 'Unknown Grade',
        className: 'Unknown Class',
        doctor: doctorName,
        selectedStudents: selectedStudents,
        diseaseType: '',
        status: appointmentStatus,
      );
    } catch (e) {
      print('❌ Error converting FHIR appointment: $e');
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

  Future<void> createAppointment(Appointment appointment) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Generate a simple ID
      appointment.id = (appointments.length + 1).toString();
      appointments.add(appointment);

      // Initialize statuses for new appointment students
      for (var student in appointment.selectedStudents) {
        final key = '${appointment.id}_${student.id}';
        appointmentStatuses[key] = AppointmentStatus.notDone;
      }

      // Reset pagination when new appointments are added
      resetPagination();

      screenState.value = AppointmentScreenState.success;
    } catch (e) {
      errorMessage.value = e.toString();
      screenState.value = AppointmentScreenState.error;
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
}
