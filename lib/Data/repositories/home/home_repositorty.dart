import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../features/homeScreen/model/feedback_form_modal.dart';
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

    return (response as List)
        .map((paper) => ResearchPaper.fromMap(paper))
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

