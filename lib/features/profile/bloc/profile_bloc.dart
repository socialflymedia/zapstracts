import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zapstract/features/profile/bloc/profile_event.dart';
import 'package:zapstract/features/profile/bloc/profile_state.dart';

import '../model/user_profile.dart';


class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileLoading()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateNotifications>(_onUpdateNotifications);
    on<UpdateLanguage>(_onUpdateLanguage);
  }

  Future<void> _onLoadProfile(
      LoadProfile event,
      Emitter<ProfileState> emit,
      ) async {
    emit(ProfileLoading());

    try {
      final prefs = await SharedPreferences.getInstance();



      final name = prefs.getString('name') ?? 'No Name';
      final subject = prefs.getString('selected_goal') ?? 'No Goal';
      final occupation = prefs.getString('expertise_level') ?? 'Unknown';
      final papersRead = prefs.getInt('papersRead') ?? 0;
      final bookmarks = prefs.getInt('bookmarks') ?? 0;
      final following = prefs.getInt('following') ?? 0;
      final language = prefs.getString('language') ?? 'English';
      final notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;

      // You can customize or deserialize `researchStats` if stored as JSON
      final researchStats = {
        'Physics': prefs.getDouble('physics') ?? 0.0,
        'Biology': prefs.getDouble('biology') ?? 0.0,
        'Chemistry': prefs.getDouble('chemistry') ?? 0.0,
      };

      final profile = UserProfile(
        name: name,
        subject: subject,
        occupation: occupation,
        papersRead: papersRead,
        bookmarks: bookmarks,
        following: following,
        researchStats: researchStats,
        language: language,
        notificationsEnabled: notificationsEnabled,
      );

      emit(ProfileLoaded(profile: profile));
    } catch (e) {
      emit(ProfileError('Failed to load profile: $e'));
    }
  }

  Future<void> _onUpdateNotifications(
      UpdateNotifications event,
      Emitter<ProfileState> emit,
      ) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      final updatedProfile = currentState.profile.copyWith(
        notificationsEnabled: event.enabled,
      );

      emit(ProfileLoaded(profile: updatedProfile));
    }
  }

  Future<void> _onUpdateLanguage(
      UpdateLanguage event,
      Emitter<ProfileState> emit,
      ) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      final updatedProfile = currentState.profile.copyWith(
        language: event.language,
      );

      emit(ProfileLoaded(profile: updatedProfile));
    }
  }
}