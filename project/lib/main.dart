import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'services/auth_service.dart';
import 'services/class_service.dart';
import 'services/material_service.dart';
import 'services/discussion_service.dart';
import 'services/grade_service.dart';
import 'services/assignment_service.dart';
import 'services/quiz_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ClassService()),
        ChangeNotifierProvider(create: (_) => MaterialService()),
        ChangeNotifierProvider(create: (_) => DiscussionService()),
        ChangeNotifierProvider(create: (_) => GradeService()),
        ChangeNotifierProvider(create: (_) => AssignmentService()),
        ChangeNotifierProvider(create: (_) => QuizService()),
      ],
      child: const StudentApp(),
    ),
  );
}