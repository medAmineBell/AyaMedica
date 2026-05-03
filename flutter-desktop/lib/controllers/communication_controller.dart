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

  /// "" = no filter, or one of "Inbox", "Sent", "Received records", "Vaccination requests"
  var selectedStatusFilter = 'Inbox'.obs;

  /// Active API type: 'inbox' | 'sent' | 'records' | 'vaccination'
  final RxString selectedType = 'inbox'.obs;

  /// (Optional) search query
  var searchQuery = ''.obs;

  /// Pagination
  RxInt currentPage = 1.obs;
  final int itemsPerPage = 20;
  RxInt totalItems = 0.obs;
  RxInt totalPages = 1.obs;

  /// Loading state
  RxBool isLoading = false.obs;

  /// Inbox unread count — refreshed silently (e.g. from loadAppointments)
  /// without touching [messages], so the sidebar badge stays accurate even
  /// when the user is viewing a non-inbox tab.
  RxInt unreadInboxCount = 0.obs;

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
    fetchInboxMessages();
  }

  /// Fetch the list for the currently selected type.
  Future<void> _fetchForCurrentType(int page) {
    switch (selectedType.value) {
      case 'records':
        return fetchReceivedRecords(page: page);
      case 'vaccination':
        messages.clear();
        filteredMessages.clear();
        currentPage.value = 1;
        totalPages.value = 1;
        totalItems.value = 0;
        return Future.value();
      case 'sent':
      case 'inbox':
      default:
        return fetchInboxMessages(page: page);
    }
  }

  /// Fetch messages from /api/messages?type=<inbox|sent>
  Future<void> fetchInboxMessages({int page = 1, String? type}) async {
    final effectiveType = type ?? selectedType.value;
    try {
      isLoading.value = true;

      final storageService = Get.find<StorageService>();
      final accessToken = storageService.getAccessToken();
      if (accessToken == null) return;

      final url =
          '${AppConfig.newBackendUrl}/api/messages?type=$effectiveType&page=$page&limit=$itemsPerPage';

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
          final list = data['messages'] as List;
          final pagination = data['pagination'] as Map<String, dynamic>;

          final parsed =
              list.map((r) => MessageModel.fromInboxApi(r)).toList();

          messages.assignAll(parsed);
          filteredMessages.assignAll(parsed);
          currentPage.value = pagination['page'] ?? 1;
          totalItems.value = pagination['total'] ?? 0;
          totalPages.value = pagination['totalPages'] ?? 1;

          if (effectiveType == 'inbox' && page == 1) {
            unreadInboxCount.value = parsed.where((m) => !m.read).length;
          }
        }
      }
    } catch (e) {
      print('[CommunicationController] Error fetching inbox: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Silently refresh the inbox unread count (used by other controllers to
  /// keep the sidebar badge fresh). Does NOT mutate [messages] or loading
  /// state, so the user's current tab view is left intact.
  Future<void> refreshInboxUnreadCount() async {
    try {
      final storageService = Get.find<StorageService>();
      final accessToken = storageService.getAccessToken();
      if (accessToken == null) return;

      final url =
          '${AppConfig.newBackendUrl}/api/messages?type=inbox&page=1&limit=$itemsPerPage';

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
          final list = data['messages'] as List;
          unreadInboxCount.value =
              list.where((m) => m is Map && m['read'] == false).length;
        }
      }
    } catch (e) {
      print('[CommunicationController] Error refreshing unread count: $e');
    }
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

      await http.post(
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
        if (!msg.read) {
          messages[idx] = msg.copyWith(read: true);
          _applyFilter();
          if (selectedType.value == 'inbox' && unreadInboxCount.value > 0) {
            unreadInboxCount.value = unreadInboxCount.value - 1;
          }
        }
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
      _fetchForCurrentType(currentPage.value + 1);
    }
  }

  /// Move to previous page if possible
  void previousPage() {
    if (currentPage.value > 1) {
      _fetchForCurrentType(currentPage.value - 1);
    }
  }

  /// Jump to a specific page
  void goToPage(int page) {
    final clamped = page.clamp(1, totalPages.value);
    _fetchForCurrentType(clamped);
  }

  /// Toggles the status filter on/off and switches the active API type
  void toggleStatusFilter(String status) {
    if (selectedStatusFilter.value == status) {
      // Re-selecting the active tab is a no-op so we never land on an empty state.
      return;
    }
    selectedStatusFilter.value = status;
    selectedMessage.value = null;
    switch (status) {
      case 'Inbox':
        selectedType.value = 'inbox';
        break;
      case 'Sent':
        selectedType.value = 'sent';
        break;
      case 'Received records':
        selectedType.value = 'records';
        break;
      case 'Vaccination requests':
        selectedType.value = 'vaccination';
        break;
    }
    _fetchForCurrentType(1);
  }

  /// Selects a message for detail view and marks it as read
  void selectMessage(MessageModel msg) {
    selectedMessage.value = msg;
    if (!msg.read && selectedType.value != 'sent') {
      markAsRead(msg.id);
    }
    if (selectedType.value == 'records' && msg.recordId != null) {
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
