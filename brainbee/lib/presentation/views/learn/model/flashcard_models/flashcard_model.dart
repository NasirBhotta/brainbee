// lib/presentation/views/learn/model/flashcard_models/flashcard_model.dart

import 'dart:convert';

// Helper function to decode JSON string
FlashcardResponse flashcardResponseFromJson(String str) =>
    FlashcardResponse.fromJson(json.decode(str));

class FlashcardResponse {
  final String message;
  final int count;
  final List<Flashcard> flashcards;

  FlashcardResponse({
    required this.message,
    required this.count,
    required this.flashcards,
  });

  factory FlashcardResponse.fromJson(Map<String, dynamic> json) =>
      FlashcardResponse(
        message: json["message"],
        count: json["count"],
        flashcards: List<Flashcard>.from(
          json["flashcards"].map((x) => Flashcard.fromJson(x)),
        ),
      );
}

class Flashcard {
  final String id;
  final String studentId;
  final String topicKey;
  final String front;
  final String back;
  final double difficulty;
  final String generatedBy;
  final bool approved;
  final int usageCount;
  final DateTime? lastReviewed;
  final DateTime generatedAt;

  Flashcard({
    required this.id,
    required this.studentId,
    required this.topicKey,
    required this.front,
    required this.back,
    required this.difficulty,
    required this.generatedBy,
    required this.approved,
    required this.usageCount,
    this.lastReviewed,
    required this.generatedAt,
  });

  factory Flashcard.fromJson(Map<String, dynamic> json) => Flashcard(
    id: json["_id"],
    studentId: json["student_id"],
    topicKey: json["topic_key"],
    front: json["front"],
    back: json["back"],
    difficulty: json["difficulty"]?.toDouble(),
    generatedBy: json["generated_by"],
    approved: json["approved"],
    usageCount: json["usage_count"],
    lastReviewed:
        json["last_reviewed"] == null
            ? null
            : DateTime.parse(json["last_reviewed"]),
    generatedAt: DateTime.parse(json["generated_at"]),
  );
}
