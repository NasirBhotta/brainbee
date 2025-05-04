import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_screen_extension.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/presentation/views/Books/bb_books.dart';
import 'package:brainbee/presentation/views/battle/bb_battle.dart';
import 'package:brainbee/presentation/views/flashcards/bb_flashcards.dart';
import 'package:brainbee/presentation/views/practice/bb_practice.dart';
import 'package:flutter/material.dart';

class BBPopupItems extends StatelessWidget {
  final String? title;
  final String? imgPath;
  final int? index;
  BBPopupItems({
    super.key,
    required this.title,
    required this.imgPath,
    required this.index,
  });

  List<Widget> popUpWidgets = [
    const BBBattle(),
    const BBPractice(),
    BBFlashcards(),
    const BBBooks(),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => popUpWidgets[index!]),
            );
          },
          child: Container(
            height: context.screenHeight * 0.065,
            width: context.screenWidth * 0.14,
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: BBColors.primaryColor.withValues(alpha: 0.5),
            ),
            child: Image.asset(imgPath ?? "assets/battle.png"),
          ),
        ),
        BBText(
          data: title ?? "nothing",
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }
}
