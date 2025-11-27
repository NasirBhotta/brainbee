enum QuestionType { singleChoice, mcq, text, longAnswer }

class Question {
  final String? id;
  final String text;
  final QuestionType? type;
  final List<String>? options;
  final bool? isMultiSelect;
  final String? answer;
  final int? correctOptionIndex;

  // ✅ NEW: Additional fields for battle questions (optional, won't break existing code)
  final String? explanation;
  final String? topicKey;
  final int? chapter;
  final double? difficulty;

  Question({
    this.id,
    required this.text,
    this.type,
    this.options,
    this.isMultiSelect,
    this.answer,
    this.correctOptionIndex,
    this.explanation, // ✅ Optional
    this.topicKey, // ✅ Optional
    this.chapter, // ✅ Optional
    this.difficulty, // ✅ Optional
  });

  // ---------- ✅ JSON Serialization ----------
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'type': type.toString().split('.').last,
      'options': options,
      'isMultiSelect': isMultiSelect,
      'answer': answer,
      'correctOptionIndex': correctOptionIndex,
      if (explanation != null)
        'explanation': explanation, // ✅ Only include if present
      if (topicKey != null) 'topicKey': topicKey,
      if (chapter != null) 'chapter': chapter,
      if (difficulty != null) 'difficulty': difficulty,
    };
  }

  // ---------- ✅ JSON Deserialization (Enhanced but backward compatible) ----------
  factory Question.fromJson(Map<String, dynamic> json) {
    // Handle ID from multiple sources (_id from MongoDB, id from other APIs)
    final questionId = json['_id']?.toString() ?? json['id']?.toString() ?? '';

    // Handle text from multiple field names
    final questionText =
        json['text']?.toString() ??
        json['stem']?.toString() ??
        json['question']?.toString() ??
        '';

    // Handle options/choices/answers array
    final optionsData = json['options'] ?? json['choices'] ?? json['answers'];

    List<String>? parsedOptions;
    if (optionsData != null) {
      if (optionsData is List) {
        parsedOptions = optionsData.map((o) => o.toString()).toList();
      }
    }

    // Handle correct answer index with multiple possible field names
    int correctIndex = 0;
    final indexValue =
        json['correctOptionIndex'] ??
        json['correct_choice_index'] ?? // ✅ MongoDB field
        json['correctChoiceIndex'] ??
        json['correctAnswer'];

    if (indexValue is int) {
      correctIndex = indexValue;
    } else if (indexValue is String) {
      correctIndex = int.tryParse(indexValue) ?? 0;
    }

    return Question(
      id: questionId.isEmpty ? null : questionId,
      text: questionText,
      type: _parseQuestionType(json['type']),
      options: parsedOptions,
      isMultiSelect: json['isMultiSelect'] ?? false,
      answer: json['answer']?.toString(),
      correctOptionIndex: correctIndex,
      explanation: json['explanation']?.toString(), // ✅ NEW: MongoDB field
      topicKey:
          json['topic_key']?.toString() ??
          json['topicKey']?.toString(), // ✅ NEW: MongoDB field
      chapter: json['chapter'] is int ? json['chapter'] as int : null, // ✅ NEW
      difficulty:
          json['difficulty'] is num
              ? (json['difficulty'] as num).toDouble()
              : null, // ✅ NEW
    );
  }

  // ---------- ✅ Helper to safely parse enum ----------
  static QuestionType _parseQuestionType(dynamic value) {
    if (value == null) return QuestionType.singleChoice;
    if (value is QuestionType) return value;
    final str = value.toString().toLowerCase();
    if (str.contains('multi')) return QuestionType.mcq;
    if (str.contains('text')) return QuestionType.text;
    return QuestionType.singleChoice;
  }

  // ✅ BONUS: Add copyWith method for immutability (useful for state management)
  Question copyWith({
    String? id,
    String? text,
    QuestionType? type,
    List<String>? options,
    bool? isMultiSelect,
    String? answer,
    int? correctOptionIndex,
    String? explanation,
    String? topicKey,
    int? chapter,
    double? difficulty,
  }) {
    return Question(
      id: id ?? this.id,
      text: text ?? this.text,
      type: type ?? this.type,
      options: options ?? this.options,
      isMultiSelect: isMultiSelect ?? this.isMultiSelect,
      answer: answer ?? this.answer,
      correctOptionIndex: correctOptionIndex ?? this.correctOptionIndex,
      explanation: explanation ?? this.explanation,
      topicKey: topicKey ?? this.topicKey,
      chapter: chapter ?? this.chapter,
      difficulty: difficulty ?? this.difficulty,
    );
  }
}
