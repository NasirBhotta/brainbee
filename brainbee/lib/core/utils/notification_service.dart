import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quest_model.dart';

class NotificationService {
  static const String _notificationsEnabledKey = 'quest_notifications_enabled';
  static const String _sentNotificationsKey = 'sent_notifications';
  
  static NotificationService? _instance;
  static NotificationService get instance => _instance ??= NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = 
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  Future<void> _onNotificationTapped(NotificationResponse response) async {
    // Handle notification tap - could navigate to quest screen
    // This would be implemented based on your navigation structure
    print('Notification tapped: ${response.payload}');
  }

  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ?? true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);
  }

  Future<void> showQuestCompleteNotification(Quest quest) async {
    if (!await areNotificationsEnabled()) return;
    if (await _hasNotificationBeenSent(quest.id)) return;

    await _ensureInitialized();

    const androidDetails = AndroidNotificationDetails(
      'quest_complete',
      'Quest Complete',
      channelDescription: 'Notifications for completed quests',
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

    await _notificationsPlugin.show(
      quest.id.hashCode,
      'Quest Complete! 🎉',
      '${quest.title} is ready to claim ${quest.coinReward} coins!',
      details,
      payload: quest.id,
    );

    await _markNotificationAsSent(quest.id);
  }

  Future<void> showCoinRewardNotification(int coins) async {
    if (!await areNotificationsEnabled()) return;

    await _ensureInitialized();

    const androidDetails = AndroidNotificationDetails(
      'coin_reward',
      'Coin Reward',
      channelDescription: 'Notifications for coin rewards',
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

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'Coins Added! 💰',
      '+$coins coins added to your wallet!',
      details,
    );
  }

  Future<bool> _hasNotificationBeenSent(String questId) async {
    final prefs = await SharedPreferences.getInstance();
    final sentNotifications = prefs.getStringList(_sentNotificationsKey) ?? [];
    return sentNotifications.contains(questId);
  }

  Future<void> _markNotificationAsSent(String questId) async {
    final prefs = await SharedPreferences.getInstance();
    final sentNotifications = prefs.getStringList(_sentNotificationsKey) ?? [];
    if (!sentNotifications.contains(questId)) {
      sentNotifications.add(questId);
      await prefs.setStringList(_sentNotificationsKey, sentNotifications);
    }
  }

  Future<void> clearSentNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sentNotificationsKey);
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  Future<void> requestPermissions() async {
    await _ensureInitialized();
    
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }
}