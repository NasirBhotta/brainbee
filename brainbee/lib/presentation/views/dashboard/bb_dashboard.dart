import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_extension.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/presentation/views/dashboard/bb_progress_bar.dart';
import 'package:flutter/material.dart';

class BBDashboard extends StatefulWidget {
  const BBDashboard({super.key});

  @override
  State<BBDashboard> createState() => _BBDashboardState();
}

class _BBDashboardState extends State<BBDashboard> {
  List<String> imgPath = [
    'assets/trophy.png',
    'assets/coin.png',
    'assets/fire.png',
    'assets/heart.png',
  ];
  List<Color> color = [
    BBColors.orangeAccent,
    BBColors.yellowAccent,
    BBColors.secondaryColor,
    BBColors.alertRed,
  ];
  List<String> desc = ['10', '1', '0', '5/5'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            floating: false,

            backgroundColor: Colors.transparent,
            elevation: 0,

            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.only(left: 10, right: 10),
                color: Colors.transparent,
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),
                        Text(
                          "Good Evening",
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(fontSize: 10),
                        ),
                        const Expanded(child: SizedBox.shrink()),
                        Text(
                          "Nasir Bhutta",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 50),
                        const Expanded(child: SizedBox.shrink()),
                      ],
                    ),
                    const Expanded(child: SizedBox.shrink()),
                    const Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(height: 150),
                            Icon(
                              Icons.notifications,
                              size: 20,
                              color: BBColors.disabledText,
                            ),
                            SizedBox(width: 10),
                            CircleAvatar(),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              expandedTitleScale: 1,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  return BbProgressBar(
                    color: color[index],
                    imgPath: imgPath[index],
                    desc: desc[index],
                    index: index,
                  );
                }),
              ),
              centerTitle: true,
            ),
          ),
          SliverList.builder(
            itemBuilder: (_, index) {
              return index == 0
                  ? Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: BBColors.white,
                    ),
                    height: 70,
                    width: double.infinity,

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            BBText(
                              data: "Bookmark 6 Questions",
                              style: Theme.of(
                                context,
                              ).textTheme.titleSmall?.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(
                              width: context.screenWidth * 0.7,
                              child: LinearProgressIndicator(
                                value: 0.5,
                                backgroundColor: BBColors.lightGrayBG,
                                color: BBColors.primaryColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          constraints: const BoxConstraints(
                            maxHeight: 30,
                            maxWidth: 60,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              colors: [
                                BBColors.primaryColor,
                                BBColors.secondaryColor,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Image.asset(
                                  "assets/coin.png",
                                  width: context.screenWidth * 0.05,
                                  height: context.screenHeight * 0.05,
                                ),
                                BBText(
                                  data: "6",
                                  style: Theme.of(
                                    context,
                                  ).textTheme.labelLarge?.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: BBColors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                  : Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    height: context.screenHeight * 0.12,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: BBColors.white,
                    ),
                    child: Center(
                      child: Text(
                        "Item $index",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  );
            },
            itemCount: 20,
          ),
        ],
      ),
    );
  }
}
