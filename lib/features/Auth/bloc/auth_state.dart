import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final bool agreed;

  const AuthState({
    this.obscurePassword = true,
    this.obscureConfirmPassword = true,
    this.agreed = false,
  });

  @override
  List<Object?> get props => [obscurePassword, obscureConfirmPassword, agreed];
}

class AuthInitial extends AuthState {
  const AuthInitial({
    bool obscurePassword = true,
    bool obscureConfirmPassword = true,
    bool agreed = false,
  }) : super(
    obscurePassword: obscurePassword,
    obscureConfirmPassword: obscureConfirmPassword,
    agreed: agreed,
  );
}

class AuthLoading extends AuthState {
  const AuthLoading({
    bool obscurePassword = true,
    bool obscureConfirmPassword = true,
    bool agreed = false,
  }) : super(
    obscurePassword: obscurePassword,
    obscureConfirmPassword: obscureConfirmPassword,
    agreed: agreed,
  );
}

class Authenticated extends AuthState {
  final String successMessage;

  const Authenticated(
      this.successMessage, {
        bool obscurePassword = true,
        bool obscureConfirmPassword = true,
        bool agreed = false,
      }) : super(
    obscurePassword: obscurePassword,
    obscureConfirmPassword: obscureConfirmPassword,
    agreed: agreed,
  );

  @override
  List<Object?> get props =>
      [successMessage, obscurePassword, obscureConfirmPassword, agreed];
}

class UserAlreadyPresent extends AuthState {
  final String message;

  const UserAlreadyPresent(
      this.message, {
        bool obscurePassword = true,
        bool obscureConfirmPassword = true,
        bool agreed = false,
      }) : super(
    obscurePassword: obscurePassword,
    obscureConfirmPassword: obscureConfirmPassword,
    agreed: agreed,
  );

  @override
  List<Object?> get props =>
      [message, obscurePassword, obscureConfirmPassword, agreed];
}

class NewUserAuthenticated extends AuthState {
  final String message;

  const NewUserAuthenticated(
      this.message, {
        bool obscurePassword = true,
        bool obscureConfirmPassword = true,
        bool agreed = false,
      }) : super(
    obscurePassword: obscurePassword,
    obscureConfirmPassword: obscureConfirmPassword,
    agreed: agreed,
  );

  @override
  List<Object?> get props =>
      [message, obscurePassword, obscureConfirmPassword, agreed];
}

class Unauthenticated extends AuthState {
  const Unauthenticated({
    bool obscurePassword = true,
    bool obscureConfirmPassword = true,
    bool agreed = false,
  }) : super(
    obscurePassword: obscurePassword,
    obscureConfirmPassword: obscureConfirmPassword,
    agreed: agreed,
  );
}

class AuthError extends AuthState {
  final String message;

  const AuthError(
      this.message, {
        bool obscurePassword = true,
        bool obscureConfirmPassword = true,
        bool agreed = false,
      }) : super(
    obscurePassword: obscurePassword,
    obscureConfirmPassword: obscureConfirmPassword,
    agreed: agreed,
  );

  @override
  List<Object?> get props =>
      [message, obscurePassword, obscureConfirmPassword, agreed];
}
