import '../model/research_paper.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class PaperSaving extends HomeState {}

class HomeLoaded extends HomeState {
  final List<ResearchPaper> papers;
  final List<ResearchPaper> featuredPapers;
  final List<ResearchPaper> trendingPapers;
  final List<ResearchPaper> myFeedPapers;
  final List<ResearchPaper> worldPapers;
  final String searchQuery;
  final String? selectedCategory;
  final FeedType selectedFeed;
  final bool shouldShowFeedback;
  final int summaryCount;
  final bool feedbackGiven;

  HomeLoaded({
    required this.papers,
    required this.featuredPapers,
    required this.trendingPapers,
    required this.myFeedPapers,
    required this.worldPapers,
    this.searchQuery = '',
    this.selectedCategory,
    this.selectedFeed = FeedType.myFeed,
    this.shouldShowFeedback = false,
    this.summaryCount = 0,
    this.feedbackGiven = false,
  });

  HomeLoaded copyWith({
    List<ResearchPaper>? papers,
    List<ResearchPaper>? featuredPapers,
    List<ResearchPaper>? trendingPapers,
    List<ResearchPaper>? myFeedPapers,
    List<ResearchPaper>? worldPapers,
    String? searchQuery,
    String? selectedCategory,
    FeedType? selectedFeed,
    bool? shouldShowFeedback,
    int? summaryCount,
    bool? feedbackGiven,
  }) {
    return HomeLoaded(
      papers: papers ?? this.papers,
      featuredPapers: featuredPapers ?? this.featuredPapers,
      trendingPapers: trendingPapers ?? this.trendingPapers,
      myFeedPapers: myFeedPapers ?? this.myFeedPapers,
      worldPapers: worldPapers ?? this.worldPapers,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedFeed: selectedFeed ?? this.selectedFeed,
      shouldShowFeedback: shouldShowFeedback ?? this.shouldShowFeedback,
      summaryCount: summaryCount ?? this.summaryCount,
      feedbackGiven: feedbackGiven ?? this.feedbackGiven,
    );
  }
}


class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}

class FeedbackSubmitting extends HomeState {}

class FeedbackSubmitted extends HomeState {}

class FeedbackError extends HomeState {
  final String message;
  FeedbackError(this.message);
}

enum FeedType { myFeed, world, trending }
