import 'package:equatable/equatable.dart';

import '../modal/article_modal.dart';

abstract class ArticleState extends Equatable {
  const ArticleState();

  @override
  List<Object> get props => [];
}

class ArticleInitial extends ArticleState {
  const ArticleInitial();
}

class ArticleLoading extends ArticleState {
  const ArticleLoading();
}

class ArticleLoaded extends ArticleState {
  final Article article;

  const ArticleLoaded({required this.article});

  @override
  List<Object> get props => [article];
}

class ArticleError extends ArticleState {
  final String message;

  const ArticleError({required this.message});

  @override
  List<Object> get props => [message];
}

class SummaryCountIncremented extends ArticleState {
  const SummaryCountIncremented();

  @override
  List<Object> get props => [];
}