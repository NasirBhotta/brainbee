# Coin Quests Feature - Implementation Guide

## 🎯 Overview

This implementation provides a complete **Coin Quests** system for the BrainBee app based on your functional requirements. Students can complete daily, weekly, and one-time quests to earn coins that are stored in their digital wallet.

## 📋 Features Implemented

### ✅ FR-01: Coin Quests Setup
- ✅ Three quest types: Daily, Weekly, One-Time
- ✅ Quest properties: Title, Description, Coin reward, Type, Status
- ✅ Status tracking: Incomplete, Complete, Claimed
- ✅ Automatic reset system for daily/weekly quests
- ✅ One-time quests remain visible after completion

### ✅ FR-02: Quest UI Display
- ✅ Beautiful card-based quest display
- ✅ Icons, titles, coin rewards, and status indicators
- ✅ "Claim Now" button with proper state management
- ✅ Disabled states for incomplete/already claimed quests

### ✅ FR-03: Quest Claim Logic
- ✅ Confirmation popup before claiming
- ✅ Success popup showing coins earned
- ✅ Instant wallet updates
- ✅ Prevention of double-claiming
- ✅ Proper reset logic for repeatable quests

### ✅ FR-04: Coin Wallet Management
- ✅ Student wallet with coin balance tracking
- ✅ Instant updates on earn/spend
- ✅ Balance display in UI
- ✅ Negative balance prevention

### ✅ FR-05: Coin Notifications
- ✅ Push + in-app notifications for completed quests
- ✅ One notification per claimable quest
- ✅ User settings to enable/disable notifications
- ✅ Coin reward notifications when claimed

## 📁 File Structure

```
brainbee/lib/
├── core/
│   ├── models/
│   │   ├── quest_model.dart          # Quest data model
│   │   ├── quest_model.g.dart        # Generated JSON serialization
│   │   ├── wallet_model.dart         # Wallet data model
│   │   └── wallet_model.g.dart       # Generated JSON serialization
│   ├── utils/
│   │   ├── quest_repository.dart     # Data management & storage
│   │   ├── notification_service.dart # Push notifications
│   │   └── quest_helper.dart         # Easy integration utility
│   └── widgets/
│       ├── quest_card.dart           # Reusable quest card UI
│       └── wallet_display.dart       # Wallet balance display
└── presentation/
    ├── bloc/
    │   └── quest_bloc.dart           # BLoC state management
    └── views/
        ├── coin_quest_screen.dart    # Main quest screen
        └── quest_demo_screen.dart    # Demo/testing screen
```

## 🚀 Quick Start

### 1. Add to Your App

Add this import to any screen where you want to show the Coin Quests:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'lib/presentation/bloc/quest_bloc.dart';
import 'lib/presentation/views/coin_quest_screen.dart';

// Navigate to Coin Quests screen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => BlocProvider(
      create: (context) => QuestBloc(),
      child: const CoinQuestScreen(),
    ),
  ),
);
```

### 2. Initialize Firebase & Notifications (in main.dart)

```dart
import 'package:firebase_core/firebase_core.dart';
import 'lib/core/utils/quest_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (required for FCM)
  await Firebase.initializeApp();
  
  // Initialize quest notifications
  await QuestHelper.instance.initializeNotifications();
  
  runApp(MyApp());
}
```

### 3. Trigger Quest Completion

Throughout your app, add these calls when students complete activities:

```dart
import 'lib/core/utils/quest_helper.dart';

// When student logs in daily
await QuestHelper.instance.onDailyLogin();

// When student completes a lesson
await QuestHelper.instance.onLessonCompleted();

// When student takes a quiz
await QuestHelper.instance.onQuizCompleted();

// When student completes first lesson ever
await QuestHelper.instance.onFirstLessonCompleted();

// When student completes profile setup
await QuestHelper.instance.onProfileSetupCompleted();

// When student gets perfect score (100%)
await QuestHelper.instance.onPerfectScoreAchieved();

// When student maintains learning streak
await QuestHelper.instance.onLearningStreakMaintained(5); // 5 days

