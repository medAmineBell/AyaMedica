class MedicalRecord {
  final String id;
  final DateTime date;
  final String dateTime; // Formatted string from API
  final String complaint;
  final String suspectedDiseases;
  final String? sickLeave; // nullable - can be "2 days" or null
  final DateTime? sickLeaveStartDate; // nullable

  MedicalRecord({
    required this.id,
    required this.date,
    required this.dateTime,
    required this.complaint,
    required this.suspectedDiseases,
    this.sickLeave,
    this.sickLeaveStartDate,
  });

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      dateTime: json['dateTime'] as String,
      complaint: json['complaint'] as String,
      suspectedDiseases: json['suspectedDiseases'] as String,
      sickLeave: json['sickLeave'] as String?,
      sickLeaveStartDate: json['sickLeaveStartDate'] != null
          ? DateTime.parse(json['sickLeaveStartDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'dateTime': dateTime,
      'complaint': complaint,
      'suspectedDiseases': suspectedDiseases,
      'sickLeave': sickLeave,
      'sickLeaveStartDate': sickLeaveStartDate?.toIso8601String(),
    };
  }

  // Helper to get formatted sick leave display
  String get formattedSickLeave {
    if (sickLeave == null) return 'None';
    return sickLeave!;
  }

  // Helper to get formatted sick leave start date
  String get formattedSickLeaveStartDate {
    if (sickLeaveStartDate == null) return 'N/A';
    final date = sickLeaveStartDate!;
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
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
      student: StudentDetails.fromJson(data['student'] as Map<String, dynamic>),
      records: (data['records'] as List)
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
  final String grade;
  final String className;
  final String gender;
  final DateTime dateOfBirth;
  final String bloodType;
  final int height; // in cm
  final int weight; // in kg

  StudentDetails({
    required this.id,
    required this.fullName,
    required this.studentId,
    required this.grade,
    required this.className,
    required this.gender,
    required this.dateOfBirth,
    required this.bloodType,
    required this.height,
    required this.weight,
  });

  factory StudentDetails.fromJson(Map<String, dynamic> json) {
    return StudentDetails(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      studentId: json['studentId'] as String,
      grade: json['grade'] as String,
      className: json['className'] as String,
      gender: json['gender'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      bloodType: json['bloodType'] as String,
      height: json['height'] as int,
      weight: json['weight'] as int,
    );
  }

  // Helper to get initials
  String get initials {
    final names = fullName.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  // Helper to get formatted date of birth
  String get formattedDateOfBirth {
    return '${dateOfBirth.day.toString().padLeft(2, '0')}/${dateOfBirth.month.toString().padLeft(2, '0')}/${dateOfBirth.year}';
  }

  // Helper to get age
  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
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
