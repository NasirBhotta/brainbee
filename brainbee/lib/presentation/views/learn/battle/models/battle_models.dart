import 'package:brainbee/core/models/bb_question.dart';

enum BattleStatus {
  waiting,
  searching,
  matched,
  inProgress,
  completed,
  cancelled,
}

enum BattleMode { random, invitation, wholeBook, byChapter }

class BattleRoom {
  final String roomId;
  final String invitationCode;
  final BattleMode mode;
  final BattleStatus status;
  final String subject;
  final List<String>? chapters;
  final BattlePlayer host;
  final BattlePlayer? opponent;
  final DateTime createdAt;
  final DateTime? startedAt;
  final int maxPlayers;

  BattleRoom({
    required this.roomId,
    required this.invitationCode,
    required this.mode,
    required this.status,
    required this.subject,
    this.chapters,
    required this.host,
    this.opponent,
    required this.createdAt,
    this.startedAt,
    this.maxPlayers = 2,
  });

  factory BattleRoom.fromJson(Map<String, dynamic> json) {
    return BattleRoom(
      roomId: json['roomId'] ?? json['_id'] ?? '',
      invitationCode: json['invitationCode'] ?? '',
      mode: _parseBattleMode(json['mode']),
      status: _parseBattleStatus(json['status']),
      subject: json['subject'] ?? '',
      chapters:
          json['chapters'] != null ? List<String>.from(json['chapters']) : null,
      host: BattlePlayer.fromJson(json['host']),
      opponent:
          json['opponent'] != null
              ? BattlePlayer.fromJson(json['opponent'])
              : null,
      createdAt: DateTime.parse(json['createdAt']),
      startedAt:
          json['startedAt'] != null ? DateTime.parse(json['startedAt']) : null,
      maxPlayers: json['maxPlayers'] ?? 2,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'invitationCode': invitationCode,
      'mode': mode.name,
      'status': status.name,
      'subject': subject,
      'chapters': chapters,
      'host': host.toJson(),
      'opponent': opponent?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'maxPlayers': maxPlayers,
    };
  }

  static BattleMode _parseBattleMode(String? mode) {
    switch (mode?.toLowerCase()) {
      case 'random':
        return BattleMode.random;
      case 'invitation':
        return BattleMode.invitation;
      case 'wholebook':
        return BattleMode.wholeBook;
      case 'bychapter':
        return BattleMode.byChapter;
      default:
        return BattleMode.random;
    }
  }

  static BattleStatus _parseBattleStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'waiting':
        return BattleStatus.waiting;
      case 'searching':
        return BattleStatus.searching;
      case 'matched':
        return BattleStatus.matched;
      case 'inprogress':
        return BattleStatus.inProgress;
      case 'completed':
        return BattleStatus.completed;
      case 'cancelled':
        return BattleStatus.cancelled;
      default:
        return BattleStatus.waiting;
    }
  }

  BattleRoom copyWith({
    String? roomId,
    String? invitationCode,
    BattleMode? mode,
    BattleStatus? status,
    String? subject,
    List<String>? chapters,
    BattlePlayer? host,
    BattlePlayer? opponent,
    DateTime? createdAt,
    DateTime? startedAt,
    int? maxPlayers,
  }) {
    return BattleRoom(
      roomId: roomId ?? this.roomId,
      invitationCode: invitationCode ?? this.invitationCode,
      mode: mode ?? this.mode,
      status: status ?? this.status,
      subject: subject ?? this.subject,
      chapters: chapters ?? this.chapters,
      host: host ?? this.host,
      opponent: opponent ?? this.opponent,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      maxPlayers: maxPlayers ?? this.maxPlayers,
    );
  }
}

class BattlePlayer {
  final String id;
  final String username;
  final String avatarInitial;
  final String avatarColor;
  final int currentScore;
  final int currentQuestionIndex;
  final bool isReady;
  final DateTime? lastAnswerTime;

  BattlePlayer({
    required this.id,
    required this.username,
    required this.avatarInitial,
    required this.avatarColor,
    this.currentScore = 0,
    this.currentQuestionIndex = 0,
    this.isReady = false,
    this.lastAnswerTime,
  });

