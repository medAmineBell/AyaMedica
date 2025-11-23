// Updated StudentController with updateStudent method
import 'package:flutter/material.dart';
import 'package:flutter_getx_app/screens/students/widgets/student_data_table.dart';
import 'package:flutter_getx_app/screens/students/widgets/student_details_sheet_widget.dart';
import 'package:get/get.dart';

import '../models/student.dart';
import '../models/chronic_disease.dart';

// Student Controller with GetX
class StudentController extends GetxController {
  // Reactive variables
  final RxList<Student> _allStudents = <Student>[].obs;
  final RxList<Student> filteredStudents = <Student>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'All'.obs;
  final RxBool isLoading = false.obs;
  final RxInt currentPage = 0.obs;
  final RxInt itemsPerPage = 10.obs;
  final RxList<Map<String, dynamic>> defectiveRecords =
      <Map<String, dynamic>>[].obs;
  final RxBool hasDefectiveRecords = false.obs;

  // Method to add defective records
  void addDefectiveRecords(List<Map<String, dynamic>> records) {
    defectiveRecords.value = records;
    hasDefectiveRecords.value = records.isNotEmpty;
  }

  // Method to clear defective records
  void clearDefectiveRecords() {
    defectiveRecords.clear();
    hasDefectiveRecords.value = false;
  }

