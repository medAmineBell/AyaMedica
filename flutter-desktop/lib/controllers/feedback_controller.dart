import 'package:flutter_getx_app/models/feedback.dart';
import 'package:flutter_getx_app/utils/api_service.dart';
import 'package:get/get.dart';

class FeedbackController extends GetxController {
  final RxList<FeedbackItem> feedbacks = <FeedbackItem>[].obs;
  final Rx<FeedbackItem?> selectedFeedback = Rx<FeedbackItem?>(null);

  // Loading and error states
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Pagination
  final Rx<FeedbackPagination?> pagination = Rx<FeedbackPagination?>(null);
  final RxInt currentPage = 1.obs;
  final RxInt limit = 50.obs;

  // Filters
  final RxnString organizationId = RxnString(null);
  final RxnString feedbackRequestId = RxnString(null);
  final RxnString statusFilter = RxnString(null);
  final RxnInt ratingFilter = RxnInt(null);

  late final ApiService _apiService;

  @override
  void onInit() {
    super.onInit();
    _apiService = Get.find<ApiService>();
    fetchFeedbacks();
  }

  Future<void> fetchFeedbacks({bool resetPage = false}) async {
    if (resetPage) {
      currentPage.value = 1;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _apiService.getFeedbacks(
        organizationId: organizationId.value,
        feedbackRequestId: feedbackRequestId.value,
        status: statusFilter.value,
        rating: ratingFilter.value,
        page: currentPage.value,
        limit: limit.value,
      );

      if (result['success'] == true) {
        feedbacks.value = result['feedbacks'] as List<FeedbackItem>;
        pagination.value = result['pagination'] as FeedbackPagination?;
      } else {
        errorMessage.value = result['error'] ?? 'Failed to load feedbacks';
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilters({
    String? orgId,
    String? requestId,
    String? status,
    int? rating,
  }) {
    organizationId.value = orgId;
    feedbackRequestId.value = requestId;
    statusFilter.value = status;
    ratingFilter.value = rating;
    fetchFeedbacks(resetPage: true);
  }

  void clearFilters() {
    organizationId.value = null;
    feedbackRequestId.value = null;
    statusFilter.value = null;
    ratingFilter.value = null;
    fetchFeedbacks(resetPage: true);
  }

  void goToPage(int page) {
    if (pagination.value != null && page >= 1 && page <= pagination.value!.totalPages) {
      currentPage.value = page;
      fetchFeedbacks();
    }
  }

  void nextPage() {
    if (pagination.value != null && currentPage.value < pagination.value!.totalPages) {
      currentPage.value++;
      fetchFeedbacks();
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      fetchFeedbacks();
    }
  }

  void view(FeedbackItem item) {
    selectedFeedback.value = item;
  }

  void notify(FeedbackItem item) {
    print('Notifying for ${item.subject}');
  }

  void highlight(FeedbackItem item) {
    print('Highlighting ${item.subject}');
  }
}
