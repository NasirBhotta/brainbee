import 'package:brainbee/presentation/views/learn/battle/bb_reportcard_pdf.dart';
import 'package:flutter/material.dart';
import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_screen_extension.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/core/utils/bb_textTheme_extention.dart';
import 'package:brainbee/core/models/bb_question.dart';
import 'package:intl/intl.dart';

class BBBattleReportCardScreen extends StatefulWidget {
  final int score;
  final int opponentScore;
  final bool won;
  final List<Question> questions;
  final List<int?> userAnswers;
  final int timeSpent; // Total seconds spent on the quiz

  const BBBattleReportCardScreen({
    super.key,
    required this.score,
    required this.opponentScore,
    required this.won,
    required this.questions,
    required this.userAnswers,
    required this.timeSpent,
  });

  @override
  State<BBBattleReportCardScreen> createState() =>
      _BBBattleReportCardScreenState();
}

class _BBBattleReportCardScreenState extends State<BBBattleReportCardScreen> {
  bool _questionsExpanded = true;
  bool _performanceExpanded = true;
  bool _improvementsExpanded = true;
  bool _comparisonExpanded = false;

  late Map<String, dynamic> quizAnalytics = {};
  late List<Map<String, dynamic>> pastQuizzes = [];
  late List<Map<String, dynamic>> questionAnalysis = [];
  late Map<String, dynamic> performanceMetrics = {};
  late List<Map<String, dynamic>> improvements = [];

  // Added properties to handle edge cases
  late bool isQuizAbandoned;
  late List<int?> normalizedUserAnswers;

  @override
  void initState() {
    super.initState();
    _handleEdgeCases();
    _generateQuizAnalytics();
    _mockPastQuizData();
    _analyzeQuestions();
    _generatePerformanceMetrics();
    _generateImprovementSuggestions();
  }

  void _handleEdgeCases() {
    // Check if quiz was abandoned (empty answers array or significantly fewer answers than questions)
    isQuizAbandoned =
        widget.userAnswers.isEmpty ||
        widget.userAnswers.length < widget.questions.length;

    // Normalize user answers to match questions length
    normalizedUserAnswers = List<int?>.filled(widget.questions.length, null);

    // Copy existing answers if any
    for (
      int i = 0;
      i < widget.userAnswers.length && i < widget.questions.length;
      i++
    ) {
      normalizedUserAnswers[i] = widget.userAnswers[i];
    }
  }

  void _generateQuizAnalytics() {
    // Calculate analytics for this specific quiz
    int correctAnswers = 0;
    int incorrectAnswers = 0;
    int unanswered = 0;

    for (int i = 0; i < widget.questions.length; i++) {
      // Use normalized answers
      int? userAnswer =
          i < normalizedUserAnswers.length ? normalizedUserAnswers[i] : null;

      if (userAnswer == null) {
        unanswered++;
      } else if (userAnswer == widget.questions[i].correctOptionIndex) {
        correctAnswers++;
      } else {
        incorrectAnswers++;
      }
    }

    // Calculate average time per question - handle zero time case
    int avgTimePerQuestion =
        widget.questions.isEmpty
            ? 0
            : (widget.timeSpent <= 0
                ? 0
                : widget.timeSpent ~/ widget.questions.length);

    // Handle accuracy calculation for edge cases
    double accuracyPercentage = 0;
    if (widget.questions.isNotEmpty) {
      accuracyPercentage = (correctAnswers / widget.questions.length * 100);
    }

    quizAnalytics = {
      "date": DateFormat('MMM d, yyyy').format(DateTime.now()),
      "totalQuestions": widget.questions.length,
      "correctAnswers": correctAnswers,
      "incorrectAnswers": incorrectAnswers,
      "unanswered": unanswered,
      "accuracy": accuracyPercentage.round(),
      "score": widget.score,
      "opponentScore": widget.opponentScore,
      "result": widget.won ? "Won" : "Lost",
      "timeSpent": widget.timeSpent,
      "avgTimePerQuestion": avgTimePerQuestion,
      "isAbandoned": isQuizAbandoned,
    };
  }

  void _mockPastQuizData() {
    // Mock data for past quizzes - in production, this would come from backend
    pastQuizzes = [
      {
        "id": 1,
        "date": "May 10, 2025",
        "score": 85,
        "opponentScore": 72,
        "accuracy": 80,
        "avgTimePerQuestion": 8,
      },
      {
        "id": 2,
        "date": "May 8, 2025",
        "score": 63,
        "opponentScore": 78,
        "accuracy": 60,
        "avgTimePerQuestion": 10,
      },
      {
        "id": 3,
        "date": "May 5, 2025",
        "score": 92,
        "opponentScore": 85,
        "accuracy": 90,
        "avgTimePerQuestion": 7,
      },
    ];
  }

