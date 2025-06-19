import 'package:equatable/equatable.dart';


import 'home_state.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadResearchPapers extends HomeEvent {}

class SearchResearchPapers extends HomeEvent {
  final String query;

  const SearchResearchPapers(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterByCategory extends HomeEvent {
  final String category;

  const FilterByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class ChangeFeedType extends HomeEvent {
  final FeedType feedType;

  const ChangeFeedType(this.feedType);

  @override
  List<Object?> get props => [feedType];
}

class RefreshResearchPapers extends HomeEvent {}