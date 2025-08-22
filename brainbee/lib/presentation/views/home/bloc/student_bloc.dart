import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:brainbee/presentation/views/auth/bloc/auth_bloc.dart';
import 'package:brainbee/presentation/views/auth/models/user_model.dart';
import 'package:brainbee/presentation/views/home/models/bb_student_model.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'student_event.dart';
part 'student_state.dart';

class StudentBloc extends Bloc<StudentEvent, StudentState> {
  StudentBloc() : super(StudentInitial()) {
    on<StudentFetchData>(_onStudentFetchData);
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
          print("Error parsing user data: $e");
          // Clear corrupted data
          await _removeTokenAndUser();
        }
      }

      print("Retrieved token: ${token != null ? 'Present' : 'Null'}");
      print("Retrieved user: ${user?.toJson() ?? 'Null'}");

      return {'token': token, 'user': user};
    } catch (e) {
      print("Error getting token and user: $e");
      return {'token': null, 'user': null};
    }
  }

  Future<void> _removeTokenAndUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
      print("Token and user data removed");
    } catch (e) {
      print("Error removing token and user: $e");
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
      const response = '''
    {
      "status": "success",
      "accessToken": "dummy-token-123",
      "user": {
        "_id": "S001",
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
        "achievements": {
          "badges": [],
          "trophies": []
        },
        "leaderboardStats": {
          "rank": 15,
          "points": 1200
        },
        "battleStats": {
          "wins": 10,
          "losses": 3,
          "totalBattles": 13
        },
        "enrolledClasses": ["Math101", "Sci101"],
        "chapter_levels": {
          "math_ch1": "completed",
          "sci_ch1": "in-progress"
        },
        "score": 25,
        "topic_performance": {
          "fractions": {"attempts": 10, "correct": 7},
          "algebra": {"attempts": 5, "correct": 4}
        }
      }
    }
    ''';

      final data = jsonDecode(response);

      final tokenAndUser = await _getTokenAndUser();
      final token = tokenAndUser['token'] as String;
      final user = tokenAndUser['user'] as UserModel;
      data['user']['_id'] = user.id;
      data['user']['email'] = user.email;
      data['user']['firstName'] = user.firstName;
      data['user']['lastName'] = user.lastName;
      data['accessToken'] = token;
      data['status'] = user.status;

      final studentData = StudentModel.fromJson(data);

      emit(StudentDataLoaded(studentData));
    } catch (e) {
      emit(StudentDataError(e.toString()));
    }
  }
}
