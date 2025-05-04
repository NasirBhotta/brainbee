import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/core/utils/bb_textTheme_extention.dart';
import 'package:flutter/material.dart';

class BBFlashcards extends StatelessWidget {
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

  BBFlashcards({super.key});

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
                // boxShadow: const [
                //   BoxShadow(
                //     color: Colors.black12,
                //     blurRadius: 5,
                //     offset: Offset(0, 2),
                //   ),
                // ],
              ),
              child: ListTile(
                leading: Image.asset(subject.imgPath, scale: 13),
                title: BBText(
                  data: subject.name,
                  style: context.textStyle.titleMedium?.copyWith(fontSize: 16),
                ),
                subtitle: BBText(
                  data: "${subject.flashcardCount} Flashcard",
                  style: context.textStyle.bodySmall?.copyWith(
                    color: BBColors.bodyText,
                  ),
                ),
                onTap: () {
                  // Handle subject selection
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

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
