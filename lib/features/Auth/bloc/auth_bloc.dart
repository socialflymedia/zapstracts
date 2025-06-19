import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zapstract/Data/repositories/auth/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepo;

  AuthBloc(this.authRepo) : super(AuthPasswordVisibilityState(obscurePassword: true, obscureConfirmPassword: true, agreed: false)) {
    on<SignUpRequested>(_onSignUp);
    on<LoginRequested>(_onLogin);
    on<LogoutRequested>(_onLogout);
    on<AuthStatusChanged>(_onAuthStatusChanged);
    on<SignInWithGoogle>(_onSignInWithGoogle);

    on<TogglePasswordVisibility>(_onTogglePasswordVisibility);
    on<ToggleConfirmPasswordVisibility>(_onToggleConfirmPasswordVisibility);
    on<ToggleAgreement>(_onToggleAgreement);
  }

  Future<void> _onSignUp(SignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepo.signUp(event.email, event.password, event.name, event.phone);
      emit(Authenticated("success"));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepo.login(event.email, event.password);
      emit(Authenticated("success"));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    await authRepo.logout();

    emit(Unauthenticated());

  }

  void _onAuthStatusChanged(AuthStatusChanged event, Emitter<AuthState> emit) {
    emit(event.isLoggedIn ? Authenticated("success") : Unauthenticated());
  }

  void _onTogglePasswordVisibility(TogglePasswordVisibility event, Emitter<AuthState> emit) {
    if (state is AuthPasswordVisibilityState) {
      final currentState = state as AuthPasswordVisibilityState;
      emit(AuthPasswordVisibilityState(
        obscurePassword: !currentState.obscurePassword,
        obscureConfirmPassword: currentState.obscureConfirmPassword,
        agreed: currentState.agreed,
      ));
    }
  }
  Future<void> _onSignInWithGoogle(SignInWithGoogle event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepo.signUpWithGoogle();
      emit(Authenticated("Google Sign-in successful"));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void _onToggleConfirmPasswordVisibility(ToggleConfirmPasswordVisibility event, Emitter<AuthState> emit) {
    if (state is AuthPasswordVisibilityState) {
      final currentState = state as AuthPasswordVisibilityState;
      emit(AuthPasswordVisibilityState(
        obscurePassword: currentState.obscurePassword,
        obscureConfirmPassword: !currentState.obscureConfirmPassword,
        agreed: currentState.agreed,
      ));
    }
  }

  void _onToggleAgreement(ToggleAgreement event, Emitter<AuthState> emit) {
    if (state is AuthPasswordVisibilityState) {
      final currentState = state as AuthPasswordVisibilityState;
      emit(AuthPasswordVisibilityState(
        obscurePassword: currentState.obscurePassword,
        obscureConfirmPassword: currentState.obscureConfirmPassword,
        agreed: !currentState.agreed,
      ));
    }
  }
}
