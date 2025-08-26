import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class BBNotificationService {
  static final BBNotificationService _instance =
      BBNotificationService()._internal();

  factory BBNotificationService() => _instance;
  BBNotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> Initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    const InitializationSettings initializationSetting = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSetting,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // handle notification badge tap here

        print('Notification tapped: ${response.payload}');
      },
    );

    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      await Permission.notification.request();

      if (await Permission.scheduleExactAlarm.isDenied) {
        await Permission.scheduleExactAlarm.request();
      }
    } else if (Platform.isIOS) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  Future<void> scheduleGoalReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    try {
      final tz.TZDateTime scheduledTZ = tz.TZDateTime.from(
        scheduledTime,
        tz.local,
      );

      if (scheduledTZ.isBefore(tz.TZDateTime.now(tz.local))) {
        print('Cannot schedule notification in the past');
        return;
      }

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'goal_reminders',
            'Goal Reminders',
            channelDescription: 'Notifications for daily goal reminders',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            sound: RawResourceAndroidNotificationSound('notification_sound'),
            enableVibration: true,
          );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
            sound: 'default',
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTZ,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

        payload: 'goal_reminder_$id',
      );

      print('Reminder scheduled for: $scheduledTime');
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  Future<void> scheduleRepeatingGoalReminder({
    required int id,
    required String title,
    required String body,
    required DateTime firstReminderTime,
    required RepeatInterval repeatInterval,
  }) async {
    try {
      final tz.TZDateTime scheduledTZ = tz.TZDateTime.from(
        firstReminderTime,
        tz.local,
      );

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'daily_goal_reminders',
            'Daily Goal Reminders',
            channelDescription: 'Daily notifications for goal reminders',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails();

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await _flutterLocalNotificationsPlugin.periodicallyShow(
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        id,
        title,
        body,
        repeatInterval,
        platformChannelSpecifics,
        payload: 'daily_goal_reminder_$id',
      );

      print('Repeating reminder scheduled starting: $firstReminderTime');
    } catch (e) {
      print('Error scheduling repeating notification: $e');
    }
  }

  Future<void> cancelReminder(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
    print('Cancelled reminder with id: $id');
  }

  Future<void> cancelAllReminders() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
    print('Cancelled all reminders');
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  // Helper method to generate unique IDs for notifications
  static int generateNotificationId(String studentId, DateTime reminderTime) {
    return '${studentId}_${reminderTime.millisecondsSinceEpoch}'.hashCode.abs();
  }
}
