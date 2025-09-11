// Add this new service class to handle goal notification preferences
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoalNotificationPreferences {
  static const String _goalNotificationsKey = 'goal_notifications_enabled';
  static const String _questNotificationsKey = 'quest_notifications_enabled';

  /// Get goal notification preference (default: true)
  static Future<bool> isGoalNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_goalNotificationsKey) ?? true;
  }

  /// Set goal notification preference
  static Future<void> setGoalNotificationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_goalNotificationsKey, enabled);
    print('Goal notifications preference set to: $enabled');
  }

  /// Get quest notification preference (default: true)
  // static Future<bool> isQuestNotificationEnabled() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.getBool(_questNotificationsKey) ?? true;
  // }

  /// Set quest notification preference
  static Future<void> setQuestNotificationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_questNotificationsKey, enabled);
    print('Quest notifications preference set to: $enabled');
  }

  /// Check if system notification permission is granted
  static Future<bool> hasSystemNotificationPermission() async {
    try {
      final status = await Permission.notification.status;
      return status.isGranted;
    } catch (e) {
      print('Error checking system notification permission: $e');
      return false;
    }
  }

  /// Check if we can actually send goal notifications
  /// (both app preference enabled AND system permission granted)
  static Future<bool> canSendGoalNotifications() async {
    final appPreference = await isGoalNotificationEnabled();
    final systemPermission = await hasSystemNotificationPermission();
    return appPreference && systemPermission;
  }
}
