class RecommendationResponse {
  final String message;
  final List<String> topics;
  final List<FlashcardRecommendation> flashcards;
  final List<QuizRecommendation> quizzes;
  final RecommendationMeta meta;

  RecommendationResponse({
    required this.message,
    required this.topics,
    required this.flashcards,
    required this.quizzes,
    required this.meta,
  });

  factory RecommendationResponse.fromJson(Map<String, dynamic> json) {
    return RecommendationResponse(
      message: json['message'] ?? '',
      topics: List<String>.from(json['topics'] ?? []),
      flashcards:
          (json['flashcards'] as List?)
              ?.map((e) => FlashcardRecommendation.fromJson(e))
              .toList() ??
          [],
      quizzes:
          (json['quizzes'] as List?)
              ?.map((e) => QuizRecommendation.fromJson(e))
              .toList() ??
          [],
      meta: RecommendationMeta.fromJson(json['meta'] ?? {}),
    );
  }
}

class FlashcardRecommendation {
  final String id;
  final String topicKey;
  final String front;
  final String back;
  final double difficulty;

  FlashcardRecommendation({
    required this.id,
    required this.topicKey,
    required this.front,
    required this.back,
    required this.difficulty,
  });

  factory FlashcardRecommendation.fromJson(Map<String, dynamic> json) {
    return FlashcardRecommendation(
      id: json['_id'] ?? '',
      topicKey: json['topic_key'] ?? '',
      front: json['front'] ?? '',
      back: json['back'] ?? '',
      difficulty: (json['difficulty'] ?? 0.5).toDouble(),
    );
  }
}

class QuizRecommendation {
  final String id;
  final String quizId;
  final String topicKey;
  final List<QuizQuestion> questions;
  final int numQuestions;
  final String difficultyTarget;
  final bool isAttempted;

  QuizRecommendation({
    required this.id,
    required this.quizId,
    required this.topicKey,
    required this.questions,
    required this.numQuestions,
    required this.difficultyTarget,
    this.isAttempted = false,
  });

  factory QuizRecommendation.fromJson(Map<String, dynamic> json) {
    return QuizRecommendation(
      id: json['_id'] ?? '',
      quizId: json['quiz_id'] ?? '',
      topicKey: json['topic_key'] ?? '',
      questions:
          (json['questions'] as List?)
              ?.map((e) => QuizQuestion.fromJson(e))
              .toList() ??
          [],
      numQuestions: json['num_questions'] ?? 0,
      difficultyTarget: json['difficulty_target'] ?? 'medium',
      isAttempted: json['isAttempted'] ?? false,
    );
  }

  // Get display name from topic key
  String get displayName {
    final parts = topicKey.split('::');
    return parts.length >= 3 ? parts[2] : topicKey;
  }
}

class QuizQuestion {
  final String id;
  final String stem;
  final List<String> choices;
  final int correctChoiceIndex;
  final String explanation;

  QuizQuestion({
    required this.id,
    required this.stem,
    required this.choices,
    required this.correctChoiceIndex,
    required this.explanation,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['_id'] ?? '',
      stem: json['stem'] ?? '',
      choices: List<String>.from(json['choices'] ?? []),
      correctChoiceIndex: json['correct_choice_index'] ?? 0,
      explanation: json['explanation'] ?? '',
    );
  }
}

class RecommendationMeta {
  final bool quizIndexAvailable;
  final int totalFlashcards;
  final int totalQuizzes;

  RecommendationMeta({
    required this.quizIndexAvailable,
    required this.totalFlashcards,
    required this.totalQuizzes,
  });

  factory RecommendationMeta.fromJson(Map<String, dynamic> json) {
    return RecommendationMeta(
      quizIndexAvailable: json['quiz_index_available'] ?? false,
      totalFlashcards: json['total_flashcards'] ?? 0,
      totalQuizzes: json['total_quizzes'] ?? 0,
    );
  }
}
