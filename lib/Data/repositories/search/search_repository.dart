import 'package:zapstract/Data/repositories/home/home_repositorty.dart';

import '../../../features/homeScreen/model/research_paper.dart';

class ResearchRepository  {
  // Your existing implementation...

  @override
  Future<List<ResearchPaper>> searchPapers(String query) async {
    try {
      // Replace this with your actual API call
      // Example API call:
      // final response = await http.get(
      //   Uri.parse('$baseUrl/search?q=${Uri.encodeComponent(query)}'),
      //   headers: headers,
      // );

      // For now, returning mock data that filters based on query
      HomeRepository homeRepository = HomeRepository();
      final allPapers = await  homeRepository.fetchResearchPapers(); // Your existing method to get papers

      // Filter papers based on query (title, summary, publishedIn)
      final filteredPapers = allPapers.where((paper) {
        final queryLower = query.toLowerCase();
        return paper.title.toLowerCase().contains(queryLower) ||
            paper.summary.toLowerCase().contains(queryLower) ||
            paper.publishedIn.toLowerCase().contains(queryLower);
      }).toList();

      return filteredPapers;
    } catch (e) {
      throw Exception('Failed to search papers: $e');
    }
  }


}