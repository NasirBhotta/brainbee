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

  // Added toJson method to convert UserModel back to JSON
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': {
        'user': {
          'id': id,
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
        },
        'accessToken': token,
      },
    };
  }

  // Optional: Add toString method for debugging
  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, firstName: $firstName, lastName: $lastName, status: $status)';
  }

  // Optional: Add equality comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.id == id &&
        other.email == email &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.token == token &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        token.hashCode ^
        status.hashCode;
  }

  // Convenience getters
  String get fullName => '$firstName $lastName';

  // Check if user data is valid
  bool get isValid => id.isNotEmpty && email.isNotEmpty && token.isNotEmpty;
}
