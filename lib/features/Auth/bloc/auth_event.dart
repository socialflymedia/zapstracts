import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SignUpRequested extends AuthEvent {
  final String email, password, name, phone;

  SignUpRequested({
    required this.email,
    required this.password,
    required this.name,
    required this.phone,
  });

  @override
  List<Object?> get props => [email, password, name, phone];
}

class LoginRequested extends AuthEvent {
  final String email, password;

  LoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class LogoutRequested extends AuthEvent {}

class AuthStatusChanged extends AuthEvent {
  final bool isLoggedIn;

  AuthStatusChanged({required this.isLoggedIn});

  @override
  List<Object?> get props => [isLoggedIn];
}

class TogglePasswordVisibility extends AuthEvent {}

class ToggleConfirmPasswordVisibility extends AuthEvent {}

class ToggleAgreement extends AuthEvent {}
class SignInWithGoogle extends AuthEvent {}

class SignUpWithGoogle extends AuthEvent {}