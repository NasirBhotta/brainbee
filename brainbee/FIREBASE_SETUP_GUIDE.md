# Firebase Cloud Messaging (FCM) Setup Guide

## 📱 Flutter App Setup

### 1. Add Firebase Dependencies
The following dependencies are already added to `pubspec.yaml`:
```yaml
dependencies:
  firebase_core: ^3.6.0
  firebase_messaging: ^15.1.3
```

### 2. Configure Firebase for Flutter

#### Android Setup:
1. Place your `google-services.json` file in `android/app/`
2. Update `android/build.gradle`:
```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.4.0'
}
```

3. Update `android/app/build.gradle`:
```gradle
apply plugin: 'com.google.gms.google-services'

dependencies {
    implementation 'com.google.firebase:firebase-messaging:23.4.0'
}
```

4. Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.VIBRATE" />

<application>
    <!-- Existing configuration -->
    
    <!-- Firebase Messaging Service -->
    <service
        android:name="io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingService"
        android:exported="false">
        <intent-filter>
            <action android:name="com.google.firebase.MESSAGING_EVENT" />
        </intent-filter>
    </service>
</application>
```

#### iOS Setup:
1. Place your `GoogleService-Info.plist` file in `ios/Runner/`
2. Update `ios/Podfile`:
```ruby
platform :ios, '12.0'
```

3. Add to `ios/Runner/Info.plist`:
```xml
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>
```

### 3. Initialize Firebase in Your App

Update your `main.dart`:
```dart
import 'package:firebase_core/firebase_core.dart';
import 'lib/core/utils/quest_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize quest notifications
  await QuestHelper.instance.initializeNotifications();
  
  runApp(MyApp());
}
```

### 4. Configure Backend API

Update `lib/core/utils/api_config.dart` with your backend URL:
```dart
class ApiConfig {
  static const String baseUrl = 'https://your-actual-backend-url.com';
  // ... rest of the config
}
```

## 🔧 Backend Integration Points

Your Node.js backend needs to handle these endpoints:

### 1. FCM Token Registration
**Endpoint:** `POST /api/users/fcm-token`

**Request Body:**
```json
{
  "fcmToken": "user_fcm_token_here",
  "platform": "flutter",
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

**Purpose:** Store user's FCM token for sending notifications

### 2. Send Notification Request
**Endpoint:** `POST /api/notifications/send`

**Request Body:**
```json
{
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

**Purpose:** Flutter app requests backend to send FCM notification

### 3. Notification Preferences
**Endpoint:** `POST /api/users/notification-preferences`

**Request Body:**
```json
{
  "fcmToken": "user_fcm_token_here",
  "questNotificationsEnabled": true,
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

**Purpose:** Update user's notification preferences

## 🔔 Backend FCM Implementation Example

Here's how your Node.js backend should handle FCM:

### Install Firebase Admin SDK:
```bash
npm install firebase-admin
```

### Initialize Firebase Admin:
```javascript
const admin = require('firebase-admin');
const serviceAccount = require('./path/to/serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});
```

### Send Notification Function:
```javascript
async function sendFCMNotification(fcmToken, notificationData) {
  try {
    const message = {
      token: fcmToken,
      notification: {
        title: notificationData.title,
        body: notificationData.body,
      },
      data: notificationData.data || {},
      android: {
        notification: {
          icon: 'ic_notification',
          color: '#6366F1',
          sound: 'default',
        },
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
            badge: 1,
          },
        },
      },
    };

    const response = await admin.messaging().send(message);
    console.log('Successfully sent message:', response);
    return response;
  } catch (error) {
    console.error('Error sending message:', error);
    throw error;
  }
}
```

### API Route Examples:
```javascript
// Store FCM token
app.post('/api/users/fcm-token', async (req, res) => {
  try {
    const { fcmToken, platform, timestamp } = req.body;
    
    // Store token in your database associated with user
    await User.findByIdAndUpdate(userId, {
      fcmToken: fcmToken,
      platform: platform,
      lastTokenUpdate: timestamp,
    });
    
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Send notification
app.post('/api/notifications/send', async (req, res) => {
  try {
    const { fcmToken, notification } = req.body;
    
    // Check if user has notifications enabled
    const user = await User.findOne({ fcmToken });
    if (!user?.questNotificationsEnabled) {
      return res.json({ success: false, reason: 'Notifications disabled' });
    }
    
    await sendFCMNotification(fcmToken, notification);
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Update preferences
app.post('/api/users/notification-preferences', async (req, res) => {
  try {
    const { fcmToken, questNotificationsEnabled } = req.body;
    
    await User.findOneAndUpdate(
      { fcmToken },
      { questNotificationsEnabled }
    );
    
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
```

## 📊 Database Schema

Add these fields to your User model:

```javascript
// MongoDB/Mongoose example
const userSchema = new mongoose.Schema({
  // ... existing fields
  fcmToken: String,
  platform: String,
  questNotificationsEnabled: { type: Boolean, default: true },
  lastTokenUpdate: Date,
});
```

## 🧪 Testing Notifications

### 1. Test FCM Token Registration:
- Install and run the app
- Check your backend logs for FCM token registration
- Verify token is stored in your database

### 2. Test Quest Completion:
- Use the `QuestDemoScreen` to trigger quest completion
- Check backend receives notification request
- Verify FCM notification is sent and received

### 3. Test Notification Preferences:
- Toggle notifications in the demo screen
- Verify preferences are updated on backend
- Test that notifications respect user preferences

## 🚨 Important Notes

### Security:
- Never expose your Firebase server key in client code
- Use Firebase Admin SDK on your backend only
- Validate all incoming requests

### Error Handling:
- Handle FCM token refresh properly
- Gracefully handle notification send failures
- Log errors for debugging

### Testing:
- Test on both Android and iOS devices
- Test with app in foreground, background, and terminated states
- Test notification tap behavior

### Production Considerations:
- Set up proper Firebase project for production
- Configure notification icons and sounds
- Handle notification batching for multiple users
- Monitor FCM quota and usage

This setup ensures your Flutter app properly integrates with Firebase and your Node.js backend for quest notifications! 🔔