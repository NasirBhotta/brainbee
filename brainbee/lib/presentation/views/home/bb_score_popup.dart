import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_screen_extension.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/core/utils/bb_textTheme_extention.dart';
import 'package:brainbee/presentation/views/home/bb_edit_goals.dart';
import 'package:flutter/material.dart';

void showScoreGoalsPopup(BuildContext context) {
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
            // Title Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BBText(
                  data: 'Score & Goals',
                  style: context.textStyle.titleMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Score & Streak Row
            Padding(
              padding: EdgeInsets.only(
                left: context.screenWidth * 0.05,
                right: context.screenWidth * 0.15,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    spacing: 12,
                    children: [
                      Image.asset('assets/trophy.png', scale: 15),
                      Column(
                        children: [
                          const SizedBox(height: 4),
                          const BBText(data: 'Quiz'),
                          BBText(
                            data: '0/2',
                            style: context.textStyle.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 27,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const BBText(data: 'Streak'),
                      BBText(
                        data: '1 Days',
                        style: context.textStyle.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 27,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Today's score and year score
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const BBText(data: "Today's score"),
                    BBText(
                      data: '5',
                      style: context.textStyle.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 27,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const BBText(data: "This year's score"),
                    BBText(
                      data: '10',
                      style: context.textStyle.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 27,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Days of the week row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:
                  ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su']
                      .map(
                        (day) => Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: BBColors.borderGray,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: BBText(data: day),
                        ),
                      )
                      .toList(),
            ),

            const SizedBox(height: 20),

            // Change Goal Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BBEditGoals()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Colors.green),
                foregroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Change Goal'),
            ),
          ],
        ),
      );
    },
  );
}
