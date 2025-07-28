import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../models/quest_model.dart';
import 'api_config.dart';

class NotificationService {
  static const String _notificationsEnabledKey = 'quest_notifications_enabled';
  static const String _sentNotificationsKey = 'sent_notifications';
  static const String _fcmTokenKey = 'fcm_token';
  
  static NotificationService? _instance;
  static NotificationService get instance => _instance ??= NotificationService._();
  NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  late final Dio _dio;
  bool _isInitialized = false;
  String? _currentToken;

  NotificationService._() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      headers: ApiConfig.defaultHeaders,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Request notification permissions
    await _requestPermissions();

    // Get FCM token
    await _getFCMToken();

    // Set up message handlers
    _setupMessageHandlers();

    _isInitialized = true;
  }

  Future<void> _requestPermissions() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );

    print('Notification permission status: ${settings.authorizationStatus}');
  }

  Future<void> _getFCMToken() async {
    try {
      _currentToken = await _messaging.getToken();
      if (_currentToken != null) {
        await _saveFCMToken(_currentToken!);
        // Send token to your backend
        await _sendTokenToBackend(_currentToken!);
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) async {
        _currentToken = newToken;
        await _saveFCMToken(newToken);
        await _sendTokenToBackend(newToken);
      });
    } catch (e) {
      print('Error getting FCM token: $e');
    }
  }

  Future<void> _saveFCMToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fcmTokenKey, token);
  }

  Future<String?> getFCMToken() async {
    if (_currentToken != null) return _currentToken;
    
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_fcmTokenKey);
  }

  Future<void> _sendTokenToBackend(String token) async {
    try {
      await _dio.post(
        ApiConfig.fcmTokenEndpoint,
        data: {
          'fcmToken': token,
          'platform': 'flutter',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      print('FCM token sent to backend successfully');
    } catch (e) {
      print('Failed to send FCM token to backend: $e');
    }
  }

  void _setupMessageHandlers() {
    // Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received foreground message: ${message.notification?.title}');
      _handleMessage(message);
    });

    // Handle messages when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('App opened from notification: ${message.notification?.title}');
      _handleMessageTap(message);
    });

    // Handle messages when app is opened from terminated state
    FirebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('App opened from terminated state: ${message.notification?.title}');
        _handleMessageTap(message);
      }
    });
  }

  void _handleMessage(RemoteMessage message) {
    // Handle incoming FCM message when app is in foreground
    // You can show local notification or update UI here
    print('Handling message: ${message.data}');
  }

  void _handleMessageTap(RemoteMessage message) {
    // Handle notification tap - navigate to quest screen
    // This would be implemented based on your navigation structure
    print('Notification tapped: ${message.data}');
    
    // You can add navigation logic here based on message data
    if (message.data['type'] == 'quest_complete') {
      // Navigate to quest screen
      // NavigationService.instance.navigateToQuests();
    }
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

    // Send notification request to your backend
    await _sendNotificationToBackend({
      'type': 'quest_complete',
      'questId': quest.id,
      'title': 'Quest Complete! 🎉',
      'body': '${quest.title} is ready to claim ${quest.coinReward} coins!',
      'data': {
        'questId': quest.id,
        'questTitle': quest.title,
        'coinReward': quest.coinReward.toString(),
        'type': 'quest_complete',
      },
    });

    await _markNotificationAsSent(quest.id);
  }

  Future<void> showCoinRewardNotification(int coins) async {
    if (!await areNotificationsEnabled()) return;

    await _ensureInitialized();

    // Send notification request to your backend
    await _sendNotificationToBackend({
      'type': 'coin_reward',
      'title': 'Coins Added! 💰',
      'body': '+$coins coins added to your wallet!',
      'data': {
        'coins': coins.toString(),
        'type': 'coin_reward',
      },
    });
  }

  Future<void> _sendNotificationToBackend(Map<String, dynamic> notificationData) async {
    try {
      final token = await getFCMToken();
      if (token == null) {
        print('No FCM token available for sending notification');
        return;
      }

      await _dio.post(
        ApiConfig.sendNotificationEndpoint,
        data: {
          'fcmToken': token,
          'notification': notificationData,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      
      print('Notification sent to backend successfully');
    } catch (e) {
      print('Failed to send notification to backend: $e');
    }
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
    // Permissions are already requested in _requestPermissions() during initialization
  }

  // Method to update backend with user notification preferences
  Future<void> updateNotificationPreferences(bool enabled) async {
    try {
      final token = await getFCMToken();
      if (token == null) return;

      await _dio.post(
        ApiConfig.notificationPreferencesEndpoint,
        data: {
          'fcmToken': token,
          'questNotificationsEnabled': enabled,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      
      print('Notification preferences updated on backend');
    } catch (e) {
      print('Failed to update notification preferences: $e');
    }
  }
}