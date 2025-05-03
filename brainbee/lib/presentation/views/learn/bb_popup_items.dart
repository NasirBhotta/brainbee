import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_screen_extension.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:flutter/material.dart';

class BBPopupItems extends StatelessWidget {
  final String? title;
  final String? imgPath;
  const BBPopupItems({super.key, required this.title, required this.imgPath});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: context.screenHeight * 0.07,
          width: context.screenWidth * 0.15,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: BBColors.primaryColor,
          ),
          child: Image.asset(imgPath ?? "assets/battle.png"),
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
