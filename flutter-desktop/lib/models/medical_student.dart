class MedicalStudent {
  final String id;
  final String fullName;
  final String studentId;
  final String? grade;
  final String? className;
  final String? gradeAndClass;
  final int numberOfRecords;
  final DateTime? lastVisit;
  final String? lastVisitRaw; // Keep original string for display

  const MedicalStudent({
    required this.id,
    required this.fullName,
    required this.studentId,
    this.grade,
    this.className,
    this.gradeAndClass,
    required this.numberOfRecords,
    this.lastVisit,
    this.lastVisitRaw,
  });

  factory MedicalStudent.fromJson(Map<String, dynamic> json) {
    return MedicalStudent(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      studentId: json['studentId'] as String,
      grade: json['grade'] as String?,
      className: json['className'] as String?,
      gradeAndClass: json['gradeAndClass'] as String?,
      numberOfRecords: json['numberOfRecords'] as int? ?? 0,
      lastVisitRaw: json['lastVisit'] as String?,
      lastVisit: json['lastVisit'] != null
          ? _parseCustomDate(json['lastVisit'] as String)
          : null,
    );
  }

  /// Custom date parser to handle formats like "27[/12/2025](), 08:20 pm"
  static DateTime? _parseCustomDate(String dateStr) {
    try {
      // Remove square brackets, parentheses and clean up the string
      // "27[/12/2025](), 08:20 pm" -> "27/12/2025, 08:20 pm"
      String cleaned = dateStr
          .replaceAll('[', '')
          .replaceAll(']', '')
          .replaceAll('()', '')
          .trim();

      // Split by comma to separate date and time
      final parts = cleaned.split(',');
      if (parts.isEmpty) return null;

      final datePart = parts[0].trim(); // "27/12/2025"
      final timePart = parts.length > 1 ? parts[1].trim() : null; // "08:20 pm"

      // Parse date part (dd/MM/yyyy)
      final dateComponents = datePart.split('/');
      if (dateComponents.length != 3) return null;

      final day = int.tryParse(dateComponents[0]);
      final month = int.tryParse(dateComponents[1]);
      final year = int.tryParse(dateComponents[2]);

      if (day == null || month == null || year == null) return null;

      // Parse time part if available
      int hour = 0;
      int minute = 0;

      if (timePart != null) {
        final timeComponents = timePart.toLowerCase().split(' ');
        if (timeComponents.isNotEmpty) {
          final timeStr = timeComponents[0]; // "08:20"
          final isPM = timeComponents.length > 1 && timeComponents[1] == 'pm';

          final timeValues = timeStr.split(':');
          if (timeValues.length == 2) {
            hour = int.tryParse(timeValues[0]) ?? 0;
            minute = int.tryParse(timeValues[1]) ?? 0;

            // Convert to 24-hour format
            if (isPM && hour != 12) {
              hour += 12;
            } else if (!isPM && hour == 12) {
              hour = 0;
            }
          }
        }
      }

      return DateTime(year, month, day, hour, minute);
    } catch (e) {
      print('⚠️ Error parsing date "$dateStr": $e');
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'studentId': studentId,
      'grade': grade,
      'className': className,
      'gradeAndClass': gradeAndClass,
      'numberOfRecords': numberOfRecords,
      'lastVisit': lastVisit?.toIso8601String(),
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

  // Helper to get formatted last visit
  String get formattedLastVisit {
    if (lastVisit == null) return 'Never visited';

    final date = lastVisit!;
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;

    // Format time
    int hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'pm' : 'am';

    if (hour > 12) {
      hour -= 12;
    } else if (hour == 0) {
      hour = 12;
    }

    return '$day/$month/$year, ${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  // Helper to check if visited
  bool get hasVisited => numberOfRecords > 0 || lastVisit != null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MedicalStudent && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'MedicalStudent(id: $id, name: $fullName, studentId: $studentId, records: $numberOfRecords)';
  }
}

// Pagination Model
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
