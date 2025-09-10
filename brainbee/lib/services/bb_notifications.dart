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

    tz.initializeTimeZones();

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
  }

  /// Handle tap
  Future<void> _onNotificationTapped(NotificationResponse response) async {
    print('Notification tapped: ${response.payload}');
    // TODO: Route user to correct screen depending on payload
  }

  /// Request permissions
  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      await Permission.notification.request();
      if (await Permission.scheduleExactAlarm.isDenied) {
        await Permission.scheduleExactAlarm.request();
      }
    } else if (Platform.isIOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  // ============================================================
  // 🚀 LOCAL NOTIFICATIONS (Goals, Quests, Achievements, Badges)
  // ============================================================

  /// 🔔 One-time Goal Reminder
  Future<void> scheduleGoalReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    final scheduledTZ = tz.TZDateTime.from(scheduledTime, tz.local);
    if (scheduledTZ.isBefore(tz.TZDateTime.now(tz.local))) return;

    const android = AndroidNotificationDetails(
      'goal_reminders',
      'Goal Reminders',
      channelDescription: 'Notifications for daily goal reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      sound: RawResourceAndroidNotificationSound('notification_sound'),
    );

    const ios = DarwinNotificationDetails(
      sound: 'default',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTZ,
      const NotificationDetails(android: android, iOS: ios),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'goal_reminder_$id',
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

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
  }

  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _plugin.pendingNotificationRequests();
  }

  static int generateNotificationId(String key) {
    return key.hashCode.abs();
  }
}
