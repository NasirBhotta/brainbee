enum QuestionType { singleChoice, mcq, text, longAnswer }

class Question {
  final String? id;
  final String text;
  final QuestionType? type;
  final List<String>? options;
  final bool? isMultiSelect;
  final String? answer;
  final int? correctOptionIndex;

  Question({
    this.id,
    required this.text,
    this.type,
    this.options,
    this.isMultiSelect,
    this.answer,
    this.correctOptionIndex,
  });

  // ---------- ✅ JSON Serialization ----------
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'type': type.toString().split('.').last, // store enum as string
      'options': options,
      'isMultiSelect': isMultiSelect,
      'answer': answer,
      'correctOptionIndex': correctOptionIndex,
    };
  }

  // ---------- ✅ JSON Deserialization ----------
  factory Question.fromJson(Map<String, dynamic> json) {
    // support multiple naming conventions from backend
    final optionsList =
        json['options'] ?? json['choices'] ?? json['answers'] ?? [];

    return Question(
      id: json['id']?.toString() ?? '',
      text: json['text'] ?? json['stem'] ?? json['question'] ?? '',
      type: _parseQuestionType(json['type']),
      options:
          optionsList != null
              ? List<String>.from(optionsList.map((o) => o.toString()))
              : null,
      isMultiSelect: json['isMultiSelect'] ?? false,
      answer: json['answer']?.toString(),
      correctOptionIndex:
          json['correctOptionIndex'] ??
          json['correctChoiceIndex'] ??
          json['correctAnswer'] ??
          0,
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
}
