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

  Topic({required this.topic, required this.quizzes});

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      topic: json['topic'],
      quizzes: (json['quizzes'] as List).map((e) => Quiz.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {"topic": topic, "quizzes": quizzes.map((e) => e.toJson()).toList()};
  }
}

class Quiz {
  final String id;
  final String quizId;
  final int numQuestions;
  final String difficultyTarget;
  final DateTime generatedAt;

  Quiz({
    required this.id,
    required this.quizId,
    required this.numQuestions,
    required this.difficultyTarget,
    required this.generatedAt,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['_id'],
      quizId: json['quiz_id'],
      numQuestions: json['num_questions'],
      difficultyTarget: json['difficulty_target'],
      generatedAt: DateTime.parse(json['generated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "quiz_id": quizId,
      "num_questions": numQuestions,
      "difficulty_target": difficultyTarget,
      "generated_at": generatedAt.toIso8601String(),
    };
  }
}
