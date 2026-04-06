import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppointmentHistory {
  final String id;
  final String country;
  final String branchId;
  final String createdByAid;
  final DateTime createdAt;
  final DateTime appointmentDate;
  final String? updatedByAid;
  final DateTime updatedAt;
  final String? checkedOutByAid;
  final DateTime? checkOutDate;
  final String appointmentType;
  final String? disease;
  final String? vaccineType;
  final DateTime? vaccineTypeLastConfirmationDate;
  final bool allPatientsChecked;
  final int checkedPatientsCount;
  final int uncheckedPatientsCount;
  final bool includesOnePatient;
  final String gradeName;
  final String gradeId;
  final String className;
  final String classId;
  final int totalPatientsCount;
  final String? onePatientAid;
  final bool enableNotification;
  final String? canceledByAid;
  final String appointmentStatus;
  final String? cancelReason;
  final String? fullName;
  final String? medicalRecordId;

  AppointmentHistory({
    required this.id,
    required this.country,
    required this.branchId,
    required this.createdByAid,
    required this.createdAt,
    required this.appointmentDate,
    this.updatedByAid,
    required this.updatedAt,
    this.checkedOutByAid,
    this.checkOutDate,
    required this.appointmentType,
    this.disease,
    this.vaccineType,
    this.vaccineTypeLastConfirmationDate,
    required this.allPatientsChecked,
    required this.checkedPatientsCount,
    required this.uncheckedPatientsCount,
    required this.includesOnePatient,
    required this.gradeName,
    required this.gradeId,
    required this.className,
    required this.classId,
    required this.totalPatientsCount,
    this.onePatientAid,
    required this.enableNotification,
    this.canceledByAid,
    required this.appointmentStatus,
    this.cancelReason,
    this.fullName,
    this.medicalRecordId,
  });

  factory AppointmentHistory.fromJson(Map<String, dynamic> json) {
    return AppointmentHistory(
      id: json['id'] as String,
      country: json['country'] as String? ?? '',
      branchId: json['branchId'] as String? ?? '',
      createdByAid: json['createdByAID'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      appointmentDate: DateTime.parse(json['appointmentDate'] as String),
      updatedByAid: json['updatedByAID'] as String?,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      checkedOutByAid: json['checkedOutByAID'] as String?,
      checkOutDate: json['checkOutDate'] != null
          ? DateTime.parse(json['checkOutDate'] as String)
          : null,
      appointmentType: json['appointmentType'] as String? ?? '',
      disease: json['reason'] as String?,
      vaccineType: json['vaccineType'] as String?,
      vaccineTypeLastConfirmationDate:
          json['vaccineLastConfirmationDate'] != null
              ? DateTime.parse(
                  json['vaccineLastConfirmationDate'] as String)
              : null,
      allPatientsChecked: json['allPatientsChecked'] as bool? ?? false,
      checkedPatientsCount: json['checkedPatientsCount'] as int? ?? 0,
      uncheckedPatientsCount: json['unCheckedPatientsCount'] as int? ?? 0,
      includesOnePatient: json['includesOnePatient'] as bool? ?? false,
      gradeName: json['gradeName'] as String? ?? '',
      gradeId: json['gradeId'] as String? ?? '',
      className: json['className'] as String? ?? '',
      classId: json['classId'] as String? ?? '',
      totalPatientsCount: json['totalPatientsCount'] as int? ?? 0,
      onePatientAid: json['onePatientAid'] as String?,
      enableNotification: json['enableNotification'] as bool? ?? false,
      canceledByAid: json['canceledByAID'] as String?,
      appointmentStatus: json['appointmentStatus'] as String? ?? '',
      cancelReason: json['cancelReason'] as String?,
      fullName: json['fullName'] as String?,
      medicalRecordId: json['medicalRecordId'] as String?,
    );
  }

  // Convenience getters for UI display
  String get gradeAndClass => '$gradeName - $className';

  bool get isWalkIn => appointmentType.toLowerCase() == 'walkin';

  /// Display name: fullName for walk-in, "ClassName Class | GradeName" otherwise
  String get nameDisplay {
    if (isWalkIn && fullName != null && fullName!.isNotEmpty) {
      return fullName!;
    }
    return '$className Class | $gradeName';
  }

  /// Subtitle: onePatientAid for walk-in, "X students" otherwise
  String get subtitleDisplay {
    if (isWalkIn && onePatientAid != null) {
      return onePatientAid!;
    }
    return '$totalPatientsCount students';
  }

  /// Initials for avatar: from fullName for walk-in, class+grade otherwise
  String get initials {
    if (isWalkIn && fullName != null && fullName!.isNotEmpty) {
      final parts = fullName!.trim().split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return fullName![0].toUpperCase();
    }
    final c = className.isNotEmpty ? className[0].toUpperCase() : '';
    final g = gradeName.isNotEmpty ? gradeName[0].toUpperCase() : '';
    return '$c$g';
  }

  String get formattedType {
    switch (appointmentType.toLowerCase()) {
      case 'walkin':
        return 'Walk in';
      case 'scheduled':
        return 'Scheduled';
      case 'vaccine':
        return 'Vaccine';
      case 'followup':
        return 'Follow up';
      case 'checkup':
        return 'Checkup';
      default:
        return appointmentType;
    }
  }

  /// Disease type display for the "Type" column
  String get typeDisplay => disease ?? '--';

  /// Cases count display
  String get casesDisplay {
    if (appointmentType.toLowerCase() == 'walkin') return '--';
    return '$totalPatientsCount';
  }

  String get dateTimeFormatted {
    try {
      return DateFormat('dd MMM yyyy, hh:mm a').format(appointmentDate);
    } catch (_) {
      return appointmentDate.toIso8601String();
    }
  }

  /// New status display matching the redesigned UI
  String get displayStatus {
    final status = appointmentStatus.toLowerCase();
    if (status == 'cancelled') return 'Cancelled';
    if (status == 'fulfilled') return 'Checked out';

    // Booked status - derive from time and patient counts
    if (status == 'booked') {
      final now = DateTime.now();
      final diff = appointmentDate.difference(now);

      // Future appointment - show countdown
      if (diff.inMinutes > 0) {
        final hours = diff.inHours;
        final minutes = diff.inMinutes % 60;
        if (hours > 0) {
          return 'Starting in ${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')} hr';
        }
        return 'Starting in ${minutes.toString().padLeft(2, '0')}:${(diff.inSeconds % 60).toString().padLeft(2, '0')} min';
      }

      // Past/current appointment
      if (checkedPatientsCount == 0) return 'Not Started';
      if (!allPatientsChecked) return 'Incomplete';
      return 'Completed';
    }

    return appointmentStatus;
  }

  /// Status text color for the redesigned UI
  Color get displayStatusColor {
    final status = appointmentStatus.toLowerCase();
    if (status == 'cancelled') return const Color(0xFFDC2626);
    if (status == 'fulfilled') return const Color(0xFF059669);

    if (status == 'booked') {
      final now = DateTime.now();
      final diff = appointmentDate.difference(now);
      if (diff.inMinutes > 0) return const Color(0xFF059669); // Starting in...
      if (checkedPatientsCount == 0) return const Color(0xFFDC2626); // Not Started
      if (!allPatientsChecked) return const Color(0xFFDC2626); // Incomplete
      return const Color(0xFF059669);
    }

    return Colors.grey;
  }

  /// Status background color for the redesigned UI
  Color get displayStatusBgColor {
    final status = appointmentStatus.toLowerCase();
    if (status == 'cancelled') return const Color(0xFFFFEBEE);
    if (status == 'fulfilled') return const Color(0xFFD1FAE5);

    if (status == 'booked') {
      final now = DateTime.now();
      final diff = appointmentDate.difference(now);
      if (diff.inMinutes > 0) return const Color(0xFFD1FAE5); // green bg
      if (checkedPatientsCount == 0) return const Color(0xFFFFEBEE); // red bg
      if (!allPatientsChecked) return const Color(0xFFFFEBEE); // red bg
      return const Color(0xFFD1FAE5);
    }

    return Colors.grey.shade100;
  }

  // Keep old getters for backward compatibility
  String get statusDisplay => displayStatus;
  Color get statusColor => displayStatusColor;
  Color get statusBackgroundColor => displayStatusBgColor;
}

class AppointmentHistoryResponse {
  final List<AppointmentHistory> appointments;

  AppointmentHistoryResponse({
    required this.appointments,
  });

  factory AppointmentHistoryResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List;
    return AppointmentHistoryResponse(
      appointments: data
          .map((a) => AppointmentHistory.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }
}
