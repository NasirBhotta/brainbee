import 'package:flutter/material.dart';

class BattleStats {
  final String username;
  final String initial;
  final Color avatarColor;
  final String ranking;
  final int wins;
  final int totalBattles;
  final int coinsCollected;

  BattleStats({
    required this.username,
    required this.initial,
    required this.avatarColor,
    required this.ranking,
    required this.wins,
    required this.totalBattles,
    required this.coinsCollected,
  });

  factory BattleStats.fromJson(Map<String, dynamic> json) {
    return BattleStats(
      username: json['username'] ?? '@Username',
      initial: json['initial'] ?? 'N',
      avatarColor: _getColorFromString(json['avatarColor']),
      ranking: json['ranking']?.toString() ?? '0',
      wins: json['wins'] ?? 0,
      totalBattles: json['totalBattles'] ?? 0,
      coinsCollected: json['coinsCollected'] ?? 0,
    );
  }

  static Color _getColorFromString(String? colorStr) {
    if (colorStr == null) return Colors.green[700]!;
    // Parse color from string or use default
    switch (colorStr.toLowerCase()) {
      case 'red':
        return Colors.red[700]!;
      case 'blue':
        return Colors.blue[700]!;
      case 'green':
        return Colors.green[700]!;
      case 'orange':
        return Colors.orange[700]!;
      case 'purple':
        return Colors.purple[700]!;
      default:
        return Colors.green[700]!;
    }
  }
}

class BattleHistoryItem {
  final String id;
  final String opponentUsername;
  final String opponentInitial;
  final String result; // 'win' or 'loss'
  final String date;
  final int yourScore;
  final int opponentScore;

  BattleHistoryItem({
    required this.id,
    required this.opponentUsername,
    required this.opponentInitial,
    required this.result,
    required this.date,
    required this.yourScore,
    required this.opponentScore,
  });

  factory BattleHistoryItem.fromJson(Map<String, dynamic> json) {
    return BattleHistoryItem(
      id: json['id'] ?? '',
      opponentUsername: json['opponentUsername'] ?? '@Username',
      opponentInitial: json['opponentInitial'] ?? 'U',
      result: json['result'] ?? 'loss',
      date: json['date'] ?? 'Today',
      yourScore: json['yourScore'] ?? 0,
      opponentScore: json['opponentScore'] ?? 0,
    );
  }
}
