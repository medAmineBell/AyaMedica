import 'package:flutter/material.dart';
import 'package:flutter_getx_app/config/app_config.dart';
import 'package:flutter_getx_app/controllers/appointment_history_controller.dart';
import 'package:flutter_getx_app/controllers/home_controller.dart';
import 'package:flutter_getx_app/models/appointment_history_model.dart';
import 'package:flutter_getx_app/models/appointment_models.dart';
import 'package:flutter_getx_app/models/student.dart';
import 'package:flutter_getx_app/controllers/creating_appointment_controller.dart';
import 'package:flutter_getx_app/screens/appointmentScheduling/widgets/creating_appointment_dialog.dart';
import 'package:flutter_getx_app/screens/appointmentScheduling/widgets/notify_parents_dialog.dart';
import 'package:flutter_getx_app/utils/api_service.dart';
import 'package:flutter_getx_app/utils/storage_service.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:convert';
import '../../../models/appointment.dart';
import '../../../controllers/appointment_scheduling_controller.dart';
import '../screens/appointmentScheduling/widgets/parents_notification_dialog.dart';

class CreateAppointmentController extends GetxController {
  final AppointmentSchedulingController appointmentController = Get.find();
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();

  final _formKey = GlobalKey<FormState>();
  late final List<Map<String, dynamic>> _appointmentTypes;
  final RxList<String> _doctors = <String>[].obs;
  final RxList<String> _diseases = <String>[].obs;
  final RxList<String> _vaccinationTypesList = <String>[].obs;

  // Predefined disease categories for Checkup/Follow-Up
  static const List<String> predefinedDiseases = [
    'General',
    'Hygiene',
    'Diabetes',
    'Blood pressure',
    'Cardiovascular',
    'BMI',
  ];

  // "Other" disease text field
  final otherDiseaseText = ''.obs;
  final otherDiseaseController = TextEditingController();
  final RxList<String> _classes = <String>[].obs;
  final RxList<String> _grades = <String>[].obs;
  final RxBool isLoadingDiseases = false.obs;
  final RxBool isLoadingVaccinations = false.obs;
  final RxList<Student> _students = <Student>[].obs;
  final RxBool isLoadingClasses = false.obs;
  final RxBool isLoadingStudents = false.obs;

  // Regular appointment fields
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  final Rx<TimeOfDay?> selectedTime = Rx<TimeOfDay?>(null);

  // Vaccination: Last confirmation date fields
  final Rx<DateTime?> lastConfirmationDate = Rx<DateTime?>(null);
  final Rx<TimeOfDay?> lastConfirmationTime = Rx<TimeOfDay?>(null);
  final RxString selectedType = 'Checkup'.obs;
  final RxString selectedOption = 'all'.obs;
  final RxString selectedDateTimeOption = 'addDate'.obs; // 'addDate' or 'startNow'
  final Rx<String?> selectedClass = Rx<String?>(null);
  final Rx<String?> selectedGrade = Rx<String?>(null);
  final Rx<String?> selectedDisease = Rx<String?>(null);
  final Rx<String?> selectedDoctor = Rx<String?>(null);
  final Rx<String?> selectedVaccinationType = Rx<String?>(null);
  final RxList<Student> selectedStudents = <Student>[].obs;

  // Walk-In specific fields
  final aidController = TextEditingController();
  final Rx<Student?> walkInSelectedStudent = Rx<Student?>(null);
  final RxList<Student> filteredStudentsForWalkIn = <Student>[].obs;
  bool _isSelectingStudent = false;

  // Getters for easy access
  GlobalKey<FormState> get formKey => _formKey;
  List<Map<String, dynamic>> get appointmentTypes => _appointmentTypes;
  RxList<String> get doctors => _doctors;
  RxList<String> get diseases => _diseases;
  RxList<String> get classes => _classes;
  RxList<String> get grades => _grades;
  RxList<String> get vaccinationTypes => _vaccinationTypesList;
  RxList<Student> get students => _students;

  @override
  void onInit() {
    super.onInit();
    
    // Initialize lists
    _appointmentTypes = _buildAppointmentTypes();
    _loadDoctorsFromHome();
    fetchDiseases('');
    fetchVaccinations('');

    // Load grades from branch data
    _loadGradesFromBranch();
    // Load classes from API
    _loadClassesFromApi();
    // Load students from API
    _loadStudentsFromApi().then((_) {
      filteredStudentsForWalkIn.assignAll(_students);
    });

    // Listen to grade and class changes for Walk-In filtering
    ever(selectedGrade, (_) => _filterStudentsForWalkIn());
    ever(selectedClass, (_) => _filterStudentsForWalkIn());
  }

