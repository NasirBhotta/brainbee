import 'dart:io';

import 'package:brainbee/presentation/views/auth/models/user_model.dart';
import 'package:brainbee/presentation/views/extras/achievements/models/bb_achievement_model.dart';
import 'package:brainbee/presentation/views/extras/leaderboard/models/bb_leaderboard_class.dart';

class StudentModel extends UserModel {
  final int grade;
  final List<String> subjects;
  final String? parentId;
  final int coins;
  final int streakScore;
  final Goal goal;
  final DateTime? lastStreakDate;
  final int dailyLives;
  final DateTime? livesResetTime;
  final List<String> friends;
  final Achievements achievements;
  final LeaderboardStats leaderboardStats;
  final BattleStatics battleStatics;
  final List<String> enrolledClasses;
  final int score;
  final Map<String, String> chapterLevels;
  final Map<String, TopicPerformance>? topicPerformance;
  final String profileImage;

  StudentModel({
    required this.profileImage,
    required super.id,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.token,
    required super.status,
    required this.goal,
    required this.grade,
    required this.subjects,
    this.parentId,
    required this.coins,
    required this.streakScore,
    this.lastStreakDate,
    required this.dailyLives,
    this.livesResetTime,
    required this.friends,
    required this.achievements,
    required this.leaderboardStats,
    required this.battleStatics,
    required this.enrolledClasses,
    required this.score,
    required this.chapterLevels,
    this.topicPerformance,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    print("The user in the model is $user");
    return StudentModel(
      profileImage: user["profileImage"],
      id: user['id'] ?? user['_id'] ?? '',
      email: user['email'] ?? '',
      firstName: user['firstName'] ?? '',
      lastName: user['lastName'] ?? '',
      token: json['accessToken'] ?? '',
      status: json['status'] ?? '',
      goal: Goal.fromJson(user['goal'] ?? {}),
      grade: user['grade'] ?? 0,
      subjects: List<String>.from(user['subjects'] ?? []),
      parentId: user['parentId'],
      coins: user['coins'] ?? 0,
      streakScore: user['streakScore'] ?? 0,
      lastStreakDate:
          user['lastStreakDate'] != null
              ? DateTime.parse(user['lastStreakDate'])
              : null,
      dailyLives: user['dailyLives'] ?? 5,
      livesResetTime:
          user['livesResetTime'] != null
              ? DateTime.parse(user['livesResetTime'])
              : null,
      friends: List<String>.from(user['friends'] ?? []),
      achievements: Achievements.fromJson(user['achievements'] ?? {}),
      leaderboardStats: LeaderboardStats.fromJson(
        user['leaderboardStats'] ?? {},
      ),
      battleStatics: BattleStatics.fromJson(user['battleStats'] ?? {}),
      enrolledClasses: List<String>.from(user['enrolledClasses'] ?? []),
      score: user['score'] ?? 0,

      chapterLevels: Map<String, String>.from(user['chapter_levels'] ?? {}),
      // topicPerformance: (user['topic_performance'] ?? {}).map<dynamic, dynamic>(
      //   (key, value) => MapEntry(key, TopicPerformance.fromJson(value)),
      // ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'accessToken': token,
      'user': {
        'profileImage': profileImage,
        'id': id,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'grade': grade,
        'subjects': subjects,
        'parentId': parentId,
        'coins': coins,
        'streakScore': streakScore,
        'lastStreakDate': lastStreakDate?.toIso8601String(),
        'dailyLives': dailyLives,
        'livesResetTime': livesResetTime?.toIso8601String(),
        'friends': friends,
        'achievements': achievements.toJson(),
        'leaderboardStats': leaderboardStats.toJson(),
        'battleStatics': battleStatics.toJson(),
        'enrolledClasses': enrolledClasses,
        'chapter_levels': chapterLevels,
        'score': score,
        'topic_performance': topicPerformance?.map(
          (key, value) => MapEntry(key, value.toJson()),
        ),
        'goal': goal.toJson(),
      },
    };
  }
}

class Goal {
  final String title;
  final String description;
  final DateTime dueDate;
  final List<DateTime> reminder;
  final int value;
  final bool status;
  final int noOfAttempts;

  // Optional (parent-assigned or progress-based)
  final String? parentId;
  final int? targetScore;
  final int? targetCompletion;
  final int? rewardCoins;
  final int? progress; // percentage

  Goal({
    required this.title,
    required this.description,
    required this.dueDate,
    required this.reminder,
    required this.value,
    required this.status,
    required this.noOfAttempts,
    this.parentId,
    this.targetScore,
    this.targetCompletion,
    this.rewardCoins,
    this.progress,
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      dueDate: DateTime.parse(json['dueDate'] ?? DateTime.now().toString()),
      reminder: List<DateTime>.from(
        json['reminder']?.map((x) => DateTime.parse(x)) ?? [],
      ),
      value: json['value'] ?? 0,
      status: json['status'] ?? false,
      noOfAttempts: json['noOfAttempts'] ?? 0,
      parentId: json['parentId'],
      targetScore: json['targetScore'],
      targetCompletion: json['targetCompletion'],
      rewardCoins: json['rewardCoins'],
      progress: json['progress'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'reminder': reminder.map((x) => x.toIso8601String()).toList(),
      'value': value,
      'status': status,
      'noOfAttempts': noOfAttempts,
      'parentId': parentId,
      'targetScore': targetScore,
      'targetCompletion': targetCompletion,
      'rewardCoins': rewardCoins,
      'progress': progress,
    };
  }
}

class BattleStatics {
  final int wins;
  final int losses;
  final int totalBattles;

  BattleStatics({
    required this.wins,
    required this.losses,
    required this.totalBattles,
  });

  factory BattleStatics.fromJson(Map<String, dynamic> json) {
    return BattleStatics(
      wins: json['wins'] ?? 0,
      losses: json['losses'] ?? 0,
      totalBattles: json['totalBattles'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {'wins': wins, 'losses': losses, 'totalBattles': totalBattles};
  }
}

class TopicPerformance {
  final int attempts;
  final int correct;

  TopicPerformance({required this.attempts, required this.correct});

  factory TopicPerformance.fromJson(Map<String, dynamic> json) {
    return TopicPerformance(
      attempts: json['attempts'] ?? 0,
      correct: json['correct'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {'attempts': attempts, 'correct': correct};
  }
}
