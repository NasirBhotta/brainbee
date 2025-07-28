import 'package:flutter/material.dart';
import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/presentation/views/rewards/reward_catalog_screen.dart';

class RewardDemoScreen extends StatelessWidget {
  const RewardDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BBColors.lightGrayBG,
      appBar: AppBar(
        title: Text(
          'Reward System Demo',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: BBColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: BBColors.secondaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [BBColors.secondaryColor, BBColors.lightGrayBG],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Hero section
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: BBColors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [BBColors.primaryColor, BBColors.secondaryColor],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.redeem,
                              color: BBColors.white,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Reward Store',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: BBColors.darkHeading,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Redeem your coins for amazing rewards!',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: BBColors.bodyText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                // Features list
                Text(
                  'Features Implemented',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: BBColors.darkHeading,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                ...[
                  '✅ Reward catalog with grid layout',
                  '✅ Different reward statuses (Available, Redeemed, Insufficient)',
                  '✅ Detailed reward information page',
                  '✅ User input validation for redemption',
                  '✅ Confirmation flow with review step',
                  '✅ Daily redemption limit (600 coins)',
                  '✅ Non-refundable redemption system',
                  '✅ Success confirmations and email notifications',
                  '✅ Modern UI with BrainBee theme',
                ].map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feature.split(' ')[0],
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: BBColors.successGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature.substring(2),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: BBColors.bodyText,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
                const Spacer(),
                // Demo button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RewardCatalogScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BBColors.primaryColor,
                      foregroundColor: BBColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.store, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Open Reward Store',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: BBColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Integration note
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: BBColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: BBColors.primaryColor.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.integration_instructions,
                            color: BBColors.primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Integration Ready',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: BBColors.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This reward system is ready to be integrated with your backend. Simply replace the mock data with API calls and connect the coin balance to your user management system.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: BBColors.bodyText,
                          height: 1.4,
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
}