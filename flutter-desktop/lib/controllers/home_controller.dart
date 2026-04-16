import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_getx_app/config/app_config.dart';
import 'package:flutter_getx_app/models/appointment_history_model.dart';
import 'package:flutter_getx_app/models/student.dart';
import 'package:flutter_getx_app/models/branch_model.dart';
import 'package:flutter_getx_app/utils/api_service.dart';
import 'package:flutter_getx_app/utils/storage_service.dart';
import 'package:flutter_getx_app/controllers/resources_controller.dart';
import 'package:flutter_getx_app/controllers/appointment_history_controller.dart';
import 'package:flutter_getx_app/controllers/appointment_scheduling_controller.dart';
import 'package:flutter_getx_app/controllers/branch_management_controller.dart';
import 'package:flutter_getx_app/controllers/users_controller.dart';
import 'package:flutter_getx_app/controllers/mobile_app_user_controller.dart';
import 'package:flutter_getx_app/controllers/notification_controller.dart';
import 'package:flutter_getx_app/controllers/favorite_drugs_controller.dart';
import 'package:flutter_getx_app/controllers/student_controller.dart';
import 'package:flutter_getx_app/controllers/medical_records_controller.dart';
import 'package:flutter_getx_app/controllers/communication_controller.dart';
import 'package:flutter_getx_app/controllers/reports_controller.dart';
import 'package:flutter_getx_app/controllers/dashboard_controller.dart';

enum ContentType {
  dashboard,
  appointmentScheduling,
  communication,
  calendar,
  studentsOverview,
  studentsList,
  medicalCheckups,
  medicalCheckupTable,
  reports,
  branches,
  gradesSettings,
  schoolYear,
  users,
  studentProfile,
  appointmentStudentProfile,
  checkedOutWalkInSummary,
  studentForm,
  branchForm,
  settings,
  support,
  feedbackDetails,
  notifications,
  favoriteDrugs,
}

class HomeController extends GetxController {
  final RxInt selectedIndex = 0.obs;
  final RxInt selectedSideIndex = 0.obs;
  final RxBool isSummaryMode = false.obs;
  final RxBool isChronicExpanded = true.obs;
  final RxBool isMedicationExpanded = true.obs;
  final RxString selectedProfileMenuItem = 'Profile'.obs;
  final RxBool isMedicalRecordsView = false.obs;
  final RxBool isAssessmentView = false.obs;
  final RxBool isMonitoringSignsView = false.obs;
  final RxBool isPlansView = false.obs;

  final Rx<ContentType> currentContent = ContentType.dashboard.obs;
  final Rx<Student?> currentStudent = Rx<Student?>(null);
  final RxString currentAppointmentType = ''.obs;
  final Rx<dynamic> currentAppointment = Rx<dynamic>(null);
  final Rx<AppointmentHistory?> currentAppointmentHistory = Rx<AppointmentHistory?>(null);
  final Rx<Map<String, dynamic>> currentMedicalCheckupData =
      Rx<Map<String, dynamic>>({});
  final Rx<Student?> studentToEdit = Rx<Student?>(null);
  final RxBool isEditingStudent = false.obs;
  final Rx<BranchModel?> branchToEdit = Rx<BranchModel?>(null);
  final RxBool isEditingBranch = false.obs;
  final RxSet<int> expandedMenuItems = <int>{}.obs;
  final RxBool isSecondSidebarVisible = true.obs;
  final RxBool isMedicalHistoryView = false.obs;

  // Patient records data (medical history tab)
  final RxList<Map<String, dynamic>> patientMedicalRecords = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> patientMedicalHistory = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingPatientRecords = false.obs;

  // Multi-branch flag
  final RxBool hasMultipleBranches = false.obs;

  // User profile data
  final RxString userName = ''.obs;
  final RxString userRole = ''.obs;
  final RxString userInitials = ''.obs;
  final RxnString userAvatarUrl = RxnString(null);
  final RxBool isRoleLoaded = false.obs;

