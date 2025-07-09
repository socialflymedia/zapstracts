import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../features/homeScreen/model/research_paper.dart';


class HomeRepository {
  final supabase = Supabase.instance.client;

  Future<List<ResearchPaper>> fetchResearchPapers() async {
    final response = await supabase
        .from('papers_metadata')
        .select('''
          paper_id,
          title,
          author,
          publication,
          summary_images(card_image_url)
        ''');

    if (response == null || response.isEmpty) {
      return [];
    }

    //print(response);
    return (response as List)
        .map((paper) => ResearchPaper.fromMap(paper))
        .toList();
  }
}
