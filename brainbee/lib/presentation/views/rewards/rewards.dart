// Reward System Exports
// This file provides easy access to all reward system components

// Models
export 'package:brainbee/core/models/reward_model.dart';

// Screens
export 'package:brainbee/presentation/views/rewards/reward_catalog_screen.dart';
export 'package:brainbee/presentation/views/rewards/reward_detail_screen.dart';
export 'package:brainbee/presentation/views/rewards/reward_demo_screen.dart';

// Widgets
export 'package:brainbee/presentation/views/rewards/widgets/reward_card.dart';
export 'package:brainbee/presentation/views/rewards/widgets/redemption_bottom_sheet.dart';

/*
Usage Examples:

1. Basic Integration:
   ```dart
   import 'package:brainbee/presentation/views/rewards/rewards.dart';
   
   // Navigate to reward catalog
   Navigator.push(
     context,
     MaterialPageRoute(builder: (context) => const RewardCatalogScreen()),
   );
   ```

2. Custom Implementation:
   ```dart
   import 'package:brainbee/presentation/views/rewards/rewards.dart';
   
   // Create custom reward list
   final rewards = [
     RewardModel(
       id: '1',
       title: 'Custom Reward',
       description: 'Description here',
       imageUrl: 'url_here',
       coinPrice: 100,
       status: RewardStatus.available,
       redemptionInstructions: 'Instructions here',
       termsAndConditions: 'Terms here',
     ),
   ];
   ```

3. Backend Integration Points:
   - Replace mock data in RewardCatalogScreen with API calls
   - Connect currentCoins to user management system
   - Implement actual redemption logic in RedemptionBottomSheet
   - Add email notification service
   - Implement daily limit tracking with backend
*/