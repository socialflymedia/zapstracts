import 'package:equatable/equatable.dart';


import '../model/feedback_form_modal.dart';
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


class SaveResearchPaper extends HomeEvent {
  final String paperId;

  const SaveResearchPaper(this.paperId);

  @override
  List<Object?> get props => [paperId];
}
// New feedback-related events
class CheckFeedbackStatus extends HomeEvent {}

class SubmitFeedback extends HomeEvent {
  final FeedbackModel feedback;
  SubmitFeedback(this.feedback);
}

class IncrementSummaryCount extends HomeEvent {}

class DismissFeedbackForm extends HomeEvent {}

