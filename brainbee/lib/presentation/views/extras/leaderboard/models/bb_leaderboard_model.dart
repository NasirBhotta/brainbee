// lib/presentation/views/extras/leaderboard/model/bb_leaderboard_model.dart

class LeaderboardResponse {
  final String status;
  final LeaderboardData data;

  LeaderboardResponse({required this.status, required this.data});

  factory LeaderboardResponse.fromJson(Map<String, dynamic> json) {
    return LeaderboardResponse(
      status: json['status'] ?? '',
      data: LeaderboardData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'data': data.toJson()};
  }
}

class LeaderboardData {
  final String type;
  final int total;
  final List<LeaderboardEntry> leaderboard;

  LeaderboardData({
    required this.type,
    required this.total,
    required this.leaderboard,
  });

  factory LeaderboardData.fromJson(Map<String, dynamic> json) {
    return LeaderboardData(
      type: json['type'] ?? '',
      total: json['total'] ?? 0,
      leaderboard:
          (json['leaderboard'] as List<dynamic>?)
              ?.map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'total': total,
      'leaderboard': leaderboard.map((e) => e.toJson()).toList(),
    };
  }
}

class LeaderboardEntry {
  final int rank;
  final String studentId;
  final String name;
  final String? profilePic;
  final int? grade;
  final int score;
  final int? activities;
  final int quizzesCompleted;
  final String type;

  LeaderboardEntry({
    required this.rank,
    required this.studentId,
    required this.name,
    this.profilePic,
    this.grade,
    required this.score,
    this.activities,
    required this.quizzesCompleted,
    required this.type,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] ?? 0,
      studentId: json['studentId'] ?? '',
      name: json['name'] ?? '',
      profilePic: json['profilePic'],
      grade: json['grade'],
      score: json['score'] ?? 0,
      activities: json['activities'],
      quizzesCompleted: json['quizzesCompleted'] ?? 0,
      type: json['type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'studentId': studentId,
      'name': name,
      'profilePic': profilePic,
      'grade': grade,
      'score': score,
      'activities': activities,
      'quizzesCompleted': quizzesCompleted,
      'type': type,
    };
  }

  // Helper method for backward compatibility with existing code
  int get position => rank;
  String get classGrade => grade != null ? 'Grade $grade' : '';
  String get id => studentId;
}
