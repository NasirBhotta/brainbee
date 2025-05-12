import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_screen_extension.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/core/utils/bb_textTheme_extention.dart';
import 'package:brainbee/presentation/views/battle/bb_book_selection.dart';
import 'package:flutter/material.dart';

class BBBattle extends StatefulWidget {
  const BBBattle({super.key});

  @override
  State<BBBattle> createState() => _BBBattleState();
}

class _BBBattleState extends State<BBBattle> {
  final List<String> letters = [
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
  ];
  final List<Color?> colors = [
    Colors.red[700],
    Colors.blue[700],
    Colors.green[700],
    Colors.orange[700],
    Colors.purple[700],
    Colors.brown[700],
    Colors.teal[700],
    Colors.pink[700],
    Colors.indigo[700],
    Colors.cyan[700],
  ];

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
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: BBColors.white),
        ),
        actions: const [],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
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
                margin: const EdgeInsets.symmetric(vertical: 10),

                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [BBColors.primaryColor, BBColors.secondaryColor],
                  ),

                  borderRadius: BorderRadius.circular(5),
                ),
                child: Stack(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 10,
                          ),
                          child: Column(
                            spacing: 5,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => BbBattleChapSelect()));
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 5,
                                  ),

                                  decoration: BoxDecoration(
                                    color: BBColors.lightGrayBG,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: BBColors.alertRed,
                                        offset: Offset(0, 3),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: BBText(
                                    data: "Start the Battle",
                                    style: context.textStyle.labelLarge
                                        ?.copyWith(color: BBColors.alertRed),
                                  ),
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
                        ),
                      ],
                    ),
                    Positioned(
                      left: -context.screenWidth * 0.015,
                      top: -20,
                      bottom: -20,
                      child: Transform.rotate(
                        angle: 0.2,

                        child: Opacity(
                          opacity: 0.8,
                          child: Image.asset("assets/crown.png"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // battle history
              Container(
                padding: const EdgeInsets.only(top: 20),
                margin: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  color: BBColors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    BBText(
                      data: "Your Battle History",
                      style: context.textStyle.labelLarge,
                    ),

                    SizedBox(
                      height: context.screenHeight * 0.5,
                      child: ListView.builder(
                        itemCount: 10,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: colors[index],
                              child: BBText(
                                data: letters[index],
                                style: context.textStyle.titleSmall?.copyWith(
                                  color: BBColors.white,
                                ),
                              ),
                            ),
                            title: BBText(
                              data: "@Username",
                              style: context.textStyle.labelSmall,
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 5,
                                horizontal: 5,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: BBColors.primaryColor,
                                  width: 1.5,
                                ),
                              ),
                              child: Image.asset(
                                'assets/right-arrow.png',
                                color: BBColors.primaryColor,
                                scale: 30,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
