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

final class AuthFailureState extends AuthState {
  final String message;

  AuthFailureState({required this.message});
}

//

final class NavigateToDashboardActionState extends AuthActionState {}

final class NavigateToForgotPasswordAction extends AuthActionState {}
