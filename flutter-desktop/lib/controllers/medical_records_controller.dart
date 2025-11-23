import 'package:flutter_getx_app/models/medicalRecord.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/student.dart';

enum MedicalRecordsState { loading, success, error, empty }

class MedicalRecordsController extends GetxController {
  final RxList<Student> allStudents = <Student>[].obs;
  final RxList<Student> displayedStudents = <Student>[].obs;
final Rx<Student?> selectedStudent = Rx<Student?>(null);
void clearSelectedStudent() {
  selectedStudent.value = null;
}
  final Rx<MedicalRecordsState> state = MedicalRecordsState.loading.obs;
  final RxBool isLoading = false.obs;
  final RxString currentFilter = 'all'.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRecords();
  }

  Future<void> fetchRecords() async {
    try {
      isLoading.value = true;
      state.value = MedicalRecordsState.loading;

      await Future.delayed(const Duration(seconds: 1));

final mockStudents = List.generate(5, (i) {
  final records = List.generate(4, (j) {
    return MedicalRecord(
      date: DateTime(2025, 6, 16, 13, 37),
      complaint: 'Complaint',
      suspectedDiseases: 'Suspected diseases',
      sickLeaveDays: 2,
      sickLeaveStartDate: DateTime(2025, 6, 16),
    );
  });

  return Student(
    id: '$i',
    name: 'Ahmed Khaled Ali Ibrahim',
    avatarColor: Colors.blue,
    studentId: '290000000000',
    aid: '4EG23905U7H',
    grade: 'G4',
    className: 'Lions',
    lastAppointmentDate: DateTime(2025, 6, 16, 13, 37),
    emrNumber: records.length,
    medicalRecords: records,
  );
});


      allStudents.assignAll(mockStudents);
      displayedStudents.assignAll(mockStudents);

      state.value = displayedStudents.isEmpty
          ? MedicalRecordsState.empty
          : MedicalRecordsState.success;
    } catch (e) {
      state.value = MedicalRecordsState.error;
    } finally {
      isLoading.value = false;
    }
  }

  void searchRecords(String query) {
    searchQuery.value = query.trim().toLowerCase();
    _applySearchAndFilter();
  }

  void filterByStatus(String filter) {
    currentFilter.value = filter;
    _applySearchAndFilter();
  }

  void _applySearchAndFilter() {
    List<Student> filtered = List.from(allStudents);

    // (Optional) Apply status filter if needed later (e.g., by visit type or EMR presence)

    // Apply search
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((student) {
        final name = student.name.toLowerCase();
        final aid = student.aid?.toLowerCase() ?? '';
        final sid = student.studentId?.toLowerCase() ?? '';
        return name.contains(searchQuery.value) ||
            aid.contains(searchQuery.value) ||
            sid.contains(searchQuery.value);
      }).toList();
    }

    displayedStudents.assignAll(filtered);

    state.value = displayedStudents.isEmpty
        ? MedicalRecordsState.empty
        : MedicalRecordsState.success;
  }

  void refreshRecords() {
    fetchRecords();
  }
}
