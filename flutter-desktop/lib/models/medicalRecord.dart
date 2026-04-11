class MedicalRecord {
  final String id;
  final DateTime date;
  final String? type;
  final String? description;
  final String? value;
  final String? doctorName;
  final String? clinicAddress;
  final String? notes;
  final String? platform;
  final String? category;
  final String? specialty;
  final bool? isRead;
  final String? appointmentId;

  // Nested assessment data
  final List<String>? chiefComplaints;
  final String? examinationDetails;
  final List<String>? suspectedDiseasesList;
  final List<String>? recommendation;
  final String? assessmentNote;

  // Nested signs data
  final Map<String, dynamic>? signs;

  // Nested drugs data
  final List<Map<String, dynamic>>? drugs;

  // Nested sick leave data
  final int? sickLeaveDays;
  final DateTime? sickLeaveStartDate;
  final bool? sickLeaveConfirmed;

  // Attachments
  final List<String>? attachments;

  // Flat format fields (from simplified API response)
  final String? flatDateTime;
  final String? flatComplaint;
  final String? flatSuspectedDiseases;
  final String? flatSickLeave;
  final DateTime? flatSickLeaveStartDate;

  MedicalRecord({
    required this.id,
    required this.date,
    this.type,
    this.description,
    this.value,
    this.doctorName,
    this.clinicAddress,
    this.notes,
    this.platform,
    this.category,
    this.specialty,
    this.isRead,
    this.appointmentId,
    this.chiefComplaints,
    this.examinationDetails,
    this.suspectedDiseasesList,
    this.recommendation,
    this.assessmentNote,
    this.signs,
    this.drugs,
    this.sickLeaveDays,
    this.sickLeaveStartDate,
    this.sickLeaveConfirmed,
    this.attachments,
    this.flatDateTime,
    this.flatComplaint,
    this.flatSuspectedDiseases,
    this.flatSickLeave,
    this.flatSickLeaveStartDate,
  });

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    // Parse assessment
    final assessment = json['assessment'] as Map<String, dynamic>?;
    List<String>? chiefComplaints;
    String? examinationDetails;
    List<String>? suspectedDiseases;
    List<String>? recommendation;
    String? assessmentNote;
    if (assessment != null) {
      chiefComplaints = (assessment['chief_complaints'] as List?)
          ?.map((e) => e.toString())
          .toList();
      examinationDetails = assessment['examination_details'] as String?;
      suspectedDiseases = (assessment['suspected_diseases'] as List?)
          ?.map((e) => e.toString())
          .toList();
      recommendation = (assessment['recommendation'] as List?)
          ?.map((e) => e.toString())
          .toList();
      assessmentNote = assessment['assessment_note'] as String?;
    }

    // Parse sick leave
    final sickLeave = json['sick_leave'] as Map<String, dynamic>?;
    int? sickLeaveDays;
    DateTime? sickLeaveStartDate;
    bool? sickLeaveConfirmed;
    if (sickLeave != null) {
      sickLeaveDays = sickLeave['days'] as int?;
      sickLeaveStartDate = sickLeave['start_date'] != null
          ? DateTime.tryParse(sickLeave['start_date'].toString())
          : null;
      sickLeaveConfirmed = sickLeave['sickleave_confirmed'] as bool?;
    }

    // Parse drugs
    List<Map<String, dynamic>>? drugs;
    if (json['drugs'] is List) {
      drugs = (json['drugs'] as List)
          .map((d) => d as Map<String, dynamic>)
          .toList();
    }

    // Parse attachments
    List<String>? attachments;
    if (json['attachments'] is List) {
      attachments =
          (json['attachments'] as List).map((a) => a.toString()).toList();
    }

    return MedicalRecord(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      type: json['type'] as String?,
      description: json['description'] as String?,
      value: json['value'] as String?,
      doctorName: json['doctorName'] as String?,
      clinicAddress: json['clinicAddress'] as String?,
      notes: json['notes'] as String?,
      platform: json['platform'] as String?,
      category: json['category'] as String?,
      specialty: json['specialty'] as String?,
      isRead: json['is_read'] as bool?,
      appointmentId: json['appointment_id'] as String?,
      chiefComplaints: chiefComplaints,
      examinationDetails: examinationDetails,
      suspectedDiseasesList: suspectedDiseases,
      recommendation: recommendation,
      assessmentNote: assessmentNote,
      signs: json['signs'] as Map<String, dynamic>?,
      drugs: drugs,
      sickLeaveDays: sickLeaveDays,
      sickLeaveStartDate: sickLeaveStartDate,
      sickLeaveConfirmed: sickLeaveConfirmed,
      attachments: attachments,
      // Flat format fields
      flatDateTime: json['dateTime'] as String?,
      flatComplaint: json['complaint'] as String?,
      flatSuspectedDiseases: json['suspectedDiseases'] as String?,
      flatSickLeave: json['sickLeave'] as String?,
      flatSickLeaveStartDate: json['sickLeaveStartDate'] != null
          ? DateTime.tryParse(json['sickLeaveStartDate'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'type': type,
      'description': description,
      'value': value,
      'doctorName': doctorName,
      'clinicAddress': clinicAddress,
      'notes': notes,
      'platform': platform,
      'category': category,
      'specialty': specialty,
      'is_read': isRead,
      'appointment_id': appointmentId,
    };
  }

  // Backward-compatible getters for UI (prefer flat format, fallback to rich)
  String get dateTime {
    if (flatDateTime != null && flatDateTime!.isNotEmpty) return flatDateTime!;
    final d = date;
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final year = d.year;
    final hour = d.hour.toString().padLeft(2, '0');
    final minute = d.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  String get complaint {
    if (flatComplaint != null && flatComplaint!.isNotEmpty) return flatComplaint!;
    if (chiefComplaints != null && chiefComplaints!.isNotEmpty) {
      return chiefComplaints!.join(', ');
    }
    return '-';
  }

  String get suspectedDiseases {
    if (flatSuspectedDiseases != null && flatSuspectedDiseases!.isNotEmpty) return flatSuspectedDiseases!;
    if (suspectedDiseasesList != null && suspectedDiseasesList!.isNotEmpty) {
      return suspectedDiseasesList!.join(', ');
    }
    return '-';
  }

  String? get sickLeave {
    if (flatSickLeave != null && flatSickLeave!.isNotEmpty) return flatSickLeave!;
    if (sickLeaveDays != null) {
      return '$sickLeaveDays days';
    }
    return null;
  }

  String get formattedSickLeave {
    return sickLeave ?? 'None';
  }

  String get formattedSickLeaveStartDate {
    final d = flatSickLeaveStartDate ?? sickLeaveStartDate;
    if (d == null) return 'N/A';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }
}

// Student Detail Response Model
class StudentDetailResponse {
  final StudentDetails student;
  final List<MedicalRecord> records;
  final PaginationData pagination;

  StudentDetailResponse({
    required this.student,
    required this.records,
    required this.pagination,
  });

  factory StudentDetailResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return StudentDetailResponse(
      student:
          StudentDetails.fromJson(data['student'] as Map<String, dynamic>),
      records: ((data['medicalRecords'] ?? data['records']) as List? ?? [])
          .map((r) => MedicalRecord.fromJson(r as Map<String, dynamic>))
          .toList(),
      pagination:
          PaginationData.fromJson(data['pagination'] as Map<String, dynamic>),
    );
  }
}

// Student Details Model (for individual student view)
class StudentDetails {
  final String id;
  final String fullName;
  final String studentId;
  final String? grade;
  final String? className;
  final String gender;
  final DateTime? dateOfBirth;
  final String? bloodType;
  final double? height;
  final double? weight;

  StudentDetails({
    required this.id,
    required this.fullName,
    required this.studentId,
    this.grade,
    this.className,
    required this.gender,
    this.dateOfBirth,
    this.bloodType,
    this.height,
    this.weight,
  });

  factory StudentDetails.fromJson(Map<String, dynamic> json) {
    return StudentDetails(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      studentId: json['studentId'] as String,
      grade: json['grade'] as String?,
      className: json['className'] as String?,
      gender: json['gender'] as String,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'].toString())
          : null,
      bloodType: json['bloodType'] as String?,
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
    );
  }

  String get initials {
    final names = fullName.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  String get formattedDateOfBirth {
    if (dateOfBirth == null) return '-';
    final d = dateOfBirth!;
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  int get age {
    if (dateOfBirth == null) return 0;
    final now = DateTime.now();
    int a = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      a--;
    }
    return a;
  }
}

class PaginationData {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const PaginationData({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaginationData.fromJson(Map<String, dynamic> json) {
    return PaginationData(
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
