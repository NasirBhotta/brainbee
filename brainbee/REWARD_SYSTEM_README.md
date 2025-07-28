# 🎁 BrainBee Reward System

A complete reward catalog and redemption system implementation for the BrainBee Flutter app, following all functional requirements (FR-06, FR-07, FR-08).

## 📋 Features Implemented

### ✅ FR-06: Reward Catalog System
- **FR-06.01**: Complete reward catalog where students can redeem coins
- **FR-06.02**: Each reward item includes:
  - Image/Icon (custom gradient icons with reward-specific designs)
  - Title
  - Coin Price
  - Redeem button
  - Current status (Available, Redeemed, Insufficient Coins)
- **FR-06.03**: No filtering or categories (simple grid layout)
- **FR-06.04**: Detailed reward page with:
  - Description
  - Redemption instructions
  - Terms & conditions

### ✅ FR-07: Reward Redemption Flow
- **FR-07.01**: Complete redemption flow:
  - Tap "Redeem" button
  - Automatic coin balance check
  - Confirmation popup with review
  - User input for required details (PUBG ID, Email, etc.)
  - Final confirmation step
- **FR-07.02**: Post-redemption handling:
  - Success message display
  - Automatic coin deduction
  - Status update to "Redeemed"
  - One-time reward restriction
- **FR-07.03**: Insufficient coins handling:
  - Clear error messages
  - Visual indicators
- **FR-07.04**: Non-refundable system implemented
- **FR-07.05**: Daily redemption limit of 600 coins per student

### ✅ FR-08: Redeemed Reward Visibility
- **FR-08.01**: Redeemed rewards visible in same catalog
- **FR-08.02**: Redeemed items show:
  - "Redeemed" badge
  - Disabled redeem button
- **FR-08.03**: No separate history screen (unified catalog)
- **FR-08.04**: Submitted information is non-editable
- **FR-08.05**: Redemption confirmation system:
  - In-app success confirmation
  - Email notification placeholder

## 🎨 Design Features

- **Modern UI**: Consistent with BrainBee theme using Poppins fonts and brand colors
- **Gradient Designs**: Beautiful gradient backgrounds and button designs
- **Status Indicators**: Clear visual feedback for different reward states
- **Responsive Layout**: Grid-based layout that works on various screen sizes
- **Smooth Animations**: Loading states and transitions
- **User-Friendly**: Intuitive navigation and clear information hierarchy

## 📁 Project Structure

```
lib/
├── core/
│   ├── models/
│   │   └── reward_model.dart          # Reward data model
│   ├── constants/
│   │   └── bb_colors.dart            # Color constants
│   └── theme/
│       └── bb_theme.dart             # App theme
└── presentation/
    └── views/
        └── rewards/
            ├── reward_catalog_screen.dart    # Main catalog screen
            ├── reward_detail_screen.dart     # Detailed reward view
            ├── reward_demo_screen.dart       # Demo/showcase screen
            ├── rewards.dart                  # Export file
            └── widgets/
                ├── reward_card.dart          # Individual reward card
                └── redemption_bottom_sheet.dart # Redemption flow
```

## 🚀 How to Run

1. **Prerequisites**:
   ```bash
   flutter --version  # Ensure Flutter is installed
   ```

2. **Install Dependencies**:
   ```bash
   cd brainbee
   flutter pub get
   ```

3. **Run the App**:
   ```bash
   flutter run
   ```

The app will launch with the reward system demo. To see the full reward catalog, tap "Open Reward Store".

## 🔧 Integration Guide

### Quick Integration

```dart
import 'package:brainbee/presentation/views/rewards/rewards.dart';

// Navigate to reward catalog
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const RewardCatalogScreen()),
);
```

### Backend Integration Points

1. **Replace Mock Data**: 
   - Update `RewardCatalogScreen` to fetch rewards from your API
   - Replace the hardcoded reward list with API calls

2. **User Coin Balance**:
   - Connect `currentCoins` to your user management system
   - Update coin balance after successful redemptions

3. **Redemption Logic**:
   - Implement actual redemption in `RedemptionBottomSheet._confirmRedemption()`
   - Add real API calls for reward processing

