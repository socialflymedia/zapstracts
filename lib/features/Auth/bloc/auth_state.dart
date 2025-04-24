import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final String sucessMessage;

  Authenticated(this.sucessMessage);

  @override
  List<Object> get props => [sucessMessage];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);

  @override
  List<Object> get props => [message];
}

class AuthPasswordVisibilityState extends AuthState {
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final bool agreed;

  AuthPasswordVisibilityState({
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.agreed,
  });

  @override
  List<Object> get props => [obscurePassword, obscureConfirmPassword, agreed];
}
