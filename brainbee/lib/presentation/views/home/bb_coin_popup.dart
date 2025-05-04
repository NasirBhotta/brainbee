import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/core/utils/bb_textTheme_extention.dart';
import 'package:flutter/material.dart';

void showCoinsPopup(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Container(
        color: BBColors.white,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with title and close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BBText(data: 'Coins', style: context.textStyle.titleMedium),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Coin Icon and Info
            Row(
              children: [
                // Coin Image or Icon
                Image.asset('assets/coin.png', scale: 15),
                const SizedBox(width: 16),

                // Text Info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BBText(
                      data: 'Expires in  08 hour 01 min 16 sec',
                      style: context.textStyle.labelMedium?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: BBColors.disabledText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    BBText(
                      data: '1 Coins',
                      style: context.textStyle.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Claim More Coins Button
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Colors.green),
                foregroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Claim More Coins'),
            ),
          ],
        ),
      );
    },
  );
}