  factory BattlePlayer.fromJson(Map<String, dynamic> json) {
    return BattlePlayer(
      id: json['id'] ?? json['_id'] ?? '',
      username: json['username'] ?? 'Player',
      avatarInitial: json['avatarInitial'] ?? 'P',
      avatarColor: json['avatarColor'] ?? '#E94A76',
      currentScore: json['currentScore'] ?? 0,
      currentQuestionIndex: json['currentQuestionIndex'] ?? 0,
      isReady: json['isReady'] ?? false,
      lastAnswerTime:
          json['lastAnswerTime'] != null
              ? DateTime.parse(json['lastAnswerTime'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'avatarInitial': avatarInitial,
      'avatarColor': avatarColor,
      'currentScore': currentScore,
      'currentQuestionIndex': currentQuestionIndex,
      'isReady': isReady,
      'lastAnswerTime': lastAnswerTime?.toIso8601String(),
    };
  }

  BattlePlayer copyWith({
    String? id,
    String? username,
    String? avatarInitial,
    String? avatarColor,
    int? currentScore,
    int? currentQuestionIndex,
    bool? isReady,
    DateTime? lastAnswerTime,
  }) {
    return BattlePlayer(
      id: id ?? this.id,
      username: username ?? this.username,
      avatarInitial: avatarInitial ?? this.avatarInitial,
      avatarColor: avatarColor ?? this.avatarColor,
      currentScore: currentScore ?? this.currentScore,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      isReady: isReady ?? this.isReady,
      lastAnswerTime: lastAnswerTime ?? this.lastAnswerTime,
    );
  }
}

class BattleQuizData {
  final String quizId;
  final String roomId;
  final List<Question> questions;
  final int totalQuestions;
  final int timePerQuestion;
  final DateTime startTime;

  BattleQuizData({
    required this.quizId,
    required this.roomId,
    required this.questions,
    required this.totalQuestions,
    this.timePerQuestion = 15,
    required this.startTime,
  });

  factory BattleQuizData.fromJson(Map<String, dynamic> json) {
    return BattleQuizData(
      quizId: json['quizId'] ?? '',
      roomId: json['roomId'] ?? '',
      questions:
          (json['questions'] as List)
              .map((q) => Question.fromJson(q))
              .toList(), // getting error here
      totalQuestions: json['totalQuestions'] ?? 0,
      timePerQuestion: json['timePerQuestion'] ?? 15,
      startTime: DateTime.parse(json['startTime']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quizId': quizId,
      'roomId': roomId,
      'questions': questions.map((q) => q.toJson()).toList(),
      'totalQuestions': totalQuestions,
      'timePerQuestion': timePerQuestion,
      'startTime': startTime.toIso8601String(),
    };
  }
}

class BattleAnswer {
  final String roomId;
  final String playerId;
  final int questionIndex;
  final int? selectedOptionIndex;
  final int timeSpent;
  final DateTime answeredAt;

  BattleAnswer({
    required this.roomId,
    required this.playerId,
    required this.questionIndex,
    this.selectedOptionIndex,
    required this.timeSpent,
    required this.answeredAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'playerId': playerId,
      'questionIndex': questionIndex,
      'selectedOptionIndex': selectedOptionIndex,
      'timeSpent': timeSpent,
      'answeredAt': answeredAt.toIso8601String(),
    };
  }

  factory BattleAnswer.fromJson(Map<String, dynamic> json) {
    return BattleAnswer(
      roomId: json['roomId'] ?? '',
      playerId: json['playerId'] ?? '',
      questionIndex: json['questionIndex'] ?? 0,
      selectedOptionIndex: json['selectedOptionIndex'],
      timeSpent: json['timeSpent'] ?? 0,
      answeredAt: DateTime.parse(json['answeredAt']),
    );
  }
}

class BattleResult {
  final String roomId;
  final BattlePlayer winner;
  final BattlePlayer loser;
  final int winnerScore;
  final int loserScore;
  final List<BattleAnswer> winnerAnswers;
  final List<BattleAnswer> loserAnswers;
  final DateTime completedAt;

  BattleResult({
    required this.roomId,
    required this.winner,
    required this.loser,
    required this.winnerScore,
    required this.loserScore,
    required this.winnerAnswers,
    required this.loserAnswers,
    required this.completedAt,
  });

  factory BattleResult.fromJson(Map<String, dynamic> json) {
    return BattleResult(
      roomId: json['roomId'] ?? '',
      winner: BattlePlayer.fromJson(json['winner']),
      loser: BattlePlayer.fromJson(json['loser']),
      winnerScore: json['winnerScore'] ?? 0,
      loserScore: json['loserScore'] ?? 0,
      winnerAnswers:
          (json['winnerAnswers'] as List)
              .map((a) => BattleAnswer.fromJson(a))
              .toList(),
      loserAnswers:
          (json['loserAnswers'] as List)
              .map((a) => BattleAnswer.fromJson(a))
              .toList(),
      completedAt: DateTime.parse(json['completedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'winner': winner.toJson(),
      'loser': loser.toJson(),
      'winnerScore': winnerScore,
      'loserScore': loserScore,
      'winnerAnswers': winnerAnswers.map((a) => a.toJson()).toList(),
      'loserAnswers': loserAnswers.map((a) => a.toJson()).toList(),
      'completedAt': completedAt.toIso8601String(),
    };
  }
}
