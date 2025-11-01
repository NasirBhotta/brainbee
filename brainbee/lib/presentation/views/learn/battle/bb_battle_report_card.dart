import 'package:brainbee/presentation/views/home/bloc/student_bloc.dart';
import 'package:brainbee/presentation/views/home/quizzes/models/quiz_question_model.dart';
import 'package:brainbee/presentation/views/learn/battle/bb_reportcard_pdf.dart';
import 'package:flutter/material.dart';
import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/core/utils/bb_textTheme_extention.dart';
import 'package:brainbee/core/models/bb_question.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

enum QuizType { battle, inAppQuiz }

class BBQuizReportCardScreen extends StatefulWidget {
  // Common fields
  final int score;
  final int timeSpent;
  final List<int?> userAnswers;
  final QuizType quizType;

  // Battle-specific fields
  final int? opponentScore;
  final bool? won;
  final List<Question>? questions;

  // In-app quiz specific fields
  final List<QuizQuestion>? inAppQuestions;
  final List<String>? explanations;
  final int? correctAnswers;
  final int? totalQuestions;
  final String? quizTitle;
  final String? topicKey;

  const BBQuizReportCardScreen({
    super.key,
    required this.score,
    required this.timeSpent,
    required this.userAnswers,
    required this.quizType,
    // Battle fields
    this.opponentScore,
    this.won,
    this.questions,
    // In-app quiz fields
    this.inAppQuestions,
    this.explanations,
    this.correctAnswers,
    this.totalQuestions,
    this.quizTitle,
    this.topicKey,
  }) : assert(
         quizType == QuizType.battle
             ? (opponentScore != null && won != null && questions != null)
             : (inAppQuestions != null &&
                 explanations != null &&
                 correctAnswers != null &&
                 totalQuestions != null),
       );

  @override
  State<BBQuizReportCardScreen> createState() => _BBQuizReportCardScreenState();
}

class _BBQuizReportCardScreenState extends State<BBQuizReportCardScreen> {
  bool _questionsExpanded = true;
  bool _performanceExpanded = true;
  bool _improvementsExpanded = true;
  bool _comparisonExpanded = false;

  late Map<String, dynamic> quizAnalytics = {};
  late List<Map<String, dynamic>> pastQuizzes = [];
  late List<Map<String, dynamic>> questionAnalysis = [];
  late Map<String, dynamic> performanceMetrics = {};
  late List<Map<String, dynamic>> improvements = [];

  // Properties to handle edge cases
  late bool isQuizAbandoned;
  late List<int?> normalizedUserAnswers;

  // Dynamic properties based on quiz type
  late List<dynamic> currentQuestions;
  late int totalQuestionsCount;

  @override
  void initState() {
    super.initState();

    _initializeDynamicProperties();
    _handleEdgeCases();
    _generateQuizAnalytics();
    _mockPastQuizData();
    _analyzeQuestions();
    _generatePerformanceMetrics();
    _generateImprovementSuggestions();
  }

  void _initializeDynamicProperties() {
    if (widget.quizType == QuizType.battle) {
      currentQuestions = widget.questions!;
      totalQuestionsCount = widget.questions!.length;
    } else {
      currentQuestions = widget.inAppQuestions!;
      totalQuestionsCount = widget.totalQuestions!;
    }
  }

  void _handleEdgeCases() {
    isQuizAbandoned =
        widget.userAnswers.isEmpty ||
        widget.userAnswers.length < totalQuestionsCount;

    normalizedUserAnswers = List<int?>.filled(totalQuestionsCount, null);

    for (
      int i = 0;
      i < widget.userAnswers.length && i < totalQuestionsCount;
      i++
    ) {
      normalizedUserAnswers[i] = widget.userAnswers[i];
    }
  }

