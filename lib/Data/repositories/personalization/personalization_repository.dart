import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../features/personalization/bloc/personalization_state.dart';

class PersonalizationRepository {
  final supabase = Supabase.instance.client;

  Future<void> savePreferences({

    required String? selectedGoal,
    required String? expertiseLevel,

    required List<String> selectedTopicIds,
    required String sliderText,
  }) async {
    try {


      final prefs = await SharedPreferences.getInstance();

      final userId = prefs.getString('user_id') ?? '-';
      await supabase.from('user_prefrences').upsert({
        'user_id': userId,
        'selected_goal': selectedGoal,
        'expertise_level': expertiseLevel,

        'selected_topics': selectedTopicIds,


      }).select();

      await prefs.setString('selected_goal',selectedGoal!);
      await prefs.setString('expertise_level',expertiseLevel!);

      await prefs.setStringList('selected_topic_ids',
          selectedTopicIds.isNotEmpty ? selectedTopicIds : ['']);

      print('Personalization preferences saved.');
    } catch (e) {
      print('Error saving personalization preferences: $e');
      rethrow;
    }
  }

  Future<PersonalizationState?> fetchPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? '-';

      final res = await supabase
          .from('user_prefrences')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (res == null) return null;

      // Save to SharedPreferences
      await prefs.setString('selected_goal', res['selected_goal'] ?? '');
      await prefs.setString('expertise_level', res['expertise_level'] ?? '');

      await prefs.setStringList('selected_topic_ids',
          List<String>.from(res['selected_topic_ids'] ?? []));

      return PersonalizationState(
        status: PersonalizationStatus.completed,
        selectedGoal: res['selected_goal'],
        expertiseLevel: res['expertise_level'],
        expertiseSliderValue: (res['expertise_slider_value'] ?? 0.0).toDouble(),
        selectedTopicIds: List<String>.from(res['selected_topic_ids'] ?? []),
        slidertext: res['slider_text'] ?? "skip",
      );
    } catch (e) {
      print('Error fetching personalization preferences: $e');
      return null;
    }
  }

  Future<void> clearPreferences(String userId) async {
    try {
      await supabase
          .from('personalization')
          .delete()
          .eq('user_id', userId);

      print('Personalization preferences cleared.');
    } catch (e) {
      print('Error clearing personalization preferences: $e');
      rethrow;
    }
  }
}
