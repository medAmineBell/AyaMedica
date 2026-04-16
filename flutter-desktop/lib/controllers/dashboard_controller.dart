import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../utils/storage_service.dart';
import 'home_controller.dart';

class DashboardController extends GetxController {
  // Appointments chart data
  final RxInt appointmentsTotal = 0.obs;
  final RxList<Map<String, dynamic>> appointmentsByType =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoadingAppointments = false.obs;
  final RxString selectedPeriod = 'This Week'.obs;

  // Health issues chart data
  final RxInt healthIssuesTotal = 0.obs;
  final RxList<Map<String, dynamic>> healthIssuesByReason =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoadingHealthIssues = false.obs;
  final RxString selectedHealthPeriod = 'This Week'.obs;

  // Dashboard summary stats
  final RxInt totalStudents = 0.obs;
  final RxInt totalMedicalRecords = 0.obs;
  final RxInt totalVisits = 0.obs;
  final RxInt totalBranches = 0.obs;
  final RxInt totalUsers = 0.obs;
  final RxBool isLoadingStats = false.obs;

  // Monthly trend data
  final RxList<Map<String, dynamic>> monthlyTrend =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoadingMonthlyTrend = false.obs;

  // Custom date ranges
  DateTime? customStartDate;
  DateTime? customEndDate;
  DateTime? healthCustomStartDate;
  DateTime? healthCustomEndDate;

  Worker? _branchWorker;

  @override
  void onInit() {
    super.onInit();
    refreshAll();

    // Re-fetch all data when branch changes
    final homeController = Get.find<HomeController>();
    _branchWorker = ever(homeController.selectedBranchData, (_) {
      refreshAll();
    });
  }

  @override
  void onClose() {
    _branchWorker?.dispose();
    super.onClose();
  }

  void refreshAll() {
    fetchDashboardStats();
    fetchAppointmentsChart();
    fetchHealthIssuesChart();
    fetchMonthlyTrend();
  }

