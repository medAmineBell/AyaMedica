import 'package:get/get.dart';
import 'package:flutter_getx_app/models/student.dart';
import 'package:flutter_getx_app/models/branch_model.dart'; // Fixed import path for BranchModel
import 'package:flutter_getx_app/utils/storage_service.dart';

enum ContentType {
  dashboard,
  appointmentScheduling,
  communication,
  calendar,
  studentsOverview,
  studentsList,
  medicalCheckups,
  medicalCheckupTable, // New content type for medical checkup table
  branches,
  gradesSettings,
  users,
  studentProfile,
  studentForm, // Add new content type for student form
  branchForm, // Add new content type for branch form
  settings, // Add new content type for settings with tab bar
  feedbackDetails, // New content type for feedback details
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

  // Add current content tracking
  final Rx<ContentType> currentContent = ContentType.dashboard.obs;

  // Add student data for profile navigation
  final Rx<Student?> currentStudent = Rx<Student?>(null);
  final RxString currentAppointmentType = ''.obs;

  // Add medical checkup data for table view
  final Rx<dynamic> currentAppointment = Rx<dynamic>(null);
  final Rx<Map<String, dynamic>> currentMedicalCheckupData =
      Rx<Map<String, dynamic>>({});

  // Add student form state
  final Rx<Student?> studentToEdit = Rx<Student?>(null);
  final RxBool isEditingStudent = false.obs;

  // Add branch form state
  final Rx<BranchModel?> branchToEdit = Rx<BranchModel?>(null);
  final RxBool isEditingBranch = false.obs;

  final RxSet<int> expandedMenuItems = <int>{}.obs;
  final RxBool isSecondSidebarVisible = true.obs;
  final RxBool isMedicalHistoryView = false.obs;
  
  // Selected branch data
  final Rx<Map<String, dynamic>?> selectedBranchData = Rx<Map<String, dynamic>?>(null);

  void changeIndex(int index) {
    selectedIndex.value = index;
    // Set default content based on main menu selection
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

  // New method to change content directly
  void changeContent(ContentType content) {
    currentContent.value = content;
  }

  // New method to navigate to student profile
  void navigateToStudentProfile(Student student,
      {String appointmentType = 'Walk-In'}) {
    currentStudent.value = student;
    currentAppointmentType.value = appointmentType;
    currentContent.value = ContentType.studentProfile;
  }

  // New methods for student form navigation
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

  // Method to go back from student form
  void exitStudentForm() {
    studentToEdit.value = null;
    isEditingStudent.value = false;
    // Return to students list or previous content
    currentContent.value = ContentType.studentsList;
  }

  // New methods for branch form navigation
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

  // Method to go back from branch form
  void exitBranchForm() {
    branchToEdit.value = null;
    isEditingBranch.value = false;
    // Return to branches list or previous content
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
  }
  
  // Method to update selected branch data
  void updateSelectedBranchData(Map<String, dynamic> branchData) {
    selectedBranchData.value = branchData;
  }
  
  @override
  void onInit() {
    super.onInit();
    // Load selected branch data on initialization
    loadSelectedBranchData();
  }
}
