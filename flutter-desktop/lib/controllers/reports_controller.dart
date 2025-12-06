import 'package:flutter_getx_app/models/report.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ReportsController extends GetxController {
  final RxList<Report> reports = <Report>[].obs;
  final RxString searchQuery = ''.obs;
  final RxInt activeFilterCount = 0.obs;

  List<Report> get filteredReports {
    var filtered = reports.toList();

    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((report) {
        return report.reportType.toLowerCase().contains(query) ||
               report.gradesAndClasses.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  void addReport(Report report) {
    reports.add(report);
    reports.refresh();
  }

  void deleteReport(String reportId) {
    reports.removeWhere((report) => report.id == reportId);
    reports.refresh();
  }

  String formatDateTime(DateTime dateTime) {
    final dateFormat = DateFormat('dd/MM/yyyy, HH:mm');
    return dateFormat.format(dateTime);
  }
}

