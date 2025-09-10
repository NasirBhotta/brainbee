import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:brainbee/presentation/views/auth/models/user_model.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    on<AuthCheckRequested>(authCheckRequested);
    on<AuthLogoutRequested>(
      authLogoutRequested,
    ); // Added missing logout handler
  }

  Future<void> _saveTokenAndUser(String token, UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);

      // Convert UserModel to JSON string properly
      final userJson = jsonEncode(user.toJson());
      await prefs.setString('user_data', userJson);

      print("Token saved: $token");
      print("User data saved: ${user.toJson()}");
    } catch (e) {
      print("Error saving user data: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _getTokenAndUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userData = prefs.getString('user_data');

      UserModel? user;
      if (userData != null && userData.isNotEmpty) {
        try {
          final userMap = jsonDecode(userData);
          user = UserModel.fromJson(userMap);
        } catch (e) {
          print("Error parsing user data: $e");
          // Clear corrupted data
          await _removeTokenAndUser();
        }
      }

      print("Retrieved token: ${token != null ? 'Present' : 'Null'}");
      print("Retrieved user: ${user?.toJson() ?? 'Null'}");

      return {'token': token, 'user': user};
    } catch (e) {
      print("Error getting token and user: $e");
      return {'token': null, 'user': null};
    }
  }

  Future<void> _removeTokenAndUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
      print("Token and user data removed");
    } catch (e) {
      print("Error removing token and user: $e");
    }
  }

  FutureOr<void> authLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
    try {
      print("Comming here");
      final response = await http
          .post(
            Uri.parse(
              "https://fyp-backend-express.onrender.com/api/auth/login",
            ),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "email": event.email,
              "password": event.password,
              "role": event.role,
            }),
          )
          .timeout(const Duration(seconds: 15)); // Increased timeout

      final data = jsonDecode(response.body);
      print("data is: $data");
      if (response.statusCode == 200) {
        try {
          _user = UserModel.fromJson(data);
          final token = data['data']['accessToken'];
          await _saveTokenAndUser(token, _user!);

          // Emit NavigateToDashboardActionState first, then AuthAuthenticated
          emit(NavigateToDashboardActionState());
          emit(AuthAuthenticated(user: _user!, token: token));
        } catch (e) {
          print("Error processing login response: $e");
          emit(
            AuthFailureState(
              message: "Error processing login data: ${e.toString()}",
            ),
          );
        }
      } else {
        emit(
          AuthFailureState(
            message: data['message'] ?? data['status'] ?? "Sign in failed",
          ),
        );
      }
    } on SocketException {
      emit(
        AuthFailureState(
          message:
              "❌ Server not reachable. Please check your internet connection.",
        ),
      );
    } on TimeoutException {
      emit(AuthFailureState(message: "⏰ Request timeout. Please try again."));
    } catch (e) {
      print("Login error: $e");
      emit(AuthFailureState(message: "Login failed: ${e.toString()}"));
    }
  }

  Future<void> authSignupRequested(
    AuthSignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
    // https://fyp-backend-express.onrender.com
    try {
      final response = await http
          .post(
            Uri.parse("http://localhost:5000/api/auth/register"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "email": event.email,
              "fullName": event.fullName,
              "firstName": event.firstName,
              "lastName": event.lastName,
              "password": event.password,
              "role": event.role,
            }),
          )
          .timeout(const Duration(seconds: 15));

      Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        try {
          _user = UserModel.fromJson(data);
          final token = data['data']['accessToken'];
          await _saveTokenAndUser(token, _user!);

          emit(NavigateToDashboardActionState());
          emit(AuthAuthenticated(user: _user!, token: token));
        } catch (e) {
          print("Error processing signup response: $e");
          emit(
            AuthFailureState(
              message: "Error processing signup data: ${e.toString()}",
            ),
          );
        }
      } else {
        emit(
          AuthFailureState(
            message: data['message'] ?? data['status'] ?? "Signup failed",
          ),
        );
      }
    } on SocketException {
      emit(
        AuthFailureState(
          message:
              "❌ Server not reachable. Please check your internet connection.",
        ),
      );
    } on TimeoutException {
      emit(AuthFailureState(message: "⏰ Request timeout. Please try again."));
    } catch (e) {
      print("Signup error: $e");
      emit(AuthFailureState(message: "Signup failed: ${e.toString()}"));
    }
  }

  FutureOr<void> authGoogleLoginRequested(
    AuthGoogleLoginRequested event,
    Emitter<AuthState> emit,
  ) {
    // TODO: Implement Google login
  }

  FutureOr<void> authGoogleSignupRequested(
    AuthGoogleSignupRequested event,
    Emitter<AuthState> emit,
  ) {
    // TODO: Implement Google signup
  }

  FutureOr<void> authForgotPasswordRequested(
    AuthForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) {
    // TODO: Implement forgot password
  }

  FutureOr<void> authCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());

    try {
      final tokenAndUser = await _getTokenAndUser();
      final token = tokenAndUser['token'] as String?;
      final user = tokenAndUser['user'] as UserModel?;

      if (token != null && user != null) {
        try {
          final response = await http
              .get(
                Uri.parse(
                  "https://fyp-backend-express.onrender.com/api/auth/protected",
                ),
                headers: {"Authorization": "Bearer $token"},
              )
              .timeout(const Duration(seconds: 10));

          if (response.statusCode == 200) {
            _user = user;
            print("Authentication verified - User: ${user.toJson()}");
            emit(AuthAuthenticated(user: user, token: token));
          } else {
            print(
              "Token verification failed with status: ${response.statusCode}",
            );
            await _removeTokenAndUser();
            emit(AuthLoggedOut());
          }
        } catch (e) {
          print("Error verifying token: $e");
          await _removeTokenAndUser();
          emit(AuthLoggedOut());
        }
      } else {
        print("No valid token or user found");
        emit(AuthLoggedOut());
      }
    } catch (e) {
      print("Auth check error: $e");
      emit(AuthLoggedOut());
    }
  }

  FutureOr<void> authLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _removeTokenAndUser();
      _user = null;
      emit(AuthLoggedOut());
    } catch (e) {
      print("Logout error: $e");
      emit(AuthLoggedOut()); // Still emit logged out even if cleanup fails
    }
  }
}
