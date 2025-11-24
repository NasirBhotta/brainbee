import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:brainbee/presentation/views/auth/models/user_model.dart';
import 'package:brainbee/presentation/views/auth/repository/auth_repo.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  UserModel? _user;
  UserModel? get user => _user;

  AuthBloc({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository(),
      super(AuthInitial()) {
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthSignupRequested>(_onAuthSignupRequested);
    on<AuthGoogleLoginRequested>(_onAuthGoogleLoginRequested);
    on<AuthGoogleSignupRequested>(_onAuthGoogleSignupRequested);
    on<AuthForgotPasswordRequested>(_onAuthForgotPasswordRequested);
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());

    try {
      final result = await _authRepository.login(
        email: event.email,
        password: event.password,
        role: event.role,
      );

      if (result.success && result.user != null && result.token != null) {
        _user = result.user;
        emit(NavigateToDashboardActionState());

        emit(AuthAuthenticated(user: result.user!, token: result.token!));
      } else {
        emit(AuthFailureState(message: result.message ?? "Login failed"));
      }
    } catch (e) {
      emit(AuthFailureState(message: "Login failed: ${e.toString()}"));
    }
  }

  Future<void> _onAuthSignupRequested(
    AuthSignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());

    try {
      final result = await _authRepository.signup(
        email: event.email,
        firstName: event.firstName,
        lastName: event.lastName,
        password: event.password,
        role: event.role,
      );

      if (result.success && result.user != null && result.token != null) {
        _user = result.user;
        emit(NavigateToDashboardActionState());
        emit(AuthAuthenticated(user: result.user!, token: result.token!));
      } else {
        emit(AuthFailureState(message: result.message ?? "Signup failed"));
      }
    } catch (e) {
      emit(AuthFailureState(message: "Signup failed: ${e.toString()}"));
    }
  }

  Future<void> _onAuthGoogleLoginRequested(
    AuthGoogleLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    // emit(AuthLoadingState());

    // try {
    //   final result = await _authRepository.googleLogin(
    //     idToken: event.idToken,
    //     role: event.role,
    //   );

    //   if (result.success && result.user != null && result.token != null) {
    //     _user = result.user;
    //     emit(NavigateToDashboardActionState());
    //     emit(AuthAuthenticated(user: result.user!, token: result.token!));
    //   } else {
    //     emit(
    //       AuthFailureState(message: result.message ?? "Google login failed"),
    //     );
    //   }
    // } catch (e) {
    //   emit(AuthFailureState(message: "Google login failed: ${e.toString()}"));
    // }
  }

  Future<void> _onAuthGoogleSignupRequested(
    AuthGoogleSignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    // For now, we'll treat Google signup the same as Google login
    // You can modify this based on your backend implementation
    add(AuthGoogleLoginRequested());
  }

  Future<void> _onAuthForgotPasswordRequested(
    AuthForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());

    try {
      final result = await _authRepository.forgotPassword(event.email);

      if (result.success) {
        emit(
          AuthPasswordResetSentState(
            message: result.message ?? "Password reset link sent to your email",
          ),
        );
      } else {
        emit(
          AuthFailureState(
            message: result.message ?? "Failed to send password reset email",
          ),
        );
      }
    } catch (e) {
      emit(
        AuthFailureState(
          message: "Failed to send password reset email: ${e.toString()}",
        ),
      );
    }
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());

    try {
      final result = await _authRepository.checkAuthStatus();

      if (result.success && result.user != null && result.token != null) {
        _user = result.user;
        emit(AuthAuthenticated(user: result.user!, token: result.token!));
      } else {
        _user = null;
        emit(AuthLoggedOut());
      }
    } catch (e) {
      _user = null;
      emit(AuthLoggedOut());
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepository.logout();
      _user = null;
      emit(AuthLoggedOut());
    } catch (e) {
      // Still emit logged out even if cleanup fails
      _user = null;
      emit(AuthLoggedOut());
    }
  }
}
