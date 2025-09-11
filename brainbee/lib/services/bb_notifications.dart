import 'package:brainbee/services/goalNotificationPrefrences/bb_goal_notification_prefrences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

/// Unified Notification Service
class BBNotificationService {
  static final BBNotificationService _instance =
      BBNotificationService._internal();
  factory BBNotificationService() => _instance;
  BBNotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Initialize
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone data
    tz.initializeTimeZones();

    // Set local timezone

    //! https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
    tz.setLocalLocation(tz.getLocation('Asia/Karachi'));

    // final String currentTimeZone =
    //     await FlutterNativeTimezone.getLocalTimezone();
    // tz.setLocalLocation(tz.getLocation(currentTimeZone));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    const settings = InitializationSettings(android: android, iOS: ios);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _requestPermissions();
    _initialized = true;

    print('BBNotificationService initialized successfully');
  }

  /// Handle tap
  Future<void> _onNotificationTapped(NotificationResponse response) async {
    print('Notification tapped: ${response.payload}');
    // TODO: Route user to correct screen depending on payload
  }

  /// Request permissions
  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      // Request notification permission
      final notificationStatus = await Permission.notification.request();
      print('Notification permission: $notificationStatus');

      // Request exact alarm permission for Android 12+
      if (await Permission.scheduleExactAlarm.isDenied) {
        final exactAlarmStatus = await Permission.scheduleExactAlarm.request();
        print('Exact alarm permission: $exactAlarmStatus');
      }
    } else if (Platform.isIOS) {
      final iosPlugin =
          _plugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >();
      final result = await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      print('iOS notification permission: $result');
    }
  }

  // ============================================================
  // 🚀 LOCAL NOTIFICATIONS (Goals, Quests, Achievements, Badges)
  // ============================================================

  /// 🔔 One-time Goal Reminder
  // Future<void> scheduleGoalReminder({
  //   required int id,
  //   required String title,
  //   required String body,
  //   required DateTime scheduledTime,
  // }) async {
  //   print('=== SCHEDULING NOTIFICATION ===');
  //   print('ID: $id');
  //   print('Title: $title');
  //   print('Body: $body');
  //   print('Scheduled Time: $scheduledTime');
  //   print('Current Time: ${DateTime.now()}');

  //   // Convert to timezone aware datetime
  //   final scheduledTZ = tz.TZDateTime.from(scheduledTime, tz.local);
  //   final currentTZ = tz.TZDateTime.now(tz.local);

  //   print('Scheduled TZ: $scheduledTZ');
  //   print('Current TZ: $currentTZ');

  //   // Check if scheduled time is in the future
  //   if (scheduledTZ.isBefore(currentTZ)) {
  //     print(
  //       'ERROR: Scheduled time is in the past! Cannot schedule notification.',
  //     );
  //     return;
  //   }

  //   const android = AndroidNotificationDetails(
  //     'goal_reminders',
  //     'Goal Reminders',
  //     channelDescription: 'Notifications for daily goal reminders',
  //     importance: Importance.high,
  //     priority: Priority.high,
  //     icon: '@mipmap/ic_launcher',
  //     enableLights: true,
  //     enableVibration: true,
  //     playSound: true,
  //   );

  //   const ios = DarwinNotificationDetails(
  //     presentAlert: true,
  //     presentBadge: true,
  //     presentSound: true,
  //   );

  //   try {
  //     await _plugin.zonedSchedule(
  //       id,
  //       title,
  //       body,
  //       scheduledTZ,
  //       const NotificationDetails(android: android, iOS: ios),
  //       androidScheduleMode: AndroidScheduleMode.inexact,
  //       payload: 'goal_reminder_$id',
  //       // Remove this line - it causes issues with one-time notifications
  //       // matchDateTimeComponents: DateTimeComponents.time,
  //     );

  //     print('✅ Notification scheduled successfully!');

  //     // Verify scheduling
  //     final pending = await getPendingNotifications();
  //     final scheduled = pending.where((n) => n.id == id).toList();
  //     print(
  //       'Verification: Found ${scheduled.length} pending notifications with ID $id',
  //     );
  //   } catch (e) {
  //     print('❌ Error scheduling notification: $e');
  //     rethrow;
  //   }
  // }

  Future<void> scheduleGoalReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    // Check if goal notifications are enabled before scheduling
    final canSendGoalNotifications =
        await GoalNotificationPreferences.canSendGoalNotifications();

    if (!canSendGoalNotifications) {
      print(
        '❌ Skipping goal reminder: Goal notifications disabled or no system permission',
      );
      return;
    }

    print('=== SCHEDULING GOAL NOTIFICATION ===');
    print('ID: $id');
    print('Title: $title');
    print('Body: $body');
    print('Scheduled Time: $scheduledTime');
    print('Current Time: ${DateTime.now()}');

    final scheduledTZ = tz.TZDateTime.from(scheduledTime, tz.local);
    final currentTZ = tz.TZDateTime.now(tz.local);

    print('Scheduled TZ: $scheduledTZ');
    print('Current TZ: $currentTZ');

    if (scheduledTZ.isBefore(currentTZ)) {
      print(
        'ERROR: Scheduled time is in the past! Cannot schedule notification.',
      );
      return;
    }

    const android = AndroidNotificationDetails(
      'goal_reminders',
      'Goal Reminders',
      channelDescription: 'Notifications for daily goal reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      enableLights: true,
      enableVibration: true,
      playSound: true,
    );

    const ios = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTZ,
        const NotificationDetails(android: android, iOS: ios),
        androidScheduleMode: AndroidScheduleMode.inexact,
        payload: 'goal_reminder_$id',
      );

      print('✅ Goal notification scheduled successfully!');

      // Verify scheduling
      final pending = await getPendingNotifications();
      final scheduled = pending.where((n) => n.id == id).toList();
      print(
        'Verification: Found ${scheduled.length} pending notifications with ID $id',
      );
    } catch (e) {
      print('❌ Error scheduling goal notification: $e');
      rethrow;
    }
  }

  /// Cancel all goal-specific notifications
  Future<void> cancelAllGoalNotifications() async {
    try {
      final pendingNotifications = await getPendingNotifications();

      int cancelledCount = 0;
      for (final notification in pendingNotifications) {
        if (notification.payload?.contains('goal_reminder') == true) {
          await cancelNotification(notification.id);
          cancelledCount++;
        }
      }

      print('Cancelled $cancelledCount goal notifications');
    } catch (e) {
      print('Error cancelling goal notifications: $e');
    }
  }

  /// Get count of pending goal notifications
  Future<int> getPendingGoalNotificationCount() async {
    try {
      final pendingNotifications = await getPendingNotifications();
      return pendingNotifications
          .where((n) => n.payload?.contains('goal_reminder') == true)
          .length;
    } catch (e) {
      print('Error getting goal notification count: $e');
      return 0;
    }
  }

  /// Debug method to check permissions and pending notifications
  // Future<void> debugNotificationStatus() async {
  //   print('=== NOTIFICATION DEBUG INFO ===');

  //   if (Platform.isAndroid) {
  //     final notificationPermission = await Permission.notification.status;
  //     final exactAlarmPermission = await Permission.scheduleExactAlarm.status;

  //     print('Android Notification Permission: $notificationPermission');
  //     print('Android Exact Alarm Permission: $exactAlarmPermission');
  //   }

  //   final pending = await getPendingNotifications();
  //   print('Total Pending Notifications: ${pending.length}');

  //   for (final notification in pending) {
  //     print('- ID: ${notification.id}, Title: ${notification.title}');
  //     print('  Body: ${notification.body}');
  //     print('  Payload: ${notification.payload}');
  //   }

  //   print('Current Time: ${DateTime.now()}');
  //   print('Current TZ Time: ${tz.TZDateTime.now(tz.local)}');
  //   print('Local Timezone: ${tz.local.name}');
  // }

  /// 🔁 Repeating Goal Reminder (Daily, Weekly, etc.)
  Future<void> scheduleRepeatingGoalReminder({
    required int id,
    required String title,
    required String body,
    required RepeatInterval repeatInterval,
  }) async {
    const android = AndroidNotificationDetails(
      'daily_goal_reminders',
      'Daily Goal Reminders',
      channelDescription: 'Daily notifications for goal reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const ios = DarwinNotificationDetails();

    await _plugin.periodicallyShow(
      id,
      title,
      body,
      repeatInterval,
      const NotificationDetails(android: android, iOS: ios),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'daily_goal_reminder_$id',
    );
  }

  /// 🎉 Quest Complete Notification (local-only)
  Future<void> showQuestCompleteNotification({
    required String questId,
    required String title,
    required int coinReward,
  }) async {
    if (!await areQuestNotificationsEnabled()) return;

    final prefs = await SharedPreferences.getInstance();
    final notifiedQuests = prefs.getStringList('notified_quests') ?? [];

    // Prevent duplicate notifications
    if (notifiedQuests.contains(questId)) return;

    const android = AndroidNotificationDetails(
      'quest_complete',
      'Quest Completed',
      channelDescription: 'Notifications when quests are ready to claim',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const ios = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _plugin.show(
      questId.hashCode,
      'Quest Completed! 🎉',
      '$title - Claim $coinReward coins now!',
      const NotificationDetails(android: android, iOS: ios),
      payload: 'quest_$questId',
    );

    // Mark quest as notified
    notifiedQuests.add(questId);
    await prefs.setStringList('notified_quests', notifiedQuests);
  }

  /// Toggle Quest Notifications
  Future<bool> areQuestNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('quest_notifications_enabled') ?? true;
  }

  Future<void> setQuestNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('quest_notifications_enabled', enabled);
  }

  // ============================================================
  // 📡 PUSH + LOCAL HYBRID (Classroom, Battles, Live Classes)
  // ============================================================

  Future<void> handleFirebaseMessage(Map<String, dynamic> message) async {
    print('Firebase message received: $message');

    final type = message['type'];

    if (type == 'classroom_update') {
      await _showInstantNotification(
        id: DateTime.now().millisecondsSinceEpoch,
        title: 'New Classroom Update',
        body: message['body'] ?? 'Check your classroom for updates.',
        payload: 'classroom_${message['classroomId']}',
      );
    } else if (type == 'battle_invite') {
      await _showInstantNotification(
        id: DateTime.now().millisecondsSinceEpoch,
        title: 'New Battle Invite ⚔️',
        body: '${message['opponent']} challenged you!',
        payload: 'battle_${message['battleId']}',
      );
    } else if (type == 'live_class') {
      await _showInstantNotification(
        id: DateTime.now().millisecondsSinceEpoch,
        title: 'Live Class Starting 📚',
        body: message['body'] ?? 'Your live class is starting soon!',
        payload: 'live_${message['classId']}',
      );
    }
  }

  Future<void> _showInstantNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async {
    const android = AndroidNotificationDetails(
      'push_channel',
      'Push Notifications',
      channelDescription: 'Notifications from the server',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const ios = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(android: android, iOS: ios),
      payload: payload,
    );
  }

  // ============================================================
  // 🧹 COMMON HELPERS
  // ============================================================

  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
    print('Cancelled notification with ID: $id');
  }

  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
    print('Cancelled all notifications');
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _plugin.pendingNotificationRequests();
  }

  static int generateNotificationId(String studentId, DateTime reminderTime) {
    final idString = '${studentId}_${reminderTime.millisecondsSinceEpoch}';
    final id = idString.hashCode.abs();
    print('Generated notification ID: $id for $idString');
    return id;
  }
}
