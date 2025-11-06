import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/models/subject_model.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/core/widgets/popups/bb_model_button.dart';
import 'package:brainbee/presentation/views/learn/battle/bloc/battle_bloc.dart';
import 'package:brainbee/presentation/views/learn/battle/models/battle_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

export 'bb_invite_popUp.dart';

void showInvitationPopUp({
  required BuildContext context,
  required String title,
  required String desc,
  required String button1Label,
  String? button2Label,
  required Subject subject,
  List<String>? chapters,
  required VoidCallback onButton1Pressed,
  required VoidCallback onButton2Pressed,
}) {
  print('=== showInvitationPopUp called ===');
  print('Title: $title');
  print('Button1: $button1Label, Button2: $button2Label');
  print('Chapters: $chapters');

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "invitation",
    pageBuilder:
        (_, __, ___) => _InvitationPopupContent(
          title: title,
          desc: desc,
          button1Label: button1Label,
          button2Label: button2Label,
          subject: subject,
          chapters: chapters,
          onButton1Pressed: onButton1Pressed,
          onButton2Pressed: onButton2Pressed,
        ),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: const Offset(0, 0),
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
        child: child,
      );
    },
  );
}

class _InvitationPopupContent extends StatefulWidget {
  final String title;
  final String desc;
  final String button1Label;
  final String? button2Label;
  final Subject subject;
  final List<String>? chapters;
  final VoidCallback onButton1Pressed;
  final VoidCallback onButton2Pressed;

  const _InvitationPopupContent({
    required this.title,
    required this.desc,
    required this.button1Label,
    this.button2Label,
    required this.subject,
    this.chapters,
    required this.onButton1Pressed,
    required this.onButton2Pressed,
  });

  @override
  State<_InvitationPopupContent> createState() =>
      _InvitationPopupContentState();
}

class _InvitationPopupContentState extends State<_InvitationPopupContent> {
  late TextEditingController questionsController;
  String selectedDifficulty = 'Medium';
  String selectedQuestionType = 'Multiple Choice';
  int selectedTimeLimit = 30;
  bool isLoading = false;

  final List<String> difficulties = ['Easy', 'Medium', 'Hard'];
  final List<String> questionTypes = [
    'Multiple Choice',
    'True/False',
    'Short Questions',
  ];
  final List<int> timeLimits = [15, 30, 45, 60];

  @override
  void initState() {
    super.initState();
    questionsController = TextEditingController(text: '10');
  }

  @override
  void dispose() {
    questionsController.dispose();
    super.dispose();
  }

