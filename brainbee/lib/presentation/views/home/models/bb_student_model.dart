// models/bb_student_model.dart
import 'package:brainbee/presentation/views/auth/models/user_model.dart';
import 'package:brainbee/presentation/views/extras/achievements/models/bb_achievement_model.dart';
import 'package:brainbee/presentation/views/extras/leaderboard/models/bb_leaderboard_class.dart';
import 'package:brainbee/presentation/views/settings/model/book_model.dart';

class StudentModel extends UserModel {
  final int grade;
  final List<String> subjects;
  final List<BookModel>
  selectedBooks; // ✅ NEW: Book IDs (preferred over subjects)
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
  final String? profileImage;

  StudentModel({
    this.profileImage,
    required super.id,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.token,
    required super.status,
    required this.goal,
    required this.grade,
    required this.subjects,
    required this.selectedBooks, // ✅ NEW: Optional for backward compatibility
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

    final List<dynamic>? booksJson = user['selectedBooks'] as List<dynamic>?;

    final List<BookModel> selectedBooksList =
        booksJson != null
            ? booksJson.map((bookJson) => BookModel.fromJson(bookJson)).toList()
            : [];

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
      selectedBooks: selectedBooksList, // ✅ NEW: Parse selectedBooks if present
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
        'selectedBooks': selectedBooks, // ✅ NEW: Include in JSON
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

  // ✅ Helper to get profile image URL with fallback
  String getProfileImageUrl() {
    if (profileImage != null && profileImage!.isNotEmpty) {
      return profileImage!;
    }
    return 'https://ui-avatars.com/api/?name=$firstName+$lastName&background=random';
  }

  // ✅ NEW: Helper to check if user has selected books
  bool hasSelectedBooks() {
    return selectedBooks.isNotEmpty;
  }

  // ✅ NEW: Helper to get book count
  int getSelectedBooksCount() {
    return selectedBooks.length ?? 0;
  }

  // ✅ NEW: Helper to check if using legacy subjects
  bool isUsingLegacySubjects() {
    return !hasSelectedBooks() && subjects.isNotEmpty;
  }

  // ✅ NEW: Create a copy with updated fields
  StudentModel copyWith({
    String? profileImage,
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? token,
    String? status,
    Goal? goal,
    int? grade,
    List<String>? subjects,
    List<BookModel>? selectedBooks,
    String? parentId,
    int? coins,
    int? streakScore,
    DateTime? lastStreakDate,
    int? dailyLives,
    DateTime? livesResetTime,
    List<String>? friends,
    Achievements? achievements,
    LeaderboardStats? leaderboardStats,
    BattleStatics? battleStatics,
    List<String>? enrolledClasses,
    int? score,
    Map<String, String>? chapterLevels,
    Map<String, TopicPerformance>? topicPerformance,
  }) {
    return StudentModel(
      profileImage: profileImage ?? this.profileImage,
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      token: token ?? this.token,
      status: status ?? this.status,
      goal: goal ?? this.goal,
      grade: grade ?? this.grade,
      subjects: subjects ?? this.subjects,
      selectedBooks: selectedBooks ?? this.selectedBooks,
      parentId: parentId ?? this.parentId,
      coins: coins ?? this.coins,
      streakScore: streakScore ?? this.streakScore,
      lastStreakDate: lastStreakDate ?? this.lastStreakDate,
      dailyLives: dailyLives ?? this.dailyLives,
      livesResetTime: livesResetTime ?? this.livesResetTime,
      friends: friends ?? this.friends,
      achievements: achievements ?? this.achievements,
      leaderboardStats: leaderboardStats ?? this.leaderboardStats,
      battleStatics: battleStatics ?? this.battleStatics,
      enrolledClasses: enrolledClasses ?? this.enrolledClasses,
      score: score ?? this.score,
      chapterLevels: chapterLevels ?? this.chapterLevels,
      topicPerformance: topicPerformance ?? this.topicPerformance,
    );
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
    // ✅ Handle empty goal data with defaults
    if (json.isEmpty) {
      return Goal(
        title: 'Casual',
        description: '2 Quizzes & Estimate 7 minutes daily',
        dueDate: DateTime.now().add(Duration(days: 7)),
        reminder: [],
        value: 2,
        status: true,
        noOfAttempts: 0,
      );
    }

    return Goal(
      title: json['title'] ?? 'Casual',
      description:
          json['description'] ?? '2 Quizzes & Estimate 7 minutes daily',
      dueDate:
          json['dueDate'] != null
              ? DateTime.parse(json['dueDate'])
              : DateTime.now().add(Duration(days: 7)),
      reminder:
          json['reminder'] != null
              ? List<DateTime>.from(
                json['reminder'].map((x) => DateTime.parse(x)),
              )
              : [],
      value: json['value'] ?? 2,
      status: json['status'] ?? true,
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

  Goal copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    List<DateTime>? reminder,
    int? value,
    bool? status,
    int? noOfAttempts,
    String? parentId,
    int? targetScore,
    int? targetCompletion,
    int? rewardCoins,
    int? progress,
  }) {
    return Goal(
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      reminder: reminder ?? this.reminder,
      value: value ?? this.value,
      status: status ?? this.status,
      noOfAttempts: noOfAttempts ?? this.noOfAttempts,
      parentId: parentId ?? this.parentId,
      targetScore: targetScore ?? this.targetScore,
      targetCompletion: targetCompletion ?? this.targetCompletion,
      rewardCoins: rewardCoins ?? this.rewardCoins,
      progress: progress ?? this.progress,
    );
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
