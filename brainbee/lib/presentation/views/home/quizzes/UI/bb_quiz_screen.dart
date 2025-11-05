import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/core/utils/bb_textTheme_extention.dart';
import 'package:brainbee/core/utils/helper/bb_confirmation_dialog.dart';
import 'package:brainbee/core/utils/helper/bb_result_extention.dart';
import 'package:brainbee/presentation/views/home/quizzes/bloc/quiz_bloc.dart';
import 'package:brainbee/presentation/views/home/quizzes/models/quiz_data_model.dart';
import 'package:brainbee/presentation/views/learn/battle/UI/bb_battle_report_card.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

class BBInAppQuizScreen extends StatefulWidget {
  final String quizTitle;
  final String quizId;
  final String studentId;
  const BBInAppQuizScreen({
    super.key,
    this.quizTitle = "Topic Quiz",
    required this.quizId,
    required this.studentId,
  });

  @override
  State<BBInAppQuizScreen> createState() => _BBInAppQuizScreenState();
}

class _BBInAppQuizScreenState extends State<BBInAppQuizScreen> {
  QuizData? quizData;
  int currentQuestionIndex = 0;
  int? selectedOptionIndex;
  bool isAnswerSubmitted = false;
  bool isCorrectAnswer = false;
  int score = 0;
  int correctAnswers = 0;
  int timeSpent = 0;
  List<int?> answers = [];
  List<String> explanations = [];
  int timeRemaining = 30;
  late Timer timer;
  late Timer totalTimeTimer;
  int totalQuizTime = 0;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();

    loadQuiz();

