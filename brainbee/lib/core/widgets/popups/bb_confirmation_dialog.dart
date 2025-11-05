import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/models/bb_question.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/core/widgets/popups/bb_model_button.dart';
import 'package:brainbee/presentation/views/learn/battle/UI/bb_battle_report_card.dart';
import 'package:flutter/material.dart';

class QuitConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmButtonText;
  final String cancelButtonText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final QuizType quizType;

  // Battle-specific properties
  final int? battleScore;
  final int? opponentScore;
  final List<Question>? battleQuestions;
  final List<int?>? battleAnswers;
  final int? battleTimeSpent;

  // In-app quiz specific properties
  final int? inAppScore;
  final int? correctAnswers;
  final int? totalQuestions;
  final int? inAppTimeSpent;
  final String? quizTitle;
  final List<int?>? inAppAnswers;
  final List<String>? explanations;

  const QuitConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    required this.quizType,
    this.confirmButtonText = "Quit",
    this.cancelButtonText = "Cancel",
    this.onCancel,
    // Battle properties
    this.battleScore,
    this.opponentScore,
    this.battleQuestions,
    this.battleAnswers,
    this.battleTimeSpent,
    // In-app quiz properties
    this.inAppScore,
    this.correctAnswers,
    this.totalQuestions,
    this.inAppTimeSpent,
    this.quizTitle,
    this.inAppAnswers,
    this.explanations,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).dialogBackgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: BBText(
                      data: title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(color: BBColors.borderGray),
                  BBText(
                    data: message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Expanded(child: SizedBox.shrink()),
                      buildStudyModeButton(
                        context,
                        label: cancelButtonText,
                        onTap: () {
                          Navigator.pop(context);
                          onCancel?.call();
                        },
                      ),
                      const SizedBox(width: 20),
                      buildStudyModeButton(
                        context,
                        label: confirmButtonText,
                        onTap: () {
                          Navigator.pop(context);
                          _handleQuit(context);
                        },
                      ),
                      const Expanded(child: SizedBox.shrink()),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0.95, -0.145),
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
                onCancel?.call();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                decoration: BoxDecoration(
                  color: Theme.of(context).dialogBackgroundColor,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 0.5,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.close,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleQuit(BuildContext context) {
    if (quizType == QuizType.battle) {
      // Navigate to battle report card
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => BBQuizReportCardScreen(
                quizType: QuizType.battle,
                score: battleScore ?? 0,
                opponentScore: opponentScore,
                won: (battleScore ?? 0) > (opponentScore ?? 0),
                questions: battleQuestions,
                userAnswers: battleAnswers ?? [],
                timeSpent: battleTimeSpent ?? 0,
              ),
        ),
      );
    } else {
      // Navigate to in-app quiz report card
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => BBQuizReportCardScreen(
                quizType: QuizType.inAppQuiz,
                score: inAppScore ?? 0,
                correctAnswers: correctAnswers,
                totalQuestions: totalQuestions,
                timeSpent: inAppTimeSpent ?? 0,
                quizTitle: quizTitle,
                userAnswers: inAppAnswers ?? [],
                explanations: explanations,
              ),
        ),
      );
    }
    onConfirm();
  }
}
