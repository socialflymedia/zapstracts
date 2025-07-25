import 'package:equatable/equatable.dart';
// Events
abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object> get props => [];
}

class SearchPapers extends SearchEvent {
  final String query;

  const SearchPapers(this.query);

  @override
  List<Object> get props => [query];
}

class ClearSearch extends SearchEvent {}
