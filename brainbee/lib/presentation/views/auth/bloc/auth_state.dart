part of 'auth_bloc.dart';

@immutable
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserModel user;
  final String token;

  const AuthAuthenticated({required this.user, required this.token});

  @override
  List<Object?> get props => [user, token];
}

class AuthFailureState extends AuthState {
  final String message;

  const AuthFailureState({required this.message});

  @override
  List<Object?> get props => [message];
}

class AuthLoggedOut extends AuthState {}

class AuthPasswordResetSentState extends AuthState {
  final String message;

  const AuthPasswordResetSentState({required this.message});

  @override
  List<Object?> get props => [message];
}

// Action States (for navigation)
abstract class AuthActionState extends AuthState {}

class NavigateToDashboardActionState extends AuthActionState {}

class NavigateToLoginActionState extends AuthActionState {}

class NavigateToSignupActionState extends AuthActionState {}
