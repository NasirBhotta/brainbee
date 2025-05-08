import 'dart:ui';

import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_custom_progressbar.dart';
import 'package:brainbee/core/utils/bb_screen_extension.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:flutter/material.dart';

class BbQuizzesDisplay extends StatefulWidget {
  final String title;
  final String description;
  final String imagePath1;
  final String imagePath2;
  final Color color;

  const BbQuizzesDisplay({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath1,
    required this.imagePath2,
    required this.color,
  });

  @override
  State<BbQuizzesDisplay> createState() => _BbQuizzesDisplayState();
}

class _BbQuizzesDisplayState extends State<BbQuizzesDisplay> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      // padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      height: context.screenHeight * 0.18,
      width: context.screenWidth,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(widget.imagePath1),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(10),
        color: BBColors.white,
      ),
      child: Row(
        spacing: 15,
        children: [
          SizedBox(
            height: context.screenHeight * 0.3,
            width: context.screenWidth * 0.35,
            child: Transform.translate(
              offset: const Offset(0, 5),
              child: Image.asset(widget.imagePath2, fit: BoxFit.fill),
            ),
          ),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 12,
              children: [
                BBText(
                  data: widget.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: BBColors.white,
                  ),
                ),

                BBText(
                  data: widget.description,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: BBColors.white,
                  ),
                ),

                SizedBox(
                  width: context.screenWidth * 0.5,
                  child: CustomProgressBar(progress: 0.5, color: widget.color),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    margin: const EdgeInsets.only(right: 15),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),

                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: BBColors.white, width: 1.5),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        minimumSize: const Size(0, 0),
                        padding: EdgeInsets.zero,
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      onPressed: () {},
                      child: BBText(
                        data: "Answer Quiz",
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: BBColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
