part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  final String role;

  AuthLoginRequested({
    required this.email,
    required this.password,
    this.role = 'student',
  });
  @override
  List<Object?> get props => [email, password];
}

class AuthGoogleLoginRequested extends AuthEvent {}

class AuthForgotPasswordRequested extends AuthEvent {
  final String email;
  final String role;

  AuthForgotPasswordRequested({required this.email, this.role = 'student'});

  @override
  List<Object?> get props => [email];
}

class AuthSignupRequested extends AuthEvent {
  final String fullName;
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String role;

  AuthSignupRequested({
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.email,
    required this.password,
    this.role = 'student',
  });

  @override
  List<Object?> get props => [fullName, email, password];
}

class AuthGoogleSignupRequested extends AuthEvent {}