  void _generateQuizAnalytics() {
    int correctAnswers = 0;
    int incorrectAnswers = 0;
    int unanswered = 0;

    for (int i = 0; i < totalQuestionsCount; i++) {
      int? userAnswer =
          i < normalizedUserAnswers.length ? normalizedUserAnswers[i] : null;

      if (userAnswer == null) {
        unanswered++;
      } else {
        int correctIndex;
        if (widget.quizType == QuizType.battle) {
          correctIndex = (currentQuestions[i] as Question).correctOptionIndex;
        } else {
          correctIndex =
              (currentQuestions[i] as QuizQuestion).correctChoiceIndex;
        }

        if (userAnswer == correctIndex) {
          correctAnswers++;
        } else {
          incorrectAnswers++;
        }
      }
    }

    int avgTimePerQuestion =
        totalQuestionsCount == 0
            ? 0
            : (widget.timeSpent <= 0
                ? 0
                : widget.timeSpent ~/ totalQuestionsCount);

    double accuracyPercentage =
        totalQuestionsCount == 0
            ? 0.0
            : (correctAnswers / totalQuestionsCount * 100);

    quizAnalytics = {
      "date": DateFormat('MMM d, yyyy').format(DateTime.now()),
      "totalQuestions": totalQuestionsCount,
      "correctAnswers": correctAnswers,
      "incorrectAnswers": incorrectAnswers,
      "unanswered": unanswered,
      "accuracy": accuracyPercentage.round(),
      "score": widget.score,
      "opponentScore": widget.opponentScore ?? 0,
      "result": _getQuizResult(correctAnswers),
      "timeSpent": widget.timeSpent,
      "avgTimePerQuestion": avgTimePerQuestion,
      "isAbandoned": isQuizAbandoned,
    };
  }

  String _getQuizResult(int correctAnswers) {
    if (widget.quizType == QuizType.battle) {
      return widget.won! ? "Won" : "Lost";
    } else {
      if (totalQuestionsCount == 0) {
        return "Needs Improvement";
      }
      double percentage = (correctAnswers / totalQuestionsCount * 100);
      if (percentage >= 80) return "Excellent";
      if (percentage >= 60) return "Good";
      if (percentage >= 40) return "Average";
      return "Needs Improvement";
    }
  }

  void _mockPastQuizData() {
    pastQuizzes = [
      {
        "id": 1,
        "date": "May 10, 2025",
        "score": 85,
        "opponentScore": widget.quizType == QuizType.battle ? 72 : 100,
        "accuracy": 80,
        "avgTimePerQuestion": 8,
      },
      {
        "id": 2,
        "date": "May 8, 2025",
        "score": 63,
        "opponentScore": widget.quizType == QuizType.battle ? 78 : 100,
        "accuracy": 60,
        "avgTimePerQuestion": 10,
      },
      {
        "id": 3,
        "date": "May 5, 2025",
        "score": 92,
        "opponentScore": widget.quizType == QuizType.battle ? 85 : 100,
        "accuracy": 90,
        "avgTimePerQuestion": 7,
      },
    ];
  }

  void _analyzeQuestions() {
    questionAnalysis = List.generate(totalQuestionsCount, (index) {
      int? userAnswer =
          index < normalizedUserAnswers.length
              ? normalizedUserAnswers[index]
              : null;

      int correctIndex;
      String questionText;
      List<String> options;
      String? explanation;

      if (widget.quizType == QuizType.battle) {
        final question = currentQuestions[index] as Question;
        correctIndex = question.correctOptionIndex;
        questionText = question.text;
        options = question.options;
        explanation = null;
      } else {
        final question = currentQuestions[index] as QuizQuestion;
        correctIndex = question.correctChoiceIndex;
        questionText = question.stem;
        options =
            question.choices
                .map(
                  (choice) => choice.replaceFirst(RegExp(r'^[A-D]\.\s*'), ''),
                )
                .toList();
        explanation = question.explanation;
      }

      bool isCorrect = userAnswer != null && userAnswer == correctIndex;
      bool isUnanswered = userAnswer == null;

      String difficultyLevel = "Medium";
      if (widget.quizType == QuizType.inAppQuiz) {
        final difficulty = (currentQuestions[index] as QuizQuestion).difficulty;
        if (difficulty < 0.4) {
          difficultyLevel = "Easy";
        } else if (difficulty > 0.7) {
          difficultyLevel = "Hard";
        }
      } else {
        if (index % 3 == 0) difficultyLevel = "Easy";
        if (index % 3 == 2) difficultyLevel = "Hard";
      }

      return {
        "questionNumber": index + 1,
        "question": questionText,
        "correctAnswer": options[correctIndex],
        "userAnswer": isUnanswered ? "Unanswered" : options[userAnswer],
        "isCorrect": isCorrect,
        "isUnanswered": isUnanswered,
        "difficultyLevel": difficultyLevel,
        "explanation": explanation,
      };
    });
  }

