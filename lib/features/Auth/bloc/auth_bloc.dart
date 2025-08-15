import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zapstract/Data/repositories/auth/auth_repository.dart';
import 'package:zapstract/Data/repositories/personalization/personalization_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepo;

  AuthBloc(this.authRepo)
      : super(const AuthInitial(
    obscurePassword: true,
    obscureConfirmPassword: true,
    agreed: false,
  )) {
    on<SignUpRequested>(_onSignUp);
    on<LoginRequested>(_onLogin);
    on<LogoutRequested>(_onLogout);
    on<AuthStatusChanged>(_onAuthStatusChanged);
    on<SignUpWithGoogle>(_onSignUpWithGoogle);
    on<SignInWithGoogle>(_onSignInWithGoogle);
    on<TogglePasswordVisibility>(_onTogglePasswordVisibility);
    on<ToggleConfirmPasswordVisibility>(_onToggleConfirmPasswordVisibility);
    on<ToggleAgreement>(_onToggleAgreement);
  }

  /// Helper to copy current toggle values to the next state
  T _carry<T extends AuthState>(T Function(
      bool obscurePassword,
      bool obscureConfirmPassword,
      bool agreed,
      ) creator) {
    return creator(
      state.obscurePassword,
      state.obscureConfirmPassword,
      state.agreed,
    );
  }

  Future<void> _onSignUp(SignUpRequested event, Emitter<AuthState> emit) async {
    emit(_carry((o, c, a) => AuthLoading(
      obscurePassword: o,
      obscureConfirmPassword: c,
      agreed: a,
    )));
    try {
      await authRepo.signUp(event.email, event.password, event.name, event.phone);
      emit(_carry((o, c, a) => Authenticated(
        "success",
        obscurePassword: o,
        obscureConfirmPassword: c,
        agreed: a,
      )));
    } catch (e) {
      emit(_carry((o, c, a) => AuthError(
        e.toString(),
        obscurePassword: o,
        obscureConfirmPassword: c,
        agreed: a,
      )));
    }
  }

  Future<void> _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
    emit(_carry((o, c, a) => AuthLoading(
      obscurePassword: o,
      obscureConfirmPassword: c,
      agreed: a,
    )));
    try {
      await authRepo.login(event.email, event.password);
      emit(_carry((o, c, a) => Authenticated(
        "success",
        obscurePassword: o,
        obscureConfirmPassword: c,
        agreed: a,
      )));
    } catch (e) {
      emit(_carry((o, c, a) => AuthError(
        e.toString(),
        obscurePassword: o,
        obscureConfirmPassword: c,
        agreed: a,
      )));
    }
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    await authRepo.logout();
    emit(_carry((o, c, a) => Unauthenticated(
      obscurePassword: o,
      obscureConfirmPassword: c,
      agreed: a,
    )));
  }

  void _onAuthStatusChanged(AuthStatusChanged event, Emitter<AuthState> emit) {
    if (event.isLoggedIn) {
      emit(_carry((o, c, a) => Authenticated(
        "success",
        obscurePassword: o,
        obscureConfirmPassword: c,
        agreed: a,
      )));
    } else {
      emit(_carry((o, c, a) => Unauthenticated(
        obscurePassword: o,
        obscureConfirmPassword: c,
        agreed: a,
      )));
    }
  }

  Future<void> _onSignInWithGoogle(SignInWithGoogle event, Emitter<AuthState> emit) async {
    emit(_carry((o, c, a) => AuthLoading(
      obscurePassword: o,
      obscureConfirmPassword: c,
      agreed: a,
    )));
    try {
      bool isNewUser = await authRepo.signUpWithGoogle();
      if (isNewUser) {
        emit(_carry((o, c, a) => NewUserAuthenticated(
          "Welcome new user",
          obscurePassword: o,
          obscureConfirmPassword: c,
          agreed: a,
        )));
      } else {
        await PersonalizationRepository().fetchPreferences();
        emit(_carry((o, c, a) => Authenticated(
          "Welcome back",
          obscurePassword: o,
          obscureConfirmPassword: c,
          agreed: a,
        )));
      }
    } catch (e) {
      emit(_carry((o, c, a) => AuthError(
        e.toString(),
        obscurePassword: o,
        obscureConfirmPassword: c,
        agreed: a,
      )));
    }
  }

  Future<void> _onSignUpWithGoogle(SignUpWithGoogle event, Emitter<AuthState> emit) async {
    emit(_carry((o, c, a) => AuthLoading(
      obscurePassword: o,
      obscureConfirmPassword: c,
      agreed: a,
    )));
    try {
      var newUser = await authRepo.signUpWithGoogle();
      if (!newUser) {
        await PersonalizationRepository().fetchPreferences();
        emit(_carry((o, c, a) => UserAlreadyPresent(
          "User already exists with this email",
          obscurePassword: o,
          obscureConfirmPassword: c,
          agreed: a,
        )));
        return;
      }
      emit(_carry((o, c, a) => Authenticated(
        "Google Sign-in successful",
        obscurePassword: o,
        obscureConfirmPassword: c,
        agreed: a,
      )));
    } catch (e) {
      emit(_carry((o, c, a) => AuthError(
        e.toString(),
        obscurePassword: o,
        obscureConfirmPassword: c,
        agreed: a,
      )));
    }
  }

  void _onTogglePasswordVisibility(TogglePasswordVisibility event, Emitter<AuthState> emit) {
    emit(_carry((o, c, a) => AuthInitial(
      obscurePassword: !o,
      obscureConfirmPassword: c,
      agreed: a,
    )));
  }

  void _onToggleConfirmPasswordVisibility(ToggleConfirmPasswordVisibility event, Emitter<AuthState> emit) {
    emit(_carry((o, c, a) => AuthInitial(
      obscurePassword: o,
      obscureConfirmPassword: !c,
      agreed: a,
    )));
  }

  void _onToggleAgreement(ToggleAgreement event, Emitter<AuthState> emit) {
    emit(_carry((o, c, a) => AuthInitial(
      obscurePassword: o,
      obscureConfirmPassword: c,
      agreed: !a,
    )));
  }
}
