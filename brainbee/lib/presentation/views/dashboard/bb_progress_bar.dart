import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_screen_extension.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:flutter/material.dart';

class BbProgressBar extends StatelessWidget {
  final Color color;
  final String imgPath;
  final String desc;
  final int index;

  const BbProgressBar({
    super.key,
    required this.color,
    required this.imgPath,
    required this.desc,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.screenWidth * 0.22,
      height: context.screenHeight * 0.042,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0.5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset(
            imgPath,
            width: context.screenWidth * 0.06,
            height: context.screenHeight * 0.05,
            fit: BoxFit.contain,
          ),
          index == 0
              ? Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 0.5,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BBText(
                      data: desc,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: BBColors.white,
                      ),
                    ),
                    Text(
                      "score",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 10,
                        color: BBColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
              : Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: BBText(
                  data: desc,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: BBColors.white,
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
