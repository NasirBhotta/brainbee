part of 'auth_bloc.dart';

@immutable
sealed class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

abstract class AuthActionState extends AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoadingState extends AuthState {}

final class AuthSuccessState extends AuthState {}

final class AuthAuthenticated extends AuthState {
  final UserModel user;
  final String token;

  AuthAuthenticated({required this.user, required this.token});

  @override
  List<Object?> get props => [user, token];
}

final class AuthFailureState extends AuthState {
  final String message;

  AuthFailureState({required this.message});
}

final class AuthLoggedOut extends AuthState {}
//

final class NavigateToDashboardActionState extends AuthActionState {}

final class NavigateToForgotPasswordAction extends AuthActionState {}
