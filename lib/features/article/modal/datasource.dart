import 'package:supabase_flutter/supabase_flutter.dart';
import '../modal/article_modal.dart';

class ArticleLocalDataSource {
  final supabase = Supabase.instance.client;
  ArticleLocalDataSource();

  Future<Article> getArticle(String paperId) async {
    print('here ${paperId}');
    final response = await supabase
        .from('summaries')
        .select()
        .eq('paper_id', paperId)
        .single();

    print('response: $response');
    if (response == null) throw Exception("Article not found");

    final imageResponse = await supabase
        .from('summary_images')
        .select('explanation_image_url')
        .eq('paper_id', paperId)
        .maybeSingle();
 print('imageResponse: $imageResponse');
    final paperData = await supabase
        .from('papers_metadata')
        .select()
        .eq('paper_id', paperId)
        .single();

    print('paperData: $paperData');
    final String summary = response['summary'] ?? '';

    final Map<String, ArticleSection> parsedSections = _parseSummaryIntoSections(summary);

    // if (imageResponse?['explanation_image_url'] != null) {
    //   parsedSections['Explanation Image Url'] = ArticleSection(
    //     title: 'Explanation IR',
    //     content: imageResponse!['explanation_image_url'],
    //     readTime: 1,
    //   );
    // }
   print(parsedSections);
    return Article(
      id: paperId,
      title: paperData['title'],
      subtitle: 'Generated Summary',
      imageUrl: imageResponse?['explanation_image_url'] ?? '',
      author: paperData['author'],
      journal: paperData['publication'],
      readTime: 2,
      sections: parsedSections,
    );
  }

  /// Split the summary into sections like Abstract, Introduction, etc.
  Map<String, ArticleSection> _parseSummaryIntoSections(String summary) {
    final sectionTitles = [
      'Abstract',
      'Introduction',
      'Methods',
      'Results',
      'Conclusion',
    ];

    final Map<String, ArticleSection> sections = {};

    final regex = RegExp(
      r'(?<=\n|^)(Abstract|Introduction|Methods|Results|Conclusion)\n',
      caseSensitive: false,
    );

    final matches = regex.allMatches(summary);
    final List<RegExpMatch> matchList = matches.toList();

    for (int i = 0; i < matchList.length; i++) {
      final match = matchList[i];
      final title = match.group(1)!;
      final start = match.end;
      final end = (i + 1 < matchList.length) ? matchList[i + 1].start : summary.length;
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
