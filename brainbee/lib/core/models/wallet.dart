import 'package:equatable/equatable.dart';

class Wallet extends Equatable {
  final String userId;
  final int balance;
  final DateTime lastUpdated;

  const Wallet({
    required this.userId,
    required this.balance,
    required this.lastUpdated,
  });

  Wallet copyWith({String? userId, int? balance, DateTime? lastUpdated}) {
    return Wallet(
      userId: userId ?? this.userId,
      balance: balance ?? this.balance,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'balance': balance,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      userId: json['userId'],
      balance: json['balance'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }

  @override
  List<Object> get props => [userId, balance, lastUpdated];
}