  void _generatePerformanceMetrics() {
    double avgPastAccuracy = 0;
    double avgPastTime = 0;
    int totalPastQuizzes = pastQuizzes.length;

    if (totalPastQuizzes > 0) {
      for (var quiz in pastQuizzes) {
        avgPastAccuracy += quiz["accuracy"] as int;
        avgPastTime += quiz["avgTimePerQuestion"] as int;
      }
      avgPastAccuracy /= totalPastQuizzes;
      avgPastTime /= totalPastQuizzes;
    }

    performanceMetrics = {
      "accuracyChange": quizAnalytics["accuracy"] - avgPastAccuracy,
      "speedChange": avgPastTime - quizAnalytics["avgTimePerQuestion"],
      "scoreChange":
          widget.score -
          (pastQuizzes.isNotEmpty
              ? pastQuizzes[0]["score"] as int
              : widget.score),
      "winRateChange": _calculatePerformanceChange(),
    };
  }

  double _calculatePerformanceChange() {
    if (widget.quizType == QuizType.battle) {
      int pastWins = 0;
      for (var quiz in pastQuizzes) {
        if ((quiz["score"] as int) > (quiz["opponentScore"] as int)) {
          pastWins++;
        }
      }
      double pastWinRate =
          pastQuizzes.isEmpty ? 0 : (pastWins / pastQuizzes.length * 100);
      double currentWinRate = widget.won! ? 100 : 0;
      return currentWinRate - pastWinRate;
    } else {
      // For in-app quizzes, calculate improvement in overall performance
      // FIX: Convert the 'int' value from the map to a 'double'.
      double currentPerformance = (quizAnalytics["accuracy"] as int).toDouble();
      double pastAvgPerformance =
          pastQuizzes.isNotEmpty
              ? pastQuizzes
                      .map((q) => q["accuracy"] as int)
                      .reduce((a, b) => a + b) /
                  pastQuizzes.length
              : currentPerformance;
      return currentPerformance - pastAvgPerformance;
    }
  }

