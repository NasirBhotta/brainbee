import 'package:brainbee/presentation/views/battle/bb_chap_selection.dart';
import 'package:flutter/material.dart';
import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/core/utils/bb_textTheme_extention.dart';

class Subject {
  final String name;
  final int flashcardCount;
  final String imgPath;
  final Color color;

  Subject({
    required this.name,
    required this.flashcardCount,
    required this.imgPath,
    required this.color,
  });
}

class BBBookSelection extends StatelessWidget {
  final List<Subject> subjects = [
    Subject(
      name: 'English',
      flashcardCount: 104,
      imgPath: 'assets/text-book.png',
      color: Colors.red,
    ),
    Subject(
      name: 'Biology',
      flashcardCount: 34,
      imgPath: 'assets/dna.png',
      color: Colors.green,
    ),
    Subject(
      name: 'Mathematics',
      flashcardCount: 35,
      imgPath: 'assets/compass.png',
      color: Colors.blue,
    ),
    Subject(
      name: 'Chemistry',
      flashcardCount: 29,
      imgPath: 'assets/chemistry.png',
      color: Colors.pink,
    ),
    Subject(
      name: 'Physics',
      flashcardCount: 25,
      imgPath: 'assets/molecule.png',
      color: Colors.amber,
    ),
  ];

  BBBookSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: BBText(
          data: 'Select Subject',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          final subject = subjects[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              decoration: BoxDecoration(
                color: BBColors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: Image.asset(subject.imgPath, scale: 13),
                title: BBText(
                  data: subject.name,
                  style: context.textStyle.titleMedium?.copyWith(fontSize: 16),
                ),

                onTap: () {
                  _showStudyModeDialog(context, subject, index);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _showStudyModeDialog(BuildContext context, Subject subject, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Center(
            child: BBText(
              data: 'Battle Mode',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BBText(
                data: 'How would you like to Compete in ${subject.name}?',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStudyModeButton(
                    context,

                    label: 'By Chapter',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  BBChapterSelectionScreen(subject: subject),
                        ),
                      );
                    },
                  ),
                  _buildStudyModeButton(
                    context,

                    label: 'Whole Book',
                    onTap: () {
                      Navigator.pop(context);
                      _showInvitationPopUp(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStudyModeButton(
    BuildContext context, {

    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: BBColors.primaryBlue,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: BBColors.primaryColor.withValues(alpha: 0.3),
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: BBText(
          data: label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: BBColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showInvitationPopUp(BuildContext context) {
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
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: Stack(
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: const BoxDecoration(
                      color: BBColors.lightGrayBG,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: BBText(
                            data: 'Invite Friends',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            BBText(
                              data: 'Are you ready?',

                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            _buildStudyModeButton(
                              context,
                              label: "Share Invitation Code",
                              onTap: () {},
                            ),
                            Expanded(child: child),
                            _buildStudyModeButton(
                              context,
                              label: "Invite Friends",
                              onTap: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                Align(
                  alignment: const Alignment(0.72, -0.07),
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
                      child: const Icon(Icons.close, size: 20),
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
}
