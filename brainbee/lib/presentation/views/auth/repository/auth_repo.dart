import 'dart:convert';
import 'package:brainbee/presentation/views/auth/models/user_model.dart';
import 'package:brainbee/presentation/views/auth/services/auth_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final AuthApiService _apiService;

  AuthRepository({AuthApiService? apiService})
    : _apiService = apiService ?? AuthApiService();

  // Local storage methods
  Future<void> saveTokenAndUser(String token, UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);

      final userJson = jsonEncode(user.toJson());
      await prefs.setString('user_data', userJson);
    } catch (e) {
      throw Exception('Failed to save authentication data: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getTokenAndUser() async {
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
          // Clear corrupted data
          await removeTokenAndUser();
        }
      }

      return {'token': token, 'user': user};
    } catch (e) {
      return {'token': null, 'user': null};
    }
  }

  Future<void> removeTokenAndUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
    } catch (e) {
      // Silently handle errors in cleanup
    }
  }

  Future<bool> isLoggedIn() async {
    final tokenAndUser = await getTokenAndUser();
    return tokenAndUser['token'] != null && tokenAndUser['user'] != null;
  }

  // Authentication methods
  Future<AuthResult> login({
    required String email,
    required String password,
    required String role,
  }) async {
    final result = await _apiService.login(
      email: email,
      password: password,
      role: role,
    );

    if (result['success']) {
      try {
        final user = UserModel.fromJson(result['data']);
        final token = result['data']['data']['accessToken'];

        await saveTokenAndUser(token, user);

        return AuthResult(success: true, user: user, token: token);
      } catch (e) {
        return AuthResult(
          success: false,
          message: "Error processing login data: ${e.toString()}",
        );
      }
    } else {
      return AuthResult(
        success: false,
        message: result['message'],
        error: result['error'],
      );
    }
  }

  Future<AuthResult> signup({
    required String email,
    required String fullName,
    required String firstName,
    required String lastName,
    required String password,
    required String role,
  }) async {
    final result = await _apiService.signup(
      email: email,
      fullName: fullName,
      firstName: firstName,
      lastName: lastName,
      password: password,
      role: role,
    );

    if (result['success']) {
      try {
        final user = UserModel.fromJson(result['data']);
        final token = result['data']['data']['accessToken'];

        await saveTokenAndUser(token, user);

        return AuthResult(success: true, user: user, token: token);
      } catch (e) {
        return AuthResult(
          success: false,
          message: "Error processing signup data: ${e.toString()}",
        );
      }
    } else {
      return AuthResult(
        success: false,
        message: result['message'],
        error: result['error'],
      );
    }
  }

  Future<AuthResult> checkAuthStatus() async {
    final tokenAndUser = await getTokenAndUser();
    final token = tokenAndUser['token'] as String?;
    final user = tokenAndUser['user'] as UserModel?;

    if (token != null && user != null) {
      final result = await _apiService.verifyToken(token);

      if (result['success']) {
        return AuthResult(success: true, user: user, token: token);
      } else {
        await removeTokenAndUser();
        return AuthResult(success: false, message: "Token invalid");
      }
    } else {
      return AuthResult(success: false, message: "No stored credentials");
    }
  }

  Future<AuthResult> googleLogin({
    required String idToken,
    required String role,
  }) async {
    final result = await _apiService.googleLogin(idToken: idToken, role: role);

    if (result['success']) {
      try {
        final user = UserModel.fromJson(result['data']);
        final token = result['data']['data']['accessToken'];

        await saveTokenAndUser(token, user);

        return AuthResult(success: true, user: user, token: token);
      } catch (e) {
        return AuthResult(
          success: false,
          message: "Error processing Google login data: ${e.toString()}",
        );
      }
    } else {
      return AuthResult(
        success: false,
        message: result['message'],
        error: result['error'],
      );
    }
  }

  Future<AuthResult> forgotPassword(String email) async {
    final result = await _apiService.forgotPassword(email);

    return AuthResult(
      success: result['success'],
      message: result['message'],
      error: result['error'],
    );
  }

  Future<void> logout() async {
    await removeTokenAndUser();
  }
}

// Result class to encapsulate authentication results
class AuthResult {
  final bool success;
  final UserModel? user;
  final String? token;
  final String? message;
  final String? error;

  AuthResult({
    required this.success,
    this.user,
    this.token,
    this.message,
    this.error,
  });

  @override
  String toString() {
    return 'AuthResult(success: $success, user: $user, token: $token, message: $message, error: $error)';
  }
}
