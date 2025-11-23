// Your model
class FeedbackItem {
  final String title;
  final String branch;
  final DateTime launchDate;
  final String status;
  final double rating;
  final int currentResponses;
  final int totalResponses;

  FeedbackItem({
    required this.title,
    required this.branch,
    required this.launchDate,
    required this.status,
    required this.rating,
    required this.currentResponses,
    required this.totalResponses,
  });
}
