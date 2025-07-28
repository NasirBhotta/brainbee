class ApiConfig {
  // TODO: Replace with your actual backend base URL when ready
  static const String baseUrl = 'https://dummy-backend-api.com'; // Dummy URL for now
  
  // Enable/disable API calls (set to false to use dummy responses)
  static const bool enableApiCalls = false; // TODO: Set to true when backend is ready
  
  // Notification endpoints
  static const String fcmTokenEndpoint = '/api/users/fcm-token';
  static const String sendNotificationEndpoint = '/api/notifications/send';
  static const String notificationPreferencesEndpoint = '/api/users/notification-preferences';
  
  // Quest-related endpoints (for future backend sync)
  static const String questsEndpoint = '/api/quests';
  static const String walletEndpoint = '/api/wallet';
  static const String claimQuestEndpoint = '/api/quests/claim';
  
  // Headers
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer dummy_token', // TODO: Add real auth token
  };
  
  // Helper method to get full URL
  static String getFullUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
}