# Development Guide - Coin Quests Feature

## 🚀 Current Development Setup

The Coin Quests feature is currently configured with **dummy API integration** to allow development and testing without a live backend. All Firebase FCM setup remains intact and ready for production.

## 🔧 Dummy API Configuration

### Current State:
- **API Calls**: Disabled (using dummy responses)
- **Firebase FCM**: Fully configured and ready
- **Local Storage**: Working for quests and wallet data
- **UI/UX**: Fully functional

### Configuration File: `lib/core/utils/api_config.dart`

```dart
class ApiConfig {
  static const bool enableApiCalls = false; // 👈 Currently disabled
  static const String baseUrl = 'https://dummy-backend-api.com'; // 👈 Dummy URL
  
  // TODO: Update these when backend is ready
}
```

## 📋 What's Currently Working

### ✅ **Fully Functional (No Backend Needed)**:
- Quest display and management
- Wallet balance tracking
- Quest completion logic
- Coin claiming with confirmations
- Quest reset system (daily/weekly/one-time)
- UI animations and state management
- Local data persistence

### ✅ **Firebase FCM Ready**:
- FCM token generation and storage
- Notification permission handling
- Message handling (foreground/background)
- All Firebase configuration complete

### ✅ **Dummy API Simulation**:
- FCM token "sending" to backend (logged)
- Notification "requests" to backend (logged)
- User preference "updates" (logged)
- Realistic network delays simulated

## 📱 Testing the Feature

### **1. Install and Test:**
```bash
flutter pub get
flutter run
```

### **2. Use Demo Screen:**
Navigate to `QuestDemoScreen` to test:
- ✅ Quest completion simulation
- ✅ Coin earning and spending
- ✅ Notification preference toggles
- ✅ Wallet balance updates
- ✅ Data persistence testing

### **3. Check Console Logs:**
Look for these dummy API logs:
```
DUMMY API: FCM token would be sent to backend: eyJ0eXAi...
DUMMY API: Notification would be sent to backend
FCM Token: eyJ0eXAiOiJKV1QiLCJ...
Notification Data: Quest Complete! 🎉 - Daily Login is ready to claim 10 coins!
SIMULATED FCM: Quest Complete! 🎉 - Daily Login is ready to claim 10 coins!
```

## 🔄 Transitioning to Real Backend

When your Node.js backend is ready, follow these steps:

### **Step 1: Update API Configuration**

```dart
// lib/core/utils/api_config.dart
class ApiConfig {
  static const bool enableApiCalls = true; // 👈 Enable real API calls
  static const String baseUrl = 'https://your-actual-backend.com'; // 👈 Your real URL
  
  // Update headers with real authentication
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer ${UserSession.authToken}', // 👈 Real auth token
  };
}
```

### **Step 2: Backend Endpoints to Implement**

Your Node.js backend needs these endpoints:

#### **1. FCM Token Registration**
```javascript
POST /api/users/fcm-token
Body: {
  "fcmToken": "user_fcm_token_here",
  "platform": "flutter",
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

#### **2. Send Notification Request**
```javascript
POST /api/notifications/send
Body: {
  "fcmToken": "user_fcm_token_here",
  "notification": {
    "type": "quest_complete",
    "questId": "daily_login",
    "title": "Quest Complete! 🎉",
    "body": "Daily Login is ready to claim 10 coins!",
    "data": {
      "questId": "daily_login",
      "questTitle": "Daily Login",
      "coinReward": "10",
      "type": "quest_complete"
    }
  },
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

#### **3. Notification Preferences**
```javascript
POST /api/users/notification-preferences
Body: {
  "fcmToken": "user_fcm_token_here",
  "questNotificationsEnabled": true,
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

### **Step 3: Optional - Sync Quest Data with Backend**

If you want to sync quest/wallet data with backend (currently local-only):

```dart
// Add these methods to QuestRepository when ready
Future<void> syncQuestsWithBackend() async {
  if (!ApiConfig.enableApiCalls) return;
  
  try {
    final response = await _dio.get(ApiConfig.questsEndpoint);
    // Handle backend quest sync
  } catch (e) {
    print('Failed to sync quests: $e');
  }
}

Future<void> syncWalletWithBackend() async {
  if (!ApiConfig.enableApiCalls) return;
  
  try {
    final response = await _dio.get(ApiConfig.walletEndpoint);
    // Handle backend wallet sync
  } catch (e) {
    print('Failed to sync wallet: $e');
  }
}
```

## 🧪 Testing Strategy

### **Phase 1: Current (Dummy APIs)**
- ✅ Test all UI functionality
- ✅ Test quest completion flows
- ✅ Test wallet operations
- ✅ Test notification preferences
- ✅ Test data persistence

### **Phase 2: Backend Integration**
- 🔄 Test FCM token registration
- 🔄 Test notification sending
- 🔄 Test preference updates
- 🔄 Test error handling
- 🔄 Test authentication

### **Phase 3: Production Ready**
- 🔄 Load testing
- 🔄 Notification delivery testing
- 🔄 Cross-device testing
- 🔄 Analytics integration

## 🔍 Debug Information

### **Enable Debug Logs:**
The app logs all API interactions. Look for:
- `DUMMY API:` - Simulated backend calls
- `SIMULATED FCM:` - Simulated notifications
- `FCM token:` - Firebase token generation
- Quest completion and wallet updates

### **Common Debug Scenarios:**

1. **Quest not completing?**
   - Check `QuestHelper.instance.onLessonCompleted()` calls
   - Verify quest status in local storage

2. **Notifications not showing?**
   - Check Firebase configuration
   - Verify notification permissions
   - Check console for FCM token generation

3. **Wallet not updating?**
   - Check quest claim flow
   - Verify local storage persistence

## 📊 Current Data Flow

```
User Action (Complete Lesson)
    ↓
QuestHelper.onLessonCompleted()
    ↓
QuestRepository.markQuestComplete()
    ↓
NotificationService.showQuestCompleteNotification()
    ↓
[DUMMY] Log API call to backend
    ↓
[DUMMY] Simulate FCM notification
    ↓
Update local storage
    ↓
Update UI via BLoC
```

## 🚨 Important Notes

### **What to NOT Change:**
- ✅ Firebase FCM configuration (already correct)
- ✅ Quest logic and UI (fully working)
- ✅ BLoC state management (production ready)
- ✅ Local storage implementation (reliable)

### **What to Update Later:**
- 🔄 API base URL in `ApiConfig`
- 🔄 Enable `enableApiCalls` flag
- 🔄 Add real authentication tokens
- 🔄 Implement backend endpoints

### **Development Benefits:**
- 🎯 Test UI/UX without backend dependency
- 🎯 Develop quest logic independently
- 🎯 Validate user flows early
- 🎯 Easy transition to real backend
- 🎯 Firebase FCM ready for production

This setup allows you to **develop and test the complete Coin Quests feature** while your backend is still under development, then seamlessly transition to real API integration when ready! 🚀