class FeedbackModel {
  final String userId;
  final String mostUsedMode;
  final int summaryQualityRating;
  final int summaryModesUsefulnessRating;
  final String languageLevelAppropriate;
  final String errorsNoticed;
  final String errorsSpecification;
  final String mostValuableFeature;
  final String otherValuableFeature;
  final String wouldRecommend;
  final String whyNotRecommend;
  final int overallExperienceRating;
  final String additionalComments;
  final List<String> improvementSuggestions;
  final String otherImprovement;
  final DateTime submittedAt;

  FeedbackModel({
    required this.userId,
    required this.mostUsedMode,
    required this.summaryQualityRating,
    required this.summaryModesUsefulnessRating,
    required this.languageLevelAppropriate,
    required this.errorsNoticed,
    required this.errorsSpecification,
    required this.mostValuableFeature,
    required this.otherValuableFeature,
    required this.wouldRecommend,
    required this.whyNotRecommend,
    required this.overallExperienceRating,
    required this.additionalComments,
    required this.improvementSuggestions,
    required this.otherImprovement,
    required this.submittedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'most_used_mode': mostUsedMode,
      'summary_quality_rating': summaryQualityRating,
      'summary_modes_usefulness_rating': summaryModesUsefulnessRating,
      'language_level_appropriate': languageLevelAppropriate,
      'errors_noticed': errorsNoticed,
      'errors_specification': errorsSpecification,
      'most_valuable_feature': mostValuableFeature,
      'other_valuable_feature': otherValuableFeature,
      'would_recommend': wouldRecommend,
      'why_not_recommend': whyNotRecommend,
      'overall_experience_rating': overallExperienceRating,
      'additional_comments': additionalComments,
      'improvement_suggestions': improvementSuggestions,
      'other_improvement': otherImprovement,
      'submitted_at': submittedAt.toIso8601String(),
    };
  }

  factory FeedbackModel.fromMap(Map<String, dynamic> map) {
    return FeedbackModel(
      userId: map['user_id'] ?? '',
      mostUsedMode: map['most_used_mode'] ?? '',
      summaryQualityRating: map['summary_quality_rating'] ?? 0,
      summaryModesUsefulnessRating: map['summary_modes_usefulness_rating'] ?? 0,
      languageLevelAppropriate: map['language_level_appropriate'] ?? '',
      errorsNoticed: map['errors_noticed'] ?? '',
      errorsSpecification: map['errors_specification'] ?? '',
      mostValuableFeature: map['most_valuable_feature'] ?? '',
      otherValuableFeature: map['other_valuable_feature'] ?? '',
      wouldRecommend: map['would_recommend'] ?? '',
      whyNotRecommend: map['why_not_recommend'] ?? '',
      overallExperienceRating: map['overall_experience_rating'] ?? 0,
      additionalComments: map['additional_comments'] ?? '',
      improvementSuggestions: List<String>.from(map['improvement_suggestions'] ?? []),
      otherImprovement: map['other_improvement'] ?? '',
      submittedAt: DateTime.parse(map['submitted_at']),
    );
  }
}

// UserSummaryCount remains the same
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