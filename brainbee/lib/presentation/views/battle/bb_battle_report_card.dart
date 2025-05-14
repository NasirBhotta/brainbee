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

  @override
  void initState() {
    super.initState();
    _generateQuizAnalytics();
    _mockPastQuizData();
    _analyzeQuestions();
    _generatePerformanceMetrics();
    _generateImprovementSuggestions();
  }

  void _generateQuizAnalytics() {
    // Calculate analytics for this specific quiz
    int correctAnswers = 0;
    int incorrectAnswers = 0;
    int unanswered = 0;

    for (int i = 0; i < widget.questions.length; i++) {
      if (widget.userAnswers[i] == null) {
        unanswered++;
      } else if (widget.userAnswers[i] ==
          widget.questions[i].correctOptionIndex) {
        correctAnswers++;
      } else {
        incorrectAnswers++;
      }
    }

    // Calculate average time per question
    int avgTimePerQuestion = widget.timeSpent ~/ widget.questions.length;

    quizAnalytics = {
      "date": DateFormat('MMM d, yyyy').format(DateTime.now()),
      "totalQuestions": widget.questions.length,
      "correctAnswers": correctAnswers,
      "incorrectAnswers": incorrectAnswers,
      "unanswered": unanswered,
      "accuracy":
          widget.questions.isEmpty
              ? 0
              : (correctAnswers / widget.questions.length * 100).round(),
      "score": widget.score,
      "opponentScore": widget.opponentScore,
      "result": widget.won ? "Won" : "Lost",
      "timeSpent": widget.timeSpent,
      "avgTimePerQuestion": avgTimePerQuestion,
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
      bool isCorrect =
          widget.userAnswers[index] ==
          widget.questions[index].correctOptionIndex;
      bool isUnanswered = widget.userAnswers[index] == null;

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
                : widget.questions[index].options[widget.userAnswers[index]!],
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

    // Check for unanswered questions
    if (quizAnalytics["unanswered"] > 0) {
      improvements.add({
        "title": "Answer All Questions",
        "description":
            "You left ${quizAnalytics["unanswered"]} questions unanswered. Remember, making an educated guess is better than no answer.",
        "icon": Icons.help_outline,
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
    int scienceQuestions =
        widget.questions.length ~/ 3; // Assuming 1/3 are science
    int incorrectScience = 0;

    for (int i = 0; i < scienceQuestions; i++) {
      if (widget.userAnswers[i] != widget.questions[i].correctOptionIndex) {
        incorrectScience++;
      }
    }

    if (incorrectScience > scienceQuestions / 2) {
      improvements.add({
        "title": "Review Science Concepts",
        "description":
            "You struggled with science questions. Focus on reviewing fundamental scientific principles.",
        "icon": Icons.science,
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
          data: "Quiz Report Card",
          style: context.textStyle.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.download)),
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
                        : Icons.sentiment_dissatisfied,
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
                      data: widget.won ? "Victory!" : "Better Luck Next Time",
                      style: context.textStyle.titleMedium?.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: widget.won ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 4),
                    BBText(
                      data: "Quiz completed on ${quizAnalytics['date']}",
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
                  "${(widget.timeSpent ~/ 60).toString().padLeft(2, '0')}:${(widget.timeSpent % 60).toString().padLeft(2, '0')}",
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
            -performanceMetrics['speedChange'], // Negative for speed because lower is better
            15, // Max 15 seconds
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
      // For inverted metrics (like speed), invert the color meaning
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
      // Round to one decimal place for display
      change = (change * 10).round() / 10;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: (isPositive ? Colors.green : Colors.red).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.arrow_upward : Icons.arrow_downward,
            size: 10,
            color: isPositive ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 2),
          BBText(
            data: "${isPositive ? '+' : ''}$change",
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
        children: [
          if (pastQuizzes.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: BBText(
                  data: "No past quizzes to compare with",
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            )
          else
            Column(
              children: [
                Container(
                  height: context.screenHeight * 0.25,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: BBColors.primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _buildSimpleBarChart(),
                ),
                const SizedBox(height: 16),
                _buildComparisonTable(),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSimpleBarChart() {
    // A simple visual representation of quiz scores
    List<Map<String, dynamic>> chartData = [
      {
        "label": "Current",
        "score": widget.score,
        "color": BBColors.primaryColor,
      },
      ...pastQuizzes
          .take(3)
          .map(
            (quiz) => {
              "label": "Quiz ${quiz['id']}",
              "score": quiz['score'],
              "color": Colors.grey.shade400,
            },
          ),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children:
          chartData.map((item) {
            return Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 800),
                    width: 40,
                    height: (item["score"] as int) * 1.5,
                    decoration: BoxDecoration(
                      color: item["color"] as Color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  BBText(
                    data: item["label"] as String,
                    style: const TextStyle(fontSize: 10),
                  ),
                  BBText(
                    data: "${item["score"]}",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildComparisonTable() {
    return Table(
      border: TableBorder.all(
        color: Colors.grey.withOpacity(0.3),
        width: 1,
        borderRadius: BorderRadius.circular(8),
      ),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(1),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: BBColors.lightGrayBG,
            borderRadius: BorderRadius.circular(8),
          ),
          children: [
            _buildTableHeader("Quiz"),
            _buildTableHeader("Score"),
            _buildTableHeader("Accuracy"),
            _buildTableHeader("Time/Q"),
          ],
        ),
        TableRow(
          decoration: const BoxDecoration(color: Colors.white),
          children: [
            _buildTableCell("Current", isBold: true),
            _buildTableCell("${widget.score}", isBold: true),
            _buildTableCell("${quizAnalytics['accuracy']}%", isBold: true),
            _buildTableCell(
              "${quizAnalytics['avgTimePerQuestion']}s",
              isBold: true,
            ),
          ],
        ),
        ...pastQuizzes
            .take(3)
            .map(
              (quiz) => TableRow(
                decoration: const BoxDecoration(color: Colors.white),
                children: [
                  _buildTableCell("${quiz['date']}"),
                  _buildTableCell("${quiz['score']}"),
                  _buildTableCell("${quiz['accuracy']}%"),
                  _buildTableCell("${quiz['avgTimePerQuestion']}s"),
                ],
              ),
            ),
      ],
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: BBText(
        data: text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: BBText(
        data: text,
        style: TextStyle(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
          color: isBold ? BBColors.primaryColor : BBColors.black,
        ),
        textAlign: TextAlign.center,
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BBColors.primaryColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: BBColors.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              improvement["icon"] as IconData,
              color: BBColors.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BBText(
                  data: improvement["title"] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                BBText(
                  data: improvement["description"] as String,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // Navigate to practice screen
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: BBColors.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.refresh, size: 20),
                SizedBox(width: 8),
                BBText(
                  data: "Try Again",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // Navigate to home screen
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: BBColors.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: BBColors.primaryColor),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.home, size: 20),
                SizedBox(width: 8),
                BBText(
                  data: "Home",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
