// Extension method for easy usage
import 'package:brainbee/core/models/bb_question.dart';
import 'package:brainbee/core/widgets/popups/bb_result_dialog.dart';
import 'package:brainbee/presentation/views/home/quizzes/models/quiz_question_model.dart';
import 'package:brainbee/presentation/views/learn/battle/bb_battle_report_card.dart';
import 'package:flutter/material.dart';

enum ResultType { win, lose, tie }

extension DynamicResultDialogExtension on BuildContext {
  Future<void> showDynamicResultDialog({
    required String title,
    required ResultType resultType,
    required int userScore,
    required int opponentScore,
    required VoidCallback onActionPressed,
    required VoidCallback onCrossPressed,
    required VoidCallback onPressedOutside,
    required QuizType quizType,
    String userScoreLabel = "Your Score",
    String opponentScoreLabel = "Opponent",
    String actionButtonText = "Done",
    Color? primaryColor,
    Widget? headerIcon,
    String? customResultMessage,
    bool barrierDismissible = true,
    Duration transitionDuration = const Duration(milliseconds: 300),
    // Battle properties
    List<Question>? battleQuestions,
    List<int?>? battleAnswers,
    int? battleTimeSpent,
    bool? won,
    // In-app quiz properties
    required List<QuizQuestion> inAppQuestions,
    int? correctAnswers,
    int? totalQuestions,
    int? inAppTimeSpent,
    String? quizTitle,
    List<int?>? inAppAnswers,
    List<String>? explanations,
  }) {
    return showGeneralDialog(
      context: this,
      barrierDismissible: barrierDismissible,
      barrierLabel: "result",
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.2),
            end: const Offset(0, 0),
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          ),
          child: DynamicResultDialog(
            title: title,
            resultType: resultType,
            userScore: userScore,
            opponentScore: opponentScore,
            onActionPressed: onActionPressed,
            onCrossPressed: onCrossPressed,
            quizType: quizType,
            userScoreLabel: userScoreLabel,
            opponentScoreLabel: opponentScoreLabel,
            actionButtonText: actionButtonText,
            primaryColor: primaryColor,
            headerIcon: headerIcon,
            customResultMessage: customResultMessage,
            // Battle properties
            battleQuestions: battleQuestions,
            battleAnswers: battleAnswers,
            battleTimeSpent: battleTimeSpent,
            won: won,
            // In-app quiz properties
            inAppQuestions: inAppQuestions,
            correctAnswers: correctAnswers,
            totalQuestions: totalQuestions,
            inAppTimeSpent: inAppTimeSpent,
            quizTitle: quizTitle,
            inAppAnswers: inAppAnswers,
            explanations: explanations,
          ),
        );
      },
    ).then((_) {
      onPressedOutside();
    });
  }
}
