class LeaderboardStats {
  final int overallScore;
  final int? ranking;
  final int weeklyScore;
  final int monthlyScore;
  final int yearlyScore;

  LeaderboardStats({
    required this.overallScore,
    this.ranking,
    required this.weeklyScore,
    required this.monthlyScore,
    required this.yearlyScore,
  });

  factory LeaderboardStats.fromJson(Map<String, dynamic> json) {
    return LeaderboardStats(
      overallScore: json['overallScore'] ?? 0,
      ranking: json['ranking'],
      weeklyScore: json['weeklyScore'] ?? 0,
      monthlyScore: json['monthlyScore'] ?? 0,
      yearlyScore: json['yearlyScore'] ?? 0,
    );
  }
}
