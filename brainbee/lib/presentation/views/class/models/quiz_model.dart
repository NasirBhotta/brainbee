import 'package:brainbee/core/models/bb_question.dart';

enum QuizStatus { notStarted, inProgress, overdue, submitted }

class ClassQuiz {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime dueTime;
  final DateTime? extendedDueTime;
  final QuizStatus status;
  final bool isPublished;
  final bool isReopened;
  final List<QuizQuestion> questions;
  final DateTime? submissionTime;
  final String? grade;
  final int? timeLimit; // in minutes
  final int? totalPoints;
  final String? teacherName;
  final String? className;

  ClassQuiz({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.dueTime,
    this.extendedDueTime,
    required this.status,
    required this.isPublished,
    this.isReopened = false,
    required this.questions,
    this.submissionTime,
    this.grade,
    this.timeLimit,
    this.totalPoints,
    this.teacherName,
    this.className,
  });

  DateTime get effectiveDueTime => extendedDueTime ?? dueTime;

  bool get isActive {
    final now = DateTime.now();
    return isPublished &&
        now.isAfter(startTime) &&
        now.isBefore(effectiveDueTime) &&
        status != QuizStatus.submitted;
  }

  factory ClassQuiz.fromJson(Map<String, dynamic> json) {
    // Determine status based on submission and due date
    QuizStatus determineStatus() {
      final now = DateTime.now();
      final dueDate =
          json['dueDate'] != null
              ? DateTime.parse(json['dueDate'])
              : DateTime.now().add(Duration(days: 7));

      // Check if already submitted (you might need to add this field from API)
      if (json['isCompleted'] == true || json['submittedAt'] != null) {
        return QuizStatus.submitted;
      }

      // Check if overdue
      if (now.isAfter(dueDate)) {
        return QuizStatus.overdue;
      }

      // Check if started (you might need this from API or assume not started)
      if (json['hasStarted'] == true) {
        return QuizStatus.inProgress;
      }

      return QuizStatus.notStarted;
    }

    // Parse teacher info
    String? teacherName;
    if (json['teacher'] != null) {
      final teacher = json['teacher'];
      teacherName =
          '${teacher['firstName'] ?? ''} ${teacher['lastName'] ?? ''}'.trim();
    }

    // Parse class info
    String? className;
    if (json['classId'] != null) {
      final classInfo = json['classId'];
      className = classInfo['name'] ?? '';
    }

    // Parse questions from API format
    List<QuizQuestion> parseQuestions(List<dynamic>? questionsJson) {
      if (questionsJson == null) return [];

      return questionsJson.asMap().entries.map((entry) {
        final index = entry.key;
        final q = entry.value;

        return QuizQuestion(
          id: q['_id'] ?? 'q_$index',
          text: q['question'] ?? '',
          options: List<String>.from(q['options'] ?? []),
          correctAnswer: q['correctAnswer'] as int?,
          explanation: q['explanation'] as String?,
          type: QuestionType.mcq,
        );
      }).toList();
    }

    return ClassQuiz(
      id: json['_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      startTime:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
      dueTime:
          json['dueDate'] != null
              ? DateTime.parse(json['dueDate'])
              : DateTime.now().add(Duration(days: 7)),
      extendedDueTime:
          json['extendedDueDate'] != null
              ? DateTime.parse(json['extendedDueDate'])
              : null,
      status: determineStatus(),
      isPublished: json['isPublished'] as bool? ?? false,
      isReopened: json['isReopened'] as bool? ?? false,
      questions: parseQuestions(json['questions'] as List?),
      submissionTime:
          json['submittedAt'] != null
              ? DateTime.parse(json['submittedAt'])
              : null,
      grade: json['grade']?.toString(),
      timeLimit: json['timeLimit'] as int?,
      totalPoints: json['totalPoints'] as int?,
      teacherName: teacherName,
      className: className,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'createdAt': startTime.toIso8601String(),
      'dueDate': dueTime.toIso8601String(),
      'extendedDueDate': extendedDueTime?.toIso8601String(),
      'isPublished': isPublished,
      'isReopened': isReopened,
      'questions': questions.map((q) => q.toJson()).toList(),
      'submittedAt': submissionTime?.toIso8601String(),
      'grade': grade,
      'timeLimit': timeLimit,
      'totalPoints': totalPoints,
    };
  }
}

class QuizQuestion {
  final String id;
  final String text;
  final List<String> options;
  final int? correctAnswer;
  final String? explanation;
  final QuestionType type;

  QuizQuestion({
    required this.id,
    required this.text,
    required this.options,
    this.correctAnswer,
    this.explanation,
    this.type = QuestionType.mcq,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['_id'] ?? json['id'] ?? '',
      text: json['question'] ?? json['text'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correctAnswer'] as int?,
      explanation: json['explanation'] as String?,
      type: QuestionType.mcq,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'question': text,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
    };
  }
}
