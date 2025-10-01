import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/models/subject_model.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/core/widgets/popups/bb_model_button.dart';
import 'package:brainbee/presentation/views/learn/battle/bb_chap_selection.dart';
import 'package:brainbee/presentation/views/learn/battle/bb_searching_players.dart';
import 'package:flutter/material.dart';

export 'bb_invite_popUp.dart';

void showInvitationPopUp({
  required BuildContext context,
  required String title,
  required String desc,
  required String button1Label,
  String? button2Label,
  required Subject subject,
}) {
  // Controllers for quiz parameters
  final TextEditingController questionsController = TextEditingController(
    text: '10',
  );
  String selectedDifficulty = 'Medium';
  String selectedQuestionType = 'Multiple Choice';
  int selectedTimeLimit = 30;

  final List<String> difficulties = ['Easy', 'Medium', 'Hard'];
  final List<String> questionTypes = [
    'Multiple Choice',
    'True/False',
    'Short Questions',
  ];
  final List<int> timeLimits = [15, 30, 45, 60]; // seconds per question

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "invitaion",
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: const Offset(0, 0),
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
        child: Material(
          type: MaterialType.transparency,
          child: StatefulBuilder(
            builder: (context, setState) {
              return Stack(
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: BBColors.lightGrayBG,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: BBText(
                              data: title,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: BBText(
                              data: desc,
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ),

                          // Quiz parameters section - only show when title is "Invite Friends"
                          if (title.toLowerCase() == "invite friends") ...[
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: BBColors.primaryColor.withValues(
                                    alpha: 0.2,
                                  ),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  BBText(
                                    data: "Quiz Settings",
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: BBColors.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // Number of Questions
                                  Row(
                                    children: [
                                      Expanded(
                                        child: BBText(
                                          data: "Questions:",
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 80,
                                        height: 35,
                                        child: TextFormField(
                                          controller: questionsController,
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.center,
                                          style:
                                              Theme.of(
                                                context,
                                              ).textTheme.bodyMedium,
                                          decoration: InputDecoration(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 8,
                                                ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              borderSide: const BorderSide(
                                                color: BBColors.borderGray,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              borderSide: const BorderSide(
                                                color: BBColors.borderGray,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              borderSide: const BorderSide(
                                                color: BBColors.primaryColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Difficulty Level
                                  Row(
                                    children: [
                                      Expanded(
                                        child: BBText(
                                          data: "Difficulty:",
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: BBColors.primaryColor
                                                .withValues(alpha: 0.3),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: selectedDifficulty,
                                            items:
                                                difficulties.map((
                                                  String difficulty,
                                                ) {
                                                  return DropdownMenuItem<
                                                    String
                                                  >(
                                                    value: difficulty,
                                                    child: BBText(
                                                      data: difficulty,
                                                      style:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium,
                                                    ),
                                                  );
                                                }).toList(),
                                            onChanged: (String? newValue) {
                                              if (newValue != null) {
                                                setState(() {
                                                  selectedDifficulty = newValue;
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Question Type
                                  Row(
                                    children: [
                                      Expanded(
                                        child: BBText(
                                          data: "Type:",
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: BBColors.primaryColor
                                                .withValues(alpha: 0.3),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: selectedQuestionType,
                                            items:
                                                questionTypes.map((
                                                  String type,
                                                ) {
                                                  return DropdownMenuItem<
                                                    String
                                                  >(
                                                    value: type,
                                                    child: BBText(
                                                      data: type,
                                                      style:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium,
                                                    ),
                                                  );
                                                }).toList(),
                                            onChanged: (String? newValue) {
                                              if (newValue != null) {
                                                setState(() {
                                                  selectedQuestionType =
                                                      newValue;
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Time Limit per Question
                                  Row(
                                    children: [
                                      Expanded(
                                        child: BBText(
                                          data: "Time (sec):",
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: BBColors.primaryColor
                                                .withValues(alpha: 0.3),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<int>(
                                            value: selectedTimeLimit,
                                            items:
                                                timeLimits.map((int time) {
                                                  return DropdownMenuItem<int>(
                                                    value: time,
                                                    child: BBText(
                                                      data: '$time',
                                                      style:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium,
                                                    ),
                                                  );
                                                }).toList(),
                                            onChanged: (int? newValue) {
                                              if (newValue != null) {
                                                setState(() {
                                                  selectedTimeLimit = newValue;
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 20),
                          Row(
                            children: [
                              const Expanded(child: SizedBox.shrink()),
                              buildStudyModeButton(
                                context,
                                label: button1Label,
                                onTap: () {
                                  Navigator.pop(context);
                                  if (button1Label.startsWith('By')) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                BBChapterSelectionScreen(
                                                  subject: subject,
                                                ),
                                      ),
                                    );
                                  } else if (title.toLowerCase() ==
                                          "invite friends" &&
                                      button1Label.toLowerCase().contains(
                                        'share',
                                      )) {
                                    // Handle sharing invitation with quiz parameters
                                    _handleShareInvitation(
                                      context,
                                      subject,
                                      int.tryParse(questionsController.text) ??
                                          10,
                                      selectedDifficulty,
                                      selectedQuestionType,
                                      selectedTimeLimit,
                                    );
                                  }
                                },
                              ),
                              const Expanded(child: SizedBox.shrink()),
                              button2Label != null
                                  ? buildStudyModeButton(
                                    context,
                                    label: button2Label,
                                    onTap: () {
                                      Navigator.pop(context);
                                      if (button2Label.startsWith('Whole')) {
                                        showInvitationPopUp(
                                          context: context,
                                          title: "Invite Friends",
                                          desc: "Are you ready?",
                                          button1Label: "Share invitation code",
                                          button2Label: "Random Match",
                                          subject: subject,
                                        );
                                      } else if (title.toLowerCase() ==
                                              "invite friends" &&
                                          button2Label.toLowerCase().contains(
                                            'random',
                                          )) {
                                        // Handle random match with quiz parameters
                                        _handleRandomMatch(
                                          context,
                                          subject,
                                          int.tryParse(
                                                questionsController.text,
                                              ) ??
                                              10,
                                          selectedDifficulty,
                                          selectedQuestionType,
                                          selectedTimeLimit,
                                        );
                                      }
                                    },
                                  )
                                  : const SizedBox.shrink(),
                              const Expanded(child: SizedBox.shrink()),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  Align(
                    alignment:
                        title.toLowerCase() == "invite friends" &&
                                button2Label!.toLowerCase().contains('random')
                            ? const Alignment(0.95, -0.515)
                            : const Alignment(0.95, -0.145),
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: BBColors.lightGrayBG,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: const [
                            BoxShadow(
                              color: BBColors.disabledText,
                              spreadRadius: 0.5,
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 20,
                          color: BBColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    },
  );
}

// Helper function to handle sharing invitation with parameters
void _handleShareInvitation(
  BuildContext context,
  Subject subject,
  int numberOfQuestions,
  String difficulty,
  String questionType,
  int timeLimit,
) {
  // Create quiz parameters object to pass to your AI generation service
  final Map<String, dynamic> quizParameters = {
    'subject': subject,
    'numberOfQuestions': numberOfQuestions,
    'difficulty': difficulty,
    'questionType': questionType,
    'timeLimit': timeLimit,
  };

  // TODO: Implement your sharing logic here
  // You can pass quizParameters to your AI service or sharing mechanism
  print('Sharing invitation with parameters: $quizParameters');

  Navigator.push(
    context,
    MaterialPageRoute(
      builder:
          (context) => const BbSearchingPlayers(
            matchType: MatchType.invitation,
            currentPlayerName: 'nasirbhotta', // Get from user profile
            currentPlayerInitial: 'N',
            currentPlayerColor: Color(0xFF8CAA56),
            // invitationCode is null, so it will generate a new code
          ),
    ),
  );

  // Example: Generate invitation code and share
  // String invitationCode = generateInvitationCode(quizParameters);
  // shareInvitationCode(invitationCode);
}

// Helper function to handle random match with parameters
void _handleRandomMatch(
  BuildContext context,
  Subject subject,
  int numberOfQuestions,
  String difficulty,
  String questionType,
  int timeLimit,
) {
  // Create quiz parameters object for random match
  final Map<String, dynamic> quizParameters = {
    'subject': subject,
    'numberOfQuestions': numberOfQuestions,
    'difficulty': difficulty,
    'questionType': questionType,
    'timeLimit': timeLimit,
  };

  // TODO: Implement your random match logic here
  // You can pass quizParameters to your matching service
  print('Starting random match with parameters: $quizParameters');

  // Example: Navigate to battle quiz with parameters
  Navigator.push(
    context,
    MaterialPageRoute(
      builder:
          (context) => const BbSearchingPlayers(
            matchType: MatchType.random,
            currentPlayerName: 'nasirbhotta', // Get from user profile
            currentPlayerInitial: 'N',
            currentPlayerColor: Color(0xFF8CAA56),
          ),
    ),
  );
}
