class UserModel {
  final String status;
  final String id;
  final String email;
  final String name;
  final String token;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.token,
    required this.status,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      status: json['status'],
      id: json['data']['user']['id'],
      email: json['data']['user']['email'],
      name: json['data']['user']['fullName'],
      token: json['data']['accessToken'],
    );
  }
}
