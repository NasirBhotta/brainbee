import 'package:brainbee/core/theme/bb_theme.dart';
import 'package:brainbee/presentation/splashscreen/splash_screen.dart';
import 'package:brainbee/presentation/views/auth/bloc/auth_bloc.dart';
import 'package:brainbee/presentation/views/extras/achievements/badges/bloc/badge_bloc.dart';
import 'package:brainbee/presentation/views/extras/achievements/badges/services/badge_api_services.dart';
import 'package:brainbee/presentation/views/extras/coinquests/bloc/quest_bloc.dart';
import 'package:brainbee/presentation/views/extras/coinquests/services/api_service.dart';
import 'package:brainbee/presentation/views/extras/coinquests/services/notification_service.dart';
import 'package:brainbee/presentation/views/home/bloc/student_bloc.dart';
import 'package:brainbee/presentation/views/home/quizzes/bloc/quiz_bloc.dart';
import 'package:brainbee/presentation/views/home/quizzes/repositories/quiz_repository.dart';
import 'package:brainbee/presentation/views/home/quizzes/repositories/quiz_repository_impl.dart';
import 'package:brainbee/presentation/views/home/quizzes/services/quiz_api_service.dart';
import 'package:brainbee/repositories/badge_repository.dart';
import 'package:brainbee/routes/app_routes.dart';
import 'package:brainbee/services/bb_notifications.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Notifications
  await BBNotificationService().initialize();

  runApp(
    MultiBlocProvider(
      providers: [
        // AuthBloc will auto-check authentication on app start
        BlocProvider(
          create: (context) => AuthBloc()..add(AuthCheckRequested()),
        ),

        BlocProvider(create: (context) => StudentBloc()),
        // Quest feature
        BlocProvider(
          create: (_) => QuestBloc(ApiService(), NotificationService()),
        ),
        // Badge feature
        BlocProvider(
          create:
              (_) => BadgeBloc(
                repository: BadgeRepositoryImpl(
                  apiService: BadgeApiServiceImpl(),
                ),
              ),
        ),

        BlocProvider(
          create:
              (context) => QuizBloc(
                quizRepository: QuizRepositoryImpl(
                  apiService: QuizApiService(),
                ),
              ),
        ),
      ],
      child: const BrainBeeApp(),
    ),
  );
}

class BrainBeeApp extends StatelessWidget {
  const BrainBeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brain Bee',
      theme: BrainBeeTheme.lightTheme,
      debugShowCheckedModeBanner: false,

      // Define routes
      routes: AppRoutes.getRoutes(),

      // Start with SplashScreen which will handle auth flow
      home: const SplashScreen(),
    );
  }
}
