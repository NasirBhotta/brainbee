import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_screen_extension.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/core/utils/bb_textTheme_extention.dart';
import 'package:flutter/material.dart';

class BBSettings extends StatelessWidget {
  const BBSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: context.screenHeight * 0.05,
        title: BBText(
          data: 'Menu',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: BBColors.white),
        ),
        backgroundColor: BBColors.secondaryColor,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: BBColors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: BBColors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.only(left: 13, top: 10),

                  leading: CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.green[700],
                    child: BBText(
                      data: 'N',
                      style: Theme.of(
                        context,
                      ).textTheme.titleSmall?.copyWith(color: BBColors.white),
                    ),
                  ),
                  title: BBText(
                    data: 'Nasir Bhutta',
                    style: context.textStyle.bodyMedium,
                  ),
                  horizontalTitleGap: 13,
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(
                    Icons.people,
                    color: BBColors.secondaryColor,
                  ),
                  title: BBText(
                    data: 'Manage Account',
                    style: context.textStyle.bodyMedium,
                  ),
                  visualDensity: const VisualDensity(vertical: -4),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(
                    Icons.star,
                    color: BBColors.secondaryColor,
                  ),
                  title: BBText(
                    data: 'Upgrade to Premium Free',
                    style: context.textStyle.bodyMedium,
                  ),
                  visualDensity: const VisualDensity(vertical: -4),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(
                    Icons.language,
                    color: BBColors.secondaryColor,
                  ),
                  title: BBText(
                    data: 'Select Language',
                    style: context.textStyle.bodyMedium,
                  ),
                  visualDensity: const VisualDensity(vertical: -4),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(
                    Icons.calendar_today,
                    color: BBColors.secondaryColor,
                  ),
                  title: BBText(
                    data: 'Select Year Grade',
                    style: context.textStyle.bodyMedium,
                  ),
                  visualDensity: const VisualDensity(vertical: -4),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(
                    Icons.book,
                    color: BBColors.secondaryColor,
                  ),
                  title: BBText(
                    data: 'Select Subjects',
                    style: context.textStyle.bodyMedium,
                  ),
                  visualDensity: const VisualDensity(vertical: -4),
                ),
                const Divider(),
                const ListTile(
                  leading: Icon(Icons.lock, color: BBColors.secondaryColor),
                  title: BBText(data: 'Change Password'),
                  visualDensity: VisualDensity(vertical: -4),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(
                    Icons.share,
                    color: BBColors.secondaryColor,
                  ),
                  title: BBText(
                    data: 'Share My Progress',
                    style: context.textStyle.bodyMedium,
                  ),
                  visualDensity: const VisualDensity(vertical: -4),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(
                    Icons.settings,
                    color: BBColors.secondaryColor,
                  ),
                  title: BBText(
                    data: 'App Settings',
                    style: context.textStyle.bodyMedium,
                  ),
                  visualDensity: const VisualDensity(vertical: -4),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(
                    Icons.card_giftcard,
                    color: BBColors.secondaryColor,
                  ),
                  title: BBText(
                    data: 'Learn and Earn',
                    style: context.textStyle.bodyMedium,
                  ),
                  visualDensity: const VisualDensity(vertical: -4),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(
                    Icons.help,
                    color: BBColors.secondaryColor,
                  ),
                  title: BBText(
                    data: 'Help and Feedback',
                    style: context.textStyle.bodyMedium,
                  ),
                  visualDensity: const VisualDensity(vertical: -4),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(
                    Icons.logout,
                    color: BBColors.secondaryColor,
                  ),
                  title: BBText(
                    data: 'Logout',
                    style: context.textStyle.bodyMedium,
                  ),
                  visualDensity: const VisualDensity(vertical: -4),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: BBText(
                      data: 'See Terms of Services and Privacy Policy',
                      style: Theme.of(context).textTheme.labelMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: BBText(
                      data: 'Version 1.59.2 (1)',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
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
