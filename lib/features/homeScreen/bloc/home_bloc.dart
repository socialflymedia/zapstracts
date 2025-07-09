import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Data/repositories/home/home_repositorty.dart';
import '../model/research_paper.dart';

import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository repository;
  List<ResearchPaper> _allPapers = [];

  HomeBloc(this.repository) : super(HomeInitial()) {
    on<LoadResearchPapers>(_onLoadResearchPapers);
    on<SearchResearchPapers>(_onSearchResearchPapers);
    on<FilterByCategory>(_onFilterByCategory);
    on<ChangeFeedType>(_onChangeFeedType);
    on<RefreshResearchPapers>(_onRefreshResearchPapers);
  }

  Future<void> _onLoadResearchPapers(
      LoadResearchPapers event,
      Emitter<HomeState> emit,
      ) async {
    emit(HomeLoading());
    try {
      _allPapers = await repository.fetchResearchPapers();
      print( 'paper from rep ${_allPapers}');
      emit(HomeLoaded(
        papers: _allPapers,
        featuredPapers: _allPapers.take(1).toList(),
        trendingPapers: _allPapers.skip(1).toList(),
        myFeedPapers: _allPapers.where((p) => p.tags.contains('physics')).toList(),
        worldPapers: _allPapers.where((p) => p.tags.contains('technology')).toList(),
      ));
    } catch (e) {
      emit(HomeError('Failed to load papers: $e'));
    }
  }

  Future<void> _onSearchResearchPapers(
      SearchResearchPapers event,
      Emitter<HomeState> emit,
      ) async {
    if (state is! HomeLoaded) return;
    final currentState = state as HomeLoaded;

    try {
      final filteredPapers = _filterPapers(event.query);

      emit(currentState.copyWith(
        papers: filteredPapers,
        searchQuery: event.query,
      ));
    } catch (e) {
      emit(HomeError('Failed to search papers: $e'));
    }
  }

  Future<void> _onFilterByCategory(
      FilterByCategory event,
      Emitter<HomeState> emit,
      ) async {
    if (state is! HomeLoaded) return;
    final currentState = state as HomeLoaded;

    try {
      final filteredPapers = _allPapers
          .where((paper) => paper.publishedIn == event.category)
          .toList();

      emit(currentState.copyWith(
        papers: filteredPapers,
        selectedCategory: event.category,
      ));
    } catch (e) {
      emit(HomeError('Failed to filter papers: $e'));
    }
  }

  Future<void> _onChangeFeedType(
      ChangeFeedType event,
      Emitter<HomeState> emit,
      ) async {
    if (state is! HomeLoaded) return;
    final currentState = state as HomeLoaded;

    emit(currentState.copyWith(selectedFeed: event.feedType));
  }

  Future<void> _onRefreshResearchPapers(
      RefreshResearchPapers event,
      Emitter<HomeState> emit,
      ) async {
    if (state is! HomeLoaded) return;

    try {
      _allPapers = await repository.fetchResearchPapers();

      emit(HomeLoaded(
        papers: _allPapers,
        featuredPapers: _allPapers.take(1).toList(),
        trendingPapers: _allPapers.skip(1).toList(),
        myFeedPapers: _allPapers.where((p) => p.tags.contains('physics')).toList(),
        worldPapers: _allPapers.where((p) => p.tags.contains('technology')).toList(),
      ));
    } catch (e) {
      emit(HomeError('Failed to refresh papers: $e'));
    }
  }

  List<ResearchPaper> _filterPapers(String query) {
    if (query.isEmpty) return _allPapers;

    return _allPapers.where((paper) =>
    paper.title.toLowerCase().contains(query.toLowerCase()) ||
        paper.summary.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}
