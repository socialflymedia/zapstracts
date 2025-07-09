class FeedbackModel {
  final String userId;
  final int uiRating;
  final int summaryAccuracyRating;
  final int overallExperienceRating;
  final String additionalComments;
  final DateTime submittedAt;

  FeedbackModel({
    required this.userId,
    required this.uiRating,
    required this.summaryAccuracyRating,
    required this.overallExperienceRating,
    required this.additionalComments,
    required this.submittedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'ui_rating': uiRating,
      'summary_accuracy_rating': summaryAccuracyRating,
      'overall_experience_rating': overallExperienceRating,
      'additional_comments': additionalComments,
      'submitted_at': submittedAt.toIso8601String(),
    };
  }

  factory FeedbackModel.fromMap(Map<String, dynamic> map) {
    return FeedbackModel(
      userId: map['user_id'] ?? '',
      uiRating: map['ui_rating'] ?? 0,
      summaryAccuracyRating: map['summary_accuracy_rating'] ?? 0,
      overallExperienceRating: map['overall_experience_rating'] ?? 0,
      additionalComments: map['additional_comments'] ?? '',
      submittedAt: DateTime.parse(map['submitted_at']),
    );
  }
}

class UserSummaryCount {
  final String userId;
  final int summaryCount;
  final bool feedbackGiven;

  UserSummaryCount({
    required this.userId,
    required this.summaryCount,
    required this.feedbackGiven,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'summary_count': summaryCount,
      'feedback_given': feedbackGiven,
    };
  }

  factory UserSummaryCount.fromMap(Map<String, dynamic> map) {
    return UserSummaryCount(
      userId: map['user_id'] ?? '',
      summaryCount: map['summary_count'] ?? 0,
      feedbackGiven: map['feedback_given'] ?? false,
    );
  }
}