import 'package:brainbee/core/utils/bb_screen_extension.dart';
import 'package:brainbee/presentation/views/learn/bb_popup_items.dart';
import 'package:flutter/material.dart';

void showExtraPopup(
  BuildContext context,
  List<Map<String, String>> items, {
  VoidCallback? onDismiss,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Popup",
    barrierColor: Colors.black45,
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionBuilder: (context, animation, secondaryAnimation, _) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1), // start from bottom
          end: const Offset(0, 0), // end at center
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            elevation: 20,
            child: Container(
              width: MediaQuery.of(context).size.width * 1,
              height: context.screenHeight * 0.4,
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: 20,
                top: 10,
              ),
              child: Column(
                children: [
                  Container(
                    width: context.screenWidth * 0.15,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 202, 202, 202),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: context.screenWidth,
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      direction: Axis.horizontal,
                      spacing: context.screenWidth * 0.05,
                      runSpacing: context.screenWidth * 0.1,
                      children: List.generate(items.length, (index) {
                        return BBPopupItems(
                          barType: BottomBarType.extra,
                          index: index,
                          title: items[index]['title'],
                          imgPath: items[index]['imgPath'],
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  ).then((_) {
    if (onDismiss != null) onDismiss();
  });
}
