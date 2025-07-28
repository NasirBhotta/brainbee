import 'package:flutter/material.dart';
import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/presentation/views/rewards/reward_catalog_screen.dart';

/// Example integration showing how to add reward system to existing app navigation
/// This demonstrates how to integrate the reward catalog into your existing screens

class IntegrationExample extends StatelessWidget {
  const IntegrationExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Existing Screen'),
        actions: [
          // Add reward store button to any existing screen
          IconButton(
            onPressed: () => _navigateToRewards(context),
            icon: const Icon(Icons.redeem),
            tooltip: 'Reward Store',
          ),
        ],
      ),
      body: Column(
        children: [
          // Your existing content here
          const Expanded(
            child: Center(
              child: Text('Your existing screen content'),
            ),
          ),
          
          // Add reward store button anywhere in your UI
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildRewardStoreButton(context),
          ),
        ],
      ),
      
      // Or add it to bottom navigation
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Learn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.redeem), // Reward store tab
            label: 'Rewards',
          ),
        ],
        onTap: (index) {
          if (index == 2) {
            _navigateToRewards(context);
          }
          // Handle other navigation
        },
      ),
    );
  }

  Widget _buildRewardStoreButton(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [BBColors.primaryColor, BBColors.secondaryColor],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: BBColors.primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToRewards(context),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.redeem,
                  color: BBColors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Open Reward Store',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: BBColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: BBColors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        color: BBColors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '750', // Current user coins - connect to your user system
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: BBColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToRewards(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RewardCatalogScreen(),
      ),
    );
  }
}

/// For Drawer Integration
class DrawerWithRewards extends StatelessWidget {
  const DrawerWithRewards({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [BBColors.primaryColor, BBColors.secondaryColor],
              ),
            ),
            child: Text(
              'BrainBee',
              style: TextStyle(
                color: BBColors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.book),
            title: const Text('Learn'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.quiz),
            title: const Text('Practice'),
            onTap: () => Navigator.pop(context),
          ),
          const Divider(),
          // Add reward store to drawer
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [BBColors.primaryColor, BBColors.secondaryColor],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.redeem,
                color: BBColors.white,
                size: 18,
              ),
            ),
            title: const Text(
              'Reward Store',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text('Redeem your coins'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: BBColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.monetization_on,
                    color: BBColors.primaryColor,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '750',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: BBColors.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RewardCatalogScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

/// For Card-based Dashboard Integration
class DashboardCardExample extends StatelessWidget {
  const DashboardCardExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [BBColors.primaryColor, BBColors.secondaryColor],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.redeem,
                    color: BBColors.white,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reward Store',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: BBColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Redeem amazing rewards',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: BBColors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: BBColors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.monetization_on,
                          color: BBColors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '750 Coins',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: BBColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RewardCatalogScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BBColors.white,
                      foregroundColor: BBColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Shop Now',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*
USAGE INSTRUCTIONS:

1. **Simple Navigation Button**:
   Use `_buildRewardStoreButton()` method in any screen

2. **Bottom Navigation Integration**:
   Add reward store as a tab in your BottomNavigationBar

3. **Drawer Integration**:
   Use `DrawerWithRewards` as your app drawer

4. **Dashboard Card**:
   Use `DashboardCardExample` in your dashboard grid

5. **AppBar Action**:
   Add reward store icon to any AppBar actions

6. **Floating Action Button**:
   ```dart
   floatingActionButton: FloatingActionButton(
     onPressed: () => Navigator.push(
       context,
       MaterialPageRoute(builder: (context) => const RewardCatalogScreen()),
     ),
     child: const Icon(Icons.redeem),
   ),
   ```

Remember to:
- Connect user coin balance to your user management system
- Replace mock data with real API calls
- Implement proper state management if needed
- Add authentication checks before allowing access
*/