  // Whether the user's role restricts access to settings and resources
  bool get isRestrictedRole {
    final role = userRole.value;
    return role == 'Doctor' || role == 'Nurse' || role == 'Teacher';
  }

  // Selected branch data
  final Rx<Map<String, dynamic>?> selectedBranchData =
      Rx<Map<String, dynamic>?>(null);

  // Doctors list - loaded once at startup
  final RxList<String> doctors = <String>[].obs;
  final RxBool isDoctorsLoaded = false.obs;

  void changeIndex(int index) {
    selectedIndex.value = index;
    switch (index) {
      case 0:
        currentContent.value = ContentType.dashboard;
        break;
      case 1:
        currentContent.value = ContentType.appointmentScheduling;
        break;
      case 2:
        currentContent.value = ContentType.communication;
        break;
      case 3:
        currentContent.value = ContentType.studentsOverview;
        break;
      case 4:
        currentContent.value = ContentType.branches;
        break;
      case 5:
        currentContent.value = ContentType.calendar;
        break;
    }
  }

  void changeSideIndex(int index) {
    selectedSideIndex.value = index;
  }

  void changeContent(ContentType content) {
    currentContent.value = content;
  }

  void navigateToStudentProfile(Student student,
      {String appointmentType = 'Walk-In'}) {
    currentStudent.value = student;
    currentAppointmentType.value = appointmentType;
    selectedProfileMenuItem.value = 'Profile';
    patientMedicalRecords.clear();
    patientMedicalHistory.clear();
    currentContent.value = ContentType.studentProfile;
  }

  void navigateToAppointmentStudentProfile(Student student,
      AppointmentHistory appointment) {
    currentStudent.value = student;
    currentAppointmentHistory.value = appointment;
    selectedProfileMenuItem.value = 'Profile';
    currentContent.value = ContentType.appointmentStudentProfile;

    // Fetch full student data from medical record API
    print('[HomeController] medicalRecordId: ${appointment.medicalRecordId}, appointmentId: ${appointment.id}');
    if (appointment.medicalRecordId != null) {
      _fetchStudentFromMedicalRecord(appointment.id, appointment.medicalRecordId!);
    }
    // Fetch patient records for medical history tab
    _fetchPatientRecords(appointment.id);
  }

