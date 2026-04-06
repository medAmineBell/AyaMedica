class FeedbackItem {
  final String id;
  final String subject;
  final String message;
  final int rating;
  final String status;
  final String? feedbackRequestId;
  final String? organizationId;
  final DateTime createdAt;
  final DateTime updatedAt;

  FeedbackItem({
    required this.id,
    required this.subject,
    required this.message,
    required this.rating,
    required this.status,
    this.feedbackRequestId,
    this.organizationId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FeedbackItem.fromJson(Map<String, dynamic> json) {
    return FeedbackItem(
      id: json['id'] ?? '',
      subject: json['subject'] ?? '',
      message: json['message'] ?? '',
      rating: json['rating'] ?? 0,
      status: json['status'] ?? '',
      feedbackRequestId: json['feedbackRequestId'],
      organizationId: json['organizationId'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'message': message,
      'rating': rating,
      'status': status,
      'feedbackRequestId': feedbackRequestId,
      'organizationId': organizationId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class FeedbackPagination {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  FeedbackPagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory FeedbackPagination.fromJson(Map<String, dynamic> json) {
    return FeedbackPagination(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 50,
      total: json['total'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
    );
  }
}

class FeedbackResponse {
  final bool success;
  final List<FeedbackItem> feedbacks;
  final FeedbackPagination pagination;

  FeedbackResponse({
    required this.success,
    required this.feedbacks,
    required this.pagination,
  });

  factory FeedbackResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final feedbacksList = (data['feedbacks'] as List<dynamic>?)
            ?.map((e) => FeedbackItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final paginationData = data['pagination'] ?? {};

    return FeedbackResponse(
      success: json['success'] ?? false,
      feedbacks: feedbacksList,
      pagination: FeedbackPagination.fromJson(paginationData),
    );
  }
}