  void _generateImprovementSuggestions() {
    improvements = [];

    if (isQuizAbandoned) {
      improvements.add({
        "title": "Quiz Completion",
        "description":
            widget.quizType == QuizType.battle
                ? "You left the battle early. Try to answer all questions to maximize your score."
                : "You left the quiz early. Try to complete all questions even if you're unsure.",
        "icon": Icons.warning_amber,
      });
    }

    if (quizAnalytics["accuracy"] < 70) {
      improvements.add({
        "title": "Focus on Accuracy",
        "description":
            widget.quizType == QuizType.battle
                ? "Your accuracy is below 70%. Study the fundamentals to improve your battle performance."
                : "Your accuracy is below 70%. Review the topic thoroughly before attempting more quizzes.",
        "icon": Icons.gps_fixed,
      });
    }

    if (quizAnalytics["avgTimePerQuestion"] > 15) {
      improvements.add({
        "title": "Improve Speed",
        "description":
            widget.quizType == QuizType.battle
                ? "You're taking too long per question. Practice quick decision making for battles."
                : "You're taking more than 15 seconds per question. Practice time management.",
        "icon": Icons.timer,
      });
    }

    if (quizAnalytics["avgTimePerQuestion"] > 0 &&
        quizAnalytics["avgTimePerQuestion"] < 3) {
      improvements.add({
        "title": "Take Your Time",
        "description":
            "You're answering very quickly. Consider reading questions more carefully.",
        "icon": Icons.slow_motion_video,
      });
    }

    if (quizAnalytics["unanswered"] > 0) {
      improvements.add({
        "title": "Answer All Questions",
        "description":
            "You left ${quizAnalytics["unanswered"]} questions unanswered. ${widget.quizType == QuizType.battle ? "Every answer counts in battle!" : "Making an educated guess is better than no answer."}",
        "icon": Icons.help_outline,
      });
    }

    if (widget.score == 0) {
      improvements.add({
        "title": "Back to Basics",
        "description":
            widget.quizType == QuizType.battle
                ? "Consider practicing with study mode before entering battles."
                : "Review fundamental concepts before attempting more quizzes.",
        "icon": Icons.school,
      });
    }

    if (widget.quizType == QuizType.inAppQuiz &&
        widget.inAppQuestions != null &&
        widget.inAppQuestions!.isNotEmpty) {
      double avgDifficulty =
          widget.inAppQuestions!
              .map((q) => q.difficulty)
              .reduce((a, b) => a + b) /
          widget.inAppQuestions!.length;

      if (avgDifficulty > 0.7 && quizAnalytics["accuracy"] < 60) {
        improvements.add({
          "title": "Challenge Level",
          "description":
              "This was a difficult quiz. Try easier topics first to build confidence.",
          "icon": Icons.trending_down,
        });
      }
    }

    if (improvements.isEmpty) {
      improvements.add({
        "title":
            widget.quizType == QuizType.battle
                ? "Battle Champion!"
                : "Excellent Performance!",
        "description":
            widget.quizType == QuizType.battle
                ? "You're dominating the battles! Keep up the great work!"
                : "You're mastering the material! Keep practicing to maintain excellence.",
        "icon": Icons.emoji_events,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BBColors.lightGrayBG,
      appBar: AppBar(
        backgroundColor: BBColors.lightGrayBG,
        title: BBText(
          data:
              widget.quizType == QuizType.battle
                  ? "Battle Report Card"
                  : "${widget.quizTitle ?? 'Quiz'} Report",
          style: context.textStyle.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            context.read<StudentBloc>().add(StudentFetchData());
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              ReportCardPDFGenerator.generatePDF(
                score: widget.score,
                opponentScore: widget.opponentScore ?? 100,
                won: widget.won ?? (quizAnalytics["accuracy"] >= 70),
                questions: widget.questions ?? [],
                userAnswers: widget.userAnswers,
                timeSpent: widget.timeSpent,
                quizAnalytics: quizAnalytics,
                questionAnalysis: questionAnalysis,
                performanceMetrics: performanceMetrics,
                improvements: improvements,
                autoOpen: true,
                shareFile: false,
              );
            },
            icon: const Icon(Icons.download),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ReportCardPDFGenerator.generatePDF(
                score: widget.score,
                opponentScore: widget.opponentScore ?? 100,
                won: widget.won ?? (quizAnalytics["accuracy"] >= 70),
                questions: widget.questions ?? [],
                userAnswers: widget.userAnswers,
                timeSpent: widget.timeSpent,
                quizAnalytics: quizAnalytics,
                questionAnalysis: questionAnalysis,
                performanceMetrics: performanceMetrics,
                improvements: improvements,
                autoOpen: false,
                shareFile: true,
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQuizSummary(),
                const SizedBox(height: 20),
                _buildQuizStatCards(),
                const SizedBox(height: 16),
                _buildExpandableSection(
                  title: 'Question Analysis',
                  isExpanded: _questionsExpanded,
                  onToggle:
                      () => setState(
                        () => _questionsExpanded = !_questionsExpanded,
                      ),
                  child: _buildQuestionAnalysis(),
                ),
                const SizedBox(height: 16),
                _buildExpandableSection(
                  title: 'Performance Metrics',
                  isExpanded: _performanceExpanded,
                  onToggle:
                      () => setState(
                        () => _performanceExpanded = !_performanceExpanded,
                      ),
                  child: _buildPerformanceMetrics(),
                ),
                if (widget.quizType == QuizType.battle) ...[
                  const SizedBox(height: 16),
                  _buildExpandableSection(
                    title: 'Battle History',
                    isExpanded: _comparisonExpanded,
                    onToggle:
                        () => setState(
                          () => _comparisonExpanded = !_comparisonExpanded,
                        ),
                    child: _buildComparisonChart(),
                  ),
                ],
                const SizedBox(height: 16),
                _buildExpandableSection(
                  title: 'Improvement Suggestions',
                  isExpanded: _improvementsExpanded,
                  onToggle:
                      () => setState(
                        () => _improvementsExpanded = !_improvementsExpanded,
                      ),
                  child: _buildImprovementSuggestions(),
                ),
                const SizedBox(height: 20),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuizSummary() {
    String resultText;
    Color resultColor;
    IconData resultIcon;

    if (widget.quizType == QuizType.battle) {
      resultText = widget.won! ? "Victory!" : "Better Luck Next Time";
      resultColor = widget.won! ? Colors.green : Colors.red;
      resultIcon =
          widget.won! ? Icons.emoji_events : Icons.sentiment_dissatisfied;
    } else {
      double percentage =
          totalQuestionsCount > 0
              ? (quizAnalytics["correctAnswers"] / totalQuestionsCount * 100)
              : 0.0;
      if (percentage >= 80) {
        resultText = "Excellent Work!";
        resultColor = Colors.green;
        resultIcon = Icons.emoji_events;
      } else if (percentage >= 60) {
        resultText = "Good Job!";
        resultColor = Colors.blue;
        resultIcon = Icons.thumb_up;
      } else {
        resultText = "Keep Trying!";
        resultColor = Colors.orange;
        resultIcon = Icons.school;
      }
    }

    if (isQuizAbandoned) {
      resultText = "Quiz Incomplete";
      resultColor = Colors.red;
      resultIcon = Icons.warning_amber;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: resultColor.withOpacity(0.15),
                  border: Border.all(color: resultColor, width: 2),
                ),
                child: Center(
                  child: Icon(resultIcon, size: 30, color: resultColor),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BBText(
                      data: resultText,
                      style: context.textStyle.titleMedium?.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: resultColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    BBText(
                      data:
                          "${widget.quizType == QuizType.battle ? 'Battle' : 'Quiz'} completed on ${quizAnalytics['date']}",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    if (widget.quizType == QuizType.inAppQuiz &&
                        widget.topicKey != null)
                      BBText(
                        data: "Topic: ${widget.topicKey!.split('::').last}",
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: BBColors.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: BBColors.primaryColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildScoreItem(
                  "Your Score",
                  widget.score.toString(),
                  BBColors.primaryColor,
                ),
                _buildDivider(),
                if (widget.quizType == QuizType.battle)
                  _buildScoreItem(
                    "Opponent",
                    widget.opponentScore.toString(),
                    Colors.red,
                  )
                else
                  _buildScoreItem(
                    "Correct",
                    "${quizAnalytics['correctAnswers']}/$totalQuestionsCount",
                    Colors.green,
                  ),
                _buildDivider(),
                _buildScoreItem(
                  "Time",
                  widget.timeSpent <= 0
                      ? "0:00"
                      : "${(widget.timeSpent ~/ 60).toString().padLeft(2, '0')}:${(widget.timeSpent % 60).toString().padLeft(2, '0')}",
                  Colors.orange,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionAnalysis() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          for (int i = 0; i < questionAnalysis.length; i++)
            _buildQuestionItem(questionAnalysis[i], i),
        ],
      ),
    );
  }

  Widget _buildQuestionItem(Map<String, dynamic> question, int index) {
    final isCorrect = question['isCorrect'] as bool;
    final isUnanswered = question['isUnanswered'] as bool;
    final explanation = question['explanation'] as String?;

    Color statusColor =
        isCorrect ? Colors.green : (isUnanswered ? Colors.orange : Colors.red);
    IconData statusIcon =
        isCorrect
            ? Icons.check_circle
            : (isUnanswered ? Icons.help : Icons.cancel);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: BBText(
                    data: "${index + 1}",
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: BBText(
                  data: question['question'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
              Icon(statusIcon, color: statusColor, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BBText(
                      data: "Your Answer:",
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    BBText(
                      data: question['userAnswer'] as String,
                      style: TextStyle(
                        fontWeight:
                            isUnanswered ? FontWeight.normal : FontWeight.w500,
                        color:
                            isUnanswered
                                ? Colors.grey
                                : (isCorrect
                                    ? Colors.green[700]
                                    : Colors.red[700]),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isCorrect)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BBText(
                        data: "Correct Answer:",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      BBText(
                        data: question['correctAnswer'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (explanation != null && explanation.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb, size: 16, color: Colors.blue[700]),
                      const SizedBox(width: 4),
                      BBText(
                        data: "Explanation:",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  BBText(
                    data: explanation,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[800],
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getDifficultyColor(
                    question['difficultyLevel'] as String,
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _getDifficultyColor(
                      question['difficultyLevel'] as String,
                    ).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: BBText(
                  data: question['difficultyLevel'] as String,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: _getDifficultyColor(
                      question['difficultyLevel'] as String,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreItem(String label, String value, Color color) {
    return Column(
      children: [
        BBText(
          data: label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        BBText(
          data: value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 30, width: 1, color: Colors.grey.withOpacity(0.3));
  }

  Widget _buildQuizStatCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Accuracy',
            value: "${quizAnalytics['accuracy']}%",
            icon: Icons.check_circle_outline,
            color: _getAccuracyColor(quizAnalytics['accuracy']),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: widget.quizType == QuizType.battle ? 'Correct' : 'Score',
            value:
                widget.quizType == QuizType.battle
                    ? "${quizAnalytics['correctAnswers']}/${quizAnalytics['totalQuestions']}"
                    : "${quizAnalytics['correctAnswers']}/$totalQuestionsCount",
            icon: Icons.thumb_up_alt_outlined,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Avg Time',
            value: "${quizAnalytics['avgTimePerQuestion']}s",
            icon: Icons.timer_outlined,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Color _getAccuracyColor(int accuracy) {
    if (accuracy >= 80) return Colors.green;
    if (accuracy >= 60) return Colors.orange;
    return Colors.red;
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          BBText(
            data: value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: BBColors.black,
            ),
          ),
          const SizedBox(height: 4),
          BBText(
            data: title,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            splashColor: Colors.transparent,
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: BBColors.black,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: BBColors.primaryColor,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) child,
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case "Easy":
        return Colors.green;
      case "Medium":
        return Colors.orange;
      case "Hard":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildPerformanceMetrics() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPerformanceProgressBar(
            "Accuracy",
            quizAnalytics['accuracy'],
            performanceMetrics['accuracyChange'],
            100,
            Icons.check_circle_outline,
          ),
          const SizedBox(height: 16),
          _buildPerformanceProgressBar(
            "Speed (sec/question)",
            quizAnalytics['avgTimePerQuestion'],
            -performanceMetrics['speedChange'],
            widget.quizType == QuizType.battle ? 15 : 30,
            Icons.speed,
            invertProgress: true,
          ),
          const SizedBox(height: 16),
          _buildPerformanceProgressBar(
            "Score",
            widget.score,
            performanceMetrics['scoreChange'],
            widget.quizType == QuizType.battle ? 100 : 500,
            Icons.leaderboard,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceProgressBar(
    String label,
    // FIX: Use 'num' for better type safety instead of 'dynamic'
    num value,
    num change,
    int maxValue,
    IconData icon, {
    bool invertProgress = false,
  }) {
    double progressValue = (value / maxValue).clamp(0.0, 1.0);
    if (invertProgress) progressValue = 1 - progressValue;

    Color progressColor =
        progressValue > 0.7
            ? Colors.green
            : (progressValue > 0.4 ? Colors.orange : Colors.red);

    if (invertProgress) {
      progressColor =
          progressValue > 0.7
              ? Colors.green
              : (progressValue > 0.4 ? Colors.orange : Colors.red);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: progressColor),
            const SizedBox(width: 8),
            BBText(
              data: label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
            const Spacer(),
            BBText(
              data: value.toString() + (label == "Accuracy" ? "%" : ""),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: progressColor,
              ),
            ),
            const SizedBox(width: 6),
            if (change != 0) _buildChangeIndicator(change),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progressValue,
            minHeight: 10,
            backgroundColor: Colors.grey.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ),
      ],
    );
  }

  // FIX: Use 'num' for better type safety
  Widget _buildChangeIndicator(num change) {
    bool isPositive = change > 0;
    num displayChange = change;
    if (change is double) {
      displayChange = (change * 10).round() / 10;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color:
            isPositive
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              isPositive
                  ? Colors.green.withOpacity(0.3)
                  : Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            size: 12,
            color: isPositive ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 2),
          BBText(
            data: "${isPositive ? '+' : ''}${displayChange.toString()}",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isPositive ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonChart() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BBText(
            data: "Your Performance Over Time",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BBText(
                      data: "Score Trend",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: BBColors.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        BBText(
                          data: "Your Score",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (widget.quizType == QuizType.battle) ...[
                          const SizedBox(width: 12),
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          BBText(
                            data: "Opponent",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _buildChartBars(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildQuizHistoryList(),
        ],
      ),
    );
  }

  List<Widget> _buildChartBars() {
    List<Widget> bars = [];
    for (int i = 0; i < pastQuizzes.length; i++) {
      var quiz = pastQuizzes[i];
      bars.add(
        _buildChartBar(
          quiz['score'] as int,
          widget.quizType == QuizType.battle ? quiz['opponentScore'] as int : 0,
          quiz['date'] as String,
          false,
        ),
      );
    }
    bars.add(
      _buildChartBar(
        widget.score,
        widget.opponentScore ?? 0,
        quizAnalytics['date'] as String,
        true,
      ),
    );
    return bars;
  }

  Widget _buildChartBar(
    int userScore,
    int opponentScore,
    String date,
    bool isCurrent,
  ) {
    double maxHeight = 120;
    double userHeight = (userScore /
            (widget.quizType == QuizType.battle ? 100 : 500) *
            maxHeight)
        .clamp(10, maxHeight);
    double opponentHeight =
        widget.quizType == QuizType.battle
            ? (opponentScore / 100 * maxHeight).clamp(10, maxHeight)
            : 0;

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 12,
                height: userHeight,
                decoration: BoxDecoration(
                  color:
                      isCurrent
                          ? BBColors.primaryColor.withOpacity(0.8)
                          : BBColors.primaryColor.withOpacity(0.5),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                  border:
                      isCurrent
                          ? Border.all(color: BBColors.primaryColor, width: 2)
                          : null,
                ),
              ),
              if (widget.quizType == QuizType.battle) ...[
                const SizedBox(width: 4),
                Container(
                  width: 12,
                  height: opponentHeight,
                  decoration: BoxDecoration(
                    color:
                        isCurrent
                            ? Colors.red.withOpacity(0.8)
                            : Colors.red.withOpacity(0.5),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6),
                    ),
                    border:
                        isCurrent
                            ? Border.all(color: Colors.red, width: 2)
                            : null,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          BBText(
            data: date.split(',')[0],
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuizHistoryList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BBText(
          data:
              widget.quizType == QuizType.battle
                  ? "Battle History"
                  : "Quiz History",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        ...pastQuizzes.map((quiz) => _buildQuizHistoryItem(quiz)),
        _buildQuizHistoryItem({
          'date': quizAnalytics['date'],
          'score': widget.score,
          'opponentScore': widget.opponentScore ?? 0,
          'accuracy': quizAnalytics['accuracy'],
          'avgTimePerQuestion': quizAnalytics['avgTimePerQuestion'],
        }, isCurrent: true),
      ],
    );
  }

  Widget _buildQuizHistoryItem(
    Map<String, dynamic> quiz, {
    bool isCurrent = false,
  }) {
    bool won =
        widget.quizType == QuizType.battle
            ? (quiz['score'] as int) > (quiz['opponentScore'] as int)
            : (quiz['accuracy'] as int) >= 70;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            isCurrent
                ? BBColors.primaryColor.withOpacity(0.05)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              isCurrent
                  ? BBColors.primaryColor.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  won
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
            ),
            child: Icon(
              won ? Icons.check : Icons.close,
              color: won ? Colors.green : Colors.red,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    BBText(
                      data: quiz['date'] as String,
                      style: TextStyle(
                        fontWeight:
                            isCurrent ? FontWeight.bold : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    if (isCurrent) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: BBColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const BBText(
                          data: "Current",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: BBColors.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    BBText(
                      data:
                          widget.quizType == QuizType.battle
                              ? "Score: ${quiz['score']} vs ${quiz['opponentScore']}"
                              : "Score: ${quiz['score']}",
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const Spacer(),
                    BBText(
                      data: "${quiz['accuracy']}% accuracy",
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImprovementSuggestions() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children:
            improvements
                .map((improvement) => _buildImprovementItem(improvement))
                .toList(),
      ),
    );
  }

  Widget _buildImprovementItem(Map<String, dynamic> improvement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BBColors.primaryColor.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: BBColors.primaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: BBColors.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              improvement['icon'] as IconData,
              color: BBColors.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BBText(
                  data: improvement['title'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: BBColors.black,
                  ),
                ),
                const SizedBox(height: 4),
                BBText(
                  data: improvement['description'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        icon: const Icon(Icons.home, color: Colors.grey),
        label: const BBText(
          data: "Back to Home",
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
