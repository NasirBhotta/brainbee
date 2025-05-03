import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_screen_extension.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:flutter/material.dart';

class BbQuizzesDisplay extends StatefulWidget {
  final String title;
  final String description;
  final String imagePath1;
  final String imagePath2;

  const BbQuizzesDisplay({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath1,
    required this.imagePath2,
  });

  @override
  State<BbQuizzesDisplay> createState() => _BbQuizzesDisplayState();
}

class _BbQuizzesDisplayState extends State<BbQuizzesDisplay> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      height: context.screenHeight * 0.18,
      width: context.screenWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: BBColors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: BBColors.primaryColor, width: 1.8),
                ),
                child: Image.asset(
                  widget.imagePath1,
                  width: context.screenWidth * 0.04,
                  height: context.screenHeight * 0.025,
                ),
              ),
              const SizedBox(width: 10),
              BBText(
                data: widget.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2.5,
                ),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(151, 75, 182, 154),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Image.asset(
                  widget.imagePath2,
                  height: context.screenHeight * 0.06,
                  width: context.screenWidth * 0.11,
                ),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  BBText(
                    data: widget.description,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    width: context.screenWidth * 0.7,
                    child: LinearProgressIndicator(
                      value: 0.5,
                      backgroundColor: BBColors.lightGrayBG,
                      color: BBColors.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              const Expanded(child: SizedBox.shrink()),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: BBColors.secondaryColor,
                    width: 1.5,
                  ),
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
                      color: BBColors.secondaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
