import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:brainbee/presentation/views/auth/models/user_model.dart';
import 'package:brainbee/presentation/views/home/models/bb_student_model.dart';
import 'package:brainbee/services/bb_notifications.dart';
import 'package:brainbee/services/goalNotificationPrefrences/bb_goal_notification_prefrences.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

part 'student_event.dart';
part 'student_state.dart';

class StudentBloc extends Bloc<StudentEvent, StudentState> {
  final BBNotificationService _notificationService = BBNotificationService();
  static const String baseUrl = "http://10.0.2.2:5000";

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
        "reminder": [],
        "value": 2,
        "status": true,
        "noOfAttempts": 2,
      },
    },
  };

  StudentBloc() : super(StudentInitial()) {
    on<StudentFetchData>(_onStudentFetchData);
    on<StudentUpdateGoals>(_onStudentUpdateGoals);
    on<StudentUpdateProfile>(_onStudentUpdateProfile);
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
      emit(StudentDataError(e.toString()));
    }
  }

  FutureOr<void> _onStudentUpdateProfile(
    StudentUpdateProfile event,
    Emitter<StudentState> emit,
  ) async {
    emit(StudentDataLoading());

    try {
      final tokenAndUser = await _getTokenAndUser();
      final token = tokenAndUser['token'] as String;
      final user = tokenAndUser['user'] as UserModel;

      if (token.isEmpty) {
        emit(StudentDataError("Authentication token not found"));
        return;
      }

      // Update profile image
      await _updateProfileImage(event.image, token);

      // Update other profile data
      await _updateProfileData(event, token);

      // Update local response data
      response['user']['firstName'] = event.firstName;
      response['user']['lastName'] = event.lastName;

      final studentData = StudentModel.fromJson(response);
      emit(StudentUpdateProfileSuccess("Profile updated successfully"));
      emit(StudentDataLoaded(studentData));
    } catch (e) {
      String errorMessage = "Error updating profile: ${e.toString()}";

      if (e.toString().contains('Connection refused')) {
        errorMessage =
            "Cannot connect to server. Please check your connection.";
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage =
            "Request timed out. Please check your internet connection.";
      }

      emit(StudentUpdateProfileFailure(errorMessage));
    }
  }

  Future<void> _updateProfileImage(File image, String token) async {
    final uri = Uri.parse("$baseUrl/api/auth/update-profile-pic");
    var request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';

    // Determine MIME type from file extension
    String fileExtension = image.path.split('.').last.toLowerCase();
    MediaType contentType;

    switch (fileExtension) {
      case 'jpg':
      case 'jpeg':
        contentType = MediaType('image', 'jpeg');
        break;
      case 'png':
        contentType = MediaType('image', 'png');
        break;
      case 'gif':
        contentType = MediaType('image', 'gif');
        break;
      default:
        contentType = MediaType('image', 'jpeg');
    }

    request.files.add(
      await http.MultipartFile.fromPath(
        'profileImage',
        image.path,
        contentType: contentType,
      ),
    );

    var streamedResponse = await request.send().timeout(
      const Duration(seconds: 30),
    );
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('Failed to update profile image: ${response.body}');
    }
  }

  Future<void> _updateProfileData(
    StudentUpdateProfile event,
    String token,
  ) async {
    final response = await http
        .post(
          Uri.parse("$baseUrl/api/auth/update-profile"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode({
            "firstName": event.firstName,
            "lastName": event.lastName,
            "address": event.address,
            "phone": event.phoneNumber,
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('Failed to update profile data: ${response.body}');
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

      // Check if goal notifications are enabled at app level
      final goalNotificationsEnabled =
          await GoalNotificationPreferences.isGoalNotificationEnabled();

      // Check if we can actually send notifications (app pref + system permission)
      final canSendNotifications =
          await GoalNotificationPreferences.canSendGoalNotifications();

      // If user has reminders but goal notifications are disabled, clear the reminders
      List<DateTime> finalReminders = event.goal.reminder;
      if (finalReminders.isNotEmpty && !goalNotificationsEnabled) {
        print(
          'Clearing reminders: Goal notifications disabled in app preferences',
        );
        finalReminders = [];
      }

      // Cancel existing reminders before updating
      await _cancelExistingGoalReminders(response['user']['id']);

      // Update goal data
      response['user']['goal'] = {
        "title": event.goal.title,
        "description": event.goal.description,
        "dueDate": event.goal.dueDate.toIso8601String(),
        "reminder":
            finalReminders.map((date) => date.toIso8601String()).toList(),
        "value": event.goal.value,
        "status": event.goal.status,
        "noOfAttempts": noOfAttempts,
      };

      final studentData = StudentModel.fromJson(response);

      // Only schedule new reminders if goal notifications are enabled AND we have system permission
      if (goalNotificationsEnabled && finalReminders.isNotEmpty) {
        if (canSendNotifications) {
          await _scheduleGoalReminders(studentData);
          print('✅ Scheduled ${finalReminders.length} goal reminders');
        } else {
          print(
            '⚠️  Goal reminders saved but notifications require system permission',
          );
        }
      } else if (!goalNotificationsEnabled) {
        print('Goal notifications disabled - no reminders scheduled');
      } else {
        print('No reminders to schedule');
      }

      emit(StudentUpdateGoalsSuccess(studentData.goal));
      emit(StudentDataLoaded(studentData));
    } catch (e) {
      emit(StudentUpdateGoalsFailure(e.toString()));
    }
  }

  Future<void> _cancelExistingGoalReminders(String userId) async {
    try {
      final pendingNotifications =
          await _notificationService.getPendingNotifications();

      print(
        'Found ${pendingNotifications.length} pending notifications to check',
      );

      int cancelledCount = 0;
      for (final notification in pendingNotifications) {
        // More specific check for goal reminders
        if (notification.payload?.contains('goal_reminder') == true) {
          await _notificationService.cancelNotification(notification.id);
          cancelledCount++;
          print('Cancelled goal reminder notification ID: ${notification.id}');
        }
      }

      print(
        'Cancelled $cancelledCount existing goal reminders for user: $userId',
      );
    } catch (e) {
      print('Error cancelling existing goal reminders: $e');
    }
  }

  Future<void> _scheduleGoalReminders(StudentModel student) async {
    try {
      // Double-check preferences before scheduling
      final canSend =
          await GoalNotificationPreferences.canSendGoalNotifications();
      if (!canSend) {
        print(
          '❌ Cannot schedule goal reminders: Preferences or permissions not granted',
        );
        return;
      }

      final studentId = student.id;
      final goalTitle = student.goal.title;

      print('=== SCHEDULING GOAL REMINDERS ===');
      print('Student ID: $studentId');
      print('Goal Title: $goalTitle');
      print('Number of reminders: ${student.goal.reminder.length}');

      for (int i = 0; i < student.goal.reminder.length; i++) {
        final reminderTime = student.goal.reminder[i];

        print('Processing goal reminder ${i + 1}: $reminderTime');

        final notificationId = BBNotificationService.generateNotificationId(
          studentId,
          reminderTime,
        );

        final title = 'Time for your $goalTitle goal! 🎯';
        final body =
            'Complete ${student.goal.value} quizzes to stay on track with your daily goal.';

        await _notificationService.scheduleGoalReminder(
          id: notificationId,
          title: title,
          body: body,
          scheduledTime: reminderTime,
        );

        print(
          '✅ Scheduled goal reminder ID: $notificationId for $reminderTime',
        );
      }
      print(
        'Successfully scheduled ${student.goal.reminder.length} goal reminders',
      );
    } catch (e) {
      print('❌ Error scheduling goal reminders: $e');
      rethrow;
    }
  }
}
