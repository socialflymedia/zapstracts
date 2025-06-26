import 'package:equatable/equatable.dart';

abstract class PersonalizationEvent extends Equatable {
  const PersonalizationEvent();
  
  @override
  List<Object?> get props => [];
}

class SelectScienceGoal extends PersonalizationEvent {
  final String goal;
  final String sliderText = "skip";
  const SelectScienceGoal(this.goal);
  
  @override
  List<Object?> get props => [goal];
}


class SelectExpertiseLevel extends PersonalizationEvent {
  final String level;
  final double sliderValue;
  final String sliderText ;
  const SelectExpertiseLevel(this.level, this.sliderValue,this.sliderText);
  
  @override
  List<Object?> get props => [level, sliderValue];
}

class SkipPersonalization extends PersonalizationEvent {}


class SelectTopics extends PersonalizationEvent {
  final List<String> selectedTopicIds;

  const SelectTopics(this.selectedTopicIds);

  @override
  List<Object?> get props => [selectedTopicIds];
}

class ToggleTopic extends PersonalizationEvent {
  final String topicId;
  final String sliderText= "continue";
  const ToggleTopic(this.topicId);

  @override
  List<Object?> get props => [topicId];
}

class CompletePersonalization extends PersonalizationEvent {
  const CompletePersonalization();
}