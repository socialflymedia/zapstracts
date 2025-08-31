  import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
  import 'package:supabase_flutter/supabase_flutter.dart';

  import '../../../Data/repositories/home/home_repositorty.dart';
  import '../model/research_paper.dart';
  import 'home_event.dart';
  import 'home_state.dart';

  class HomeBloc extends Bloc<HomeEvent, HomeState> {
    final HomeRepository repository;
    List<ResearchPaper> _allPapers = [];
    String? _currentUserId;

    HomeBloc(this.repository) : super(HomeInitial()) {
      _currentUserId = Supabase.instance.client.auth.currentUser?.id;

      on<LoadResearchPapers>(_onLoadResearchPapers);
      on<SearchResearchPapers>(_onSearchResearchPapers);
      on<FilterByCategory>(_onFilterByCategory);
      on<ChangeFeedType>(_onChangeFeedType);
      on<RefreshResearchPapers>(_onRefreshResearchPapers);
      on<SaveResearchPaper>(_saveResearchPaper);
      on<CheckFeedbackStatus>(_onCheckFeedbackStatus);
      on<SubmitFeedback>(_onSubmitFeedback);
      on<IncrementSummaryCount>(_onIncrementSummaryCount);
      on<DismissFeedbackForm>(_onDismissFeedbackForm);
    }

    Future<void> _onLoadResearchPapers(
        LoadResearchPapers event,
        Emitter<HomeState> emit,
        ) async {
      emit(HomeLoading());
      try {
        _allPapers = await repository.fetchResearchPapers();


        // Check feedback status after loading papers
        if (_currentUserId != null) {
          final summaryCount = await repository.getUserSummaryCount(_currentUserId!);
          final shouldShowFeedback = summaryCount.summaryCount >= 5 && !summaryCount.feedbackGiven;

          emit(HomeLoaded(
            papers: _allPapers,
            featuredPapers: _allPapers.take(1).toList(),
            trendingPapers: _allPapers.skip(1).toList(),
            myFeedPapers: _allPapers.where((p) => p.tags.contains('physics')).toList(),
            worldPapers: _allPapers.where((p) => p.tags.contains('technology')).toList(),
            shouldShowFeedback: shouldShowFeedback,
            summaryCount: summaryCount.summaryCount,
            feedbackGiven: summaryCount.feedbackGiven,
          ));
        } else {
          emit(HomeLoaded(
            papers: _allPapers,
            featuredPapers: _allPapers.take(1).toList(),
            trendingPapers: _allPapers.skip(1).toList(),
            myFeedPapers: _allPapers.where((p) => p.tags.contains('physics')).toList(),
            worldPapers: _allPapers.where((p) => p.tags.contains('technology')).toList(),
          ));
        }
      } catch (e) {
        emit(HomeError('Failed to load papers: $e'));
      }
    }

// Updated save method to update the paper's saved status in the list
    Future<void> _saveResearchPaper(
        SaveResearchPaper event,
        Emitter<HomeState> emit
        ) async {
      if (state is! HomeLoaded) return;
      final currentState = state as HomeLoaded;

      // Optimistically update the paper's saved status in all lists
      final updatedPapers = _updatePaperSavedStatus(currentState.papers, event.paperId, true);
      final updatedFeaturedPapers = _updatePaperSavedStatus(currentState.featuredPapers, event.paperId, true);
      final updatedTrendingPapers = _updatePaperSavedStatus(currentState.trendingPapers, event.paperId, true);
      final updatedMyFeedPapers = _updatePaperSavedStatus(currentState.myFeedPapers, event.paperId, true);
      final updatedWorldPapers = _updatePaperSavedStatus(currentState.worldPapers, event.paperId, true);

      // Update the main _allPapers list too
      _allPapers = _updatePaperSavedStatus(_allPapers, event.paperId, true);

      // Emit updated state immediately
      emit(currentState.copyWith(
        papers: updatedPapers,
        featuredPapers: updatedFeaturedPapers,
        trendingPapers: updatedTrendingPapers,
        myFeedPapers: updatedMyFeedPapers,
        worldPapers: updatedWorldPapers,
      ));

      // Save to database in background
      try {
        await repository.saveResearchPaper(event.paperId);
        // Success - the UI already shows the saved state
      } catch (e) {
        // If save fails, revert the saved status
        final revertedPapers = _updatePaperSavedStatus(updatedPapers, event.paperId, false);
        final revertedFeaturedPapers = _updatePaperSavedStatus(updatedFeaturedPapers, event.paperId, false);
        final revertedTrendingPapers = _updatePaperSavedStatus(updatedTrendingPapers, event.paperId, false);
        final revertedMyFeedPapers = _updatePaperSavedStatus(updatedMyFeedPapers, event.paperId, false);
        final revertedWorldPapers = _updatePaperSavedStatus(updatedWorldPapers, event.paperId, false);

        _allPapers = _updatePaperSavedStatus(_allPapers, event.paperId, false);

        emit(currentState.copyWith(
          papers: revertedPapers,
          featuredPapers: revertedFeaturedPapers,
          trendingPapers: revertedTrendingPapers,
          myFeedPapers: revertedMyFeedPapers,
          worldPapers: revertedWorldPapers,
        ));

        print('Failed to save paper: $e');
      }
    }

// Helper method to update paper saved status in a list
    List<ResearchPaper> _updatePaperSavedStatus(List<ResearchPaper> papers, String paperId, bool isSaved) {
      return papers.map((paper) {
        if (paper.id == paperId) {
          return paper.copyWith(isSaved: isSaved);
        }
        return paper;
      }).toList();
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

      emit(currentState.copyWith(selectedFeed: event.feedType?? FeedType.myFeed));
    }

    Future<void> _onRefreshResearchPapers(
        RefreshResearchPapers event,
        Emitter<HomeState> emit,
        ) async {
      if (state is! HomeLoaded) return;
      final currentState = state as HomeLoaded;

      try {
        _allPapers = await repository.fetchResearchPapers();

        // Check feedback status after refresh
        if (_currentUserId != null) {
          final summaryCount = await repository.getUserSummaryCount(_currentUserId!);
          final shouldShowFeedback = summaryCount.summaryCount >= 3 && !summaryCount.feedbackGiven;

          emit(HomeLoaded(
            papers: _allPapers,
            featuredPapers: _allPapers.take(1).toList(),
            trendingPapers: _allPapers.skip(1).toList(),
            myFeedPapers: _allPapers.where((p) => p.tags.contains('physics')).toList(),
            worldPapers: _allPapers.where((p) => p.tags.contains('technology')).toList(),
            selectedFeed: currentState.selectedFeed,
            shouldShowFeedback: shouldShowFeedback,
            summaryCount: summaryCount.summaryCount,
            feedbackGiven: summaryCount.feedbackGiven,
          ));
        } else {
          emit(HomeLoaded(
            papers: _allPapers,
            featuredPapers: _allPapers.take(1).toList(),
            trendingPapers: _allPapers.skip(1).toList(),
            myFeedPapers: _allPapers.where((p) => p.tags.contains('physics')).toList(),
            worldPapers: _allPapers.where((p) => p.tags.contains('technology')).toList(),
            selectedFeed: currentState.selectedFeed,
          ));
        }
      } catch (e) {
        emit(HomeError('Failed to refresh papers: $e'));
      }
    }

    Future<void> _onCheckFeedbackStatus(
        CheckFeedbackStatus event,
        Emitter<HomeState> emit,
        ) async {

      if (state is! HomeLoaded || _currentUserId == null) return;
      final currentState = state as HomeLoaded;

      try {
        final summaryCount = await repository.getUserSummaryCount(_currentUserId!);
        final shouldShowFeedback = summaryCount.summaryCount >= 3 && !summaryCount.feedbackGiven;

        print('Checking feedback status: shouldShowFeedback=$shouldShowFeedback, summaryCount=${summaryCount.summaryCount}, feedbackGiven=${summaryCount.feedbackGiven}');
        emit(currentState.copyWith(
          shouldShowFeedback: shouldShowFeedback,
          summaryCount: summaryCount.summaryCount,
          feedbackGiven: summaryCount.feedbackGiven,
        ));
      } catch (e) {
        emit(HomeError('Failed to check feedback status: $e'));
      }
    }

    Future<void> _onSubmitFeedback(
        SubmitFeedback event,
        Emitter<HomeState> emit,
        ) async {
      if (state is! HomeLoaded) return;
      final currentState = state as HomeLoaded;

      emit(FeedbackSubmitting());

      try {
        await repository.submitFeedback(event.feedback);

        emit(currentState.copyWith(
          shouldShowFeedback: false,
          feedbackGiven: true,
        ));
      } catch (e) {
        emit(FeedbackError('Failed to submit feedback: $e'));
      }
    }

    Future<void> _onIncrementSummaryCount(
        IncrementSummaryCount event,
        Emitter<HomeState> emit,
        ) async {
      if (_currentUserId == null) return;

      try {
        await repository.incrementSummaryCount(_currentUserId!);

        // Check if we should show feedback form after increment
        add(CheckFeedbackStatus());
      } catch (e) {
        print('Failed to increment summary count: $e');
      }
    }

    Future<void> _onDismissFeedbackForm(
        DismissFeedbackForm event,
        Emitter<HomeState> emit,
        ) async {
      if (state is! HomeLoaded) return;
      final currentState = state as HomeLoaded;

      emit(currentState.copyWith(shouldShowFeedback: false));
    }

    List<ResearchPaper> _filterPapers(String query) {
      if (query.isEmpty) return _allPapers;

      return _allPapers.where((paper) =>
      paper.title.toLowerCase().contains(query.toLowerCase()) ||
          paper.summary.toLowerCase().contains(query.toLowerCase())
      ).toList();
    }



  }