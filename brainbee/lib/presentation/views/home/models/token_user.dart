import 'package:brainbee/presentation/views/auth/models/user_model.dart';

class TokenUserData {
  final String? token;
  final UserModel? user;

  TokenUserData({required this.token, required this.user});
}
