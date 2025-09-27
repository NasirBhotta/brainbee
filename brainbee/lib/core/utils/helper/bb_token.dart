import 'dart:convert';

import 'package:brainbee/core/models/token_user.dart';
import 'package:brainbee/presentation/views/auth/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<TokenUserData> getTokenAndUser() async {
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
        await removeTokenAndUser();
      }
    }

    return TokenUserData(token: token, user: user);
  } catch (e) {
    return TokenUserData(token: null, user: null);
  }
}

Future<void> removeTokenAndUser() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  } catch (e) {
    throw Exception("Error removing token and user: $e");
  }
}
