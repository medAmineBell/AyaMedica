import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/calendar_controller.dart';
import 'package:flutter_getx_app/models/appointment.dart';
import 'package:flutter_getx_app/models/student.dart';
import 'package:get/get.dart';

enum PresenceStatus { present, absent }

enum BMICategory { normal, overweight, obesity, underweight }

class StudentAppointmentData {
  final Student student;
  PresenceStatus presence;
  double? height; // in CM
  double? weight; // in Kg
  String note;
  BMICategory? bmiCategory;
  double? bmiValue;

  StudentAppointmentData({
    required this.student,
    this.presence = PresenceStatus.present,
    this.height,
    this.weight,
    this.note = '',
    this.bmiCategory,
    this.bmiValue,
  });

  void calculateBMI() {
    if (height != null && weight != null && height! > 0) {
      // BMI = weight (kg) / (height (m))^2
      final heightInMeters = height! / 100;
      bmiValue = weight! / (heightInMeters * heightInMeters);

      if (bmiValue! < 18.5) {
        bmiCategory = BMICategory.underweight;
      } else if (bmiValue! < 25) {
        bmiCategory = BMICategory.normal;
      } else if (bmiValue! < 30) {
        bmiCategory = BMICategory.overweight;
      } else {
        bmiCategory = BMICategory.obesity;
      }
    } else {
      bmiValue = null;
      bmiCategory = null;
    }
  }
}

class AppointmentDetailsController extends GetxController {
  final Appointment appointment;
  final RxList<StudentAppointmentData> studentsData =
      <StudentAppointmentData>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'All'.obs;

  AppointmentDetailsController({required this.appointment});

  @override
  void onInit() {
    super.onInit();
    _initializeStudentsData();
  }

  void _initializeStudentsData() {
    final students = appointment.allStudents
        ? _generateAllStudents(appointment.className, appointment.grade)
        : appointment.selectedStudents;

    studentsData.value = students.map((student) {
      return StudentAppointmentData(
        student: student,
        presence: PresenceStatus.present,
        height: null,
        weight: null,
        note: '',
      );
    }).toList();
  }

  List<Student> _generateAllStudents(String className, String grade) {
    // Generate 23 sample students
    return List.generate(23, (index) {
      return Student(
        id: 'student_${appointment.id}_$index',
        name: index == 0 ? 'Full name goes here' : 'Student ${index + 1}',
        avatarColor: Colors.blue,
        grade: grade,
        className: className,
        studentId: 'AID${index.toString().padLeft(6, '0')}',
      );
    });
  }

  void updatePresence(int index, PresenceStatus presence) {
    studentsData[index].presence = presence;
    if (presence == PresenceStatus.absent) {
      studentsData[index].height = null;
      studentsData[index].weight = null;
      studentsData[index].bmiValue = null;
      studentsData[index].bmiCategory = null;
    }
    studentsData.refresh();
  }

  void updateHeight(int index, String value) {
    final height = double.tryParse(value);
    studentsData[index].height = height;
    studentsData[index].calculateBMI();
    studentsData.refresh();
  }

  void updateWeight(int index, String value) {
    final weight = double.tryParse(value);
    studentsData[index].weight = weight;
    studentsData[index].calculateBMI();
    studentsData.refresh();
  }

  void updateNote(int index, String value) {
    studentsData[index].note = value;
    studentsData.refresh();
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  List<StudentAppointmentData> get filteredStudents {
    var filtered = studentsData.toList();

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((data) {
        return data.student.name.toLowerCase().contains(query) ||
            (data.student.studentId?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Apply category filter
    if (selectedFilter.value != 'All') {
      filtered = filtered.where((data) {
        if (selectedFilter.value == 'Absent') {
          return data.presence == PresenceStatus.absent;
        }
        if (data.presence == PresenceStatus.absent ||
            data.bmiCategory == null) {
          return false;
        }
        switch (selectedFilter.value) {
          case 'Normal':
            return data.bmiCategory == BMICategory.normal;
          case 'Overweight':
            return data.bmiCategory == BMICategory.overweight;
          case 'Obesity':
            return data.bmiCategory == BMICategory.obesity;
          case 'Underweight':
            return data.bmiCategory == BMICategory.underweight;
          default:
            return true;
        }
      }).toList();
    }

    return filtered;
  }

  int get allCount => studentsData.length;
  int get normalCount =>
      studentsData.where((d) => d.bmiCategory == BMICategory.normal).length;
  int get overweightCount =>
      studentsData.where((d) => d.bmiCategory == BMICategory.overweight).length;
  int get obesityCount =>
      studentsData.where((d) => d.bmiCategory == BMICategory.obesity).length;
  int get underweightCount => studentsData
      .where((d) => d.bmiCategory == BMICategory.underweight)
      .length;
  int get absentCount =>
      studentsData.where((d) => d.presence == PresenceStatus.absent).length;

  void completeAppointment() {
    // TODO: Save appointment data and mark as complete
    final calendarController = Get.find<CalendarController>();
    calendarController.hideAppointmentDetails();
    Get.snackbar(
      'Success',
      'Appointment completed successfully',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
}
