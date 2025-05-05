import 'package:flutter/material.dart';

class CustomProgressBar extends StatelessWidget {
  final double progress;
  final Color color;
  const CustomProgressBar({
    super.key,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 5,
      decoration: BoxDecoration(
        color: Colors.white, // outer background
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(1), // inset/padding for inner bar
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.transparent, // prevent double background
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ),
    );
  }
}
