import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_screen_extension.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/core/utils/bb_textTheme_extention.dart';
import 'package:brainbee/core/utils/helper/bb_confirmation_dialog.dart';
import 'package:brainbee/presentation/views/learn/battle/UI/bb_battle_report_card.dart';
import 'package:brainbee/presentation/views/learn/battle/bloc/battle_bloc.dart';
import 'package:brainbee/presentation/views/learn/battle/models/battle_models.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

class BBBattleQuizScreen extends StatefulWidget {
  final BattleRoom room;
  final BattleQuizData quizData;

  const BBBattleQuizScreen({
    super.key,
    required this.room,
    required this.quizData,
  });

  @override
  State<BBBattleQuizScreen> createState() => _BBBattleQuizScreenState();
}

class _BBBattleQuizScreenState extends State<BBBattleQuizScreen> {
  int currentQuestionIndex = 0;
  int? selectedOptionIndex;
  bool isAnswerSubmitted = false;
  bool isCorrectAnswer = false;
  int timeSpent = 0;
  List<int?> answers = [];
  int timeRemaining = 60;
  Timer? timer;
  DateTime? questionStartTime;
  bool _isWaitingForResult = false;

  @override
  void initState() {
    super.initState();
    questionStartTime = DateTime.now();
    startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    timeRemaining = widget.quizData.timePerQuestion;
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
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
    timer?.cancel();
    questionStartTime = DateTime.now();
    timeRemaining = widget.quizData.timePerQuestion;
    startTimer();
  }

  void submitAnswer(int? optionIndex) {
    if (isAnswerSubmitted) return;

    timer?.cancel();

    final questionTime =
        questionStartTime != null
            ? DateTime.now().difference(questionStartTime!).inSeconds
            : 0;

    setState(() {
      timeSpent += questionTime;
    });
    answers.add(optionIndex);

    final correctIndex =
        widget.quizData.questions[currentQuestionIndex].correctOptionIndex;

    setState(() {
      selectedOptionIndex = optionIndex;
      isAnswerSubmitted = true;
      isCorrectAnswer = selectedOptionIndex == correctIndex;
    });

    // Submit answer to backend
    context.read<BattleBloc>().add(
      SubmitAnswerEvent(
        roomId: widget.room.roomId,
        questionIndex: currentQuestionIndex,
        selectedOptionIndex: optionIndex,
        timeSpent: questionTime,
      ),
    );

    // Move to next question or finish
    if (currentQuestionIndex < widget.quizData.questions.length - 1) {
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
      // Last question - wait for battle completion
      setState(() {
        _isWaitingForResult = true;
      });

      // Don't immediately request result - wait for WebSocket event
      // The BLoC will handle the battle_completed event
    }
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
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => _showQuitDialog(),
        ),
      ),
      body: BlocConsumer<BattleBloc, BattleState>(
        listener: (context, state) {
          if (state is BattleCompleted) {
            _navigateToResults(state);
          } else if (state is BattleError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is BattleCancelled) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            Navigator.pop(context);
          }
        },
        builder: (BuildContext context, BattleState state) {
          // Get scores from state
          int userScore = 0;
          int opponentScore = 0;

          if (state is BattleInProgress) {
            userScore = state.userScore;
            opponentScore = state.opponentScore;
          }

          // Show waiting UI if waiting for opponent to finish
          if (_isWaitingForResult && state is BattleInProgress) {
            return _buildWaitingForOpponent(userScore, opponentScore);
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProgressAndScores(userScore, opponentScore),
                  const SizedBox(height: 16),
                  _buildTimerBar(),
                  const SizedBox(height: 24),
                  _buildQuestion(),
                  const SizedBox(height: 24),
                  _buildOptions(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWaitingForOpponent(int userScore, int opponentScore) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(BBColors.primaryColor),
          ),
          const SizedBox(height: 24),
          BBText(
            data: "You've finished!",
            style: context.textStyle.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          BBText(
            data: "Waiting for opponent to complete...",
            style: context.textStyle.bodyMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
              ],
            ),
            child: Column(
              children: [
                BBText(data: "Your Score", style: context.textStyle.bodyMedium),
                const SizedBox(height: 8),
                BBText(
                  data: "$userScore",
                  style: context.textStyle.headlineLarge?.copyWith(
                    color: BBColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                BBText(
                  data: "Opponent's Score",
                  style: context.textStyle.bodyMedium,
                ),
                const SizedBox(height: 8),
                BBText(
                  data: "$opponentScore",
                  style: context.textStyle.headlineLarge?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToResults(BattleCompleted completedState) {
    final String? selfUserId = context.read<BattleBloc>().currentUserId;
    if (selfUserId == null) {
      print("Error: Could not determine current user ID");
      return;
    }

    final BattleResult result = completedState.result;
    final bool isWinner = result.winner.id == selfUserId;

    final int finalUserScore =
        isWinner ? result.winnerScore : result.loserScore;
    final int finalOpponentScore =
        isWinner ? result.loserScore : result.winnerScore;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (context) => BBQuizReportCardScreen(
              quizType: QuizType.battle,
              score: finalUserScore,
              opponentScore: finalOpponentScore,
              won: finalUserScore > finalOpponentScore,
              questions: widget.quizData.questions,
              userAnswers: answers,
              timeSpent: timeSpent,
            ),
      ),
    );
  }

  Widget _buildProgressAndScores(int userScore, int opponentScore) {
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
            data:
                "Question ${currentQuestionIndex + 1}/${widget.quizData.questions.length}",
            style: context.textStyle.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
        Row(
          children: [
            _buildPlayerScore("You", userScore, Colors.blue),
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
    double progress = timeRemaining / widget.quizData.timePerQuestion;
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
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: BBText(
        data: widget.quizData.questions[currentQuestionIndex].text,
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
        itemCount:
            widget.quizData.questions[currentQuestionIndex].options!.length,
        itemBuilder: (context, index) {
          final isSelected = selectedOptionIndex == index;
          final isCorrect =
              isAnswerSubmitted &&
              index ==
                  widget
                      .quizData
                      .questions[currentQuestionIndex]
                      .correctOptionIndex;
          final isWrong =
              isAnswerSubmitted &&
              isSelected &&
              index !=
                  widget
                      .quizData
                      .questions[currentQuestionIndex]
                      .correctOptionIndex;

          Color backgroundColor =
              isSelected
                  ? (isCorrect
                      ? Colors.green.withOpacity(0.3)
                      : isWrong
                      ? Colors.red.withOpacity(0.3)
                      : BBColors.primaryColor.withOpacity(0.3))
                  : (isAnswerSubmitted && isCorrect
                      ? Colors.green.withOpacity(0.3)
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
                    color: Colors.black.withOpacity(0.05),
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
                      data:
                          widget
                              .quizData
                              .questions[currentQuestionIndex]
                              .options![index],
                      style: context.textStyle.labelMedium?.copyWith(
                        fontSize: 14,
                        color: Colors.black87,
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

  void _showQuitDialog() {
    context.showDynamicQuitDialog(
      quizType: QuizType.battle,
      title: "Quit Battle?",
      message: "Are you sure you want to quit? You'll lose this battle.",
      confirmButtonText: "Quit",
      cancelButtonText: "Cancel",
      onConfirm: () {
        context.read<BattleBloc>().add(
          LeaveBattleEvent(roomId: widget.room.roomId),
        );
        Navigator.pop(context);
        Navigator.pop(context);
      },
    );
  }
}
