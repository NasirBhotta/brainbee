import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/presentation/views/onboarding/bb_combined_onbaord.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BbCombinedOnbaord()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: BBColors.lightGrayBG,
      body: Container(
        width: screenSize.width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [BBColors.primaryColor, BBColors.secondaryColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Image.asset('assets/main_logo.png', width: 300, height: 300),
            const SizedBox(height: 10),
            const CircularProgressIndicator(
              color: BBColors.white,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
