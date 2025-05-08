import 'package:brainbee/core/theme/bb_theme.dart';
import 'package:brainbee/presentation/splashscreen/splash_screen.dart';
import 'package:brainbee/presentation/views/extras/leaderboard/bb_customgraph.dart';
import 'package:brainbee/presentation/views/extras/leaderboard/bb_leaderboard.dart';
import 'package:brainbee/presentation/views/extras/reportcard/bb_book_analytics.dart';
import 'package:brainbee/presentation/views/extras/reportcard/bb_reportcard.dart';
import 'package:brainbee/presentation/views/extras/scorecard/bb_scorecard.dart';

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

      home: const BBOverallScoreScreen(),
    );
  }
}
