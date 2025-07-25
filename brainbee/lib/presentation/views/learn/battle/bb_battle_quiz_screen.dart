import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/models/bb_question.dart';
import 'package:brainbee/core/utils/bb_screen_extension.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/core/utils/bb_textTheme_extention.dart';
import 'package:brainbee/core/widgets/popups/bb_confirmation_dialog.dart';
import 'package:brainbee/core/widgets/popups/bb_result_dialog.dart';
import 'package:brainbee/presentation/views/learn/battle/bb_battle_report_card.dart';
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
  bool won = false;
  int timeSpent = 0;
  List<int?> answers = [];
  // doing this for only github submissions
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
            timeSpent = timeSpent + (15 - timeRemaining);
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
    answers.add(optionIndex);
    if (isAnswerSubmitted) return;

    timer.cancel();

    setState(() {
      selectedOptionIndex = optionIndex;
      isAnswerSubmitted = true;

      final correctIndex = questions[currentQuestionIndex].correctOptionIndex;
      isCorrectAnswer = selectedOptionIndex == correctIndex;

      if (isCorrectAnswer) {
        // int timeBonus = (timeRemaining / 15 * 50).round();
        score += 20;
      }

      if (currentQuestionIndex < questions.length - 1) {
        if (DateTime.now().millisecondsSinceEpoch % 2 == 0) {
          int opponentTimeBonus =
              ((10 + (DateTime.now().millisecondsSinceEpoch % 5)) / 15 * 50)
                  .round();
          opponentScore += 20;
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
    // Determine result type
    ResultType resultType;
    if (score > opponentScore) {
      resultType = ResultType.win;
    } else if (score == opponentScore) {
      resultType = ResultType.tie;
    } else {
      resultType = ResultType.lose;
    }

    context.showResultDialog(
      title: "Battle Result",
      resultType: resultType,
      userScore: score,
      opponentScore: opponentScore,
      headerIcon: const Icon(Icons.emoji_events, color: Colors.white, size: 40),
      onActionPressed: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => BBBattleReportCardScreen(
                  score: score,
                  opponentScore: opponentScore,
                  won: score > opponentScore,
                  questions: questions,
                  userAnswers: answers,
                  timeSpent: timeSpent,
                ),
          ),
        );
      },
      onCrossPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => BBBattleReportCardScreen(
                  score: score,
                  opponentScore: opponentScore,
                  won: score > opponentScore,
                  questions: questions,
                  userAnswers: answers,
                  timeSpent: timeSpent,
                ),
          ),
        );
      },
      onPressedOutside: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => BBBattleReportCardScreen(
                  score: score,
                  opponentScore: opponentScore,
                  won: score > opponentScore,
                  questions: questions,
                  userAnswers: answers,
                  timeSpent: timeSpent,
                ),
          ),
        );
      },
    );
  }

  // Widget _buildEnhancedScoreCard(String label, int scoreValue, Color color) {
  //   return Column(
  //     mainAxisSize: MainAxisSize.min,
  //     children: [
  //       BBText(
  //         data: label,
  //         style: TextStyle(
  //           fontSize: 14,
  //           fontWeight: FontWeight.w500,
  //           color: Colors.grey.shade600,
  //         ),
  //       ),
  //       const SizedBox(height: 8),
  //       Container(
  //         width: 60,
  //         height: 60,
  //         decoration: BoxDecoration(
  //           shape: BoxShape.circle,
  //           color: color.withValues(alpha: 0.1),
  //           border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
  //         ),
  //         child: Center(
  //           child: BBText(
  //             data: scoreValue.toString(),
  //             style: TextStyle(
  //               fontSize: 24,
  //               fontWeight: FontWeight.bold,
  //               color: color,
  //             ),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildScoreCard(String label, int scoreValue, Color color) {
  //   return Container(
  //     padding: const EdgeInsets.all(10),
  //     decoration: BoxDecoration(
  //       color: color.withValues(alpha: 0.2),
  //       borderRadius: BorderRadius.circular(15),
  //       border: Border.all(color: color, width: 2),
  //     ),
  //     child: Column(
  //       children: [
  //         BBText(
  //           data: label,
  //           style: context.textStyle.labelMedium?.copyWith(
  //             fontSize: 16,
  //             color: Colors.white70,
  //           ),
  //         ),
  //         const SizedBox(height: 5),
  //         BBText(
  //           data: scoreValue.toString(),
  //           style: context.textStyle.labelMedium?.copyWith(
  //             fontSize: 24,
  //             fontWeight: FontWeight.bold,
  //             color: Colors.white,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

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
            showQuitDialog(context);
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
            color: BBColors.primaryColor,
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

                color: BBColors.primaryColor,
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
        color: BBColors.primaryColor,
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
                                  : BBColors.primaryColor),
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

  // Usage Examples:

  // Basic usage with extension method:
  void showQuitDialog(BuildContext context) {
    context.showConfirmationDialog(
      title: "Quit Battle?",
      message: "Are you sure you want to quit? You'll lose this battle.",
      confirmButtonText: "Quit",
      cancelButtonText: "Cancel",
      onConfirm: () {
        // print(score);
        // print(opponentScore);
        // print(questions);
        // print(answers);
        // print(timeSpent);
        // print(score > opponentScore);

        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => BBBattleReportCardScreen(
                  score: score,
                  opponentScore: opponentScore,
                  won: score > opponentScore,
                  questions: questions,
                  userAnswers: answers,
                  timeSpent: timeSpent,
                ),
          ),
        );

        // Navigate back to previous screen
      },
    );
  }

  //   void showQuitDialouge() {
  //     showGeneralDialog(
  //       context: context,
  //       barrierDismissible: true,
  //       barrierLabel: "quit_battle",
  //       pageBuilder: (_, __, ___) => const SizedBox.shrink(),
  //       transitionBuilder: (context, animation, secondaryAnimation, child) {
  //         return SlideTransition(
  //           position: Tween<Offset>(
  //             begin: const Offset(0, 0.2),
  //             end: const Offset(0, 0),
  //           ).animate(
  //             CurvedAnimation(parent: animation, curve: Curves.easeInOut),
  //           ),
  //           child: Material(
  //             type: MaterialType.transparency,
  //             child: Stack(
  //               children: [
  //                 Center(
  //                   child: Container(
  //                     margin: const EdgeInsets.symmetric(horizontal: 20),
  //                     padding: const EdgeInsets.symmetric(
  //                       horizontal: 10,
  //                       vertical: 10,
  //                     ),
  //                     decoration: BoxDecoration(
  //                       color: BBColors.lightGrayBG,
  //                       borderRadius: BorderRadius.circular(10),
  //                     ),
  //                     child: Column(
  //                       mainAxisSize: MainAxisSize.min,
  //                       crossAxisAlignment: CrossAxisAlignment.center,
  //                       children: [
  //                         Center(
  //                           child: BBText(
  //                             data: "Quit Battle?",
  //                             style: Theme.of(context).textTheme.titleLarge
  //                                 ?.copyWith(fontWeight: FontWeight.bold),
  //                           ),
  //                         ),
  //                         const Divider(color: BBColors.borderGray),
  //                         Text(
  //                           "Are you sure you want to quit? You'll lose this battle.",
  //                           style: Theme.of(context).textTheme.bodyMedium,
  //                           textAlign: TextAlign.center,
  //                         ),
  //                         const SizedBox(height: 20),
  //                         Row(
  //                           children: [
  //                             const Expanded(child: SizedBox.shrink()),
  //                             buildStudyModeButton(
  //                               context,
  //                               label: "Cancel",
  //                               onTap: () {
  //                                 Navigator.pop(context);
  //                               },
  //                             ),
  //                             const SizedBox(width: 20),
  //                             buildStudyModeButton(
  //                               context,
  //                               label: "Quit",
  //                               onTap: () {
  //                                 Navigator.pop(context);
  //                                 Navigator.pop(context);
  //                               },
  //                             ),
  //                             const Expanded(child: SizedBox.shrink()),
  //                           ],
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //                 Align(
  //                   alignment: const Alignment(0.95, -0.145),
  //                   child: InkWell(
  //                     onTap: () {
  //                       Navigator.pop(context);
  //                     },
  //                     child: Container(
  //                       padding: const EdgeInsets.symmetric(
  //                         horizontal: 5,
  //                         vertical: 5,
  //                       ),
  //                       decoration: BoxDecoration(
  //                         color: BBColors.lightGrayBG,
  //                         borderRadius: BorderRadius.circular(2),
  //                         boxShadow: const [
  //                           BoxShadow(
  //                             color: BBColors.disabledText,
  //                             spreadRadius: 0.5,
  //                             blurRadius: 10,
  //                           ),
  //                         ],
  //                       ),
  //                       child: const Icon(
  //                         Icons.close,
  //                         size: 20,
  //                         color: BBColors.primaryColor,
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         );
  //       },
  //     );
  //   }
  // }
}
