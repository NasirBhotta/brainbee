import 'package:brainbee/core/models/wallet.dart';
import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:flutter/material.dart';

class WalletWidget extends StatelessWidget {
  final Wallet wallet;

  const WalletWidget({super.key, required this.wallet});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [BBColors.primaryColor, BBColors.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: BBColors.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Wallet',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: BBColors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      color: BBColors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '${wallet.balance} Coins',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                          color: BBColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Available Balance',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: BBColors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: BBColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: BBColors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.monetization_on, color: BBColors.white, size: 32),
                const SizedBox(height: 4),
                Text(
                  'COINS',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: BBColors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
