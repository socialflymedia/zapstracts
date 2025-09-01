import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../features/homeScreen/model/feedback_form_modal.dart';
import '../../../features/homeScreen/model/research_paper.dart';

class HomeRepository {
  final supabase = Supabase.instance.client;

  Future<List<ResearchPaper>> fetchResearchPapers() async {
    // Get current user ID
    final userId = Supabase.instance.client.auth.currentUser?.id;

    // Fetch papers
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

    List<String> savedPaperIds = [];

    // If user is logged in, fetch their saved papers
    if (userId != null) {
      try {
        final savedResponse = await supabase
            .from('saved_papers')
            .select('paper_id')
            .eq('user_id', userId)
            .maybeSingle();

        if (savedResponse != null && savedResponse['paper_id'] != null) {
          savedPaperIds = List<String>.from(savedResponse['paper_id']);
        }
        print('Saved paper IDs for user $userId: $savedPaperIds');
      } catch (e) {
        print('Error fetching saved papers: $e');
      }
    }

    // Map papers and include saved status
    return (response as List)
        .map((paper) {
      final researchPaper = ResearchPaper.fromMap(paper);
      // Set the isSaved property based on saved papers list
      return researchPaper.copyWith(
        isSaved: savedPaperIds.contains(researchPaper.id),
      );
    })
        .toList();
  }


  // Check user's summary count and feedback status
  Future<UserSummaryCount> getUserSummaryCount(String userId) async {
    try {
      final response = await supabase
          .from('summary_count')
          .select('*')
          .eq('user_id', userId)
          .maybeSingle();

      print('User ID: $userId, Response: $response');

      if (response == null) {
        // Create new record if doesn't exist
        await supabase.from('summary_count').insert({
          'user_id': userId,
          'summary_count': 0,
          'feedback_given': false,
        });

        return UserSummaryCount(
          userId: userId,
          summaryCount: 0,
          feedbackGiven: false,
        );
      }

      return UserSummaryCount.fromMap(response);
    } catch (e, stackTrace) {
      print('Error in getUserSummaryCount: $e');
      print(stackTrace);

      // Optionally rethrow or return a default/fallback value
      return UserSummaryCount(
        userId: userId,
        summaryCount: 0,
        feedbackGiven: false,
      );
    }
  }




  Future<void> saveResearchPaper(String paperId) async {
    var userId = '956fddcd-8163-45b9-a6d9-79b94c1329f3';

    try {
      // First, check if user already has saved papers
      final existingData = await supabase
          .from('saved_papers')
          .select('paper_id')
          .eq('user_id', userId)
          .maybeSingle();

      if (existingData != null) {
        // User has existing saved papers - update the array
        List<String> existingPaperIds = List<String>.from(existingData['paper_id'] ?? []);

        if (!existingPaperIds.contains(paperId)) {
          existingPaperIds.add(paperId);

          await supabase
              .from('saved_papers')
              .update({'paper_id': existingPaperIds})
              .eq('user_id', userId);
        }
      } else {
        // User doesn't have any saved papers - create new row
        await supabase.from('saved_papers').insert({
          'user_id': userId,
          'paper_id': [paperId], // Array with single paper ID
        });
      }
    } catch (e) {
      throw Exception('Failed to save paper: $e');
    }
  }


  Future<List<ResearchPaper>> fetchSavedPapers() async {
    try {
      //final userId = Supabase.instance.client.auth.currentUser?.id;
       final userId = '956fddcd-8163-45b9-a6d9-79b94c1329f3';
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final savedResponse = await supabase
          .from('saved_papers')
          .select('paper_id')
          .eq('user_id', userId)
          .maybeSingle();

      if (savedResponse == null || savedResponse['paper_id'] == null) {
        return [];
      }

      List<String> savedPaperIds = List<String>.from(savedResponse['paper_id']);

      if (savedPaperIds.isEmpty) {
        return [];
      }

      // Using .filter() with raw PostgREST 'in' syntax
      final filterValue = '(${savedPaperIds.map((id) => '"$id"').join(',')})';

      final papersResponse = await supabase
          .from('papers_metadata')
          .select('''
          paper_id,
          title,
          author,
          publication,
          summary_images(card_image_url)
        ''')
          .filter('paper_id', 'in', filterValue);

      if (papersResponse == null || papersResponse.isEmpty) {
        return [];
      }

      // Convert the response to List<ResearchPaper>
      return (papersResponse as List)
          .map((paper) {
        final researchPaper = ResearchPaper.fromMap(paper);
        // Mark as saved since these are all saved papers
        return researchPaper.copyWith(isSaved: true);
      })
          .toList();

    } catch (e) {
      print('Error fetching saved papers: $e');
      return [];
    }
  }



  // Increment summary count
  Future<void> incrementSummaryCount(String userId) async {
    await supabase.rpc('increment_summary_count', params: {
      'user_id_param': userId,
    });
  }



  // Submit feedback
  Future<void> submitFeedback(FeedbackModel feedback) async {
    // Insert feedback
    await supabase.from('feedback').insert(feedback.toMap());

    // Update feedback_given status
    await supabase
        .from('summary_count')
        .update({'feedback_given': true})
        .eq('user_id', feedback.userId);
  }

  // Check if user has given feedback
  Future<bool> hasFeedbackGiven(String userId) async {
    final response = await supabase
        .from('summary_count')
        .select('feedback_given')
        .eq('user_id', userId)
        .single();

    return response?['feedback_given'] ?? false;
  }
}

