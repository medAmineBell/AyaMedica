import 'package:get/get.dart';
import 'package:flutter_getx_app/models/student.dart';
import 'package:flutter_getx_app/models/branch_model.dart';
import 'package:flutter_getx_app/utils/storage_service.dart';

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
  users,
  studentProfile,
  studentForm,
  branchForm,
  settings,
  feedbackDetails,
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
  final Rx<Map<String, dynamic>> currentMedicalCheckupData =
      Rx<Map<String, dynamic>>({});
  final Rx<Student?> studentToEdit = Rx<Student?>(null);
  final RxBool isEditingStudent = false.obs;
  final Rx<BranchModel?> branchToEdit = Rx<BranchModel?>(null);
  final RxBool isEditingBranch = false.obs;
  final RxSet<int> expandedMenuItems = <int>{}.obs;
  final RxBool isSecondSidebarVisible = true.obs;
  final RxBool isMedicalHistoryView = false.obs;

  // Selected branch data
  final Rx<Map<String, dynamic>?> selectedBranchData =
      Rx<Map<String, dynamic>?>(null);

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
    currentContent.value = ContentType.studentProfile;
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

  @override
  void onInit() {
    super.onInit();
    loadSelectedBranchData();
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
