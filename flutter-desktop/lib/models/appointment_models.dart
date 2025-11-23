import '../../../../models/student.dart';

// Enum for appointment status
enum AppointmentStatus { done, notDone,cancelled ,received,pendingApproval }

// Model for appointment student combination
class AppointmentStudent {
  final String appointmentId;
  final Student student;
  AppointmentStatus status;

  AppointmentStudent({
    required this.appointmentId,
    required this.student,
    required this.status,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppointmentStudent &&
          runtimeType == other.runtimeType &&
          appointmentId == other.appointmentId &&
          student.id == other.student.id;

  @override
  int get hashCode => appointmentId.hashCode ^ student.id.hashCode;

  // Helper method to create a copy with updated status
  AppointmentStudent copyWith({
    String? appointmentId,
    Student? student,
    AppointmentStatus? status,
  }) {
    return AppointmentStudent(
      appointmentId: appointmentId ?? this.appointmentId,
      student: student ?? this.student,
      status: status ?? this.status,
    );
  }

  // Convert to JSON for API calls
  Map<String, dynamic> toJson() {
    return {
      'appointmentId': appointmentId,
      'student': student.toJson(),
      'status': status.name,
    };
  }

  // Create from JSON
  factory AppointmentStudent.fromJson(Map<String, dynamic> json) {
    return AppointmentStudent(
      appointmentId: json['appointmentId'],
      student: Student.fromJson(json['student']),
      status: AppointmentStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => AppointmentStatus.notDone,
      ),
    );
  }
}