  // Method to download defective records as Excel
  void downloadDefectiveRecords() {
    // Implementation for downloading defective records
    Get.snackbar(
      'Download Started',
      'Defective records file is being downloaded...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  // Getters
  List<Student> get students => filteredStudents;
  int get totalStudents => _allStudents.length;
  int get totalPages => (filteredStudents.length / itemsPerPage.value).ceil();

  List<Student> get paginatedStudents {
    final startIndex = currentPage.value * itemsPerPage.value;
    final endIndex =
        (startIndex + itemsPerPage.value).clamp(0, filteredStudents.length);
    return filteredStudents.sublist(startIndex, endIndex);
  }

  @override
  void onInit() {
    super.onInit();
    loadStudents();
  }

  void loadStudents() {
    isLoading.value = true;

    // Simulate loading delay
    Future.delayed(Duration(milliseconds: 500), () {
      _allStudents.value = [
        Student(
          id: '8EG390J65A',
          name: 'Ahmed Khaled Ali Ibrahim',
          avatarColor: Color(4279450111),
          dateOfBirth: DateTime.parse('2010-10-02'),
          bloodType: 'O+',
          weightKg: 39.2,
          heightCm: 136,
          goToHospital: 'Cleopatra Hospital',
          firstGuardianName: 'Ronald Taylor',
          firstGuardianPhone: '(903)105-7844x138',
          firstGuardianEmail: 'ejohnson@owen-campbell.com',
          firstGuardianStatus: 'Online',
          secondGuardianName: 'Mr. Kevin Ramirez',
          secondGuardianPhone: '151-548-4860',
          secondGuardianEmail: 'jacksondennis@rhodes.net',
          secondGuardianStatus: 'Offline',
          city: 'North Zachary',
          street: '365 Mcclure Spring',
          zipCode: '63039',
          province: 'Delaware',
          insuranceCompany: 'Allianz',
          policyNumber: 'POL0499418',
          passportIdNumber: 'Vi36090905',
          nationality: 'Egyptian',
          nationalId: '2101013573669393',
          gender: 'Male',
          phoneNumber: '+1-743-315-1141x81905',
          email: 'scott82@mendoza.com',
          studentId: '29000000000',
          aid: '4EG2390Q3SE',
          grade: 'G4',
          className: 'Lions',
          lastAppointmentDate: DateTime.parse('2025-07-22 16:25:00'),
          lastAppointmentType: 'Walk in',
          emrNumber: 22,
          chronicDiseases: [
            ChronicDisease(
              id: 'cd1',
              name: 'Type 1 Diabetes',
              description: 'Autoimmune condition affecting insulin production',
              category: 'Endocrine',
              diagnosedDate: DateTime.parse('2018-03-15'),
              severity: 'moderate',
              isActive: true,
              treatmentPlan: 'Insulin therapy and blood glucose monitoring',
              medications: 'Insulin injections, Metformin',
              notes: 'Requires regular blood sugar monitoring',
            ),
            ChronicDisease(
              id: 'cd2',
              name: 'Asthma',
              description: 'Chronic respiratory condition',
              category: 'Respiratory',
              diagnosedDate: DateTime.parse('2019-06-20'),
              severity: 'mild',
              isActive: true,
              treatmentPlan: 'Inhaler therapy and trigger avoidance',
              medications: 'Albuterol inhaler',
              notes: 'Triggered by exercise and cold weather',
            ),
          ],
        ),
        Student(
          id: '8EG390J66B',
          name: 'Sara Mohamed Hassan',
          avatarColor: Color(4279286145),
          dateOfBirth: DateTime.parse('2015-02-26'),
          bloodType: 'B-',
          weightKg: 48.1,
          heightCm: 138,
          goToHospital: 'Al Salam Hospital',
          firstGuardianName: 'Laura Kennedy',
          firstGuardianPhone: '(151)240-2718',
          firstGuardianEmail: 'ijohnson@lyons-taylor.net',
          firstGuardianStatus: 'Offline',
          secondGuardianName: 'Brian Cardenas',
          secondGuardianPhone: '(492)549-0512x00087',
          secondGuardianEmail: 'jessica97@hotmail.com',
          secondGuardianStatus: 'Offline',
          city: 'East Rose',
          street: '851 Reese Heights',
          zipCode: '99340',
          province: 'Maryland',
          insuranceCompany: 'CIB',
          policyNumber: 'POL9961387',
          passportIdNumber: 'ln06876152',
          nationality: 'Egyptian',
          nationalId: '2746755682256140',
          gender: 'Female',
          phoneNumber: '301.261.2846x390',
          email: 'andrewmendoza@jones-carroll.info',
          studentId: '29000000001',
          aid: '4EG2390Q3SF',
          grade: 'G2',
          className: 'Eagles',
          lastAppointmentDate: DateTime.parse('2025-07-20 14:30:00'),
          lastAppointmentType: 'Scheduled',
          emrNumber: 25,
          chronicDiseases: [
            ChronicDisease(
              id: 'cd3',
              name: 'Hypertension',
              description: 'High blood pressure condition',
              category: 'Cardiovascular',
              diagnosedDate: DateTime.parse('2020-01-10'),
              severity: 'mild',
              isActive: true,
              treatmentPlan: 'Lifestyle modifications and medication',
              medications: 'Lisinopril',
              notes: 'Monitor blood pressure regularly',
            ),
          ],
        ),
        Student(
          id: '8EG390J67C',
          name: 'Omar Ahmed Farid',
          avatarColor: Color(4293870660),
          dateOfBirth: DateTime.parse('2014-08-18'),
          bloodType: 'A-',
          weightKg: 39.8,
          heightCm: 147,
          goToHospital: 'Cleopatra Hospital',
          firstGuardianName: 'Bruce Smith',
          firstGuardianPhone: '+1-383-541-1239',
          firstGuardianEmail: 'courtneymatthews@barnes.com',
          firstGuardianStatus: 'Online',
          secondGuardianName: 'Alexander Dixon',
          secondGuardianPhone: '+1-409-517-0017',
          secondGuardianEmail: 'ulee@yahoo.com',
          secondGuardianStatus: 'Online',
          city: 'South Danielville',
          street: '9053 Kevin Ridge',
          zipCode: '02378',
          province: 'New Hampshire',
          insuranceCompany: 'CIB',
          policyNumber: 'POL8991389',
          passportIdNumber: 'ok97972521',
          nationality: 'Egyptian',
          nationalId: '2628575843788600',
          gender: 'Male',
          phoneNumber: '001-685-915-3428x243',
          email: 'andreathompson@hotmail.com',
          studentId: '29000000002',
          aid: '4EG2390Q3SG',
          grade: 'G3',
          className: 'Tigers',
          lastAppointmentDate: DateTime.parse('2025-07-19 10:15:00'),
          lastAppointmentType: 'Emergency',
          emrNumber: 28,
        ),
        Student(
          id: '8EG390J65E',
          name: 'Ahmed Khaled Ali Ibrahim',
          avatarColor: Color(4279450111),
          dateOfBirth: DateTime.parse('2014-01-17'),
          bloodType: 'AB+',
          weightKg: 35.4,
          heightCm: 147,
          goToHospital: 'Al Salam Hospital',
          firstGuardianName: 'Nicole Marshall',
          firstGuardianPhone: '331-178-7656',
          firstGuardianEmail: 'medinagarrett@young.com',
          firstGuardianStatus: 'Online',
          secondGuardianName: 'Lisa Hall',
          secondGuardianPhone: '001-605-815-5262x89726',
          secondGuardianEmail: 'taylorjohn@gmail.com',
          secondGuardianStatus: 'Online',
          city: 'Whitakerside',
          street: '70453 Kirk Course Suite 916',
          zipCode: '62213',
          province: 'Washington',
          insuranceCompany: 'Allianz',
          policyNumber: 'POL9709109',
          passportIdNumber: 'qT53122254',
          nationality: 'Egyptian',
          nationalId: '2777888206975572',
          gender: 'Male',
          phoneNumber: '471.110.3632',
          email: 'lindsaylane@williams-harris.com',
          studentId: '29000000003',
          aid: '4EG2390Q3SH',
          grade: 'G4',
          className: 'Bears',
          lastAppointmentDate: DateTime.parse('2025-07-18 09:45:00'),
          lastAppointmentType: 'Walk in',
          emrNumber: 31,
        ),
        Student(
          id: '8EGdvJ66R',
          name: 'Sara Mohamed Hassan',
          avatarColor: Color(4279286145),
          dateOfBirth: DateTime.parse('2013-09-08'),
          bloodType: 'B-',
          weightKg: 43.8,
          heightCm: 145,
          goToHospital: 'Cleopatra Hospital',
          firstGuardianName: 'Diana Ochoa',
          firstGuardianPhone: '227.571.9987',
          firstGuardianEmail: 'rubenwashington@hotmail.com',
          firstGuardianStatus: 'Offline',
          secondGuardianName: 'Rachel Munoz PhD',
          secondGuardianPhone: '001-208-871-9718x7376',
          secondGuardianEmail: 'cgordon@pierce.info',
          secondGuardianStatus: 'Offline',
          city: 'Khanside',
          street: '7120 Brittney Passage',
          zipCode: '58606',
          province: 'Hawaii',
          insuranceCompany: 'CIB',
          policyNumber: 'POL7578448',
          passportIdNumber: 'OI47501527',
          nationality: 'Egyptian',
          nationalId: '2963636324432351',
          gender: 'Male',
          phoneNumber: '002.472.8675x12705',
          email: 'andersonrobert@gmail.com',
          studentId: '29000000004',
          aid: '4EG2390Q3SI',
          grade: 'G1',
          className: 'Wolves',
          lastAppointmentDate: DateTime.parse('2025-07-17 15:20:00'),
          lastAppointmentType: 'Scheduled',
          emrNumber: 19,
        ),
      ];

      filteredStudents.value = _allStudents;
      isLoading.value = false;
    });
  }

  void searchStudents(String query) {
    searchQuery.value = query;
    currentPage.value = 0;
    applyFilters();
  }

  void filterByGender(String filter) {
    selectedFilter.value = filter;
    currentPage.value = 0;
    applyFilters();
  }

  void applyFilters() {
    filteredStudents.value = _allStudents.where((student) {
      final matchesSearch = student.name
              .toLowerCase()
              .contains(searchQuery.value.toLowerCase()) ||
          student.id.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          (student.studentId
                  ?.toLowerCase()
                  .contains(searchQuery.value.toLowerCase()) ??
              false) ||
          (student.aid
                  ?.toLowerCase()
                  .contains(searchQuery.value.toLowerCase()) ??
              false);

      final matchesFilter = selectedFilter.value == 'All' ||
          student.gender == selectedFilter.value;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  void addStudent(Student student) {
    _allStudents.add(student);
    applyFilters();
    Get.snackbar(
      'Success',
      'Student "${student.name}" added successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: Duration(seconds: 3),
    );
  }

  // NEW: Update student method
  void updateStudent(Student updatedStudent) {
    final index =
        _allStudents.indexWhere((student) => student.id == updatedStudent.id);
    if (index != -1) {
      _allStudents[index] = updatedStudent;
      applyFilters();
      Get.snackbar(
        'Success',
        'Student "${updatedStudent.name}" updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } else {
      Get.snackbar(
        'Error',
        'Student not found for update',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    }
  }

  void removeStudent(String id) {
    final removedStudent =
        _allStudents.firstWhereOrNull((student) => student.id == id);
    _allStudents.removeWhere((student) => student.id == id);
    applyFilters();

    if (removedStudent != null) {
      Get.snackbar(
        'Success',
        'Student "${removedStudent.name}" removed successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    }
  }

  void refreshStudents() {
    loadStudents();
  }

  void goToPage(int page) {
    if (page >= 0 && page < totalPages) {
      currentPage.value = page;
    }
  }

  void previousPage() {
    if (currentPage.value > 0) {
      currentPage.value--;
    }
  }

  void nextPage() {
    if (currentPage.value < totalPages - 1) {
      currentPage.value++;
    }
  }

  void editStudent(Student student) {
    // This method is now handled by the HomeController navigation
    // But keeping for backward compatibility
    Get.snackbar(
      'Edit Student',
      'Edit functionality for ${student.name}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  void deleteStudent(Student student) {
    Get.dialog(
      AlertDialog(
        title: Text('Delete Student'),
        content: Text('Are you sure you want to delete ${student.name}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _allStudents.removeWhere((s) => s.id == student.id);
              applyFilters();
              Get.back();
              Get.snackbar(
                'Success',
                'Student "${student.name}" deleted successfully',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
                duration: Duration(seconds: 3),
              );
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void viewStudent(Student student) {
    Get.bottomSheet(
      StudentDetailsSheet(student: student),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // Helper method to find student by ID
  Student? getStudentById(String id) {
    try {
      return _allStudents.firstWhere((student) => student.id == id);
    } catch (e) {
      return null;
    }
  }

  // Helper method to get student count by grade
  Map<String, int> getStudentCountByGrade() {
    final gradeCount = <String, int>{};
    for (final student in _allStudents) {
      final grade = student.grade ?? 'Unknown';
      gradeCount[grade] = (gradeCount[grade] ?? 0) + 1;
    }
    return gradeCount;
  }

  // Helper method to get student count by class
  Map<String, int> getStudentCountByClass() {
    final classCount = <String, int>{};
    for (final student in _allStudents) {
      final className = student.className ?? 'Unknown';
      classCount[className] = (classCount[className] ?? 0) + 1;
    }
    return classCount;
  }

  // Method to validate student data before saving
  String? validateStudent(Student student) {
    if (student.name.trim().isEmpty) {
      return 'Student name is required';
    }

    if (student.dateOfBirth == null) {
      return 'Date of birth is required';
    }

    if (student.nationalId?.trim().isEmpty ?? true) {
      return 'National ID is required';
    }

    if (student.grade?.trim().isEmpty ?? true) {
      return 'Grade is required';
    }

    if (student.className?.trim().isEmpty ?? true) {
      return 'Class name is required';
    }

    // Check for duplicate national ID (excluding current student if updating)
    final existingStudent = _allStudents.firstWhereOrNull(
        (s) => s.nationalId == student.nationalId && s.id != student.id);
    if (existingStudent != null) {
      return 'A student with this National ID already exists';
    }

    // Check for duplicate student ID (excluding current student if updating)
    final existingStudentId = _allStudents.firstWhereOrNull(
        (s) => s.studentId == student.studentId && s.id != student.id);
    if (existingStudentId != null) {
      return 'A student with this Student ID already exists';
    }

    return null; // No validation errors
  }
}
