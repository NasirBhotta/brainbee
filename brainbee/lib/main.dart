import 'package:brainbee/core/theme/bb_theme.dart';
import 'package:brainbee/presentation/splashscreen/splash_screen.dart';
import 'package:flutter/material.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BrainBeeApp());
}

class BrainBeeApp extends StatelessWidget {
  const BrainBeeApp({super.key});
  // final List<Question> questions = [
  //   Question(
  //     text: "What is the capital of France?",
  //     options: ["London", "Berlin", "Paris", "Madrid"],
  //     correctOptionIndex: 2,
  //   ),
  //   Question(
  //     text: "Which planet is known as the Red Planet?",
  //     options: ["Earth", "Mars", "Jupiter", "Venus"],
  //     correctOptionIndex: 1,
  //   ),
  //   Question(
  //     text: "What is the chemical symbol for Gold?",
  //     options: ["Go", "Gl", "Au", "Ag"],
  //     correctOptionIndex: 2,
  //   ),
  //   Question(
  //     text: "What is the largest mammal on Earth?",
  //     options: ["Elephant", "Blue Whale", "Giraffe", "Polar Bear"],
  //     correctOptionIndex: 1,
  //   ),
  //   Question(
  //     text: "What is the hardest natural substance on Earth?",
  //     options: ["Gold", "Iron", "Diamond", "Titanium"],
  //     correctOptionIndex: 2,
  //   ),
  // ];
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brain Bee',
      theme: BrainBeeTheme.lightTheme,
      debugShowCheckedModeBanner: false,

      home: const SplashScreen(),
    );
  }
}
