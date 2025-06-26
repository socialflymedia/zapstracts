import 'package:equatable/equatable.dart';

enum PersonalizationStatus {
  initial,
  goalsSelected,
  expertiseLevelSelected,
  topicsSelected,
  completed,
  loading
}

class PersonalizationState extends Equatable {
  final PersonalizationStatus status;
  final String? selectedGoal;
  final String? expertiseLevel;
  final double expertiseSliderValue;
  final List<String> selectedTopicIds;
  final String slidertext;

  const PersonalizationState({
    this.status = PersonalizationStatus.initial,
    this.selectedGoal,
    this.expertiseLevel='novice',
    this.expertiseSliderValue = 0.0,
    this.selectedTopicIds = const [],
    this.slidertext = "skip",
  });

  PersonalizationState copyWith({
    PersonalizationStatus? status,
    String? selectedGoal,
    String? expertiseLevel,
    double? expertiseSliderValue,
    List<String>? selectedTopicIds,
    String? slidertext,
  }) {
    return PersonalizationState(
      status: status ?? this.status,
      selectedGoal: selectedGoal ?? this.selectedGoal,
      expertiseLevel: expertiseLevel ?? this.expertiseLevel,
      expertiseSliderValue: expertiseSliderValue ?? this.expertiseSliderValue,
      selectedTopicIds: selectedTopicIds ?? this.selectedTopicIds,
      slidertext: slidertext ?? this.slidertext,
    );
  }

  @override
  List<Object?> get props => [
    status,
    selectedGoal,
    expertiseLevel,
    expertiseSliderValue,
    selectedTopicIds,
    slidertext,
  ];
}
