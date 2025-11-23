class MedicalRecord {
  final DateTime date;
  final String complaint;
  final String suspectedDiseases;
  final int sickLeaveDays;
  final DateTime sickLeaveStartDate;

  MedicalRecord({
    required this.date,
    required this.complaint,
    required this.suspectedDiseases,
    required this.sickLeaveDays,
    required this.sickLeaveStartDate,
  });

  String get formattedDate {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} - ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} ${date.hour >= 12 ? 'PM' : 'AM'}';
  }

  String get formattedStartDate {
    return '${sickLeaveStartDate.day.toString().padLeft(2, '0')}/${sickLeaveStartDate.month.toString().padLeft(2, '0')}/${sickLeaveStartDate.year}';
  }
  String get formattedEndDate {
    DateTime endDate = sickLeaveStartDate.add(Duration(days: sickLeaveDays));
    return '${endDate.day.toString().padLeft(2, '0')}/${endDate.month.toString().padLeft(2, '0')}/${endDate.year}';
  }
  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      date: DateTime.parse(json['date']),
      complaint: json['complaint'],
      suspectedDiseases: json['suspectedDiseases'],
      sickLeaveDays: json['sickLeaveDays'],
      sickLeaveStartDate: DateTime.parse(json['sickLeaveStartDate']),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'complaint': complaint,
      'suspectedDiseases': suspectedDiseases,
      'sickLeaveDays': sickLeaveDays,
      'sickLeaveStartDate': sickLeaveStartDate.toIso8601String(),
    };
  }
}
