import 'package:equatable/equatable.dart';

enum PersonalizationStatus { initial, goalsSelected, expertiseLevelSelected, completed }

class PersonalizationState extends Equatable {
  final PersonalizationStatus status;
  final String? selectedGoal;
  final String? expertiseLevel;
  final double expertiseSliderValue;
  
  const PersonalizationState({
    this.status = PersonalizationStatus.initial,
    this.selectedGoal,
    this.expertiseLevel,
    this.expertiseSliderValue = 0.0,
  });
  
  PersonalizationState copyWith({
    PersonalizationStatus? status,
    String? selectedGoal,
    String? expertiseLevel,
    double? expertiseSliderValue,
  }) {
    return PersonalizationState(
      status: status ?? this.status,
      selectedGoal: selectedGoal ?? this.selectedGoal,
      expertiseLevel: expertiseLevel ?? this.expertiseLevel,
      expertiseSliderValue: expertiseSliderValue ?? this.expertiseSliderValue,
    );
  }
  
  @override
  List<Object?> get props => [status, selectedGoal, expertiseLevel, expertiseSliderValue];
}