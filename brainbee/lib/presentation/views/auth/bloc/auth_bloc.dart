import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:brainbee/presentation/views/auth/models/user_model.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  UserModel? _user;
  UserModel? get user => _user;

  AuthBloc() : super(AuthInitial()) {
    on<AuthLoginRequested>(authLoginRequested);
    on<AuthSignupRequested>(authSignupRequested);
    on<AuthGoogleLoginRequested>(authGoogleLoginRequested);
    on<AuthGoogleSignupRequested>(authGoogleSignupRequested);
    on<AuthForgotPasswordRequested>(authForgotPasswordRequested);
  }

  FutureOr<void> authLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
    try {
      final response = await http
          .post(
            Uri.parse("http://10.0.2.2:5000/api/auth/login"),
            // Uri.parse(
            //   "https://fyp-backend-express.onrender.com/api/auth/login",
            // ),

            // Uri.parse("http://192.168.2.101:5000/api/auth/login"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "email": event.email,
              "password": event.password,
              "role": event.role,
            }),
          )
          .timeout(const Duration(seconds: 5));
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        emit(NavigateToDashboardActionState());
        try {
          _user = UserModel.fromJson(data);
        } catch (e) {
          emit(AuthFailureState(message: "Error writing data ${e.toString()}"));
        }
      } else {
        emit(AuthFailureState(message: data['status'] ?? "Signin failed"));
      }
    } on SocketException {
      emit(
        AuthFailureState(
          message: "❌ Server not reachable. Please start the server.",
        ),
      );
    } on TimeoutException {
      emit(AuthFailureState(message: "⏰ Server timeout. Check your internet"));
    } catch (e) {
      emit(AuthFailureState(message: "Login Failed ${e.toString()}"));
    }
  }

  Future<void> authSignupRequested(
    AuthSignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());

    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:5000/api/auth/register"),
        // Uri.parse("https://fyp-backend-express.onrender.com/api/auth/register"),
        // Uri.parse("http://192.168.2.101:5000/api/auth/register"),
        // Uri.parse("http://16.170.203.154:5000/api/auth/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": event.email,
          "fullName": event.fullName,
          "firstName": event.firstName,
          "lastName": event.lastName,
          "password": event.password,
          "role": event.role,
        }),
      );

      Map<String, dynamic> data = jsonDecode(response.body);
      print(data);
      if (response.statusCode == 201) {
        emit(NavigateToDashboardActionState());
        try {
          _user = UserModel.fromJson(data);
        } catch (e) {
          emit(AuthFailureState(message: "error writing data ${e.toString()}"));
        }
      } else {
        emit(AuthFailureState(message: data['status'] ?? "Signup failed"));
      }
    } on SocketException {
      emit(
        AuthFailureState(
          message: "❌ Server not reachable. Please start the server.",
        ),
      );
    } on TimeoutException {
      emit(AuthFailureState(message: "⏰ Server timeout. Check your internet"));
    } catch (e) {
      emit(AuthFailureState(message: "Signup error: ${e.toString()}"));
    }
  }

  FutureOr<void> authGoogleLoginRequested(
    AuthGoogleLoginRequested event,
    Emitter<AuthState> emit,
  ) {}

  FutureOr<void> authGoogleSignupRequested(
    AuthGoogleSignupRequested event,
    Emitter<AuthState> emit,
  ) {}

  FutureOr<void> authForgotPasswordRequested(
    AuthForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) {}
}
