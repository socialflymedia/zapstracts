import 'package:equatable/equatable.dart';

abstract class ArticleEvent extends Equatable {
  const ArticleEvent();

  @override
  List<Object> get props => [];
}

class LoadArticleEvent extends ArticleEvent {
  final String paper_id;
  const LoadArticleEvent(this.paper_id);
}

class RefreshArticleEvent extends ArticleEvent {
  const RefreshArticleEvent();
}

class IncreamentSummaryCount extends ArticleEvent {

}