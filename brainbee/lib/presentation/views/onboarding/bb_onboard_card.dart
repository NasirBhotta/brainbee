import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:flutter/material.dart';

class BbOnboardCard extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  const BbOnboardCard({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            height: imagePath == "assets/3.png" ? 230 : 200,
            width: imagePath == "assets/3.png" ? 230 : 200,
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: BBColors.white),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: BBColors.white),
          ),
        ],
      ),
    );
  }
}
