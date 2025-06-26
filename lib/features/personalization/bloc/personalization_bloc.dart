import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zapstract/Data/repositories/personalization/personalization_repository.dart';
import 'package:zapstract/features/personalization/bloc/personalization_event.dart';
import 'package:zapstract/features/personalization/bloc/personalization_state.dart';


class PersonalizationBloc extends Bloc<PersonalizationEvent, PersonalizationState> {
  PersonalizationBloc() : super(const PersonalizationState()) {
    on<SelectScienceGoal>(_onSelectScienceGoal);
    on<SelectExpertiseLevel>(_onSelectExpertiseLevel);
    on<SkipPersonalization>(_onSkipPersonalization);
    on<SelectTopics>(_onSelectTopics);
    on<ToggleTopic>(_onToggleTopic);
    on<CompletePersonalization>(_onCompletePersonalization);
  }

  void _onSelectScienceGoal(SelectScienceGoal event, Emitter<PersonalizationState> emit) {
    emit(state.copyWith(
      status: PersonalizationStatus.goalsSelected,
      selectedGoal: event.goal,
      slidertext: "next",
    ));
  }

  void _onSelectExpertiseLevel(SelectExpertiseLevel event, Emitter<PersonalizationState> emit) {
    emit(state.copyWith(
      status: PersonalizationStatus.expertiseLevelSelected,
      expertiseLevel: event.level,
      expertiseSliderValue: event.sliderValue,
      slidertext: event.sliderText,
    ));
  }

  void _onSkipPersonalization(SkipPersonalization event, Emitter<PersonalizationState> emit) {
    emit(state.copyWith(
      status: PersonalizationStatus.completed,
    ));
  }

  void _onSelectTopics(SelectTopics event, Emitter<PersonalizationState> emit) {
    emit(state.copyWith(
      selectedTopicIds: event.selectedTopicIds,
      status: PersonalizationStatus.topicsSelected,
    ));
  }

  void _onToggleTopic(ToggleTopic event, Emitter<PersonalizationState> emit) {
    final currentTopics = List<String>.from(state.selectedTopicIds);

    if (currentTopics.contains(event.topicId)) {
      currentTopics.remove(event.topicId);
    } else {
      currentTopics.add(event.topicId);
    }

    emit(state.copyWith(
      selectedTopicIds: currentTopics,
      status: currentTopics.isNotEmpty
          ? PersonalizationStatus.topicsSelected
          : PersonalizationStatus.expertiseLevelSelected,
    ));
  }

  Future<void> _onCompletePersonalization(CompletePersonalization event, Emitter<PersonalizationState> emit) async {
    emit(state.copyWith(status: PersonalizationStatus.loading));

    try {
      await PersonalizationRepository().savePreferences(
        selectedGoal: state.selectedGoal ?? "",
        expertiseLevel: state.expertiseLevel ?? "",

        selectedTopicIds: state.selectedTopicIds,
        sliderText: state.slidertext,
      );

      emit(state.copyWith(status: PersonalizationStatus.completed));
    } catch (e) {
      // You can define a separate error state if needed
      print("Error saving preferences: $e");
      emit(state.copyWith(status: PersonalizationStatus.completed));
    }
  }

}