  @override
  void onClose() {
    aidController.dispose();
    otherDiseaseController.dispose();
    super.onClose();
  }

  // Regular appointment methods
  void updateSelectedDate(DateTime? date) {
    selectedDate.value = date;
  }

  void updateSelectedTime(TimeOfDay? time) {
    selectedTime.value = time;
  }

  void updateSelectedType(String type) {
    selectedType.value = type;
    // Reset fields when switching between regular and walk-in
    if (type == 'Walk-In') {
      _resetWalkInFields();
    } else {
      _resetRegularFields();
    }
  }

  void updateSelectedOption(String option) {
    selectedOption.value = option;
  }

  void updateSelectedDateTimeOption(String option) {
    selectedDateTimeOption.value = option;
    // If "Start now" is selected, set current date and time
    if (option == 'startNow') {
      selectedDate.value = DateTime.now();
      selectedTime.value = TimeOfDay.now();
    }
  }

  void updateSelectedClass(String? className) {
    selectedClass.value = className;
    selectedStudents.clear();
    walkInSelectedStudent.value = null;
    // Clear search field
    aidController.clear();
    searchResults.clear();

    if (className != null) {
      _loadStudentsFromApi(
        grade: selectedGrade.value,
        studentClass: className,
      ).then((_) {
        if (selectedType.value != 'Walk-In') {
          selectedStudents.assignAll(_students);
        }
        filteredStudentsForWalkIn.assignAll(_students);
      });
    } else {
      filteredStudentsForWalkIn.clear();
    }
  }

  void updateSelectedGrade(String? grade) {
    selectedGrade.value = grade;
    // Reset class and student when grade changes
    selectedClass.value = null;
    walkInSelectedStudent.value = null;
    filteredStudentsForWalkIn.clear();
    // Clear search field
    aidController.clear();
    searchResults.clear();
  }

  void updateSelectedDisease(String? disease) {
    selectedDisease.value = disease;
  }

  void updateSelectedDoctor(String? doctor) {
    selectedDoctor.value = doctor;
  }

  void updateSelectedVaccinationType(String? vaccinationType) {
    selectedVaccinationType.value = vaccinationType;
  }

  void updateLastConfirmationDate(DateTime? date) {
    lastConfirmationDate.value = date;
  }

  void updateLastConfirmationTime(TimeOfDay? time) {
    lastConfirmationTime.value = time;
  }

  String get actionButtonText {
    if (selectedType.value == 'Walk-In' || selectedDateTimeOption.value == 'startNow') {
      return 'Start appointment';
    }
    return 'Add appointment';
  }

  /// Whether the form has all required fields filled for non-walk-in types
  bool get isFormValid {
    if (selectedType.value == 'Walk-In') return true;

    // Date/time required if "Add date" is selected
    if (selectedDateTimeOption.value == 'addDate') {
      if (selectedDate.value == null || selectedTime.value == null) return false;
    }

    // Disease required (either dropdown or other text field must have a value)
    if (selectedType.value != 'Vaccination') {
      final hasDropdown = selectedDisease.value != null && selectedDisease.value!.isNotEmpty;
      final hasOtherText = otherDiseaseText.value.trim().isNotEmpty;
      if (!hasDropdown && !hasOtherText) return false;
    }

    // Doctor required
    if (selectedDoctor.value == null || selectedDoctor.value!.isEmpty) return false;

    // Grade required
    if (selectedGrade.value == null || selectedGrade.value!.isEmpty) return false;

    // Class required
    if (selectedClass.value == null || selectedClass.value!.isEmpty) return false;

    // Students required
    if (selectedStudents.isEmpty) return false;

    return true;
  }

  void updateSelectedStudents(List<Student> students) {
    selectedStudents.value = students;
  }

  // Walk-In specific methods
  void updateWalkInSelectedStudent(Student? student) {
    _isSelectingStudent = true;
    walkInSelectedStudent.value = student;
    if (student != null) {
      aidController.text = student.name;
      _autoSelectGradeAndClass(student);
    }
    _isSelectingStudent = false;
  }

