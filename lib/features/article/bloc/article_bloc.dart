import 'dart:async';

import 'package:bloc/bloc.dart';

import '../repository/abs_article.dart';
import '../repository/artivle_repository.dart';
import 'article_event.dart';
import 'article_state.dart';

class ArticleBloc extends Bloc<ArticleEvent, ArticleState> {
  final ArticleRepository repository;

  ArticleBloc({required this.repository}) : super(const ArticleInitial()) {
    on<LoadArticleEvent>(_onLoadArticle);
    on<RefreshArticleEvent>(_onRefreshArticle);
    on<IncreamentSummaryCount>(_onIncrementSummaryCount);
  }

  Future<void> _onLoadArticle(
      LoadArticleEvent event,
      Emitter<ArticleState> emit,
      ) async {
    emit(const ArticleLoading());
    try {

      final article = await repository.getArticle(event.paper_id);
      emit(ArticleLoaded(article: article));
    } catch (e) {
      emit(ArticleError(message: e.toString()));
    }
  }

  Future<void> _onRefreshArticle(
      RefreshArticleEvent event,
      Emitter<ArticleState> emit,
      ) async {
    try {
      final article = await repository.getArticle('1');
      emit(ArticleLoaded(article: article));
    } catch (e) {
      emit(ArticleError(message: e.toString()));
    }
  }

  Future<void> _onIncrementSummaryCount(IncreamentSummaryCount event, Emitter<ArticleState> emit) async {
    try {

      emit(const ArticleLoading());
      await repository.incrementSummaryCount();
      // Optionally, you can emit a state to indicate success
      emit(SummaryCountIncremented());
    } catch (e) {
      emit(ArticleError(message: e.toString()));
    }
  }
}