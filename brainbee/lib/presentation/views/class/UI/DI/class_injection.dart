// import 'package:brainbee/presentation/views/class/repo/asign_repo_impl.dart';
// import 'package:brainbee/presentation/views/class/repo/assign_repo.dart';
// import 'package:brainbee/presentation/views/class/repo/class_quiz_repo.dart';
// import 'package:brainbee/presentation/views/class/repo/class_quiz_repo_impl.dart';
// import 'package:brainbee/presentation/views/class/repo/disscussion_repo.dart';
// import 'package:brainbee/presentation/views/class/repo/disscussion_repo_impl.dart';
// import 'package:brainbee/presentation/views/class/repo/material_repo.dart';
// import 'package:brainbee/presentation/views/class/repo/material_repo_impl.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:brainbee/presentation/views/class/services/class_api_service.dart';
// import 'package:brainbee/presentation/views/class/repo/class_repo.dart';
// import 'package:brainbee/presentation/views/class/repo/class_repo_impl.dart';
// import 'package:brainbee/presentation/views/class/bloc/class_bloc.dart';

// /// Wraps a widget with all class-related dependencies
// class ClassDependencyProvider extends StatelessWidget {
//   final Widget child;

//   const ClassDependencyProvider({super.key, required this.child});

//   @override
//   Widget build(BuildContext context) {
//     // Create the API service
//     final apiService = ClassApiService();

//     // Create repositories
//     final classRepository = ClassRepositoryImpl(apiService: apiService);
//     final materialRepository = MaterialRepositoryImpl(apiService: apiService);
//     final discussionRepository = DiscussionRepositoryImpl(
//       apiService: apiService,
//     );
//     final assignmentRepository = AssignmentRepositoryImpl(
//       apiService: apiService,
//     );
//     final quizRepository = QuizRepositoryImpl(apiService: apiService);

//     return MultiRepositoryProvider(
//       providers: [
//         RepositoryProvider<ClassApiService>.value(value: apiService),
//         RepositoryProvider<ClassRepository>.value(value: classRepository),
//         RepositoryProvider<MaterialRepository>.value(value: materialRepository),
//         RepositoryProvider<DiscussionRepository>.value(
//           value: discussionRepository,
//         ),
//         RepositoryProvider<AssignmentRepository>.value(
//           value: assignmentRepository,
//         ),
//         RepositoryProvider<ClassQuizRepository>.value(value: quizRepository),
//       ],
//       child: BlocProvider<ClassBloc>(
//         create: (context) => ClassBloc(classRepository: classRepository),
//         child: child,
//       ),
//     );
//   }
// }
