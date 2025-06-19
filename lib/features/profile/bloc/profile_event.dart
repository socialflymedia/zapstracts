import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {}

class UpdateNotifications extends ProfileEvent {
  final bool enabled;

  const UpdateNotifications(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class UpdateLanguage extends ProfileEvent {
  final String language;

  const UpdateLanguage(this.language);

  @override
  List<Object?> get props => [language];
}