4. **Email Notifications**:
   - Integrate with your email service in the success handler
   - Send confirmation emails to users

5. **Daily Limits**:
   - Track daily redemption amounts in your backend
   - Update limit checking logic

### Custom Rewards

```dart
final customReward = RewardModel(
  id: 'unique_id',
  title: 'Custom Reward',
  description: 'Detailed description',
  imageUrl: 'https://your-image-url.com',
  coinPrice: 500,
  status: RewardStatus.available,
  redemptionInstructions: 'How to redeem instructions',
  termsAndConditions: 'Terms and conditions text',
  requiresUserInput: true,
  inputLabel: 'Required Field',
  inputPlaceholder: 'Enter information',
);
```

## 🎯 Sample Rewards Included

The demo includes 6 sample rewards:
- **PUBG Mobile UC** (500 coins) - Gaming currency
- **Amazon Gift Card** (800 coins) - Shopping voucher
- **Spotify Premium** (300 coins) - Music subscription
- **Netflix Subscription** (1200 coins) - Video streaming
- **Gaming Mouse** (2000 coins) - Physical product
- **Discord Nitro** (250 coins) - Chat platform premium

## 🛠 Customization

### Colors
Modify `BBColors` in `lib/core/constants/bb_colors.dart` to match your brand:
```dart
static const primaryColor = Color.fromRGBO(135, 219, 139, 1);
static const secondaryColor = Color.fromRGBO(75, 182, 154, 1);
```

### Typography
Update fonts in `lib/core/theme/bb_theme.dart`:
```dart
textTheme: TextTheme(
  headlineSmall: GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  ),
  // ... other text styles
),
```

### Reward Icons
Customize reward icons in `RewardCard._getRewardIcon()`:
```dart
IconData _getRewardIcon() {
  switch (reward.title.toLowerCase()) {
    case 'your reward':
      return Icons.your_icon;
    default:
      return Icons.redeem;
  }
}
```

## 📱 User Flow

1. **Browse Catalog**: Grid view of all available rewards
2. **View Details**: Tap any reward to see full information
3. **Initiate Redemption**: Tap "Redeem Now" if eligible
4. **Enter Information**: Fill required fields (email, ID, etc.)
5. **Review Details**: Confirm all information is correct
6. **Complete Redemption**: Final confirmation and success message
7. **Updated Status**: Reward marked as redeemed in catalog

## 🔒 Security Considerations

- **Input Validation**: All user inputs are validated client-side
- **Non-Refundable**: Clear warnings about irreversible actions
- **Daily Limits**: Built-in protection against excessive redemptions
- **Email Validation**: Proper email format validation for email-based rewards

## 🎨 UI Components

### RewardCard
- Modern card design with shadows
- Status badges (Available, Redeemed, Insufficient)
- Gradient backgrounds
- Icon-based reward representation

### RewardDetailScreen
- Expandable app bar with gradient
- Sectioned information display
- Status-based action buttons
- Floating redemption button

### RedemptionBottomSheet
- Two-step redemption process
- Form validation
- Confirmation review
- Loading states

## 🚀 Production Deployment

1. **Restore Original Home**: Change main.dart home back to `SplashScreen()`
2. **Remove Demo Code**: Delete `reward_demo_screen.dart` if not needed
3. **Update Mock Data**: Replace all mock data with real API calls
4. **Configure Backend**: Set up reward management in your backend
5. **Test Thoroughly**: Test all redemption flows end-to-end

## 🆘 Troubleshooting

### Common Issues

1. **Import Errors**: Make sure all files are in correct directories
2. **Theme Issues**: Ensure BrainBeeTheme is properly configured
3. **Navigation Issues**: Check MaterialApp is properly set up
4. **Build Errors**: Run `flutter pub get` and `flutter clean`

### Dependencies Required
All necessary dependencies should already be in `pubspec.yaml`:
- `flutter/material.dart`
- `google_fonts`
- Standard Flutter widgets

---

**Ready for Backend Integration!** 🚀

This reward system is fully functional with mock data and ready to be connected to your backend services. The UI is polished, follows all functional requirements, and maintains consistency with the BrainBee design system.