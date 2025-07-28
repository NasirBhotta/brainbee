import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'wallet_model.g.dart';

@JsonSerializable()
class Wallet extends Equatable {
  final String studentId;
  final int balance;
  final DateTime lastUpdated;

  const Wallet({
    required this.studentId,
    required this.balance,
    required this.lastUpdated,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) => _$WalletFromJson(json);
  Map<String, dynamic> toJson() => _$WalletToJson(this);

  factory Wallet.empty(String studentId) {
    return Wallet(
      studentId: studentId,
      balance: 0,
      lastUpdated: DateTime.now(),
    );
  }

  Wallet copyWith({
    String? studentId,
    int? balance,
    DateTime? lastUpdated,
  }) {
    return Wallet(
      studentId: studentId ?? this.studentId,
      balance: balance ?? this.balance,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Wallet addCoins(int coins) {
    return copyWith(
      balance: balance + coins,
      lastUpdated: DateTime.now(),
    );
  }

  Wallet spendCoins(int coins) {
    if (coins > balance) {
      throw Exception('Insufficient balance. Cannot spend $coins coins when balance is $balance');
    }
    return copyWith(
      balance: balance - coins,
      lastUpdated: DateTime.now(),
    );
  }

  bool canSpend(int coins) => balance >= coins;

  @override
  List<Object?> get props => [studentId, balance, lastUpdated];
}