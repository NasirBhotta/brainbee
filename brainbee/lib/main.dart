import 'package:brainbee/core/theme/bb_theme.dart';
import 'package:brainbee/presentation/splashscreen/splash_screen.dart';
import 'package:brainbee/presentation/views/battle/bb_battle.dart';
import 'package:brainbee/presentation/views/dashboard/bb_dashboard.dart';
import 'package:brainbee/presentation/views/onboarding/bb_combined_onbaord.dart';
import 'package:brainbee/presentation/views/settings/bb_settings.dart';
import 'package:flutter/material.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BrainBeeApp());
}

class BrainBeeApp extends StatelessWidget {
  const BrainBeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brain Bee',
      theme: BrainBeeTheme.lightTheme,
      debugShowCheckedModeBanner: false,

      home: const BBBattle(),
    );
  }
}
