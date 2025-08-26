import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:brainbee/presentation/views/auth/models/user_model.dart';
import 'package:brainbee/presentation/views/home/models/bb_student_model.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'student_event.dart';
part 'student_state.dart';

class StudentBloc extends Bloc<StudentEvent, StudentState> {
  final Map<String, dynamic> response = {
    "status": "success",
    "accessToken": "dummy-token-123",
    "user": {
      "id": "S001",
      "email": "student@example.com",
      "firstName": "Ali",
      "lastName": "Khan",
      "grade": 8,
      "subjects": ["Math", "Science"],
      "parentId": "P001",
      "coins": 120,
      "streakScore": 5,
      "lastStreakDate": "2025-08-10T00:00:00.000Z",
      "dailyLives": 5,
      "livesResetTime": "2025-08-23T00:00:00.000Z",
      "friends": ["S002", "S003"],
      "achievements": {"badges": [], "trophies": []},
      "leaderboardStats": {"rank": 15, "points": 1200},
      "battleStats": {"wins": 10, "losses": 3, "totalBattles": 13},
      "enrolledClasses": ["Math101", "Sci101"],
      "chapter_levels": {"math_ch1": "completed", "sci_ch1": "in-progress"},
      "score": 25,
      "topic_performance": {
        "fractions": {"attempts": 10, "correct": 7},
        "algebra": {"attempts": 5, "correct": 4},
      },
      "goal": {
        "title": "Casual",
        "description": "2 Quizzes & Estimate 7 minutes daily",
        "dueDate": "2025-08-30T00:00:00.000Z",
        "reminder": ["2025-08-25T00:00:00.000Z", "2025-08-28T00:00:00.000Z"],
        "value": 2,
        "status": true,
        "noOfAttempts": 2,
      },
    },
  };

  StudentBloc() : super(StudentInitial()) {
    on<StudentFetchData>(_onStudentFetchData);
    on<StudentUpdateGoals>(_onStudentUpdateGoals);
  }

  Future<Map<String, dynamic>> _getTokenAndUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userData = prefs.getString('user_data');

      UserModel? user;
      if (userData != null && userData.isNotEmpty) {
        try {
          final userMap = jsonDecode(userData);
          user = UserModel.fromJson(userMap);
        } catch (e) {
          // Clear corrupted data
          await _removeTokenAndUser();
        }
      }

      return {'token': token, 'user': user};
    } catch (e) {
      return {'token': null, 'user': null};
    }
  }

  Future<void> _removeTokenAndUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
    } catch (e) {
      throw Exception("Error removing token and user: $e");
    }
  }

  FutureOr<void> _onStudentFetchData(
    StudentFetchData event,
    Emitter<StudentState> emit,
  ) async {
    emit(StudentDataLoading());

    try {
      await Future.delayed(const Duration(seconds: 2));

      // Dummy response JSON (structure matches your StudentModel)
      //   const response = '''
      // {
      //   "status": "success",
      //   "accessToken": "dummy-token-123",
      //   "user": {
      //     "_id": "S001",
      //     "email": "student@example.com",
      //     "firstName": "Ali",
      //     "lastName": "Khan",
      //     "grade": 8,
      //     "subjects": ["Math", "Science"],
      //     "parentId": "P001",
      //     "coins": 120,
      //     "streakScore": 5,
      //     "lastStreakDate": "2025-08-10T00:00:00.000Z",
      //     "dailyLives": 5,
      //     "livesResetTime": "2025-08-23T00:00:00.000Z",
      //     "friends": ["S002", "S003"],
      //     "achievements": {
      //       "badges": [],
      //       "trophies": []
      //     },
      //     "leaderboardStats": {
      //       "rank": 15,
      //       "points": 1200
      //     },
      //     "battleStats": {
      //       "wins": 10,
      //       "losses": 3,
      //       "totalBattles": 13
      //     },
      //     "enrolledClasses": ["Math101", "Sci101"],
      //     "chapter_levels": {
      //       "math_ch1": "completed",
      //       "sci_ch1": "in-progress"
      //     },
      //     "score": 25,
      //     "topic_performance": {
      //       "fractions": {"attempts": 10, "correct": 7},
      //       "algebra": {"attempts": 5, "correct": 4}
      //     },
      //     "goal" : {
      //       "title": "Casual",
      //       "description": "2 Quizzes & Estimate 7 minutes daily",
      //       "dueDate": "2025-08-30T00:00:00.000Z",
      //       "reminder": [
      //         "2025-08-25T00:00:00.000Z",
      //         "2025-08-28T00:00:00.000Z"
      //       ],
      //       "value" : 2,
      //       "status" : true,
      //       "noOfAttempts": 2
      //     }
      //   }
      // }
      // ''';

      // final data = jsonDecode(response.toString());

      final tokenAndUser = await _getTokenAndUser();
      final token = tokenAndUser['token'] as String;
      final user = tokenAndUser['user'] as UserModel;
      response['user']['id'] = user.id;
      response['user']['email'] = user.email;
      response['user']['firstName'] = user.firstName;
      response['user']['lastName'] = user.lastName;
      response['accessToken'] = token;
      response['status'] = user.status;

      final studentData = StudentModel.fromJson(response);

      emit(StudentDataLoaded(studentData));
    } catch (e) {
      print(e);
      emit(StudentDataError(e.toString()));
    }
  }

  FutureOr<void> _onStudentUpdateGoals(
    StudentUpdateGoals event,
    Emitter<StudentState> emit,
  ) async {
    emit(StudentDataLoading());
    try {
      await Future.delayed(const Duration(seconds: 2));

      final int noOfAttempts = response['user']['goal']['noOfAttempts'];

      response['user']['goal'] = {
        "title": event.goal.title,
        "description": event.goal.description,
        "dueDate": event.goal.dueDate.toIso8601String(),
        "reminder":
            event.goal.reminder.map((date) => date.toIso8601String()).toList(),
        "value": event.goal.value,
        "status": event.goal.status,
        "noOfAttempts": noOfAttempts,
      };

      final studentData = StudentModel.fromJson(response);

      emit(StudentUpdateGoalsSuccess(studentData.goal));

      emit(StudentDataLoaded(studentData));
    } catch (e) {
      emit(StudentDataError(e.toString()));
    }
  }
}