  bool get showQuizSettings => widget.title.toLowerCase() == "invite friends";

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
                color: BBColors.lightGrayBG,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: BBText(
                      data: widget.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: BBText(
                      data: widget.desc,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // Quiz parameters section
                  if (showQuizSettings) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: BBColors.primaryColor.withValues(alpha: 0.2),
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
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w500),
                                ),
                              ),
                              SizedBox(
                                width: 80,
                                height: 35,
                                child: TextFormField(
                                  controller: questionsController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  enabled: !isLoading,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: const BorderSide(
                                        color: BBColors.borderGray,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: const BorderSide(
                                        color: BBColors.borderGray,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
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
                          _buildDropdownRow(
                            context,
                            label: "Difficulty:",
                            value: selectedDifficulty,
                            items: difficulties,
                            enabled: !isLoading,
                            onChanged: (value) {
                              setState(() {
                                selectedDifficulty = value!;
                              });
                            },
                          ),
                          const SizedBox(height: 12),

                          // Question Type
                          _buildDropdownRow(
                            context,
                            label: "Type:",
                            value: selectedQuestionType,
                            items: questionTypes,
                            enabled: !isLoading,
                            onChanged: (value) {
                              setState(() {
                                selectedQuestionType = value!;
                              });
                            },
                          ),
                          const SizedBox(height: 12),

                          // Time Limit
                          Row(
                            children: [
                              Expanded(
                                child: BBText(
                                  data: "Time (sec):",
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w500),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: BBColors.primaryColor.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                  borderRadius: BorderRadius.circular(6),
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
                                                  Theme.of(
                                                    context,
                                                  ).textTheme.bodyMedium,
                                            ),
                                          );
                                        }).toList(),
                                    onChanged:
                                        isLoading
                                            ? null
                                            : (int? newValue) {
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

                  // Loading indicator or buttons
                  if (isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            BBColors.primaryColor,
                          ),
                        ),
                      ),
                    )
                  else
                    Row(
                      children: [
                        const Expanded(child: SizedBox.shrink()),
                        buildStudyModeButton(
                          context,
                          label: widget.button1Label,
                          onTap: _handleButton1Press,
                        ),
                        const Expanded(child: SizedBox.shrink()),
                        if (widget.button2Label != null)
                          buildStudyModeButton(
                            context,
                            label: widget.button2Label!,
                            onTap: _handleButton2Press,
                          ),
                        const Expanded(child: SizedBox.shrink()),
                      ],
                    ),
                ],
              ),
            ),
          ),

          // Close button
          if (!isLoading)
            Align(
              alignment:
                  showQuizSettings
                      ? const Alignment(0.95, -0.515)
                      : const Alignment(0.95, -0.145),
              child: InkWell(
                onTap: () => Navigator.pop(context),
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
      ),
    );
  }

  void _handleButton1Press() {
    print('Button1 pressed: ${widget.button1Label}');

    print('Using custom button1 callback');
    Navigator.pop(context);
    widget.onButton1Pressed();
  }

  void _handleButton2Press() {
    print('Button2 pressed: ${widget.button2Label}');

    print('Using custom button2 callback');
    Navigator.pop(context);
    widget.onButton2Pressed();
  }

  void _showQuizSettingsPopup(
    BuildContext context,
    Subject subject, {
    List<String>? chapters,
  }) {
    showInvitationPopUp(
      context: context,
      title: "Invite Friends",
      desc: "Are you ready?",
      button1Label: "Share invitation code",
      button2Label: "Random Match",
      subject: subject,
      chapters: chapters,
      onButton1Pressed: () {
        // Create invitation room
        print('Creating invitation room...');
        context.read<BattleBloc>().add(
          CreateBattleRoomEvent(
            subject: subject.name,
            mode:
                chapters == null ? BattleMode.wholeBook : BattleMode.byChapter,
            chapters: chapters,
          ),
        );
      },
      onButton2Pressed: () {
        // Find random opponent
        print('Finding random opponent...');
        context.read<BattleBloc>().add(
          FindRandomOpponentEvent(subject: subject.name, chapters: chapters),
        );
      },
    );
  }

  void _handleBattleAction({
    required bool isRandom,
    required VoidCallback onComplete,
  }) {
    final quizParameters = {
      'subject': widget.subject.name,
      'numberOfQuestions': int.tryParse(questionsController.text) ?? 10,
      'difficulty': selectedDifficulty,
      'questionType': selectedQuestionType,
      'timeLimit': selectedTimeLimit,
      'chapters': widget.chapters,
    };

    print('=== _handleBattleAction called ===');
    print('isRandom: $isRandom');
    print('Battle parameters: $quizParameters');

    try {
      final battleBloc = context.read<BattleBloc>();
      print('BattleBloc obtained: ${battleBloc.runtimeType}');
      print('Current BattleBloc state: ${battleBloc.state}');

      if (isRandom) {
        print('Adding FindRandomOpponentEvent...');
        battleBloc.add(
          FindRandomOpponentEvent(
            subject: widget.subject.name,
            chapters: widget.chapters,
          ),
        );
      } else {
        print('Adding CreateBattleRoomEvent...');
        battleBloc.add(
          CreateBattleRoomEvent(
            subject: widget.subject.name,
            mode:
                widget.chapters == null
                    ? BattleMode.wholeBook
                    : BattleMode.byChapter,
            chapters: widget.chapters,
          ),
        );
      }

      print('Event added successfully');

      // Close dialog after delay
      Future.delayed(const Duration(milliseconds: 500), () {
        print('Closing dialog...');
        onComplete();
      });
    } catch (e, stackTrace) {
      print('ERROR in _handleBattleAction: $e');
      print('StackTrace: $stackTrace');
      if (mounted) {
        setState(() => isLoading = false);
      }
      onComplete();
    }
  }

  Widget _buildDropdownRow(
    BuildContext context, {
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool enabled = true,
  }) {
    return Row(
      children: [
        Expanded(
          child: BBText(
            data: label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: BBColors.primaryColor.withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              items:
                  items.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: BBText(
                        data: item,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }).toList(),
              onChanged: enabled ? onChanged : null,
            ),
          ),
        ),
      ],
    );
  }
}

void showQuizSettingsPopup(
  BuildContext context,
  Subject subject, {
  List<String>? chapters,
}) {
  showInvitationPopUp(
    context: context,
    title: "Invite Friends",
    desc: "Are you ready?",
    button1Label: "Share invitation code",
    button2Label: "Random Match",
    subject: subject,
    chapters: chapters,
    onButton1Pressed: () {
      // Create invitation room
      print('Creating invitation room...');
      context.read<BattleBloc>().add(
        CreateBattleRoomEvent(
          subject: subject.name,
          mode: chapters == null ? BattleMode.wholeBook : BattleMode.byChapter,
          chapters: chapters,
        ),
      );
    },
    onButton2Pressed: () {
      // Find random opponent
      print('Finding random opponent...');
      context.read<BattleBloc>().add(
        FindRandomOpponentEvent(subject: subject.name, chapters: chapters),
      );
    },
  );
}
