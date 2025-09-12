// quiz_models.dart
import 'dart:ui';

import 'package:flutter/material.dart';

class QuizData {
  final String id;
  final String quizId;
  final String studentId;
  final String topicKey;
  final List<QuizQuestion> questions;
  final int numQuestions;
  final String difficultyTarget;
  final String generatedBy;
  final DateTime generatedAt;

  QuizData({
    required this.id,
    required this.quizId,
    required this.studentId,
    required this.topicKey,
    required this.questions,
    required this.numQuestions,
    required this.difficultyTarget,
    required this.generatedBy,
    required this.generatedAt,
  });

  factory QuizData.fromJson(Map<String, dynamic> json) {
    return QuizData(
      id: json['_id'] ?? '',
      quizId: json['quiz_id'] ?? '',
      studentId: json['student_id'] ?? '',
      topicKey: json['topic_key'] ?? '',
      questions:
          (json['questions'] as List? ?? [])
              .map((q) => QuizQuestion.fromJson(q))
              .toList(),
      numQuestions: json['num_questions'] ?? 0,
      difficultyTarget: json['difficulty_target'] ?? 'medium',
      generatedBy: json['generated_by'] ?? '',
      generatedAt: DateTime.parse(
        json['generated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}

class QuizQuestion {
  final String id;

  QuizQuestion({required this.id});

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(id: json['_id'] ?? '');
  }
}

// Parsed chapter and topic structure
class ParsedChapter {
  final String bookName;
  final int chapterNumber;
  final String chapterTitle;
  final List<ParsedTopic> topics;
  final Color color;
  final IconData icon;

  ParsedChapter({
    required this.bookName,
    required this.chapterNumber,
    required this.chapterTitle,
    required this.topics,
    required this.color,
    required this.icon,
  });

  String get displayTitle => "Chapter $chapterNumber: $chapterTitle";
}

class ParsedTopic {
  final String topicKey;
  final String topicTitle;
  final bool hasQuiz;
  final QuizData? quizData;

  ParsedTopic({
    required this.topicKey,
    required this.topicTitle,
    required this.hasQuiz,
    this.quizData,
  });
}
