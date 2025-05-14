import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:flutter/material.dart';
export 'bb_model_button.dart';

Widget buildStudyModeButton(
  BuildContext context, {

  required String label,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [BBColors.primaryColor, BBColors.secondaryColor],
        ),
        borderRadius: BorderRadius.circular(10),

        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
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
