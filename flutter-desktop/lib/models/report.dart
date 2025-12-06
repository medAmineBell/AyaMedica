class Report {
  final String id;
  final String reportType;
  final String gradesAndClasses;
  final int records;
  final DateTime dateTime;
  final int studentCount;

  Report({
    required this.id,
    required this.reportType,
    required this.gradesAndClasses,
    required this.records,
    required this.dateTime,
    required this.studentCount,
  });
}

