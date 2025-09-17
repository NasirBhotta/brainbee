import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:brainbee/presentation/views/home/models/bb_student_model.dart';
import 'package:brainbee/presentation/views/home/repository/student_repository.dart';
import 'package:brainbee/services/bb_notifications.dart';
import 'package:brainbee/services/goalNotificationPrefrences/bb_goal_notification_prefrences.dart';
import 'package:equatable/equatable.dart';
part 'student_event.dart';
part 'student_state.dart';

class StudentBloc extends Bloc<StudentEvent, StudentState> {
  final StudentRepository _repository = StudentRepository();
  final BBNotificationService _notificationService = BBNotificationService();

  StudentBloc() : super(StudentInitial()) {
    on<StudentFetchData>(_onStudentFetchData);
    on<StudentUpdateGoals>(_onStudentUpdateGoals);
    on<StudentUpdateProfile>(_onStudentUpdateProfile);
  }

  FutureOr<void> _onStudentFetchData(
    StudentFetchData event,
    Emitter<StudentState> emit,
  ) async {
    emit(StudentDataLoading());

    try {
      final studentData = await _repository.fetchStudentData();

      print("student data fetched is $studentData");
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
      final studentData = await _repository.updateProfile(
        image: event.image,
        firstName: event.firstName,
        lastName: event.lastName,
        address: event.address,
        phoneNumber: event.phoneNumber,
      );

      emit(StudentUpdateProfileSuccess("Profile updated successfully"));
      emit(StudentDataLoaded(studentData));
    } catch (e) {
      emit(StudentUpdateProfileFailure(e.toString()));
    }
  }

  FutureOr<void> _onStudentUpdateGoals(
    StudentUpdateGoals event,
    Emitter<StudentState> emit,
  ) async {
    emit(StudentDataLoading());
    try {
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
      await _cancelExistingGoalReminders();

      // Update goals through repository
      final studentData = await _repository.updateGoals(
        title: event.goal.title,
        description: event.goal.description,
        dueDate: event.goal.dueDate,
        reminders: finalReminders,
        value: event.goal.value,
        status: event.goal.status,
      );

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

  Future<void> _cancelExistingGoalReminders() async {
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

      print('Cancelled $cancelledCount existing goal reminders');
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