    startTimer();
    startTotalTimeTimer();
  }

  void loadQuiz() {
    context.read<QuizBloc>().add(LoadQuizById(quizId: widget.quizId));
  }

  @override
  void dispose() {
    timer.cancel();
    totalTimeTimer.cancel();
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

  void startTotalTimeTimer() {
    totalTimeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        totalQuizTime++;
      }
    });
  }

  void resetTimerForNextQuestion() {
    timer.cancel();
    timeRemaining = 30;
    startTimer();
  }

  void submitAnswer(int? optionIndex) {
    answers.add(optionIndex);
    explanations[currentQuestionIndex] =
        quizData!.questions[currentQuestionIndex].explanation;

    if (isAnswerSubmitted) return;

    timer.cancel();

    setState(() {
      selectedOptionIndex = optionIndex;
      isAnswerSubmitted = true;

      final correctIndex =
          quizData!.questions[currentQuestionIndex].correctChoiceIndex;
      isCorrectAnswer = selectedOptionIndex == correctIndex;

      if (isCorrectAnswer) {
        correctAnswers++;
        // Calculate score based on difficulty and time
        double difficultyMultiplier =
            quizData!.questions[currentQuestionIndex].difficulty;
        int timeBonus = (timeRemaining / 30 * 20).round();
        int baseScore = (100 * difficultyMultiplier).round();
        score += baseScore + timeBonus;
      }
    });

    if (currentQuestionIndex < quizData!.questions.length - 1) {
      Future.delayed(const Duration(seconds: 3), () {
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
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          print("We are submitting the quiz");
          _submitQuizAndShowResult();

          // here we have to submitQuiz performance
        }
      });
    }
  }

  Future<void> _submitQuizAndShowResult() async {
    if (quizData == null) {
      print("quiz data is null");
      _showResultDialog();
      return;
    }

    // Prepare answers in the format the backend expects
    final answersPayload = <Map<String, dynamic>>[];
    for (int i = 0; i < answers.length; i++) {
      answersPayload.add({
        'question_id': quizData!.questions[i].id,
        'selected_index': answers[i], // can be null if timeout
      });
    }

    print("answer payload is $answersPayload");

    // Submit to backend
    context.read<QuizBloc>().add(
      SubmitQuizPerformance(
        studentId: widget.studentId,
        quizId: widget.quizId,
        answers: answersPayload,
      ),
    );

    // Show result dialog immediately (don't wait for submission)
    _showResultDialog();
  }

  void _showResultDialog() {
    double percentage = (correctAnswers / quizData!.questions.length) * 100;

    // Determine result type based on percentage
    ResultType resultType;
    if (percentage >= 80) {
      resultType = ResultType.win;
    } else if (percentage >= 60) {
      resultType = ResultType.tie;
    } else {
      resultType = ResultType.lose;
    }

    context.showDynamicResultDialog(
      inAppQuestions: quizData!.questions,
      quizType: QuizType.inAppQuiz,
      title: "Quiz Complete!",
      resultType: resultType,
      userScore: correctAnswers,
      opponentScore: quizData!.questions.length,
      headerIcon: Icon(
        percentage >= 80
            ? Icons.emoji_events
            : percentage >= 60
            ? Icons.thumb_up
            : Icons.refresh,
        color: Colors.white,
        size: 40,
      ),
      onActionPressed: () {
        Navigator.pop(context);
        _navigateToReportCard();
      },
      onCrossPressed: () {
        _navigateToReportCard();
      },
      onPressedOutside: () {
        _navigateToReportCard();
      },
    );
  }

  void _navigateToReportCard() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => BBQuizReportCardScreen(
              inAppQuestions: quizData!.questions,
              quizType: QuizType.inAppQuiz,
              userAnswers: answers,
              explanations: explanations,
              score: score,
              correctAnswers: correctAnswers,
              totalQuestions: quizData!.questions.length,
              timeSpent: totalQuizTime,
              quizTitle: widget.quizTitle,
            ),
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
          data: widget.quizTitle,
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
      body: BlocConsumer<QuizBloc, QuizState>(
        listener: (context, state) {
          // setState(() {
          //   if (state is QuizLoading) {
          //     isLoading = true;
          //   } else {
          //     isLoading = false;
          //   }
          // });
        },
        builder: (context, state) {
          if (state is QuizLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is QuizzesLoaded) {
            quizData = state.quizData;

            if (explanations.isEmpty) {
              explanations = List.filled(quizData!.questions.length, '');
            }
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProgressAndScore(),
                  const SizedBox(height: 16),
                  _buildTimerBar(),
                  const SizedBox(height: 24),
                  _buildQuestion(),
                  const SizedBox(height: 24),
                  _buildOptions(),
                  if (isAnswerSubmitted) ...[
                    const SizedBox(height: 16),
                    _buildExplanation(),
                  ],
                ],
              ),
            );
          } else {
            return const Center(child: Text("Failed to load quiz."));
          }
        },
      ),
    );
  }

  Widget _buildProgressAndScore() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: BBColors.primaryColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: BBText(
            data:
                "Question ${currentQuestionIndex + 1}/${quizData!.questions.length}",
            style: context.textStyle.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star, color: Colors.blue, size: 16),
              const SizedBox(width: 4),
              BBText(
                data: "Score: $score",
                style: context.textStyle.labelMedium?.copyWith(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimerBar() {
    double progress = timeRemaining / 30;
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
    final currentQuestion = quizData!.questions[currentQuestionIndex];

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: BBText(
                  data:
                      "Difficulty: ${(currentQuestion.difficulty * 10).toStringAsFixed(1)}/10",
                  style: context.textStyle.labelSmall?.copyWith(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          BBText(
            data: currentQuestion.stem,
            style: context.textStyle.labelMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptions() {
    final currentQuestion = quizData!.questions[currentQuestionIndex];

    return Expanded(
      child: ListView.builder(
        itemCount: currentQuestion.choices.length,
        itemBuilder: (context, index) {
          final isSelected = selectedOptionIndex == index;
          final isCorrect =
              isAnswerSubmitted && index == currentQuestion.correctChoiceIndex;
          final isWrong =
              isAnswerSubmitted &&
              isSelected &&
              index != currentQuestion.correctChoiceIndex;

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
                      data: currentQuestion.choices[index].replaceFirst(
                        RegExp(r'^[A-D]\.\s*'),
                        '',
                      ),
                      style: context.textStyle.labelMedium?.copyWith(
                        fontSize: 14,
                        color:
                            isAnswerSubmitted
                                ? (isCorrect || (isSelected && isWrong)
                                    ? Colors.black
                                    : Colors.black87)
                                : Colors.black87,
                        height: 1.2,
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

  Widget _buildExplanation() {
    final currentQuestion = quizData!.questions[currentQuestionIndex];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrectAnswer ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrectAnswer ? Colors.green.shade200 : Colors.red.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrectAnswer ? Icons.check_circle : Icons.cancel,
                color: isCorrectAnswer ? Colors.green : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              BBText(
                data: isCorrectAnswer ? "Correct!" : "Incorrect",
                style: context.textStyle.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isCorrectAnswer ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          BBText(
            data: currentQuestion.explanation,
            style: context.textStyle.labelMedium?.copyWith(
              fontSize: 13,
              color: Colors.black87,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  void showQuitDialog(BuildContext context) {
    context.showDynamicQuitDialog(
      quizType: QuizType.inAppQuiz,
      title: "Quit Quiz?",
      message: "Are you sure you want to quit? Your progress will be saved.",
      confirmButtonText: "Quit",
      cancelButtonText: "Cancel",
      onConfirm: () {
        Navigator.pop(context);
        if (answers.isNotEmpty) {
          _submitQuizAndShowResult();
        }
        _navigateToReportCard();
      },
    );
  }
}
