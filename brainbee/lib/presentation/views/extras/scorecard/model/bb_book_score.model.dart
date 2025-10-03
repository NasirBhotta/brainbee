// lib/presentation/views/extras/scorecard/models/overall_score_models.dart

class OverallScoreResponse {
  final String status;
  final OverallScoreData data;

  OverallScoreResponse({required this.status, required this.data});

  factory OverallScoreResponse.fromJson(Map<String, dynamic> json) {
    return OverallScoreResponse(
      status: json['status'] as String,
      data: OverallScoreData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class OverallScoreData {
  final int overallScore;
  final int totalBooks;
  final int totalQuizzesCompleted;
  final int totalStudyHours;
  final List<SubjectScore> subjectScores;
  final List<WeakPoint> weakPoints;

  OverallScoreData({
    required this.overallScore,
    required this.totalBooks,
    required this.totalQuizzesCompleted,
    required this.totalStudyHours,
    required this.subjectScores,
    required this.weakPoints,
  });

  factory OverallScoreData.fromJson(Map<String, dynamic> json) {
    return OverallScoreData(
      overallScore: json['overallScore'] as int,
      totalBooks: json['totalBooks'] as int,
      totalQuizzesCompleted: json['totalQuizzesCompleted'] as int,
      totalStudyHours: json['totalStudyHours'] as int,
      subjectScores:
          (json['subjectScores'] as List)
              .map((e) => SubjectScore.fromJson(e as Map<String, dynamic>))
              .toList(),
      weakPoints:
          (json['weakPoints'] as List)
              .map((e) => WeakPoint.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }
}

class SubjectScore {
  final String id;
  final String subject;
  final int score;
  final int completed;
  final int total;

  SubjectScore({
    required this.id,
    required this.subject,
    required this.score,
    required this.completed,
    required this.total,
  });

  factory SubjectScore.fromJson(Map<String, dynamic> json) {
    return SubjectScore(
      id: json['id'] as String,
      subject: json['subject'] as String,
      score: json['score'] as int,
      completed: json['completed'] as int,
      total: json['total'] as int,
    );
  }
}

class WeakPoint {
  final String topic;
  final int score;
  final List<String> suggestions;

  WeakPoint({
    required this.topic,
    required this.score,
    required this.suggestions,
  });

  factory WeakPoint.fromJson(Map<String, dynamic> json) {
    return WeakPoint(
      topic: json['topic'] as String,
      score: json['score'] as int,
      suggestions:
          (json['suggestions'] as List).map((e) => e as String).toList(),
    );
  }
}
