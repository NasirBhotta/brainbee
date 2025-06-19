class UserModel {
  final String status;
  final String id;
  final String email;
  final String firstName;
  final String lastName;

  final String token;

  UserModel({
    required this.firstName,
    required this.lastName,
    required this.id,
    required this.email,

    required this.token,
    required this.status,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      firstName: json['data']['user']['firstName'],
      lastName: json['data']['user']['lastName'],
      id: json['data']['user']['id'],
      email: json['data']['user']['email'],

      token: json['data']['accessToken'],
      status: json['status'],
    );
  }
}
