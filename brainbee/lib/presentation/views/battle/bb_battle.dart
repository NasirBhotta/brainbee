import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_screen_extension.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/core/utils/bb_textTheme_extention.dart';
import 'package:flutter/material.dart';

class BBBattle extends StatefulWidget {
  const BBBattle({super.key});

  @override
  State<BBBattle> createState() => _BBBattleState();
}

class _BBBattleState extends State<BBBattle> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: context.screenHeight * 0.05,
        title: BBText(
          data: "Battle",
          style: context.textStyle.titleMedium?.copyWith(color: BBColors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.arrow_back, color: BBColors.white),
        ),
        actions: const [],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: BBColors.white,

              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 15,
                  ),
                  decoration: BoxDecoration(
                    color: BBColors.primaryColor.withValues(alpha: 0.3),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(5),
                      bottomLeft: Radius.circular(5),
                    ),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.green[700],
                        child: BBText(
                          data: 'N',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(color: BBColors.white),
                        ),
                      ),
                      SizedBox(height: context.screenHeight * 0.01),
                      const BBText(data: "@Username"),
                      SizedBox(height: context.screenHeight * 0.005),
                      RichText(
                        text: TextSpan(
                          children: <InlineSpan>[
                            TextSpan(
                              text: "Ranking",
                              style: context.textStyle.labelSmall,
                            ),

                            TextSpan(
                              text: " 70007",
                              style: context.textStyle.titleSmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BBText(data: "1 Win"),
                      BBText(data: "1 Battle"),
                      BBText(data: "1 Coin Collected"),

                      BBText(data: "Full"),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // second container
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [BBColors.primaryColor, BBColors.secondaryColor],
              ),

              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  spacing: 5,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),

                        decoration: BoxDecoration(
                          color: BBColors.lightGrayBG,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                              color: BBColors.alertRed,
                              offset: Offset(0, 2),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        child: const BBText(data: "Start the Battle"),
                      ),
                    ),
                    InkWell(
                      child: BBText(
                        data: "Enter Invitation Code",
                        style: context.textStyle.titleSmall?.copyWith(
                          decoration: TextDecoration.underline,
                          fontSize: 13,
                          decorationThickness: 1.9,
                          decorationColor: BBColors.white,
                          color: BBColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
