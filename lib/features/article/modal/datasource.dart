import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../modal/article_modal.dart';

class ArticleLocalDataSource {
  final supabase = Supabase.instance.client;
  ArticleLocalDataSource();


  static Future<String> getExpertiseLevel() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('expertise_level') ?? '';
  }
  Future<Article> getArticle(String paperId) async {
    print('here ${paperId}');
    final response = await supabase
        .from('summaries')
        .select()
        .eq('paper_id', paperId)
        .single();

    //print('response: $response');
    if (response == null) throw Exception("Article not found");

    final imageResponse = await supabase
        .from('summary_images')
        .select('explanation_image_url')
        .eq('paper_id', paperId)
        .maybeSingle();
 //print('imageResponse: $imageResponse');
    final paperData = await supabase
        .from('papers_metadata')
        .select()
        .eq('paper_id', paperId)
        .single();

   // print('paperData: $paperData');
    String expertiseLevel =  await getExpertiseLevel();
    print(expertiseLevel);
// Load appropriate summary based on expertise level
    String summary = '';

    if (expertiseLevel == 'novice') {
      summary = response['summary'] ?? '';
    } else if (expertiseLevel == 'learning') {
      summary = response['summary_intermediate'] ?? '';
    } else if (expertiseLevel == 'student') {
      summary = response['summary_expert'] ?? '';
    } else {
      // Default fallback
      summary = response['summary'] ?? '';
    }
   // final String summary = response['summary'] ?? '';

    print(summary);
    final Map<String, ArticleSection> parsedSections = _parseSummaryIntoSections(summary);

    // if (imageResponse?['explanation_image_url'] != null) {
    //   parsedSections['Explanation Image Url'] = ArticleSection(
    //     title: 'Explanation IR',
    //     content: imageResponse!['explanation_image_url'],
    //     readTime: 1,
    //   );
    // }
   //print(parsedSections);
    return Article(
      id: paperId,
      title: paperData['title'],
      subtitle: '',
      imageUrl: imageResponse?['explanation_image_url'] ?? '',
      author: paperData['author'],
      journal: paperData['publication'],
      readTime: 2,
      sections: parsedSections,
    );
  }

  /// Split the summary into sections like Abstract, Introduction, etc.
  Map<String, ArticleSection> _parseSummaryIntoSections(String summary) {
    final Map<String, ArticleSection> sections = {};

    final regex = RegExp(
      r'(?:\*\*)?(Abstract|Introduction|Methods|Results|Conclusion)(?:\*\*)?',
      caseSensitive: false,
    );

    final matches = regex.allMatches(summary).toList();
    print('matches: $matches');

    for (int i = 0; i < matches.length; i++) {
      final match = matches[i];
      final title = match.group(1)!;

      final start = match.end;
      final end = (i + 1 < matches.length) ? matches[i + 1].start : summary.length;

      final content = summary.substring(start, end).trim();

      sections[title] = ArticleSection(
        title: title,
        content: content,
        readTime: 1,
      );
    }

    return sections;
  }


}
