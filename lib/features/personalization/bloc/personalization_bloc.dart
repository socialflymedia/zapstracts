import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zapstract/features/personalization/bloc/personalization_event.dart';
import 'package:zapstract/features/personalization/bloc/personalization_state.dart';


class PersonalizationBloc extends Bloc<PersonalizationEvent, PersonalizationState> {
  PersonalizationBloc() : super(const PersonalizationState()) {
    on<SelectScienceGoal>(_onSelectScienceGoal);
    on<SelectExpertiseLevel>(_onSelectExpertiseLevel);
    on<SkipPersonalization>(_onSkipPersonalization);
  }

  void _onSelectScienceGoal(SelectScienceGoal event, Emitter<PersonalizationState> emit) {
    emit(state.copyWith(
      status: PersonalizationStatus.goalsSelected,
      selectedGoal: event.goal,
    ));
  }

  void _onSelectExpertiseLevel(SelectExpertiseLevel event, Emitter<PersonalizationState> emit) {
    emit(state.copyWith(
      status: PersonalizationStatus.expertiseLevelSelected,
      expertiseLevel: event.level,
      expertiseSliderValue: event.sliderValue,
    ));
  }

  void _onSkipPersonalization(SkipPersonalization event, Emitter<PersonalizationState> emit) {
    emit(state.copyWith(
      status: PersonalizationStatus.completed,
    ));
  }
}