import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/message_model.dart';
import '../utils/storage_service.dart';

class CommunicationController extends GetxController {
  /// All received medical records
  RxList<MessageModel> messages = <MessageModel>[].obs;

  /// Messages after applying the status filter
  RxList<MessageModel> filteredMessages = <MessageModel>[].obs;

  /// Currently selected message (for detail view)
  Rxn<MessageModel> selectedMessage = Rxn<MessageModel>();

  /// "" = no filter, or one of "Received records", etc.
  var selectedStatusFilter = 'Received records'.obs;

  /// (Optional) search query
  var searchQuery = ''.obs;

  /// Pagination
  RxInt currentPage = 1.obs;
  final int itemsPerPage = 20;
  RxInt totalItems = 0.obs;
  RxInt totalPages = 1.obs;

  /// Loading state
  RxBool isLoading = false.obs;

  /// Sick leave state for selected record
  RxBool isLoadingSickLeave = true.obs;
  Rxn<Map<String, dynamic>> sickLeaveData = Rxn<Map<String, dynamic>>();

  addMessage(MessageModel message) {
    messages.add(message);
    _applyFilter();
  }

  @override
  void onInit() {
    super.onInit();
    fetchReceivedRecords();
  }

  /// Fetch received medical records from API
  Future<void> fetchReceivedRecords({int page = 1}) async {
    try {
      isLoading.value = true;

      final storageService = Get.find<StorageService>();
      final accessToken = storageService.getAccessToken();
      if (accessToken == null) return;

      final branchData = storageService.getSelectedBranchData();
      final organizationId = branchData?['organizationId'] ?? branchData?['id'];
      if (organizationId == null) return;

      final url =
          '${AppConfig.newBackendUrl}/api/messages/medical-records?organizationId=$organizationId&page=$page&limit=$itemsPerPage';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          final data = jsonData['data'] as Map<String, dynamic>;
          final records = data['records'] as List;
          final pagination = data['pagination'] as Map<String, dynamic>;

          final parsed = records.map((r) => MessageModel.fromApiRecord(r)).toList();

          messages.assignAll(parsed);
          filteredMessages.assignAll(parsed);
          currentPage.value = pagination['page'] ?? 1;
          totalItems.value = pagination['total'] ?? 0;
          totalPages.value = pagination['totalPages'] ?? 1;
        }
      }
    } catch (e) {
      print('[CommunicationController] Error fetching records: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Mark a message as read
  Future<void> markAsRead(String messageId) async {
    try {
      final storageService = Get.find<StorageService>();
      final accessToken = storageService.getAccessToken();
      if (accessToken == null) return;

      final url = '${AppConfig.newBackendUrl}/api/messages/$messageId/read';

      await http.patch(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      // Update local state
      final idx = messages.indexWhere((m) => m.id == messageId);
      if (idx != -1) {
        final msg = messages[idx];
        messages[idx] = msg.copyWith(read: true);
        _applyFilter();
      }
    } catch (e) {
      print('[CommunicationController] Error marking as read: $e');
    }
  }

  /// Applies the selectedStatusFilter to [messages] and updates [filteredMessages].
  void _applyFilter() {
    filteredMessages.assignAll(messages);
  }

  /// Move to next page if possible
  void nextPage() {
    if (currentPage.value < totalPages.value) {
      fetchReceivedRecords(page: currentPage.value + 1);
    }
  }

  /// Move to previous page if possible
  void previousPage() {
    if (currentPage.value > 1) {
      fetchReceivedRecords(page: currentPage.value - 1);
    }
  }

  /// Jump to a specific page
  void goToPage(int page) {
    final clamped = page.clamp(1, totalPages.value);
    fetchReceivedRecords(page: clamped);
  }

  /// Toggles the status filter on/off
  void toggleStatusFilter(String status) {
    if (selectedStatusFilter.value == status) {
      selectedStatusFilter.value = '';
    } else {
      selectedStatusFilter.value = status;
    }
  }

  /// Selects a message for detail view and marks it as read
  void selectMessage(MessageModel msg) {
    selectedMessage.value = msg;
    if (!msg.read) {
      markAsRead(msg.id);
    }
    if (msg.recordId != null) {
      fetchSickLeaveStatus(msg.recordId!);
    } else {
      isLoadingSickLeave.value = false;
      sickLeaveData.value = null;
    }
  }

  /// Fetch full medical record to check sick leave status
  Future<void> fetchSickLeaveStatus(String recordId) async {
    try {
      isLoadingSickLeave.value = true;
      sickLeaveData.value = null;

      final storageService = Get.find<StorageService>();
      final accessToken = storageService.getAccessToken();
      if (accessToken == null) return;

      final url =
          '${AppConfig.newBackendUrl}/api/medical-records/$recordId/full?country=EG';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          final data = jsonData['data'] as Map<String, dynamic>;
          sickLeaveData.value = data['sick_leave'] as Map<String, dynamic>?;
        }
      }
    } catch (e) {
      print('[CommunicationController] Error fetching sick leave: $e');
    } finally {
      isLoadingSickLeave.value = false;
    }
  }

  /// (Optional) update free-text search and reset page
  void updateSearchQuery(String query) {
    searchQuery.value = query;
    currentPage.value = 1;
  }
}