// When student completes multiple subjects
await QuestHelper.instance.onMultiSubjectProgress(3); // 3 subjects
```

## 🎮 Testing the Feature

### Demo Screen
Use the included `QuestDemoScreen` to test all functionality:

```dart
import 'lib/presentation/views/quest_demo_screen.dart';

Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const QuestDemoScreen()),
);
```

The demo screen lets you:
- ✅ Simulate completing all quest types
- ✅ View current wallet balance
- ✅ Test coin spending
- ✅ Reset all data for testing
- ✅ Toggle notification settings

## 💰 Wallet Integration

### Check Balance
```dart
final balance = await QuestHelper.instance.getWalletBalance();
print('Student has $balance coins');
```

### Spend Coins
```dart
final success = await QuestHelper.instance.spendCoins(50);
if (success) {
  print('Purchase successful!');
} else {
  print('Insufficient balance');
}
```

### Check Affordability
```dart
final canAfford = await QuestHelper.instance.canAfford(100);
if (canAfford) {
  // Show purchase option
}
```

## 🔔 Notification Management

### Check Settings
```dart
final enabled = await QuestHelper.instance.areNotificationsEnabled();
```

### Toggle Notifications
```dart
await QuestHelper.instance.setNotificationsEnabled(false); // Disable
await QuestHelper.instance.setNotificationsEnabled(true);  // Enable
```

## 🏗️ Architecture

### State Management
- **BLoC Pattern**: Used for reactive state management
- **Repository Pattern**: Separates data logic from UI
- **Singleton Services**: QuestHelper, NotificationService for app-wide access

### Data Storage
- **SharedPreferences**: Local storage for quests and wallet data
- **JSON Serialization**: Automatic conversion between models and storage
- **Automatic Persistence**: All changes are immediately saved

### Reset Logic
- **Daily Quests**: Reset every 24 hours
- **Weekly Quests**: Reset every 7 days  
- **One-Time Quests**: Never reset, remain visible when completed
- **Automatic Checking**: System checks for resets every hour

## 🎨 UI Components

### QuestCard
Displays individual quest information with:
- Quest icon and title
- Description and coin reward
- Type indicator (Daily/Weekly/One-time)
- Status-based action buttons
- Beautiful gradient backgrounds

### WalletDisplay
Shows current coin balance with:
- Prominent coin count
- Wallet icon
- Golden gradient design
- Refresh capability

## 📱 Sample Quests Included

### Daily Quests (Reset every 24 hours)
- **Daily Login** - 10 coins
- **Complete a Lesson** - 25 coins  
- **Take a Quiz** - 20 coins

### Weekly Quests (Reset every 7 days)
- **Weekly Learning Streak** - 100 coins (5 days)
- **Multi-Subject Mastery** - 75 coins (3 subjects)

### One-Time Quests (Never reset)
- **First Lesson Completed** - 50 coins
- **Profile Setup** - 30 coins
- **Perfect Score Achievement** - 80 coins

## 🔧 Customization

### Adding New Quests
Edit `quest_repository.dart` in the `_getSampleQuests()` method:

```dart
Quest(
  id: 'my_new_quest',
  title: 'My New Quest',
  description: 'Complete this awesome task',
  coinReward: 30,
  type: QuestType.daily,
  status: QuestStatus.incomplete,
  iconPath: 'assets/my_icon.png',
  createdAt: now,
  lastResetAt: now, // Only for daily/weekly
),
```

### Modifying Rewards
Change the `coinReward` values in the sample quests or when creating new ones.

### Styling
Customize colors and gradients in:
- `quest_card.dart` - Quest card appearance
- `wallet_display.dart` - Wallet styling
- `coin_quest_screen.dart` - Main screen theme

## 🚨 Important Notes

### Dependencies
Make sure these are in your `pubspec.yaml`:
```yaml
dependencies:
  shared_preferences: ^2.3.3
  firebase_core: ^3.6.0
  firebase_messaging: ^15.1.3
  flutter_bloc: ^9.1.1
  equatable: ^2.0.7
  json_annotation: ^4.9.0
  dio: ^5.8.0+1

dev_dependencies:
  build_runner: ^2.6.0
```

### Firebase Setup
For notifications to work, you need to set up Firebase:
- Follow the complete `FIREBASE_SETUP_GUIDE.md` for detailed instructions
- Configure FCM tokens and backend integration
- The code automatically requests permissions
- Users can disable notifications in quest settings

### Backend Configuration
Update `lib/core/utils/api_config.dart` with your actual backend URL:
```dart
static const String baseUrl = 'https://your-backend-api.com';
```

### Asset Requirements
Make sure you have coin icons in your assets folder:
- `assets/coin.png` - Main coin icon
- Other quest icons as specified in quest data

## 🔄 Data Persistence

All quest and wallet data is automatically saved to device storage using SharedPreferences. Data persists between app sessions and device restarts.

### Manual Data Management
```dart
// Clear all quest and wallet data (for testing)
await QuestRepository.instance.clearAllData();

// Force refresh quest reset logic
await QuestRepository.instance.refreshQuests();
```

## 📞 Integration Examples

### In a Lesson Completion Screen:
```dart
class LessonCompletedScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ... your UI
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Mark lesson as complete
          await QuestHelper.instance.onLessonCompleted();
          
          // Show quest screen
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => QuestBloc(),
              child: const CoinQuestScreen(),
            ),
          ));
        },
        child: Icon(Icons.stars),
      ),
    );
  }
}
```

### In a Quiz Results Screen:
```dart
void onQuizCompleted(int score, int totalQuestions) async {
  // Trigger quiz completion quest
  await QuestHelper.instance.onQuizCompleted();
  
  // Check for perfect score
  if (score == totalQuestions) {
    await QuestHelper.instance.onPerfectScoreAchieved();
  }
}
```

This implementation is ready to use and fully meets all your functional requirements! 🎉