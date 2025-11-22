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
  final List<Question> questions;
  final DateTime? submissionTime;
  final String? grade;

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
  });

  DateTime get effectiveDueTime => extendedDueTime ?? dueTime;
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(effectiveDueTime);
  }

  factory ClassQuiz.fromJson(Map<String, dynamic> json) {
    return ClassQuiz(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      dueTime: DateTime.parse(json['dueTime'] as String),
      extendedDueTime:
          json['extendedDueTime'] != null
              ? DateTime.parse(json['extendedDueTime'])
              : null,
      status: QuizStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => QuizStatus.notStarted,
      ),
      isPublished: json['isPublished'] as bool? ?? true,
      isReopened: json['isReopened'] as bool? ?? false,
      questions:
          (json['questions'] as List? ?? [])
              .map((q) => Question.fromJson(q))
              .toList(),
      submissionTime:
          json['submissionTime'] != null
              ? DateTime.parse(json['submissionTime'])
              : null,
      grade: json['grade'] as String?,
    );
  }
}
