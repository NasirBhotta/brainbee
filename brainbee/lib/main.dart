import 'package:brainbee/core/theme/bb_theme.dart';
import 'package:brainbee/presentation/splashscreen/splash_screen.dart';
import 'package:brainbee/presentation/views/auth/bloc/auth_bloc.dart';
import 'package:brainbee/presentation/views/bot/UI/bb_initial_bot_screen.dart';
import 'package:brainbee/presentation/views/dashboard/UI/bb_dashboard.dart';
import 'package:brainbee/presentation/views/settings/UI/bb_manage_profile.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(BlocProvider(create: (_) => AuthBloc(), child: const BrainBeeApp()));
}

class BrainBeeApp extends StatelessWidget {
  const BrainBeeApp({super.key});

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
