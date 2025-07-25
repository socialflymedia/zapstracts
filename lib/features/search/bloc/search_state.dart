
// States
import 'package:equatable/equatable.dart';

import '../../homeScreen/model/research_paper.dart';
abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<ResearchPaper> papers;
  final String query;

  const SearchLoaded(this.papers, this.query);

  @override
  List<Object> get props => [papers, query];
}

class SearchError extends SearchState {
  final String message;

  const SearchError(this.message);

  @override
  List<Object> get props => [message];
}

class SearchEmpty extends SearchState {
  final String query;

  const SearchEmpty(this.query);

  @override
  List<Object> get props => [query];
}
