import 'package:flutter_getx_app/config/app_config.dart';
import 'package:flutter_getx_app/models/report.dart';
import 'package:flutter_getx_app/screens/reports/widgets/generating_report_dialog.dart';
import 'package:flutter_getx_app/utils/storage_service.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';

class ReportsController extends GetxController {
  final StorageService storageService = Get.find<StorageService>();

  final RxList<Report> reports = <Report>[].obs;
  final RxList<ReportTemplate> templates = <ReportTemplate>[].obs;
  final RxString searchQuery = ''.obs;
  final RxInt activeFilterCount = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingTemplates = false.obs;
  final RxString selectedBranchId = ''.obs;
  final RxString selectedOrganizationId = ''.obs;

  static String get baseUrl => AppConfig.newBackendUrl;

  @override
  void onInit() {
    super.onInit();
    loadBranchData();
    loadTemplates();
    loadReports();
  }

  // Load branch and organization data
  void loadBranchData() {
    final branchData = storageService.getSelectedBranchData();
    if (branchData != null) {
      selectedBranchId.value = branchData['id'] ?? '';
      selectedOrganizationId.value = branchData['organizationId'] ?? '';
      print('Loaded branch ID: ${selectedBranchId.value}');
      print('Loaded organization ID: ${selectedOrganizationId.value}');
    }
  }

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

  String formatDateTime(DateTime dateTime) {
    final dateFormat = DateFormat('dd/MM/yyyy, HH:mm');
    return dateFormat.format(dateTime);
  }

  // GET /api/reports/templates
  Future<void> loadTemplates() async {
    isLoadingTemplates.value = true;
    try {
      final accessToken = await storageService.getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/reports/templates'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('Templates Response Status: ${response.statusCode}');
      print('Templates Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          final templatesJson = jsonData['data'] as List;
          templates.value = templatesJson
              .map((json) => ReportTemplate.fromJson(json))
              .toList();
          print('Templates loaded: ${templates.length}');
        }
      } else {
        throw Exception('Failed to load templates: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading templates: $e');
      Get.snackbar(
        'Error',
        'Failed to load report templates: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingTemplates.value = false;
    }
  }

  // GET /api/reports (with query parameters)
  Future<void> loadReports({
    String? reportType,
    int page = 1,
    int limit = 20,
  }) async {
    if (selectedBranchId.value.isEmpty ||
        selectedOrganizationId.value.isEmpty) {
      print('Cannot load reports: Missing branch or organization ID');
      return;
    }

    isLoading.value = true;
    try {
      final accessToken = await storageService.getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      final queryParams = {
        'organizationId': selectedOrganizationId.value,
        'branchId': selectedBranchId.value,
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (reportType != null && reportType.isNotEmpty) {
        queryParams['reportType'] = reportType;
      }

      final uri = Uri.parse('$baseUrl/api/reports')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('Reports Response Status: ${response.statusCode}');
      print('Reports Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          final reportsJson = jsonData['data']['reports'] as List;
          reports.value =
              reportsJson.map((json) => Report.fromJson(json)).toList();
          print('Reports loaded: ${reports.length}');
        }
      } else {
        throw Exception('Failed to load reports: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading reports: $e');
      Get.snackbar(
        'Error',
        'Failed to load reports: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // POST /api/reports
  Future<bool> createReport(Map<String, dynamic> reportData) async {
    isLoading.value = true;

    try {
      final accessToken = await storageService.getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      // Add organization and branch IDs
      reportData['organizationId'] = selectedOrganizationId.value;
      reportData['branchId'] = selectedBranchId.value;

      print('Creating report with data: ${jsonEncode(reportData)}');

      final response = await http.post(
        Uri.parse('$baseUrl/api/reports'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(reportData),
      );

      print('Create Report Response Status: ${response.statusCode}');
      print('Create Report Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          // Update progress to 100% if dialog is open
          if (Get.isRegistered<GeneratingReportController>()) {
            final generatingController = Get.find<GeneratingReportController>();
            generatingController.updateProgress(1.0);
          }

          // Wait a bit for the animation
          await Future.delayed(const Duration(milliseconds: 800));

          // Close dialog if it's open
          if (Get.isDialogOpen ?? false) {
            Get.back();
          }

          Get.snackbar(
            'Success',
            'Report generated successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          // Reload reports list
          await loadReports();
          return true;
        }
      }

      throw Exception('Failed to create report: ${response.statusCode}');
    } catch (e) {
      print('Error creating report: $e');

      // Close dialog on error
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      Get.snackbar(
        'Error',
        'Failed to generate report: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // DELETE /api/reports/{id}
  Future<bool> deleteReport(String reportId) async {
    try {
      final accessToken = await storageService.getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/api/reports/$reportId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('Delete Report Response Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        reports.removeWhere((report) => report.id == reportId);
        reports.refresh();
        Get.snackbar(
          'Success',
          'Report deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      }
      throw Exception('Failed to delete report: ${response.statusCode}');
    } catch (e) {
      print('Error deleting report: $e');
      Get.snackbar(
        'Error',
        'Failed to delete report: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  // GET /api/reports/{id}/download
  Future<void> downloadReport(String reportId, String format) async {
    try {
      final accessToken = await storageService.getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      final uri = Uri.parse('$baseUrl/api/reports/$reportId/download')
          .replace(queryParameters: {'format': format.toLowerCase()});

      Get.snackbar(
        'Downloading',
        'Downloading report as $format...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('Download Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Handle file download - you might want to use a package like path_provider
        // and save the file to device storage
        Get.snackbar(
          'Success',
          'Report downloaded successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        throw Exception('Failed to download report: ${response.statusCode}');
      }
    } catch (e) {
      print('Error downloading report: $e');
      Get.snackbar(
        'Error',
        'Failed to download report: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
