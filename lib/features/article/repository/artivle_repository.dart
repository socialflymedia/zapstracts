
import 'package:supabase_flutter/supabase_flutter.dart';

import '../modal/article_modal.dart';
import '../modal/datasource.dart';
import 'abs_article.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final ArticleLocalDataSource localDataSource;
   final supabase = Supabase.instance.client;
  ArticleRepositoryImpl({required this.localDataSource});

  @override
  Future<Article> getArticle(String id) async {
    return localDataSource.getArticle(id);
  }

  @override
  Future<void> incrementSummaryCount() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      // Get current count
      print('Incrementing summary count for user: $userId');
      final response = await supabase
          .from('summary_count')
          .select('summary_count')
          .eq('user_id', userId)
          .maybeSingle();

      int currentCount = (response?['summary_count'] ?? 0) as int;
      int updatedCount = currentCount + 1;

      // Update count in DB
    final res=  await supabase.from('summary_count').update({
        'summary_count': updatedCount,
      }).eq('user_id', userId);
 print(res);
      // Dispatch Bloc event
      // if (context.mounted) {
      //   context.read<HomeBloc>().add(IncrementSummaryCount());
      // }
    } catch (e) {
      print('Error incrementing summary count: $e');
    }
  }

}