  // Search results shown under the search field
  final RxList<Student> searchResults = <Student>[].obs;
  final RxBool isSearching = false.obs;

  void searchByName(String name) {
    if (_isSelectingStudent) return;
    if (name.isEmpty) {
      searchResults.clear();
      isSearching.value = false;
      walkInSelectedStudent.value = null;
      return;
    }

    if (name.length < 2) return;

    // Reset grade/class when searching by name
    selectedGrade.value = null;
    selectedClass.value = null;
    filteredStudentsForWalkIn.clear();

    isSearching.value = true;
    _loadStudentsFromApi(search: name).then((_) {
      walkInSelectedStudent.value = null;
      searchResults.assignAll(_students);
      isSearching.value = false;
    });
  }

  void selectStudentFromSearch(Student student) {
    _isSelectingStudent = true;
    walkInSelectedStudent.value = student;
    aidController.text = student.name;
    searchResults.clear();
    filteredStudentsForWalkIn.assignAll([student]);
    _autoSelectGradeAndClass(student);
    _isSelectingStudent = false;
  }

  void removeWalkInSelectedStudent() {
    walkInSelectedStudent.value = null;
    aidController.clear();
  }

  void _filterStudentsForWalkIn() {
    if (_isSelectingStudent) return;
    _loadStudentsFromApi(
      grade: selectedGrade.value,
      studentClass: selectedClass.value,
    ).then((_) {
      walkInSelectedStudent.value = null;
      filteredStudentsForWalkIn.assignAll(_students);
    });
  }

  void _autoSelectGradeAndClass(Student student) {
    if (student.grade != null) selectedGrade.value = student.grade;
    if (student.className != null) selectedClass.value = student.className;
  }

  void _resetWalkInFields() {
    walkInSelectedStudent.value = null;
    aidController.clear();
    selectedGrade.value = null;
    selectedClass.value = null;
  }

  void _resetRegularFields() {
    selectedDate.value = null;
    selectedTime.value = null;
    selectedOption.value = 'all';
    selectedClass.value = null;
    selectedGrade.value = null;
    selectedDisease.value = null;
    otherDiseaseText.value = '';
    otherDiseaseController.clear();
    selectedDoctor.value = null;
    selectedVaccinationType.value = null;
    lastConfirmationDate.value = null;
    lastConfirmationTime.value = null;
    selectedStudents.clear();
  }

  // Map UI appointment type to API appointment type
  String _mapAppointmentTypeToApi(String uiType) {
    switch (uiType) {
      case 'Checkup':
        return 'checkup';
      case 'Follow-Up':
        return 'followup';
      case 'Vaccination':
        return 'vaccination';
      default:
        return uiType.toLowerCase();
    }
  }

