import 'package:flutter_getx_app/models/feedback.dart';
import 'package:get/get.dart';

class FeedbackController extends GetxController {
  final RxList<FeedbackItem> feedbacks = <FeedbackItem>[].obs;
  final Rx<FeedbackItem?> selectedFeedback = Rx<FeedbackItem?>(null); // Add this line

  @override
  void onInit() {
    super.onInit();
    loadMockData();
  }

  void loadMockData() {
    feedbacks.value = [
      FeedbackItem(
        title: 'New Scholar year Session',
        branch: 'Branch name goes here',
        launchDate: DateTime(2025, 7, 21),
        status: 'Active',
        rating: 4.9,
        currentResponses: 131,
        totalResponses: 147,
      ),
    ];
  }

  void view(FeedbackItem item) {
    print('Viewing ${item.title}');
  }

  void notify(FeedbackItem item) {
    print('Notifying for ${item.title}');
  }

  void highlight(FeedbackItem item) {
    print('Highlighting ${item.title}');
  }
}
