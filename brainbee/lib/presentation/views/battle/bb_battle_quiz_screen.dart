import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/models/bb_question.dart';
import 'package:brainbee/core/utils/bb_screen_extension.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/core/utils/bb_textTheme_extention.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class BBBattleQuizScreen extends StatefulWidget {
  const BBBattleQuizScreen({super.key});

  @override
  State<BBBattleQuizScreen> createState() => _BBBattleQuizScreenState();
}

class _BBBattleQuizScreenState extends State<BBBattleQuizScreen> {
  int currentQuestionIndex = 0;
  int? selectedOptionIndex;
  bool isAnswerSubmitted = false;
  bool isCorrectAnswer = false;
  int score = 0;
  int opponentScore = 0;

  int timeRemaining = 15;
  late Timer timer;

  final List<Question> questions = [
    Question(
      text: "What is the capital of France?",
      options: ["London", "Berlin", "Paris", "Madrid"],
      correctOptionIndex: 2,
    ),
    Question(
      text: "Which planet is known as the Red Planet?",
      options: ["Earth", "Mars", "Jupiter", "Venus"],
      correctOptionIndex: 1,
    ),
    Question(
      text: "What is the chemical symbol for Gold?",
      options: ["Go", "Gl", "Au", "Ag"],
      correctOptionIndex: 2,
    ),
    Question(
      text: "What is the largest mammal on Earth?",
      options: ["Elephant", "Blue Whale", "Giraffe", "Polar Bear"],
      correctOptionIndex: 1,
    ),
    Question(
      text: "What is the hardest natural substance on Earth?",
      options: ["Gold", "Iron", "Diamond", "Titanium"],
      correctOptionIndex: 2,
    ),
  ];

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (timeRemaining > 0) {
            timeRemaining--;
          } else {
            if (!isAnswerSubmitted) {
              submitAnswer(null);
            }
          }
        });
      }
    });
  }

  void resetTimerForNextQuestion() {
    timer.cancel();
    timeRemaining = 15;
    startTimer();
  }

  void submitAnswer(int? optionIndex) {
    if (isAnswerSubmitted) return;

    timer.cancel();

    setState(() {
      selectedOptionIndex = optionIndex;
      isAnswerSubmitted = true;

      final correctIndex = questions[currentQuestionIndex].correctOptionIndex;
      isCorrectAnswer = selectedOptionIndex == correctIndex;

      if (isCorrectAnswer) {
        int timeBonus = (timeRemaining / 15 * 50).round();
        score += 50 + timeBonus;
      }

      if (currentQuestionIndex < questions.length - 1) {
        if (DateTime.now().millisecondsSinceEpoch % 2 == 0) {
          int opponentTimeBonus =
              ((10 + (DateTime.now().millisecondsSinceEpoch % 5)) / 15 * 50)
                  .round();
          opponentScore += 50 + opponentTimeBonus;
        }
      }
    });

    if (currentQuestionIndex < questions.length - 1) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            currentQuestionIndex++;
            selectedOptionIndex = null;
            isAnswerSubmitted = false;
            isCorrectAnswer = false;
          });
          resetTimerForNextQuestion();
        }
      });
    } else {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _showResultDialog();
        }
      });
    }
  }

  void _showResultDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dismiss",
      barrierColor: Colors.black.withValues(alpha: 0.7),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Transform.scale(
                scale: Curves.easeOutBack.transform(animation.value),
                child: Opacity(opacity: animation.value, child: child),
              );
            },
            child: Material(
              color: Colors.transparent,
              elevation: 0,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: BBColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: const BoxDecoration(
                          color: BBColors.primaryColor,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned(
                              right: 15,
                              top: 0,
                              bottom: 0,
                              child: Icon(
                                Icons.emoji_events,
                                color: Colors.white.withValues(alpha: 0.2),
                                size: 40,
                              ),
                            ),
                            BBText(
                              data: "Battle Result",
                              style: context.textStyle.titleMedium?.copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 25, 24, 15),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 24,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    score > opponentScore
                                        ? Colors.green.withValues(alpha: 0.1)
                                        : score == opponentScore
                                        ? Colors.amber.withValues(alpha: 0.1)
                                        : Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                  color:
                                      score > opponentScore
                                          ? Colors.green.withValues(alpha: 0.3)
                                          : score == opponentScore
                                          ? Colors.amber.withValues(alpha: 0.3)
                                          : Colors.red.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: BBText(
                                data:
                                    score > opponentScore
                                        ? "You Win! 🏆"
                                        : score == opponentScore
                                        ? "It's a Tie!"
                                        : "You Lost! 😔",
                                style: context.textStyle.labelMedium?.copyWith(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      score > opponentScore
                                          ? Colors.green.shade700
                                          : score == opponentScore
                                          ? Colors.amber.shade700
                                          : Colors.red.shade700,
                                ),
                              ),
                            ),

                            const SizedBox(height: 25),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildEnhancedScoreCard(
                                  "Your Score",
                                  score,
                                  Colors.blue,
                                ),
                                Container(
                                  height: 70,
                                  width: 1,
                                  color: Colors.grey.withValues(alpha: 0.2),
                                ),
                                _buildEnhancedScoreCard(
                                  "Opponent",
                                  opponentScore,
                                  Colors.red,
                                ),
                              ],
                            ),

                            const SizedBox(height: 25),

                            Container(
                              width: double.infinity,
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    BBColors.primaryColor,
                                    BBColors.primaryColor.withValues(
                                      alpha: 0.8,
                                    ),
                                    BBColors.primaryColor.withValues(
                                      alpha: 0.9,
                                    ),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(50),
                                boxShadow: [
                                  BoxShadow(
                                    color: BBColors.primaryColor.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(50),
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  child: Center(
                                    child: BBText(
                                      data: "Done",
                                      style: context.textStyle.labelSmall
                                          ?.copyWith(
                                            fontSize: 16,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedScoreCard(String label, int scoreValue, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BBText(
          data: label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.1),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
          ),
          child: Center(
            child: BBText(
              data: scoreValue.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScoreCard(String label, int scoreValue, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          BBText(
            data: label,
            style: context.textStyle.labelMedium?.copyWith(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 5),
          BBText(
            data: scoreValue.toString(),
            style: context.textStyle.labelMedium?.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BBColors.lightGrayBG,
      appBar: AppBar(
        backgroundColor: BBColors.lightGrayBG,
        title: BBText(
          data: "Brain Battle",
          style: context.textStyle.titleMedium?.copyWith(color: BBColors.black),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    backgroundColor: BBColors.secondaryColor,
                    title: BBText(
                      data: "Quit Battle?",
                      style: context.textStyle.labelMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    content: BBText(
                      data:
                          "Are you sure you want to quit? You'll lose this battle.",
                      style: context.textStyle.labelMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: BBText(
                          data: "Cancel",
                          style: context.textStyle.labelMedium?.copyWith(
                            color: BBColors.primaryColor,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: BBColors.primaryColor,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: BBText(
                          data: "Quit",
                          style: context.textStyle.labelMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
            );
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProgressAndScores(),
              const SizedBox(height: 16),
              _buildTimerBar(),
              const SizedBox(height: 24),
              _buildQuestion(),
              const SizedBox(height: 24),
              _buildOptions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressAndScores() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: BBColors.secondaryColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: BBText(
            data: "Question ${currentQuestionIndex + 1}/${questions.length}",
            style: context.textStyle.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),

        Row(
          children: [
            _buildPlayerScore("You", score, Colors.blue),
            SizedBox(width: context.screenWidth * 0.08),
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,

                color: BBColors.secondaryColor,
              ),
              child: Center(
                child: BBText(
                  data: "VS",
                  style: context.textStyle.labelMedium?.copyWith(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            _buildPlayerScore("Opponent", opponentScore, Colors.red),
          ],
        ),
      ],
    );
  }

  Widget _buildPlayerScore(String label, int scoreValue, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        BBText(
          data: label,
          style: context.textStyle.labelMedium?.copyWith(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        BBText(
          data: scoreValue.toString(),

          style: context.textStyle.labelMedium?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTimerBar() {
    double progress = timeRemaining / 15;
    Color timerColor =
        progress > 0.5
            ? Colors.green
            : progress > 0.25
            ? Colors.orange
            : Colors.red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BBText(
              data: "Time Remaining:",
              style: context.textStyle.labelMedium?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            BBText(
              data: "$timeRemaining seconds",
              style: context.textStyle.labelMedium?.copyWith(
                color: timerColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(timerColor),
          minHeight: 7,
          borderRadius: BorderRadius.circular(10),
        ),
      ],
    );
  }

  Widget _buildQuestion() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [BBColors.primaryColor, BBColors.secondaryColor],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: BBText(
        data: questions[currentQuestionIndex].text,
        style: context.textStyle.labelMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildOptions() {
    return Expanded(
      child: ListView.builder(
        itemCount: questions[currentQuestionIndex].options.length,
        itemBuilder: (context, index) {
          final isSelected = selectedOptionIndex == index;
          final isCorrect =
              isAnswerSubmitted &&
              index == questions[currentQuestionIndex].correctOptionIndex;
          final isWrong =
              isAnswerSubmitted &&
              isSelected &&
              index != questions[currentQuestionIndex].correctOptionIndex;

          Color backgroundColor =
              isSelected
                  ? (isCorrect
                      ? Colors.green.withValues(alpha: 0.3)
                      : isWrong
                      ? Colors.red.withValues(alpha: 0.3)
                      : BBColors.primaryColor.withValues(alpha: 0.3))
                  : (isAnswerSubmitted && isCorrect
                      ? Colors.green.withValues(alpha: 0.3)
                      : Colors.white);

          Color borderColor =
              isSelected
                  ? (isCorrect
                      ? Colors.green
                      : isWrong
                      ? Colors.red
                      : BBColors.primaryColor)
                  : (isAnswerSubmitted && isCorrect
                      ? Colors.green
                      : Colors.grey.shade300);

          return GestureDetector(
            onTap: isAnswerSubmitted ? null : () => submitAnswer(index),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          isSelected
                              ? (isCorrect
                                  ? Colors.green
                                  : isWrong
                                  ? Colors.red
                                  : BBColors.primaryColor)
                              : (isAnswerSubmitted && isCorrect
                                  ? Colors.green
                                  : BBColors.secondaryColor),
                    ),
                    child: Center(
                      child: BBText(
                        data: String.fromCharCode(65 + index),
                        style: context.textStyle.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: BBText(
                      data: questions[currentQuestionIndex].options[index],
                      style: context.textStyle.labelMedium?.copyWith(
                        fontSize: 14,
                        color:
                            isAnswerSubmitted
                                ? (isCorrect || (isSelected && isWrong)
                                    ? Colors.black
                                    : Colors.black87)
                                : Colors.black87,
                      ),
                    ),
                  ),
                  if (isAnswerSubmitted)
                    Icon(
                      isCorrect
                          ? Icons.check_circle
                          : (isWrong ? Icons.cancel : null),
                      color:
                          isCorrect
                              ? Colors.green
                              : (isWrong ? Colors.red : null),
                      size: 24,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