  // Regular appointment creation
  Future<void> handleCreateAppointment() async {
    try {
      // Validate form and date/time first
      if (!(_formKey.currentState?.validate() ?? false) ||
          !_validateDateTime()) {
        return;
      }

      final branchData = _storageService.getSelectedBranchData();
      final branchId = branchData?['id'] as String? ?? '';
      final country = branchData?['country'] as String? ?? 'EG';

      // Combine date + time into ISO8601
      final date = selectedDate.value!;
      final time = selectedTime.value!;
      final combinedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute)
          .toUtc()
          .toIso8601String();

      final apiType = _mapAppointmentTypeToApi(selectedType.value);
      final reason = selectedType.value == 'Vaccination'
          ? (selectedVaccinationType.value ?? '')
          : (otherDiseaseText.value.trim().isNotEmpty
              ? otherDiseaseText.value.trim()
              : (selectedDisease.value ?? ''));

      final body = <String, dynamic>{
        'country': country,
        'branchId': branchId,
        'appointmentDate': combinedDateTime,
        'appointmentType': apiType,
        'reason': reason,
        'gradeName': selectedGrade.value ?? '',
        'gradeId': selectedGrade.value ?? '',
        'className': selectedClass.value ?? '',
        'classId': selectedStudents.isNotEmpty ? (selectedStudents.first.classId ?? '') : '',
        'enableNotification': true,
      };

      // Use the appropriate patients array based on reason
      const vitalSignsDiseases = ['diabetes', 'blood pressure', 'cardiovascular', 'bmi'];
      if (vitalSignsDiseases.contains(reason.toLowerCase()) && apiType == 'checkup') {
        body['vitalSignsPatients'] = selectedStudents.map((s) => {
          'patientAid': s.aid ?? '',
          'patientNote': '',
          'patientStatus': 'pending',
          'bloodGlucose': '',
          'bloodPressure': '',
          'heartRate': '',
          'medication': '',
          'administrationForm': '',
          'doze': '',
          'unit': '',
          'presence': '',
          'height': '',
          'weight': '',
          'note': '',
          'bmiResult': '',
        }).toList();
      } else if (reason.toLowerCase() == 'hygiene' && apiType == 'checkup') {
        body['hygienePatients'] = selectedStudents.map((s) => {
          'patientAid': s.aid ?? '',
          'patientNote': '',
          'patientStatus': 'pending',
          'hairStatus': '',
          'hairReason': '',
          'earsStatus': '',
          'earsReason': '',
          'nailsStatus': '',
          'nailsReason': '',
          'teethStatus': '',
          'teethReason': '',
          'uniformStatus': '',
          'uniformReason': '',
        }).toList();
      } else {
        body['patients'] = selectedStudents.map((s) => {
          'patientAid': s.aid ?? '',
          'patientNote': '',
          'patientStatus': 'pending',
        }).toList();
      }

      // Add vaccination-specific field
      if (selectedType.value == 'Vaccination' && lastConfirmationDate.value != null) {
        final lcd = lastConfirmationDate.value!;
        final lct = lastConfirmationTime.value;
        final combinedLastConfirmation = lct != null
            ? DateTime(lcd.year, lcd.month, lcd.day, lct.hour, lct.minute).toUtc().toIso8601String()
            : DateTime(lcd.year, lcd.month, lcd.day).toUtc().toIso8601String();
        body['vaccineLastConfirmationDate'] = combinedLastConfirmation;
      }

      // Create appointment object for post-creation logic (notifications etc.)
      final appointment = Appointment(
        type: selectedType.value,
        allStudents: selectedOption.value == 'all',
        date: selectedDate.value ?? DateTime.now(),
        time: _formatTime(selectedTime.value),
        disease: reason,
        diseaseType: '',
        grade: selectedGrade.value ?? '',
        className: selectedClass.value ?? '',
        doctor: selectedDoctor.value ?? '',
        selectedStudents: selectedStudents,
        status: selectedType.value == 'Vaccination'
            ? AppointmentStatus.pendingApproval
            : AppointmentStatus.notDone,
      );

      // Close the form dialog
      Get.back();

      // Wait for the form dialog to fully close before showing progress
      await Future.delayed(const Duration(milliseconds: 300));

      // Initialize progress controller
      Get.put(CreatingAppointmentController());
      final progressController = Get.find<CreatingAppointmentController>();
      progressController.updateProgress(0.2);

      // Show loading dialog
      Get.dialog(
        const CreatingAppointmentDialog(),
        barrierDismissible: false,
      );

      // Gradually fill progress while waiting for API
      final progressTimer = Timer.periodic(
        const Duration(milliseconds: 150),
        (_) {
          if (progressController.progress < 0.9) {
            progressController.updateProgress(progressController.progress + 0.02);
          }
        },
      );

      print('📋 Create Appointment Request:');
      print('   URL: ${AppConfig.newBackendUrl}/api/appointment-sessions');
      print('   Body: ${jsonEncode(body)}');

      final accessToken = _storageService.getAccessToken();
      final url = Uri.parse('${AppConfig.newBackendUrl}/api/appointment-sessions');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(body),
      );

      progressTimer.cancel();

