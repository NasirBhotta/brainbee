class ApiConfig {
  // Replace with your actual backend base URL
  static const String baseUrl = 'https://your-backend-api.com'; // TODO: Update this
  
  // Notification endpoints
  static const String fcmTokenEndpoint = '/api/users/fcm-token';
  static const String sendNotificationEndpoint = '/api/notifications/send';
  static const String notificationPreferencesEndpoint = '/api/users/notification-preferences';
  
  // Quest-related endpoints (if you want to sync with backend in the future)
  static const String questsEndpoint = '/api/quests';
  static const String walletEndpoint = '/api/wallet';
  static const String claimQuestEndpoint = '/api/quests/claim';
  
  // Headers
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Helper method to get full URL
  static String getFullUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
}