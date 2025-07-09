
import '../modal/article_modal.dart';

abstract class ArticleRepository {
  Future<Article> getArticle(String id);
}