      print('📋 Create Appointment Response:');
      print('   Status: ${response.statusCode}');
      print('   Body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to create appointment session');
      }

      // Parse appointmentId from API response
      final responseData = jsonDecode(response.body);
      final createdAppointmentId = responseData['data']?['appointmentId'] as String?;
      appointment.id = createdAppointmentId;

      // Capture startNow flag before dialogs close
      final isStartNow = selectedDateTimeOption.value == 'startNow';

      progressController.updateProgress(1.0);
      await Future.delayed(const Duration(milliseconds: 300));

      // Close dialog and clean up
      Get.back();
      Get.delete<CreatingAppointmentController>();

      // Refresh appointments from server
      await appointmentController.loadAppointments();
      // Refresh appointment history list in background
      if (Get.isRegistered<AppointmentHistoryController>()) {
        Get.find<AppointmentHistoryController>().refreshAppointments();
      }

      // Show success
      Get.snackbar(
        'Success',
        'Appointment created successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
        duration: const Duration(seconds: 3),
      );

      if (isStartNow && createdAppointmentId != null) {
        // "Start Now" flow: navigate directly to the appropriate table view
        final matchedAppointment = appointmentController.appointments
            .firstWhereOrNull((a) => a.id == createdAppointmentId);
        if (matchedAppointment != null) {
          const vitalSignsDiseases = ['diabetes', 'blood pressure', 'cardiovascular', 'bmi'];
          if (matchedAppointment.disease.toLowerCase() == 'hygiene') {
            appointmentController.showMedicalCheckupView(matchedAppointment);
          } else if (vitalSignsDiseases.contains(matchedAppointment.disease.toLowerCase())) {
            appointmentController.showVitalSignsView(matchedAppointment);
          } else {
            appointmentController.showStudentsForAppointment(matchedAppointment);
          }
        }
      } else {
        // "Add Date" flow: show notification dialog
        if (selectedType.value == 'Vaccination') {
          bool? shouldNotify = await Get.dialog<bool>(
            ParentsNotificationDialog(
              onDismiss: () {
                Get.back();
              },
            ),
            barrierDismissible: false,
          );

          if (shouldNotify ?? false) {
            await _notifyParents(appointment);
          }
        } else {
          final shouldNotify = await showNotifyParentsDialog();

          if (shouldNotify ?? false) {
            await _notifyParents(appointment);
          }
        }
      }
    } catch (e) {
      // Clean up on error
      if (Get.isRegistered<CreatingAppointmentController>()) {
        Get.back();
        Get.delete<CreatingAppointmentController>();
      }

      Get.snackbar(
        'Error',
        'Failed to create appointment: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        duration: const Duration(seconds: 5),
      );
    }
  }

  Future<void> _notifyParents(Appointment appointment) async {
    if (appointment.id == null) return;

    // Show loading indicator
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final accessToken = _storageService.getAccessToken();
      if (accessToken == null) {
        Get.back();
        return;
      }

      final typeLabel = appointment.type == 'Follow-Up'
          ? 'Follow-up'
          : appointment.type == 'Checkup'
              ? 'Check-up'
              : appointment.type;

      final dateFormatted =
          DateFormat('yyyy-MM-dd').format(appointment.date);
      final timeFormatted = appointment.time;

      final title = '$typeLabel Appointment created';
      final body =
          'appointment has been created on $dateFormatted at $timeFormatted for ${appointment.disease}.';

      final url = Uri.parse(
          '${AppConfig.newBackendUrl}/api/appointment-sessions/${appointment.id}/notify-guardians');

      await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'title': title,
          'body': body,
          'data': {
            'appointmentId': appointment.id,
            'appointmentType':
                appointment.type == 'Follow-Up' ? 'followup' : 'checkup',
            'reason': appointment.disease,
          },
        }),
      );

      Get.back(); // Close loading
      Get.snackbar(
        'Success',
        'Parents notified successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
      );
    } catch (e) {
      Get.back(); // Close loading
      Get.snackbar(
        'Error',
        'Failed to notify parents: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }

  // Walk-In appointment creation

  Future<void> handleStartWalkInAppointment() async {
    if (!_validateWalkInForm()) return;

    try {
      final branchData = _storageService.getSelectedBranchData();
      final branchId = branchData?['id'] as String? ?? '';
      final country = branchData?['country'] as String? ?? 'EG';
      final student = walkInSelectedStudent.value!;

      final body = {
        'country': country,
        'branchId': branchId,
        'appointmentDate': DateTime.now().toUtc().toIso8601String(),
        'appointmentType': 'walkin',
        'gradeName': selectedGrade.value ?? '',
        'gradeId': selectedGrade.value ?? '',
        'className': selectedClass.value ?? '',
        'classId': student.classId ?? '',
        'onePatientAid': student.aid ?? '',
        'fullName': student.name,
        'enableNotification': true,
      };

      // Close the form dialog
      Get.back();

      // Wait for the form dialog to fully close before showing progress
      await Future.delayed(const Duration(milliseconds: 300));

      // Show progress dialog starting at 20%
      Get.put(CreatingAppointmentController());
      final progressController = Get.find<CreatingAppointmentController>();
      progressController.updateProgress(0.2);

      Get.dialog(
        const CreatingAppointmentDialog(),
        barrierDismissible: false,
      );

      // Gradually fill progress while waiting for API
      final progressTimer = Timer.periodic(
        const Duration(milliseconds: 150),
        (_) {
          if (progressController.progress < 0.9) {
            progressController.updateProgress(progressController.progress + 0.02);
          }
        },
      );

      print('📋 Create Walk-In Appointment Request:');
      print('   URL: ${AppConfig.newBackendUrl}/api/appointment-sessions');
      print('   Body: ${jsonEncode(body)}');

      final accessToken = _storageService.getAccessToken();
      final url = Uri.parse('${AppConfig.newBackendUrl}/api/appointment-sessions');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(body),
      );

      progressTimer.cancel();

      print('📋 Create Walk-In Appointment Response:');
      print('   Status: ${response.statusCode}');
      print('   Body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to create appointment session');
      }

      progressController.updateProgress(1.0);
      await Future.delayed(const Duration(milliseconds: 300));

      // Close progress dialog
      Get.back();
      Get.delete<CreatingAppointmentController>();

      // Refresh appointment history list and wait for it to complete
      if (Get.isRegistered<AppointmentHistoryController>()) {
        await Get.find<AppointmentHistoryController>().fetchAppointmentHistory();
      }

      // Navigate to appointment student profile for walk-in
      final homeController = Get.find<HomeController>();
      final responseData = jsonDecode(response.body);
      final data = responseData['data'] as Map<String, dynamic>?;
      final appointmentId = data?['appointmentId'] as String? ?? '';
      final medicalRecordId = data?['medicalRecordId'] as String?;

      final appointment = AppointmentHistory(
        id: appointmentId,
        country: country,
        branchId: branchId,
        createdByAid: '',
        createdAt: DateTime.now(),
        appointmentDate: DateTime.now(),
        updatedAt: DateTime.now(),
        appointmentType: 'walkin',
        allPatientsChecked: false,
        checkedPatientsCount: 0,
        uncheckedPatientsCount: 1,
        includesOnePatient: true,
        gradeName: selectedGrade.value ?? '',
        gradeId: selectedGrade.value ?? '',
        className: selectedClass.value ?? '',
        classId: student.classId ?? '',
        totalPatientsCount: 1,
        onePatientAid: student.aid,
        enableNotification: true,
        appointmentStatus: 'booked',
        fullName: student.name,
        medicalRecordId: medicalRecordId,
      );

      homeController.navigateToAppointmentStudentProfile(
        student,
        appointment,
      );

      Get.snackbar(
        'Success',
        'Walk-in appointment started successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
      );
    } catch (e) {
      // Clean up progress dialog on error
      if (Get.isRegistered<CreatingAppointmentController>()) {
        Get.back();
        Get.delete<CreatingAppointmentController>();
      }
      Get.snackbar(
        'Error',
        'Failed to start appointment: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }

  bool _validateDateTime() {
    // "Start now" sets date/time automatically
    if (selectedDateTimeOption.value == 'startNow') {
      selectedDate.value = DateTime.now();
      selectedTime.value = TimeOfDay.now();
      return true;
    }
    if (selectedDate.value == null || selectedTime.value == null) {
      Get.snackbar(
        'Validation Error',
        'Please select date and time',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return false;
    }
    return true;
  }

  bool _validateWalkInForm() {
    if (walkInSelectedStudent.value == null) {
      Get.snackbar(
        'Validation Error',
        'Please select a student',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return false;
    }

    if (selectedGrade.value == null) {
      Get.snackbar(
        'Validation Error',
        'Please select a grade',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return false;
    }

    if (selectedClass.value == null) {
      Get.snackbar(
        'Validation Error',
        'Please select a class',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return false;
    }

    return true;
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '';
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('hh:mm a').format(dt);
  }

  // Helper methods for initializing lists
  List<Map<String, dynamic>> _buildAppointmentTypes() => [
        {
          'label': 'Checkup',
          'icon': Icon(Icons.health_and_safety, color: Colors.black)
        },
        {
          'label': 'Follow-Up',
          'icon': Icon(Icons.schedule, color: Colors.black)
        },
        {
          'label': 'Vaccination',
          'icon': Icon(Icons.vaccines, color: Colors.black)
        },
        {
          'label': 'Walk-In',
          'icon': Icon(Icons.directions_walk, color: Colors.black)
        },
      ];

  void _loadDoctorsFromHome() {
    final homeController = Get.find<HomeController>();

    void applyDoctors() {
      _doctors.assignAll(homeController.doctors);
      // Auto-select the logged-in user as doctor if found
      if (selectedDoctor.value == null && _doctors.isNotEmpty) {
        final currentUserName = homeController.userName.value.trim().toLowerCase();
        if (currentUserName.isNotEmpty) {
          final match = _doctors.firstWhereOrNull(
            (d) => d.trim().toLowerCase() == currentUserName,
          );
          if (match != null) {
            selectedDoctor.value = match;
          }
        }
      }
    }

    if (homeController.isDoctorsLoaded.value) {
      applyDoctors();
    } else {
      ever<bool>(homeController.isDoctorsLoaded, (loaded) {
        if (loaded) applyDoctors();
      });
    }
  }

  /// Fetch diseases from API with optional search
  Future<void> fetchDiseases(String search) async {
    try {
      isLoadingDiseases.value = true;
      final accessToken = _storageService.getAccessToken();
      if (accessToken == null) return;

      final branchData = _storageService.getSelectedBranchData();
      final country = branchData?['country'] as String? ?? 'EG';

      var urlStr = '${AppConfig.newBackendUrl}/api/lookups/medical-records?type=diseases';
      if (country.isNotEmpty) urlStr += '&country=$country';
      if (search.isNotEmpty) urlStr += '&search=${Uri.encodeComponent(search)}';

      final response = await http.get(
        Uri.parse(urlStr),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          final data = jsonData['data'] as List;
          _diseases.assignAll(data.map((d) => d['name'] as String).toList());
        }
      }
    } catch (e) {
      print('Error loading diseases: $e');
    } finally {
      isLoadingDiseases.value = false;
    }
  }

  /// Fetch vaccinations from API with optional search
  Future<void> fetchVaccinations(String search) async {
    try {
      isLoadingVaccinations.value = true;
      final accessToken = _storageService.getAccessToken();
      if (accessToken == null) return;

      final branchData = _storageService.getSelectedBranchData();
      final country = branchData?['country'] as String? ?? 'EG';

      var urlStr = '${AppConfig.newBackendUrl}/api/lookups/medical-records?type=Vaccinations';
      if (country.isNotEmpty) urlStr += '&country=$country';
      if (search.isNotEmpty) urlStr += '&search=${Uri.encodeComponent(search)}';

      final response = await http.get(
        Uri.parse(urlStr),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          final data = jsonData['data'] as List;
          _vaccinationTypesList.assignAll(data.map((d) => d['name'] as String).toList());
        }
      }
    } catch (e) {
      print('Error loading vaccinations: $e');
    } finally {
      isLoadingVaccinations.value = false;
    }
  }

  void _loadGradesFromBranch() {
    final branchData = _storageService.getSelectedBranchData();
    if (branchData != null && branchData['grades'] is List && (branchData['grades'] as List).isNotEmpty) {
      final gradesList = (branchData['grades'] as List)
          .map((g) => g.toString())
          .toList();
      _grades.assignAll(gradesList);
      print('📚 Loaded ${gradesList.length} grades from branch data');
    } else {
      // Fallback: fetch grades from API via students data
      _loadGradesFromApi();
    }
  }

  Future<void> _loadGradesFromApi() async {
    final branchData = _storageService.getSelectedBranchData();
    final branchId = branchData?['id'];
    if (branchId == null) return;

    try {
      final accessToken = _storageService.getAccessToken();
      if (accessToken == null) return;

      final url = Uri.parse(
        '${AppConfig.newBackendUrl}/api/school-admin/students?branchId=$branchId&page=1&limit=100',
      );

      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      });

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          final students = jsonData['data']['students'] as List;
          final gradeNames = <String>{};
          for (final s in students) {
            final grade = s['grade'] as String?;
            if (grade != null && grade.isNotEmpty) {
              gradeNames.add(grade);
            }
          }
          if (gradeNames.isNotEmpty) {
            final sorted = gradeNames.toList()..sort();
            _grades.assignAll(sorted);
            print('📚 Loaded ${gradeNames.length} grades from students API');
          }
        }
      }
    } catch (e) {
      print('❌ Error loading grades from API: $e');
    }
  }

  Future<void> _loadClassesFromApi() async {
    final branchData = _storageService.getSelectedBranchData();
    final branchId = branchData?['id'];
    if (branchId == null) return;

    isLoadingClasses.value = true;
    try {
      final accessToken = _storageService.getAccessToken();
      if (accessToken == null) return;

      final url = Uri.parse(
        '${AppConfig.newBackendUrl}/api/school-admin/students?branchId=$branchId&page=1&limit=100',
      );

      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      });

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          final students = jsonData['data']['students'] as List;
          final classNames = <String>{};
          for (final s in students) {
            final classes = s['classes'] as List? ?? [];
            for (final c in classes) {
              final name = c['name'] as String?;
              if (name != null && name.isNotEmpty) {
                classNames.add(name);
              }
            }
          }
          _classes.assignAll(classNames.toList()..sort());
          print('🏫 Loaded ${classNames.length} classes from API');
        }
      }
    } catch (e) {
      print('❌ Error loading classes: $e');
    } finally {
      isLoadingClasses.value = false;
    }
  }

  // Load students from API
  Future<void> _loadStudentsFromApi({String? search, String? grade, String? studentClass}) async {
    isLoadingStudents.value = true;
    try {
      final branchData = _storageService.getSelectedBranchData();
      final branchId = branchData?['id'];
      if (branchId == null) {
        print('⚠️ _loadStudentsFromApi: branchId is null, skipping');
        return;
      }

      final accessToken = _storageService.getAccessToken();
      if (accessToken == null) {
        print('⚠️ _loadStudentsFromApi: accessToken is null, skipping');
        return;
      }

      var urlStr = '${AppConfig.newBackendUrl}/api/school-admin/students?branchId=$branchId&page=1&limit=100';
      if (search != null && search.isNotEmpty) urlStr += '&search=${Uri.encodeComponent(search)}';
      if (grade != null && grade.isNotEmpty) urlStr += '&grade=${Uri.encodeComponent(grade)}';
      if (studentClass != null && studentClass.isNotEmpty) urlStr += '&studentClass=${Uri.encodeComponent(studentClass)}';

      print('📡 Loading students from: $urlStr');

      final response = await http.get(
        Uri.parse(urlStr),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('📡 Students API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          final studentsJson = jsonData['data']['students'] as List;
          _students.assignAll(studentsJson.map((s) => _parseStudent(s)).toList());
          print('✅ Loaded ${_students.length} students');
        } else {
          print('⚠️ Students API returned success: false');
        }
      } else {
        print('❌ Students API failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error loading students: $e');
    } finally {
      isLoadingStudents.value = false;
    }
  }

  // Parse student from API response
  Student _parseStudent(Map<String, dynamic> json) {
    final nameObj = json['name'];
    final fullName = nameObj is Map
        ? '${nameObj['given'] ?? ''} ${nameObj['family'] ?? ''}'.trim()
        : (nameObj?.toString() ?? 'Unknown');

    final classList = json['classes'] as List? ?? [];
    String? gradeVal;
    String? classNameVal;
    String? classIdVal;
    if (classList.isNotEmpty) {
      final firstClass = classList.first as Map<String, dynamic>;
      gradeVal = firstClass['grade'];
      classNameVal = firstClass['name'];
      classIdVal = firstClass['id'] as String?;
    }

    final id = json['id'] as String? ?? '';
    final colorValue = id.hashCode & 0xFFFFFFFF;
    final avatarColor = Color(colorValue | 0xFF000000);

    return Student(
      id: id,
      name: fullName,
      avatarColor: avatarColor,
      aid: json['aid'] as String?,
      dateOfBirth: json['dateOfBirth'] != null ? DateTime.tryParse(json['dateOfBirth']) : null,
      gender: json['gender'] as String?,
      grade: gradeVal ?? json['grade'] as String?,
      className: classNameVal ?? json['studentClass'] as String?,
      classId: classIdVal,
      nationality: json['nationality'] as String?,
      nationalId: json['documentNumber'] as String?,
      imageUrl: json['photo'] as String?,
    );
  }

}