  void _analyzeQuestions() {
    // Create detailed analysis for each question
    questionAnalysis = List.generate(widget.questions.length, (index) {
      // Use normalized answers
      int? userAnswer =
          index < normalizedUserAnswers.length
              ? normalizedUserAnswers[index]
              : null;
      bool isCorrect =
          userAnswer != null &&
          userAnswer == widget.questions[index].correctOptionIndex;
      bool isUnanswered = userAnswer == null;

      String difficultyLevel = "Medium";
      if (index % 3 == 0) difficultyLevel = "Easy";
      if (index % 3 == 2) difficultyLevel = "Hard";

      return {
        "questionNumber": index + 1,
        "question": widget.questions[index].text,
        "correctAnswer":
            widget.questions[index].options[widget
                .questions[index]
                .correctOptionIndex],
        "userAnswer":
            isUnanswered
                ? "Unanswered"
                : widget.questions[index].options[userAnswer],
        "isCorrect": isCorrect,
        "isUnanswered": isUnanswered,
        "difficultyLevel": difficultyLevel,
      };
    });
  }

  void _generatePerformanceMetrics() {
    // Calculate performance metrics compared to past quizzes
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
      "speedChange":
          avgPastTime -
          quizAnalytics["avgTimePerQuestion"], // Positive means improvement
      "scoreChange":
          widget.score -
          (pastQuizzes.isNotEmpty
              ? pastQuizzes[0]["score"] as int
              : widget.score),
      "winRateChange": _calculateWinRateChange(),
    };
  }

  double _calculateWinRateChange() {
    // Calculate win rate change from past quizzes
    int pastWins = 0;
    for (var quiz in pastQuizzes) {
      if ((quiz["score"] as int) > (quiz["opponentScore"] as int)) {
        pastWins++;
      }
    }

    double pastWinRate =
        pastQuizzes.isEmpty ? 0 : (pastWins / pastQuizzes.length * 100);
    double currentWinRate = widget.won ? 100 : 0;

    return currentWinRate - pastWinRate;
  }

  void _generateImprovementSuggestions() {
    // Generate improvement suggestions based on quiz performance
    improvements = [];

    // Special handling for abandoned quiz
    if (isQuizAbandoned) {
      improvements.add({
        "title": "Quiz Completion",
        "description":
            "You left the quiz early. Try to complete all questions even if you're unsure - partial credit is better than no attempt.",
        "icon": Icons.warning_amber,
      });
    }

    // Check for accuracy issues
    if (quizAnalytics["accuracy"] < 70) {
      improvements.add({
        "title": "Focus on Accuracy",
        "description":
            "Your accuracy is below 70%. Try to understand concepts more thoroughly before answering.",
        "icon": Icons.gpp_bad,
      });
    }

    // Check for time management issues
    if (quizAnalytics["avgTimePerQuestion"] > 10) {
      improvements.add({
        "title": "Improve Speed",
        "description":
            "You're taking more than 10 seconds per question. Practice quick decision making and time management.",
        "icon": Icons.timer,
      });
    }

    // Check for time management issues - too fast (might indicate rushing)
    if (quizAnalytics["avgTimePerQuestion"] > 0 &&
        quizAnalytics["avgTimePerQuestion"] < 3) {
      improvements.add({
        "title": "Take Your Time",
        "description":
            "You're answering very quickly. Consider reading questions more carefully to improve accuracy.",
        "icon": Icons.slow_motion_video,
      });
    }

    // Check for unanswered questions
    if (quizAnalytics["unanswered"] > 0) {
      improvements.add({
        "title": "Answer All Questions",
        "description":
            "You left ${quizAnalytics["unanswered"]} questions unanswered. Remember, making an educated guess is better than no answer.",
        "icon": Icons.help_outline,
      });
    }

    // Handle zero score case
    if (widget.score == 0) {
      improvements.add({
        "title": "Back to Basics",
        "description":
            "Consider reviewing fundamental concepts before attempting more quizzes. Practice makes perfect!",
        "icon": Icons.school,
      });
    }

    // If performing well, provide positive feedback
    if (improvements.isEmpty) {
      improvements.add({
        "title": "Excellent Performance!",
        "description":
            "You're doing great! Keep practicing to maintain your high level of performance.",
        "icon": Icons.emoji_events,
      });
    }

    // Add subject-specific suggestion based on questions
    if (widget.questions.isNotEmpty) {
      int scienceQuestions =
          widget.questions.length ~/ 3; // Assuming 1/3 are science
      int incorrectScience = 0;

      for (
        int i = 0;
        i < scienceQuestions && i < normalizedUserAnswers.length;
        i++
      ) {
        if (normalizedUserAnswers[i] == null ||
            normalizedUserAnswers[i] !=
                widget.questions[i].correctOptionIndex) {
          incorrectScience++;
        }
      }

      if (scienceQuestions > 0 && incorrectScience > scienceQuestions / 2) {
        improvements.add({
          "title": "Review Science Concepts",
          "description":
              "You struggled with science questions. Focus on reviewing fundamental scientific principles.",
          "icon": Icons.science,
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BBColors.lightGrayBG,
      appBar: AppBar(
        backgroundColor: BBColors.lightGrayBG,
        title: BBText(
          data: "Quiz Report Card",
          style: context.textStyle.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
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
                opponentScore: widget.opponentScore,
                won: widget.won,
                questions: widget.questions,
                userAnswers: widget.userAnswers,
                timeSpent: widget.timeSpent,
                quizAnalytics: quizAnalytics,
                questionAnalysis: questionAnalysis,
                performanceMetrics: performanceMetrics,
                improvements: improvements,
              );
            },
            icon: const Icon(Icons.download),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share functionality
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
                const SizedBox(height: 16),
                _buildExpandableSection(
                  title: 'Comparison with Past Quizzes',
                  isExpanded: _comparisonExpanded,
                  onToggle:
                      () => setState(
                        () => _comparisonExpanded = !_comparisonExpanded,
                      ),
                  child: _buildComparisonChart(),
                ),
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
                  color:
                      widget.won
                          ? Colors.green.withOpacity(0.15)
                          : Colors.red.withOpacity(0.15),
                  border: Border.all(
                    color: widget.won ? Colors.green : Colors.red,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    widget.won
                        ? Icons.emoji_events
                        : (isQuizAbandoned
                            ? Icons.warning_amber
                            : Icons.sentiment_dissatisfied),
                    size: 30,
                    color: widget.won ? Colors.green : Colors.red,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BBText(
                      data:
                          widget.won
                              ? "Victory!"
                              : (isQuizAbandoned
                                  ? "Quiz Incomplete"
                                  : "Better Luck Next Time"),
                      style: context.textStyle.titleMedium?.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: widget.won ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 4),
                    BBText(
                      data:
                          isQuizAbandoned
                              ? "Quiz ended early on ${quizAnalytics['date']}"
                              : "Quiz completed on ${quizAnalytics['date']}",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
                _buildScoreItem(
                  "Opponent",
                  widget.opponentScore.toString(),
                  Colors.red,
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
            title: 'Correct',
            value:
                "${quizAnalytics['correctAnswers']}/${quizAnalytics['totalQuestions']}",
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

  // ... (rest of the methods remain the same as in your original code)
  // I'm keeping the rest of the implementation unchanged to focus on the edge case fixes

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
            15,
            Icons.speed,
            invertProgress: true,
          ),
          const SizedBox(height: 16),
          _buildPerformanceProgressBar(
            "Score",
            widget.score,
            performanceMetrics['scoreChange'],
            100,
            Icons.leaderboard,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceProgressBar(
    String label,
    dynamic value,
    dynamic change,
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

  Widget _buildChangeIndicator(dynamic change) {
    bool isPositive = change > 0;
    if (change is double) {
      change = (change * 10).round() / 10;
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
            data: "${isPositive ? '+' : ''}${change.toString()}",
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

    // Add past quizzes data
    for (int i = 0; i < pastQuizzes.length; i++) {
      var quiz = pastQuizzes[i];
      bars.add(
        _buildChartBar(
          quiz['score'] as int,
          quiz['opponentScore'] as int,
          quiz['date'] as String,
          false,
        ),
      );
    }

    // Add current quiz
    bars.add(
      _buildChartBar(
        widget.score,
        widget.opponentScore,
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
    double userHeight = (userScore / 100 * maxHeight).clamp(10, maxHeight);
    double opponentHeight = (opponentScore / 100 * maxHeight).clamp(
      10,
      maxHeight,
    );

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
          ),
          const SizedBox(height: 8),
          BBText(
            data: date.split(',')[0], // Show only "May 10" part
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
          data: "Recent Quiz History",
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
          'opponentScore': widget.opponentScore,
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
    bool won = (quiz['score'] as int) > (quiz['opponentScore'] as int);

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
                          "Score: ${quiz['score']} vs ${quiz['opponentScore']}",
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
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigate to quiz practice
                },
                icon: const Icon(Icons.quiz, color: Colors.white),
                label: const BBText(
                  data: "Practice More",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: BBColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Navigate to battle arena
                },
                icon: const Icon(
                  Icons.sports_esports,
                  color: BBColors.primaryColor,
                ),
                label: const BBText(
                  data: "Battle Again",
                  style: TextStyle(
                    color: BBColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: BBColors.primaryColor),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pop(context);
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
        ),
      ],
    );
  }
}
