import 'package:brainbee/presentation/views/settings/model/book_model.dart';

class BookData {
  final String book;
  final String grade;
  final List<Chapter> chapters;

  BookData({required this.book, required this.grade, required this.chapters});

  factory BookData.fromJson(Map<String, dynamic> json) {
    return BookData(
      book: json['book'],
      grade: json['grade'],
      chapters:
          (json['chapters'] as List).map((e) => Chapter.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "book": book,
      "grade": grade,
      "chapters": chapters.map((e) => e.toJson()).toList(),
    };
  }
}

class Chapter {
  final int chapter;
  final List<Topic> topics;

  Chapter({required this.chapter, required this.topics});

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      chapter: json['chapter'],
      topics: (json['topics'] as List).map((e) => Topic.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "chapter": chapter,
      "topics": topics.map((e) => e.toJson()).toList(),
    };
  }
}

class Topic {
  final String topic;
  final List<Quiz> quizzes;
  final bool isUnlocked;
  final int quizzesCompleted;
  final int totalQuizzes;
  final bool canGenerateNew;
  final int minQuizzesToUnlockNext;
  final int remainingToUnlock;
  Topic({
    required this.topic,
    required this.quizzes,
    this.isUnlocked = false,
    this.quizzesCompleted = 0,
    this.totalQuizzes = 0,
    this.canGenerateNew = false,
    this.minQuizzesToUnlockNext = 2,
    this.remainingToUnlock = 2,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      topic: json['topic'],
      quizzes: (json['quizzes'] as List).map((e) => Quiz.fromJson(e)).toList(),
      isUnlocked: json['isUnlocked'] ?? false,
      quizzesCompleted: json['quizzesCompleted'] ?? 0,
      totalQuizzes: json['totalQuizzes'] ?? 0,
      canGenerateNew: json['canGenerateNew'] ?? false,
      minQuizzesToUnlockNext: json['minQuizzesToUnlockNext'] ?? 2,
      remainingToUnlock: json['remainingToUnlock'] ?? 2,
    );
  }

  Map<String, dynamic> toJson() {
    return {"topic": topic, "quizzes": quizzes.map((e) => e.toJson()).toList()};
  }
}

class Quiz {
  final String id;
  final String quizId;
  final int? numQuestions;
  final String? difficultyTarget;
  final DateTime? generatedAt;
  final bool? isAttempted; // ✅ Add this for topic status endpoint

  Quiz({
    required this.id,
    required this.quizId,
    this.numQuestions,
    this.difficultyTarget,
    this.generatedAt,
    this.isAttempted,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    // ✅ Handle both API response formats

    // Format 1: From topic status endpoint (id, quizId, isAttempted, generatedAt)
    if (json.containsKey('id') && json.containsKey('quizId')) {
      return Quiz(
        id: json['id'] as String,
        quizId: json['quizId'] as String,
        isAttempted: json['isAttempted'] as bool? ?? false,
        generatedAt:
            json['generatedAt'] != null
                ? DateTime.parse(json['generatedAt'] as String)
                : null,
        numQuestions: null,
        difficultyTarget: null,
      );
    }

    // Format 2: From quiz details endpoint (_id, quiz_id, num_questions, etc.)
    return Quiz(
      id: json['_id'] as String,
      quizId: json['quiz_id'] as String,
      numQuestions: json['num_questions'] as int?,
      difficultyTarget: json['difficulty_target'] as String?,
      generatedAt:
          json['generated_at'] != null
              ? DateTime.parse(json['generated_at'] as String)
              : null,
      isAttempted: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "quiz_id": quizId,
      "num_questions": numQuestions,
      "difficulty_target": difficultyTarget,
      "generated_at": generatedAt?.toIso8601String(),
      "isAttempted": isAttempted,
    };
  }
}

class QuizBookPair {
  final Map<String, dynamic> quiz;
  final BookModel book;

  QuizBookPair({required this.quiz, required this.book});
}
