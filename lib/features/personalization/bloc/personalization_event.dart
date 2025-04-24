import 'package:equatable/equatable.dart';

abstract class PersonalizationEvent extends Equatable {
  const PersonalizationEvent();
  
  @override
  List<Object?> get props => [];
}

class SelectScienceGoal extends PersonalizationEvent {
  final String goal;
  
  const SelectScienceGoal(this.goal);
  
  @override
  List<Object?> get props => [goal];
}

class SelectExpertiseLevel extends PersonalizationEvent {
  final String level;
  final double sliderValue;
  
  const SelectExpertiseLevel(this.level, this.sliderValue);
  
  @override
  List<Object?> get props => [level, sliderValue];
}

class SkipPersonalization extends PersonalizationEvent {}