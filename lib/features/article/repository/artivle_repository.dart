
import '../modal/article_modal.dart';
import '../modal/datasource.dart';
import 'abs_article.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final ArticleLocalDataSource localDataSource;

  ArticleRepositoryImpl({required this.localDataSource});

  @override
  Future<Article> getArticle(String id) async {
    return localDataSource.getArticle(id);
  }
}