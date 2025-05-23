import 'package:flutter/material.dart';
import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/core/utils/bb_textTheme_extention.dart';
import 'package:brainbee/core/widgets/popups/bb_invite_popUp.dart';

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
    // showDialog(
    //   context: context,
    //   builder: (BuildContext context) {
    //     return AlertDialog(
    //       shape: RoundedRectangleBorder(
    //         borderRadius: BorderRadius.circular(15),
    //       ),
    //       title: Center(
    //         child: BBText(
    //           data: 'Battle Mode',
    //           style: Theme.of(
    //             context,
    //           ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    //         ),
    //       ),
    //       content: Column(
    //         mainAxisSize: MainAxisSize.min,
    //         children: [
    //           BBText(
    //             data: 'How would you like to Compete in ${subject.name}?',
    //             style: Theme.of(context).textTheme.bodyMedium,
    //             textAlign: TextAlign.center,
    //           ),
    //           const SizedBox(height: 20),
    //           Row(
    //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //             children: [
    //               buildStudyModeButton(
    //                 context,

    //                 label: 'By Chapter',
    //                 onTap: () {
    //                   Navigator.pushReplacement(
    //                     context,
    //                     MaterialPageRoute(
    //                       builder:
    //                           (context) =>
    //                               BBChapterSelectionScreen(subject: subject),
    //                     ),
    //                   );
    //                 },
    //               ),
    //               buildStudyModeButton(
    //                 context,

    //                 label: 'Whole Book',
    //                 onTap: () {
    //                   Navigator.pop(context);
    //                   showInvitationPopUp(
    //                     context: context,
    //                     button1Label: "Share invitation code",
    //                     title: "Invite Friends",
    //                     desc: "Are you ready?",
    //                     button2Label: "Invite Friends",
    //                   );
    //                 },
    //               ),
    //             ],
    //           ),
    //         ],
    //       ),
    //     );
    //   },
    // );

    showInvitationPopUp(
      context: context,
      title: 'Battle Mode',
      desc: 'How would you like to compete in ${subject.name}?',
      button1Label: 'By Chapter',
      button2Label: 'Whole Book',
      subject: subject,
    );
  }
}
