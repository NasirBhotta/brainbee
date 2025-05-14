import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/core/widgets/popups/bb_model_button.dart';
import 'package:brainbee/presentation/views/battle/bb_battle_quiz_screen.dart';
import 'package:brainbee/presentation/views/battle/bb_book_selection.dart';
import 'package:brainbee/presentation/views/battle/bb_chap_selection.dart';
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
          child: Stack(
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
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Expanded(child: SizedBox.shrink()),
                          buildStudyModeButton(
                            context,
                            label: button1Label,
                            onTap: () {
                              Navigator.pop(context);
                              button1Label.startsWith('By')
                                  ? Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => BBChapterSelectionScreen(
                                            subject: subject,
                                          ),
                                    ),
                                  )
                                  : null;
                            },
                          ),
                          const Expanded(child: SizedBox.shrink()),
                          button2Label != null
                              ? buildStudyModeButton(
                                context,
                                label: button2Label,
                                onTap: () {
                                  Navigator.pop(context);
                                  button2Label.startsWith('Whole')
                                      ? showInvitationPopUp(
                                        context: context,
                                        title: "Invite Friends",
                                        desc: "Are you ready?",
                                        button1Label: "Share invitation code",
                                        button2Label: "Random Match",
                                        subject: subject,
                                      )
                                      : Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) =>
                                                  const BBBattleQuizScreen(),
                                        ),
                                      );
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
                alignment: const Alignment(0.95, -0.145),
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
                      color: BBColors.secondaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
