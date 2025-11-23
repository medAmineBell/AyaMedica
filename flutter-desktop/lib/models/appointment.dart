import 'package:flutter_getx_app/models/appointment_models.dart';
import 'package:flutter_getx_app/models/student.dart';

class Appointment {
  String? id;
  final String type;
  final bool allStudents;
  final DateTime date;
  final String time;
  final String disease;
  final String diseaseType;
  final String grade;
  final String className;
  final String doctor;
  final List<Student> selectedStudents;
  AppointmentStatus status; // Added status field

  Appointment({
    this.id,
    required this.type,
    required this.allStudents,
    required this.date,
    required this.time,
    required this.disease,
    required this.diseaseType,
    required this.grade,
    required this.className,
    required this.doctor,
    required this.selectedStudents,
    this.status = AppointmentStatus.notDone, // Default status
  });

  // Convert to JSON for API calls
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'allStudents': allStudents,
      'date': date.toIso8601String(),
      'time': time,
      'disease': disease,
      'diseaseType': diseaseType,
      'grade': grade,
      'className': className,
      'doctor': doctor,
      'selectedStudents': selectedStudents.map((student) => student.toJson()).toList(),
      'status': status, // Include status in JSON
    };
  }

  // Create from JSON
  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      type: json['type'],
      allStudents: json['allStudents'],
      date: DateTime.parse(json['date']),
      time: json['time'],
      disease: json['disease'],
      diseaseType: json['diseaseType'],
      grade: json['grade'],
      className: json['className'],
      doctor: json['doctor'],
      selectedStudents: (json['selectedStudents'] as List)
          .map((studentJson) => Student.fromJson(studentJson))
          .toList(),
      status: json['status'] ?? 'Scheduled', // Handle status from JSON
    );
  }

  // Add copyWith method to create modified copies
  Appointment copyWith({
    String? id,
    String? type,
    bool? allStudents,
    DateTime? date,
    String? time,
    String? disease,
    String? diseaseType,
    String? grade,
    String? className,
    String? doctor,
    List<Student>? selectedStudents,
    AppointmentStatus? status,
  }) {
    return Appointment(
      id: id ?? this.id,
      type: type ?? this.type,
      allStudents: allStudents ?? this.allStudents,
      date: date ?? this.date,
      time: time ?? this.time,
      disease: disease ?? this.disease,
      diseaseType: diseaseType ?? this.diseaseType,
      grade: grade ?? this.grade,
      className: className ?? this.className,
      doctor: doctor ?? this.doctor,
      selectedStudents: selectedStudents ?? this.selectedStudents,
      status: status ?? this.status,
    );
  }
}