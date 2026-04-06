import 'package:get/get.dart';
import '../models/notification_model.dart';
import '../utils/api_service.dart';

class NotificationController extends GetxController {
  final RxList<NotificationItem> notifications = <NotificationItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  late final ApiService _apiService;

  int get unreadCount =>
      notifications.where((n) => !n.read).length;

  @override
  void onInit() {
    super.onInit();
    _apiService = Get.find<ApiService>();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _apiService.getNotifications();

      if (result['success'] == true) {
        final List<dynamic> data = result['data'] ?? [];
        notifications.value =
            data.map((json) => NotificationItem.fromJson(json)).toList();
        print('🔔 NotificationController: Loaded ${notifications.length} notifications');
      } else {
        errorMessage.value = result['error'] ?? 'Failed to fetch notifications';
        print('❌ NotificationController: ${errorMessage.value}');
      }
    } catch (e) {
      errorMessage.value = 'Error loading notifications: ${e.toString()}';
      print('💥 NotificationController: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final result = await _apiService.markNotificationAsRead(notificationId);

      if (result['success'] == true) {
        final index = notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          final old = notifications[index];
          notifications[index] = NotificationItem(
            id: old.id,
            title: old.title,
            body: old.body,
            data: old.data,
            read: true,
            createdAt: old.createdAt,
          );
        }
        print('🔔 NotificationController: Marked $notificationId as read');
      }
    } catch (e) {
      print('💥 NotificationController: Error marking as read: $e');
    }
  }
}
