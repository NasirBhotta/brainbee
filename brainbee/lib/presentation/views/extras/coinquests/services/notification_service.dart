import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quest.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  Future<void> _onNotificationTapped(NotificationResponse response) async {
    // Handle notification tap - navigate to coin quest screen
    // This can be extended with navigation logic
    print('Notification tapped: ${response.payload}');
  }

  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('quest_notifications_enabled') ?? true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('quest_notifications_enabled', enabled);
  }

  Future<void> showQuestCompleteNotification(Quest quest) async {
    if (!await areNotificationsEnabled()) return;

    // Check if we've already shown notification for this quest completion
    final prefs = await SharedPreferences.getInstance();
    final notifiedQuests = prefs.getStringList('notified_quests') ?? [];
    final notificationKey =
        '${quest.id}_${quest.completedAt?.millisecondsSinceEpoch}';

    if (notifiedQuests.contains(notificationKey)) return;

    const androidDetails = AndroidNotificationDetails(
      'quest_complete',
      'Quest Completed',
      channelDescription: 'Notifications when quests are ready to claim',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      quest.id.hashCode,
      'Quest Completed! 🎉',
      '${quest.title} - Claim ${quest.coinReward} coins now!',
      details,
      payload: quest.id,
    );

    // Mark this quest as notified
    notifiedQuests.add(notificationKey);
    await prefs.setStringList('notified_quests', notifiedQuests);
  }

  Future<void> cancelQuestNotification(String questId) async {
    await _notifications.cancel(questId.hashCode);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Method to be called when integrating with Firebase later
  Future<void> handleFirebaseMessage(Map<String, dynamic> message) async {
    // This method can be extended when Firebase is integrated
    // For now, it's a placeholder for future Firebase message handling
    print('Firebase message received: $message');

    // Parse the message and show appropriate notification
    if (message['type'] == 'quest_complete') {
      // Handle quest completion from Firebase
      final questId = message['questId'];
      // You would fetch the quest details and show notification
    }
  }
}
