// lib/presentation/views/extras/scorecard/models/book_score_models.dart

class BookScoreResponse {
  final String status;
  final BookScoreData data;

  BookScoreResponse({required this.status, required this.data});

  factory BookScoreResponse.fromJson(Map<String, dynamic> json) {
    return BookScoreResponse(
      status: json['status'] as String,
      data: BookScoreData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class BookScoreData {
  final String id;
  final String title;
  final String author;
  final int overallScore;
  final String? coverImage;
  final int pagesRead;
  final int totalPages;
  final int studyTimeInSeconds;
  final int quizzesCompleted;
  final int totalQuizzes;
  final int totalActivities;
  final List<ChapterScoreData> chapterScores;
  final List<String> recommendations;
  final int averageScore;

  BookScoreData({
    required this.id,
    required this.title,
    required this.author,
    required this.overallScore,
    this.coverImage,
    required this.pagesRead,
    required this.totalPages,
    required this.studyTimeInSeconds,
    required this.quizzesCompleted,
    required this.totalQuizzes,
    required this.totalActivities,
    required this.chapterScores,
    required this.recommendations,
    required this.averageScore,
  });

  // Convert seconds to hours for display
  double get studyHours => ((studyTimeInSeconds / 3600) * 100).round() / 100;

  factory BookScoreData.fromJson(Map<String, dynamic> json) {
    return BookScoreData(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String? ?? '',
      overallScore: json['overallScore'] as int,
      coverImage: json['coverImage'] as String?,
      pagesRead: json['pagesRead'] as int,
      totalPages: json['totalPages'] as int,
      studyTimeInSeconds: json['studyTimeInSeconds'] as int,
      quizzesCompleted: json['quizzesCompleted'] as int,
      totalQuizzes: json['totalQuizzes'] as int,
      totalActivities: json['totalActivities'] as int,
      chapterScores:
          (json['chapterScores'] as List)
              .map((e) => ChapterScoreData.fromJson(e as Map<String, dynamic>))
              .toList(),
      recommendations:
          (json['recommendations'] as List).map((e) => e as String).toList(),
      averageScore: json['averageScore'] as int,
    );
  }
}

class ChapterScoreData {
  final int chapterNumber;
  final String title;
  final int score;
  final bool completed;
  final List<QuizScoreData> quizScores;

  ChapterScoreData({
    required this.chapterNumber,
    required this.title,
    required this.score,
    required this.completed,
    required this.quizScores,
  });

  factory ChapterScoreData.fromJson(Map<String, dynamic> json) {
    return ChapterScoreData(
      chapterNumber: json['chapterNumber'] as int,
      title: json['title'] as String,
      score: json['score'] as int,
      completed: json['completed'] as bool,
      quizScores:
          (json['quizScores'] as List)
              .map((e) => QuizScoreData.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }
}

class QuizScoreData {
  final String quizId;
  final String title;
  final int score;
  final String difficultyTarget;

  QuizScoreData({
    required this.quizId,
    required this.title,
    required this.score,
    required this.difficultyTarget,
  });

  factory QuizScoreData.fromJson(Map<String, dynamic> json) {
    return QuizScoreData(
      quizId: json['quizId'] as String,
      title: json['title'] as String,
      score: json['score'] as int,
      difficultyTarget: json['difficultyTarget'] as String,
    );
  }
}

class CategoryScore {
  final String category;
  final int score;

  CategoryScore({required this.category, required this.score});
}
