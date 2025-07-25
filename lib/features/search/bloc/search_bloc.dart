// Bloc
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zapstract/features/search/bloc/search_event.dart';
import 'package:zapstract/features/search/bloc/search_state.dart';

import '../../../Data/repositories/search/search_repository.dart';
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final ResearchRepository repository;

  SearchBloc({required this.repository}) : super(SearchInitial()) {
    on<SearchPapers>(_onSearchPapers);
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onSearchPapers(
      SearchPapers event,
      Emitter<SearchState> emit,
      ) async {
    if (event.query.trim().isEmpty) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());

    try {
      final papers = await repository.searchPapers(event.query);

      if (papers.isEmpty) {
        emit(SearchEmpty(event.query));
      } else {
        emit(SearchLoaded(papers, event.query));
      }
    } catch (e) {
      emit(SearchError('Failed to search papers: ${e.toString()}'));
    }
  }

  void _onClearSearch(
      ClearSearch event,
      Emitter<SearchState> emit,
      ) {
    emit(SearchInitial());
  }
}