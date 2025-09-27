class QuizQuestion {
  final String id;
  final String stem;
  final List<String> choices;
  final int correctChoiceIndex;
  final String explanation;
  final double difficulty;

  QuizQuestion({
    required this.id,
    required this.stem,
    required this.choices,
    required this.correctChoiceIndex,
    required this.explanation,
    required this.difficulty,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['_id'] ?? '',
      stem: json['stem'] ?? '',
      choices: List<String>.from(json['choices'] ?? []),
      correctChoiceIndex: json['correct_choice_index'] ?? 0,
      explanation: json['explanation'] ?? '',
      difficulty: (json['difficulty'] ?? 0.0).toDouble(),
    );
  }
}
