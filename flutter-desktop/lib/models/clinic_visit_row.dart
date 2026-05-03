import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ClinicVisitRow {
  final String id;
  final String studentId;
  final String studentName;
  final String studentAid;
  final String? studentPhotoUrl;
  final String gradeName;
  final String className;
  final int cases;
  final DateTime appointmentDate;
  final String appointmentType;
  final String disease;
  final String? doctor;
  final String status;
  final String? cancellationReason;

  ClinicVisitRow({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.studentAid,
    this.studentPhotoUrl,
    required this.gradeName,
    required this.className,
    required this.cases,
    required this.appointmentDate,
    required this.appointmentType,
    required this.disease,
    this.doctor,
    required this.status,
    this.cancellationReason,
  });

  factory ClinicVisitRow.fromJson(Map<String, dynamic> json) {
    final name = json['studentName'];
    String resolvedName;
    if (name is Map) {
      final given = (name['given'] ?? '').toString();
      final family = (name['family'] ?? '').toString();
      resolvedName = '$given $family'.trim();
    } else {
      resolvedName = (name ?? json['fullName'] ?? '').toString();
    }

    return ClinicVisitRow(
      id: (json['id'] ?? '').toString(),
      studentId: (json['studentId'] ?? '').toString(),
      studentName: resolvedName,
      studentAid: (json['studentAid'] ?? json['patientAid'] ?? '').toString(),
      studentPhotoUrl: json['studentPhotoUrl'] as String? ?? json['photo'] as String?,
      gradeName: (json['gradeName'] ?? '').toString(),
      className: (json['className'] ?? '').toString(),
      cases: (json['cases'] is int)
          ? json['cases'] as int
          : int.tryParse('${json['cases'] ?? 0}') ?? 0,
      appointmentDate: json['appointmentDate'] != null
          ? DateTime.parse(json['appointmentDate'].toString())
          : DateTime.now(),
      appointmentType: (json['appointmentType'] ?? '').toString(),
      disease: (json['disease'] ?? json['reason'] ?? '').toString().trim(),
      doctor: json['doctor'] as String?,
      status: (json['status'] ?? json['appointmentStatus'] ?? '').toString(),
      cancellationReason:
          json['cancellationReason'] as String? ?? json['cancelReason'] as String?,
    );
  }

  bool get hasCancellationReason =>
      cancellationReason != null && cancellationReason!.trim().isNotEmpty;

  String get gradeAndClass {
    if (gradeName.isEmpty && className.isEmpty) return '--';
    if (gradeName.isEmpty) return className;
    if (className.isEmpty) return gradeName;
    return '$gradeName - $className';
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
        return appointmentType.isEmpty ? '--' : appointmentType;
    }
  }

  String get dateTimeFormatted {
    try {
      return DateFormat('dd/MM/yyyy - hh:mm a').format(appointmentDate);
    } catch (_) {
      return appointmentDate.toIso8601String();
    }
  }

  String get initials {
    final parts = studentName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (studentName.isNotEmpty) return studentName[0].toUpperCase();
    return '?';
  }

  /// UI-facing status label per screenshot: Completed / Canceled / Expired / Booked.
  String get displayStatus {
    final s = status.toLowerCase();
    if (s == 'fulfilled' || s == 'completed' || s == 'checked') return 'Completed';
    if (s == 'cancelled' || s == 'canceled') return 'Canceled';
    if (s == 'expired') return 'Expired';
    if (s == 'booked') {
      return appointmentDate.isBefore(DateTime.now()) ? 'Expired' : 'Booked';
    }
    return status.isEmpty ? '--' : status;
  }

  Color get displayStatusColor {
    switch (displayStatus) {
      case 'Completed':
        return const Color(0xFF059669);
      case 'Canceled':
        return const Color(0xFFDC2626);
      case 'Expired':
        return const Color(0xFFD97706);
      case 'Booked':
        return const Color(0xFF1339FF);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color get displayStatusBgColor {
    switch (displayStatus) {
      case 'Completed':
        return const Color(0xFFD1FAE5);
      case 'Canceled':
        return const Color(0xFFFFEBEE);
      case 'Expired':
        return const Color(0xFFFEF3C7);
      case 'Booked':
        return const Color(0xFFE0E7FF);
      default:
        return const Color(0xFFF3F4F6);
    }
  }
}

class ClinicVisitsMeta {
  final int page;
  final int limit;
  final int totalPages;
  final int totalCount;

  ClinicVisitsMeta({
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.totalCount,
  });

  factory ClinicVisitsMeta.fromJson(Map<String, dynamic> json) {
    return ClinicVisitsMeta(
      page: (json['page'] is int)
          ? json['page'] as int
          : int.tryParse('${json['page'] ?? 1}') ?? 1,
      limit: (json['limit'] is int)
          ? json['limit'] as int
          : int.tryParse('${json['limit'] ?? 20}') ?? 20,
      totalPages: (json['totalPages'] is int)
          ? json['totalPages'] as int
          : int.tryParse('${json['totalPages'] ?? 1}') ?? 1,
      totalCount: (json['totalCount'] is int)
          ? json['totalCount'] as int
          : int.tryParse('${json['totalCount'] ?? 0}') ?? 0,
    );
  }

  ClinicVisitsMeta.empty()
      : page = 1,
        limit = 20,
        totalPages = 1,
        totalCount = 0;
}

class ClinicVisitsResponse {
  final List<ClinicVisitRow> rows;
  final ClinicVisitsMeta meta;

  ClinicVisitsResponse({required this.rows, required this.meta});

  factory ClinicVisitsResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    final List list = raw is List
        ? raw
        : (raw is Map && raw['rows'] is List)
            ? raw['rows'] as List
            : (raw is Map && raw['visits'] is List)
                ? raw['visits'] as List
                : const [];

    ClinicVisitsMeta meta = ClinicVisitsMeta.empty();
    final metaJson = json['meta'] ??
        (raw is Map ? raw['meta'] : null) ??
        json['pagination'];
    if (metaJson is Map<String, dynamic>) {
      meta = ClinicVisitsMeta.fromJson(metaJson);
    }

    return ClinicVisitsResponse(
      rows: list
          .map((e) => ClinicVisitRow.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: meta,
    );
  }
}
