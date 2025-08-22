import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:brainbee/presentation/views/home/models/bb_student_model.dart';
import 'package:equatable/equatable.dart';

part 'student_event.dart';
part 'student_state.dart';

class StudentBloc extends Bloc<StudentEvent, StudentState> {
  StudentBloc() : super(StudentInitial()) {
    on<StudentFetchData>(_onStudentFetchData);
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
        "topic_performance": {
          "fractions": {"attempts": 10, "correct": 7},
          "algebra": {"attempts": 5, "correct": 4}
        }
      }
    }
    ''';

      final data = jsonDecode(response);
      final studentData = StudentModel.fromJson(data);
      emit(StudentDataLoaded(studentData));
    } catch (e) {
      emit(StudentDataError(e.toString()));
    }
  }
}
