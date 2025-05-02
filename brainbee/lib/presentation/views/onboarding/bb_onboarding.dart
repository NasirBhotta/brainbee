import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/presentation/views/onboarding/bb_onboard_card.dart';
import 'package:flutter/material.dart';

class BbOnboarding extends StatefulWidget {
  const BbOnboarding({super.key});

  @override
  State<BbOnboarding> createState() => _BbOnboardingState();
}

class _BbOnboardingState extends State<BbOnboarding> {
  final List<Map<String, String>> onboardingData = [
    {
      'title': 'Welcome to BrainBee',
      'desc':
          'Your all-in-one learning companion — powered by AI to make education more personal, engaging, and effective.',
      'image': 'assets/1.png',
    },
    {
      'title': 'Learn Smarter, Not Harder',
      'desc':
          'Get personalized summaries, quizzes, and flashcards tailored to your learning needs. Study at your pace — from Grades 5 to 12.',
      'image': 'assets/2.png',
    },
    {
      'title': 'Track Progress. Reach Goals.',
      'desc':
          'Monitor your performance with real-time feedback, report cards, and score trends. Parents and teachers stay in sync to guide your growth.',
      'image': 'assets/3.png',
    },
  ];
  int currentPage = 0;
  PageController pageController = PageController();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: pageController,
            itemCount: 3,
            onPageChanged: (value) {
              setState(() {
                currentPage = value;
              });
            },
            itemBuilder: (_, index) {
              return BbOnboardCard(
                title: onboardingData[index]['title']!,
                description: onboardingData[index]['desc']!,
                imagePath: onboardingData[index]['image']!,
              );
            },
          ),
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: index == currentPage ? 12 : 8,
              height: index == currentPage ? 12 : 8,
              decoration: BoxDecoration(
                color: index == currentPage ? BBColors.white : BBColors.white,
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