  Future<void> _fetchStudentFromMedicalRecord(String appointmentId, String recordId) async {
    try {
      final storageService = Get.find<StorageService>();
      final accessToken = storageService.getAccessToken();
      if (accessToken == null) return;

      final url =
          '${AppConfig.newBackendUrl}/api/appointment-sessions/$appointmentId/medical-records/$recordId';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('[HomeController] _fetchStudentFromMedicalRecord status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          final data = jsonData['data'] as Map<String, dynamic>;
          if (data['student'] is Map<String, dynamic>) {
            print('[HomeController] Updating student from API data');
            _updateStudentFromApi(data['student'] as Map<String, dynamic>);
          }
        }
      }
    } catch (e) {
      print('[HomeController] Error fetching student data: $e');
    }
  }

  void _updateStudentFromApi(Map<String, dynamic> s) {
    final current = currentStudent.value;
    if (current == null) return;

    final name = s['name'];
    final fullName = name is Map
        ? '${name['given'] ?? ''} ${name['family'] ?? ''}'.trim()
        : current.name;

    final firstGuardian = s['firstGuardian'] as Map<String, dynamic>?;
    final secondGuardian = s['secondGuardian'] as Map<String, dynamic>?;

    print('[HomeController] Guardian data - first: ${firstGuardian?['fullName']}, phone: ${firstGuardian?['phone']}, email: ${firstGuardian?['email']}');
    print('[HomeController] Guardian data - second: ${secondGuardian?['fullName']}, phone: ${secondGuardian?['phone']}, email: ${secondGuardian?['email']}');
    currentStudent.value = current.copyWith(
      imageUrl: s['photo'] as String? ?? current.imageUrl,
      name: fullName,
      dateOfBirth: s['dateOfBirth'] != null
          ? DateTime.tryParse(s['dateOfBirth'].toString())
          : current.dateOfBirth,
      gender: s['gender'] as String? ?? current.gender,
      nationality: s['nationality'] as String? ?? current.nationality,
      nationalId: s['documentNumber'] as String? ?? current.nationalId,
      passportIdNumber: s['documentType'] == 'passport'
          ? s['documentNumber'] as String?
          : current.passportIdNumber,
      documentType: s['documentType'] as String? ?? current.documentType,
      documentNumber: s['documentNumber'] as String? ?? current.documentNumber,
      city: s['city'] as String? ?? current.city,
      firstGuardianName: firstGuardian?['fullName'] as String?,
      firstGuardianPhone: firstGuardian?['phone'] as String?,
      firstGuardianEmail: firstGuardian?['email'] as String?,
      firstGuardianStatus: firstGuardian?['status'] as String?,
      secondGuardianName: secondGuardian?['fullName'] as String?,
      secondGuardianPhone: secondGuardian?['phone'] as String?,
      secondGuardianEmail: secondGuardian?['email'] as String?,
      secondGuardianStatus: secondGuardian?['status'] as String?,
    );
  }

  Future<void> _fetchPatientRecords(String appointmentId) async {
    try {
      isLoadingPatientRecords.value = true;
      patientMedicalRecords.clear();
      patientMedicalHistory.clear();

      final storageService = Get.find<StorageService>();
      final accessToken = storageService.getAccessToken();
      if (accessToken == null) return;

      final url =
          '${AppConfig.newBackendUrl}/api/appointment-sessions/$appointmentId/patient-records';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          final data = jsonData['data'] as Map<String, dynamic>;

          if (data['medicalRecords'] is List) {
            patientMedicalRecords.assignAll(
              (data['medicalRecords'] as List)
                  .map((e) => Map<String, dynamic>.from(e))
                  .toList(),
            );
          }

          if (data['medicalHistory'] is List) {
            patientMedicalHistory.assignAll(
              (data['medicalHistory'] as List)
                  .map((e) => Map<String, dynamic>.from(e))
                  .toList(),
            );
          }
        }
      }
    } catch (e) {
      print('[HomeController] Error fetching patient records: $e');
    } finally {
      isLoadingPatientRecords.value = false;
    }
  }

  /// Fetch medical records & history for a student profile (not appointment-based)
  Future<void> fetchStudentMedicalData(String studentId) async {
    try {
      isLoadingPatientRecords.value = true;
      patientMedicalRecords.clear();
      patientMedicalHistory.clear();

      final storageService = Get.find<StorageService>();
      final accessToken = storageService.getAccessToken();
      if (accessToken == null) return;

      final branchId = getBranchId();
      if (branchId == null) return;

      final url =
          '${AppConfig.newBackendUrl}/api/school-admin/medical-records/students/$studentId?organizationId=$branchId&page=1&limit=20';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          final data = jsonData['data'] as Map<String, dynamic>;

          if (data['medicalRecords'] is List) {
            patientMedicalRecords.assignAll(
              (data['medicalRecords'] as List)
                  .map((e) => Map<String, dynamic>.from(e))
                  .toList(),
            );
          }

          if (data['medicalHistory'] is List) {
            patientMedicalHistory.assignAll(
              (data['medicalHistory'] as List)
                  .map((e) => Map<String, dynamic>.from(e))
                  .toList(),
            );
          }
        }
      }
    } catch (e) {
      print('[HomeController] Error fetching student medical data: $e');
    } finally {
      isLoadingPatientRecords.value = false;
    }
  }

  /// Refresh patient records after adding new medical history.
  /// Handles both appointment-based and student profile contexts.
  Future<void> refreshPatientRecords() async {
    final appointment = currentAppointmentHistory.value;
    if (appointment != null) {
      await _fetchPatientRecords(appointment.id);
    } else if (currentStudent.value != null) {
      await fetchStudentMedicalData(currentStudent.value!.id);
    }
  }

  void navigateToAddStudent() {
    studentToEdit.value = null;
    isEditingStudent.value = false;
    currentContent.value = ContentType.studentForm;
  }

  void navigateToEditStudent(Student student) {
    studentToEdit.value = student;
    isEditingStudent.value = true;
    currentContent.value = ContentType.studentForm;
  }

  void exitStudentForm() {
    studentToEdit.value = null;
    isEditingStudent.value = false;
    currentContent.value = ContentType.studentsList;
  }

  void navigateToAddBranch() {
    branchToEdit.value = null;
    isEditingBranch.value = false;
    currentContent.value = ContentType.branchForm;
  }

  void navigateToEditBranch(BranchModel branch) {
    branchToEdit.value = branch;
    isEditingBranch.value = true;
    currentContent.value = ContentType.branchForm;
  }

  void navigateToFavoriteDrugs() {
    currentContent.value = ContentType.favoriteDrugs;
  }

  void exitFavoriteDrugs() {
    currentContent.value = ContentType.studentsList;
  }

  void exitBranchForm() {
    branchToEdit.value = null;
    isEditingBranch.value = false;
    currentContent.value = ContentType.branches;
  }

  void toggleMenuExpansion(int index) {
    if (expandedMenuItems.contains(index)) {
      expandedMenuItems.remove(index);
    } else {
      expandedMenuItems.add(index);
    }
  }

  void toggleSecondSidebar() {
    isSecondSidebarVisible.value = !isSecondSidebarVisible.value;
  }

  void showMedicalCheckupTable(
      dynamic appointment, Map<String, dynamic> medicalCheckupData) {
    currentAppointment.value = appointment;
    currentMedicalCheckupData.value = medicalCheckupData;
    currentContent.value = ContentType.medicalCheckupTable;
  }

  void backToAppointmentScheduling() {
    currentContent.value = ContentType.appointmentScheduling;
  }

  /// Reset controller state for a branch switch (reloads branch data + defaults)
  void resetForBranchSwitch() {
    // Reload branch data from storage
    loadSelectedBranchData();

    // Reset HomeController UI state to defaults
    selectedIndex.value = 0;
    currentContent.value = ContentType.dashboard;
    expandedMenuItems.clear();
    currentStudent.value = null;
    currentAppointment.value = null;
    currentAppointmentHistory.value = null;
    currentMedicalCheckupData.value = {};
    studentToEdit.value = null;
    isEditingStudent.value = false;
    branchToEdit.value = null;
    isEditingBranch.value = false;
    isSecondSidebarVisible.value = true;
    isSummaryMode.value = false;
    isMedicalRecordsView.value = false;
    isMedicalHistoryView.value = false;
    isAssessmentView.value = false;
    isMonitoringSignsView.value = false;
    isPlansView.value = false;
    patientMedicalRecords.clear();
    patientMedicalHistory.clear();
    selectedProfileMenuItem.value = 'Profile';
    doctors.clear();
    isDoctorsLoaded.value = false;

    // Delete all branch-dependent controllers so they get recreated
    // fresh (via fenix) with the new branch data when their screens
    // are next accessed.
    _deleteSafely<DashboardController>();
    _deleteSafely<AppointmentSchedulingController>();
    _deleteSafely<AppointmentHistoryController>();
    _deleteSafely<BranchManagementController>();
    _deleteSafely<UsersController>();
    _deleteSafely<MobileAppUserController>();
    _deleteSafely<ResourcesController>();
    _deleteSafely<NotificationController>();
    _deleteSafely<FavoriteDrugsController>();
    _deleteSafely<StudentController>();
    _deleteSafely<MedicalRecordsController>();
    _deleteSafely<CommunicationController>();
    _deleteSafely<ReportsController>();

    // Reload HomeController's own data for the new branch
    _checkMultipleBranches();
    fetchAndCacheUserProfile();
    loadDoctors();
    // Eagerly reload classes so they're cached before Create Appointment opens
    Get.find<ResourcesController>().loadClasses();
  }

  void _deleteSafely<T extends GetxController>() {
    if (Get.isRegistered<T>()) {
      Get.delete<T>(force: true);
    }
  }

  // Method to load selected branch data
  void loadSelectedBranchData() {
    final storageService = Get.find<StorageService>();
    selectedBranchData.value = storageService.getSelectedBranchData();
    print(
        '📍 HomeController loaded branch: ${selectedBranchData.value?['id']}');
  }

  // Method to update selected branch data
  void updateSelectedBranchData(Map<String, dynamic> branchData) {
    selectedBranchData.value = branchData;
    print('📍 HomeController updated branch: ${branchData['id']}');
  }

  // Get branch ID
  String? getBranchId() {
    return selectedBranchData.value?['id'];
  }

  // Load user profile from cache instantly, then refresh from API in background
  Future<void> fetchAndCacheUserProfile() async {
    final storageService = Get.find<StorageService>();
    final apiService = Get.find<ApiService>();

    // Load from cache first for instant display
    final cached = storageService.getUserProfile();
    if (cached != null) {
      _applyProfileData(cached);
    }

    // Refresh from API in background
    final result = await apiService.fetchUserProfile();
    print('[HomeController] Profile API response: $result');
    if (result['success'] == true) {
      final data = result['data'] as Map<String, dynamic>;
      _applyProfileData(data);
      await storageService.saveUserProfile(data);
    }
  }

  void _applyProfileData(Map<String, dynamic> data) {
    final name = data['name'] as Map<String, dynamic>?;
    final given = name?['given'] ?? '';
    final family = name?['family'] ?? '';
    userName.value = '$given $family'.trim();

    final initGiven = given.isNotEmpty ? given[0].toUpperCase() : '';
    final initFamily = family.isNotEmpty ? family[0].toUpperCase() : '';
    userInitials.value = '$initGiven$initFamily';

    final roles = data['roles'] as List<dynamic>?;
    if (roles != null && roles.isNotEmpty) {
      userRole.value = roles[0]['role'] ?? '';
    }

    userAvatarUrl.value = data['avatarUrl'];
    isRoleLoaded.value = true;
  }

  void _checkMultipleBranches() {
    final storageService = Get.find<StorageService>();
    hasMultipleBranches.value = storageService.getHasMultipleBranches();
  }

  @override
  void onInit() {
    super.onInit();
    loadSelectedBranchData();
    _checkMultipleBranches();
    fetchAndCacheUserProfile();
    loadDoctors();
    // Eagerly load grades/classes so they're cached before Create Appointment opens
    Get.find<ResourcesController>().loadClasses();
  }

  /// Load doctors list once at startup
  Future<void> loadDoctors() async {
    try {
      final storageService = Get.find<StorageService>();
      final branchData = storageService.getSelectedBranchData();
      final branchId = branchData?['id'];
      if (branchId == null) return;

      final accessToken = storageService.getAccessToken();
      if (accessToken == null) return;

      final response = await http.get(
        Uri.parse('${AppConfig.newBackendUrl}/api/school-admin/branches/$branchId/doctors'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          final staff = jsonData['data']['staff'] as List;
          doctors.assignAll(staff.map((d) {
            final name = d['name'];
            return name is Map
                ? ((name['full'] as String?) ?? '${name['given']} ${name['family']}').trim()
                : d['name'].toString();
          }).toList());
        }
      }
    } catch (e) {
      print('Error loading doctors: $e');
    } finally {
      isDoctorsLoaded.value = true;
    }
  }

  // Add these methods to HomeController class

  /// CENTRALIZED METHOD: Get Organization ID from storage
  String? getOrganizationId() {
    final storageService = Get.find<StorageService>();

    // Try multiple sources
    String? orgId = storageService.getOrganizationId();
    if (orgId != null) return orgId;

    // From branch data
    final branchData = storageService.getSelectedBranchData();
    if (branchData != null) {
      return branchData['organizationId'] ?? branchData['parentId'];
    }

    return null;
  }

  /// CENTRALIZED METHOD: Get Branch ID from storage
  String? getCurrentBranchId() {
    return getBranchId(); // Use existing method
  }
}