  Future<void> fetchDashboardStats() async {
    try {
      isLoadingStats.value = true;

      final storageService = Get.find<StorageService>();
      final homeController = Get.find<HomeController>();

      final accessToken = storageService.getAccessToken();
      if (accessToken == null) return;

      final organizationId = homeController.getOrganizationId();

      final queryParams = <String, String>{};
      if (organizationId != null) {
        queryParams['organizationId'] = organizationId;
      }

      final uri = Uri.parse(
        '${AppConfig.newBackendUrl}/api/school-admin/dashboard',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          final data = jsonData['data'];
          totalStudents.value = data['totalStudents'] ?? 0;
          totalMedicalRecords.value = data['totalMedicalRecords'] ?? 0;
          totalVisits.value = data['totalVisits'] ?? 0;
          totalBranches.value = data['totalBranches'] ?? 0;
          totalUsers.value = data['totalUsers'] ?? 0;
        }
      }
    } catch (e) {
      print('📊 Dashboard: Error fetching stats: $e');
    } finally {
      isLoadingStats.value = false;
    }
  }

  Future<void> fetchAppointmentsChart() async {
    try {
      isLoadingAppointments.value = true;

      final storageService = Get.find<StorageService>();
      final homeController = Get.find<HomeController>();

      final accessToken = storageService.getAccessToken();
      if (accessToken == null) return;

      final branchId = homeController.getBranchId();

      final queryParams = <String, String>{};
      if (branchId != null) queryParams['branchId'] = branchId;
      queryParams['period'] = selectedPeriod.value;

      if (selectedPeriod.value == 'Custom Date' &&
          customStartDate != null &&
          customEndDate != null) {
        queryParams['startDate'] =
            customStartDate!.toIso8601String().split('T')[0];
        queryParams['endDate'] =
            customEndDate!.toIso8601String().split('T')[0];
      }

      final uri = Uri.parse(
        '${AppConfig.newBackendUrl}/api/school-admin/dashboard/appointments-chart',
      ).replace(queryParameters: queryParams);

      print('📊 Dashboard: Fetching appointments chart from $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          final data = jsonData['data'];
          appointmentsTotal.value = data['total'] ?? 0;
          appointmentsByType.assignAll(
            (data['byType'] as List)
                .map((item) => Map<String, dynamic>.from(item))
                .toList(),
          );
          print(
              '📊 Dashboard: Loaded ${appointmentsByType.length} appointment types, total: ${appointmentsTotal.value}');
        }
      } else {
        print('📊 Dashboard: API error ${response.statusCode}');
      }
    } catch (e) {
      print('📊 Dashboard: Error fetching appointments chart: $e');
    } finally {
      isLoadingAppointments.value = false;
    }
  }

  Future<void> fetchHealthIssuesChart() async {
    try {
      isLoadingHealthIssues.value = true;

      final storageService = Get.find<StorageService>();
      final homeController = Get.find<HomeController>();

      final accessToken = storageService.getAccessToken();
      if (accessToken == null) return;

      final branchId = homeController.getBranchId();

      final queryParams = <String, String>{};
      if (branchId != null) queryParams['branchId'] = branchId;
      queryParams['period'] = selectedHealthPeriod.value;

      if (selectedHealthPeriod.value == 'Custom Date' &&
          healthCustomStartDate != null &&
          healthCustomEndDate != null) {
        queryParams['startDate'] =
            healthCustomStartDate!.toIso8601String().split('T')[0];
        queryParams['endDate'] =
            healthCustomEndDate!.toIso8601String().split('T')[0];
      }

      final uri = Uri.parse(
        '${AppConfig.newBackendUrl}/api/school-admin/dashboard/health-issues-chart',
      ).replace(queryParameters: queryParams);

      print('📊 Dashboard: Fetching health issues chart from $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          final data = jsonData['data'];
          healthIssuesTotal.value = data['total'] ?? 0;
          healthIssuesByReason.assignAll(
            (data['byReason'] as List)
                .map((item) => Map<String, dynamic>.from(item))
                .toList(),
          );
          print(
              '📊 Dashboard: Loaded ${healthIssuesByReason.length} health issue types, total: ${healthIssuesTotal.value}');
        }
      } else {
        print('📊 Dashboard: Health issues API error ${response.statusCode}');
      }
    } catch (e) {
      print('📊 Dashboard: Error fetching health issues chart: $e');
    } finally {
      isLoadingHealthIssues.value = false;
    }
  }

  void changeHealthPeriod(String period,
      {DateTime? startDate, DateTime? endDate}) {
    selectedHealthPeriod.value = period;
    if (period == 'Custom Date') {
      healthCustomStartDate = startDate;
      healthCustomEndDate = endDate;
    } else {
      healthCustomStartDate = null;
      healthCustomEndDate = null;
    }
    fetchHealthIssuesChart();
  }

  Future<void> fetchMonthlyTrend() async {
    try {
      isLoadingMonthlyTrend.value = true;

      final storageService = Get.find<StorageService>();
      final homeController = Get.find<HomeController>();

      final accessToken = storageService.getAccessToken();
      if (accessToken == null) return;

      final branchId = homeController.getBranchId();

      final queryParams = <String, String>{};
      if (branchId != null) queryParams['branchId'] = branchId;

      final uri = Uri.parse(
        '${AppConfig.newBackendUrl}/api/school-admin/dashboard/monthly-trend',
      ).replace(queryParameters: queryParams);

      print('📊 Dashboard: Fetching monthly trend from $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          final data = jsonData['data'];
          monthlyTrend.assignAll(
            (data['byMonth'] as List)
                .map((item) => Map<String, dynamic>.from(item))
                .toList(),
          );
          print(
              '📊 Dashboard: Loaded ${monthlyTrend.length} months of trend data');
        }
      } else {
        print('📊 Dashboard: Monthly trend API error ${response.statusCode}');
      }
    } catch (e) {
      print('📊 Dashboard: Error fetching monthly trend: $e');
    } finally {
      isLoadingMonthlyTrend.value = false;
    }
  }

  void changePeriod(String period, {DateTime? startDate, DateTime? endDate}) {
    selectedPeriod.value = period;
    if (period == 'Custom Date') {
      customStartDate = startDate;
      customEndDate = endDate;
    } else {
      customStartDate = null;
      customEndDate = null;
    }
    fetchAppointmentsChart();
  }

  // Helpers for the pie chart
  Color getColorForType(String type) {
    switch (type) {
      case 'walkin':
        return const Color(0xFF1339FF);
      case 'checkup':
        return const Color(0xFFCDFF1F);
      case 'followup':
        return const Color(0xFFEDF1F5);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  String getLabelForType(String type) {
    switch (type) {
      case 'walkin':
        return 'Walk In';
      case 'checkup':
        return 'Checkup';
      case 'followup':
        return 'Follow-up';
      default:
        return type;
    }
  }

  // Health issues chart helpers
  static const List<Color> healthIssueColors = [
    Color(0xFF1339FF),
    Color(0xFF01C448),
    Color(0xFF1397FF),
    Color(0xFFD6A100),
    Color(0xFFFF6B6B),
  ];

  Color getColorForReason(int index) {
    return healthIssueColors[index % healthIssueColors.length];
  }

  TextStyle getTitleStyleForType(String type) {
    final color = type == 'walkin' ? Colors.white : const Color(0xFF2D2E2E);
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: color,
    );
  }
}
