import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/presentation/views/auth/bb_login.dart';
import 'package:brainbee/presentation/views/auth/bb_signup.dart';
import 'package:brainbee/presentation/views/onboarding/bb_onboarding.dart';
import 'package:flutter/material.dart';

class BbCombinedOnbaord extends StatefulWidget {
  const BbCombinedOnbaord({super.key});

  @override
  State<BbCombinedOnbaord> createState() => _BbCombinedOnbaordState();
}

class _BbCombinedOnbaordState extends State<BbCombinedOnbaord> {
  // ScrollController scrollController = ScrollController();
  double currentOffset = 0;
  bool isLogin = false;
  // @override
  // void initState() {
  //   super.initState();
  //   scrollController.addListener(() {
  //     if (scrollController.offset >= 0) {
  //       offset = scrollController.hasClients ? scrollController.offset : 0;
  //       setState(() {});
  //     }
  //   });
  // }.

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: BBColors.lightGrayBG,
      body: SizedBox(
        height: size.height,
        child: Stack(
          children: [
            Container(
              height: size.height * 0.6,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [BBColors.primaryColor, BBColors.secondaryColor],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: const BbOnboarding(),
            ),
            Positioned(
              top: size.height * 0.6 - currentOffset * 0.5,
              bottom: 0,
              child: SizedBox(
                height: size.height * 0.5,
                width: size.width,
                child:
                    isLogin
                        ? BbLogin(
                          onScroll: (offset) {
                            setState(() {
                              currentOffset = offset;
                            });
                          },
                          signUp: () {
                            setState(() {
                              isLogin = !isLogin;
                              currentOffset = 0;
                            });
                          },
                        )
                        : BbSignup(
                          onScroll: (offset) {
                            setState(() {
                              currentOffset = offset;
                            });
                          },
                          login: () {
                            setState(() {
                              isLogin = !isLogin;
                              currentOffset = 0;
                            });
                          },
                        ),
              ),
            ),
            Text(currentOffset.toString()),
          ],
        ),
      ),
    );
  }
}
