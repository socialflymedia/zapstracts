import 'package:equatable/equatable.dart';

import '../model/research_paper.dart';


abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<ResearchPaper> papers;
  final List<ResearchPaper> featuredPapers;
  final List<ResearchPaper> trendingPapers;
  final List<ResearchPaper> myFeedPapers;
  final List<ResearchPaper> worldPapers;
  final String searchQuery;
  final String selectedCategory;
  final FeedType selectedFeed;

  const HomeLoaded({
    required this.papers,
    required this.featuredPapers,
    required this.trendingPapers,
    required this.myFeedPapers,
    required this.worldPapers,
    this.searchQuery = '',
    this.selectedCategory = '',
    this.selectedFeed = FeedType.myFeed,
  });

  @override
  List<Object?> get props => [
    papers,
    featuredPapers,
    trendingPapers,
    myFeedPapers,
    worldPapers,
    searchQuery,
    selectedCategory,
    selectedFeed,
  ];

  HomeLoaded copyWith({
    List<ResearchPaper>? papers,
    List<ResearchPaper>? featuredPapers,
    List<ResearchPaper>? trendingPapers,
    List<ResearchPaper>? myFeedPapers,
    List<ResearchPaper>? worldPapers,
    String? searchQuery,
    String? selectedCategory,
    FeedType? selectedFeed,
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
    );
  }
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}

enum FeedType { myFeed, world, trending }