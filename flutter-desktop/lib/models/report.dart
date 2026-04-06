class Report {
  final String id;
  final String reportTitle;
  final String templateId;
  final String organizationId;
  final String branchId;
  final DateTime dateFrom;
  final DateTime dateTo;
  final String? vaccinationType;
  final String? doctorId;
  final String? grade;
  final List<String>? classIds;
  final List<String>? studentIds;
  final int studentCount;
  final int records;
  final DateTime createdAt;
  final String status; // 'pending', 'processing', 'completed', 'failed'

  Report({
    required this.id,
    required this.reportTitle,
    required this.templateId,
    required this.organizationId,
    required this.branchId,
    required this.dateFrom,
    required this.dateTo,
    this.vaccinationType,
    this.doctorId,
    this.grade,
    this.classIds,
    this.studentIds,
    required this.studentCount,
    required this.records,
    required this.createdAt,
    this.status = 'completed',
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] ?? '',
      reportTitle: json['reportDetails']?['title'] ?? '',
      templateId: json['reportType'] ?? '', // Using reportType as templateId
      organizationId: '', // Not in response
      branchId: '', // Not in response
      dateFrom: DateTime.now(), // Not in response
      dateTo: DateTime.now(), // Not in response
      grade: json['gradesAndClasses'],
      studentCount: json['reportDetails']?['studentCount'] ?? 0,
      records: json['records'] ?? 0,
      createdAt:
          DateTime.parse(json['dateTime'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'completed',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reportTitle': reportTitle,
      'templateId': templateId,
      'organizationId': organizationId,
      'branchId': branchId,
      'dateFrom': dateFrom.toIso8601String().split('T')[0],
      'dateTo': dateTo.toIso8601String().split('T')[0],
      if (vaccinationType != null) 'vaccinationType': vaccinationType,
      if (doctorId != null) 'doctorId': doctorId,
      if (grade != null) 'grade': grade,
      if (classIds != null) 'classIds': classIds,
      if (studentIds != null) 'studentIds': studentIds,
    };
  }

  String get gradesAndClasses {
    if (grade != null) {
      return grade!;
    }
    return 'All';
  }

  String get reportType {
    return reportTitle;
  }
}

class ReportTemplate {
  final String id;
  final String name;
  final String description;
  final String type;

  ReportTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
  });

  factory ReportTemplate.fromJson(Map<String, dynamic> json) {
    return ReportTemplate(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
    );
  }
}
