import 'package:flutter/material.dart';

class AppointmentHistory {
  final String id;
  final DateTime date;
  final String dateTime; // Formatted: "16/01/2026 - 08:20 PM"
  final String status; // booked, fulfilled, cancelled
  final String type; // checkup, consultation, followup, etc.
  final String formattedType;
  final PatientInfo patient;
  final String grade;
  final String className;
  final String gradeAndClass;
  final int cases;
  final String? disease;
  final DoctorInfo doctor;
  final String description;
  final String? cancelationReason;

  AppointmentHistory({
    required this.id,
    required this.date,
    required this.dateTime,
    required this.status,
    required this.type,
    required this.formattedType,
    required this.patient,
    required this.grade,
    required this.className,
    required this.gradeAndClass,
    required this.cases,
    this.disease,
    required this.doctor,
    required this.description,
    this.cancelationReason,
  });

  factory AppointmentHistory.fromJson(Map<String, dynamic> json) {
    return AppointmentHistory(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      dateTime: json['dateTime'] as String,
      status: json['status'] as String,
      type: json['type'] as String,
      formattedType: json['formattedType'] as String,
      patient: PatientInfo.fromJson(json['patient'] as Map<String, dynamic>),
      grade: json['grade'] as String,
      className: json['className'] as String,
      gradeAndClass: json['gradeAndClass'] as String,
      cases: json['cases'] as int,
      disease: json['disease'] as String?,
      doctor: DoctorInfo.fromJson(json['doctor'] as Map<String, dynamic>),
      description: json['description'] as String,
      cancelationReason: json['cancelationReason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'dateTime': dateTime,
      'status': status,
      'type': type,
      'formattedType': formattedType,
      'patient': patient.toJson(),
      'grade': grade,
      'className': className,
      'gradeAndClass': gradeAndClass,
      'cases': cases,
      'disease': disease,
      'doctor': doctor.toJson(),
      'description': description,
      'cancelationReason': cancelationReason,
    };
  }

  // Helper getters
  String get statusDisplay {
    switch (status.toLowerCase()) {
      case 'booked':
        return 'Incomplete';
      case 'fulfilled':
        return 'Incomplete';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'booked':
        return const Color(0xFFFFA500); // Orange
      case 'fulfilled':
        return const Color(0xFFFFA500); // Orange
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color get statusBackgroundColor {
    switch (status.toLowerCase()) {
      case 'booked':
        return const Color(0xFFFFF3E0);
      case 'fulfilled':
        return const Color(0xFFFFF3E0);
      case 'cancelled':
        return const Color(0xFFFFEBEE);
      default:
        return Colors.grey.shade100;
    }
  }
}

class PatientInfo {
  final String id;
  final String name;
  final String studentId;
  final String fullName;

  PatientInfo({
    required this.id,
    required this.name,
    required this.studentId,
    required this.fullName,
  });

  factory PatientInfo.fromJson(Map<String, dynamic> json) {
    return PatientInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      studentId: json['studentId'] as String,
      fullName: json['fullName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'studentId': studentId,
      'fullName': fullName,
    };
  }

  // Helper to get initials
  String get initials {
    final names = fullName.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }
}

class DoctorInfo {
  final String id;
  final String name;

  DoctorInfo({
    required this.id,
    required this.name,
  });

  factory DoctorInfo.fromJson(Map<String, dynamic> json) {
    return DoctorInfo(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class AppointmentHistoryResponse {
  final List<AppointmentHistory> appointments;
  final PaginationInfo pagination;

  AppointmentHistoryResponse({
    required this.appointments,
    required this.pagination,
  });

  factory AppointmentHistoryResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return AppointmentHistoryResponse(
      appointments: (data['appointments'] as List)
          .map((a) => AppointmentHistory.fromJson(a as Map<String, dynamic>))
          .toList(),
      pagination:
          PaginationInfo.fromJson(data['pagination'] as Map<String, dynamic>),
    );
  }
}

class PaginationInfo {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  PaginationInfo({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      page: json['page'] as int,
      limit: json['limit'] as int,
      total: json['total'] as int,
      totalPages: json['totalPages'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'total': total,
      'totalPages': totalPages,
    };
  }
}
