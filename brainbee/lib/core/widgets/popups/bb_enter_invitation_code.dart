import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_text.dart';

void showInvitationCodePopUp(BuildContext context) async {
  final int codeLength = 6;
  int currentInd = 0;
  final List<TextEditingController> controllers = List.generate(
    codeLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> focusNodes = List.generate(
    codeLength,
    (_) => FocusNode(),
  );

  String getCode() {
    return controllers.map((controller) => controller.text).join();
  }

  void disposeResources() {
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
  }

  try {
    showGeneralDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierLabel: "battleInvitation",
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.2),
            end: const Offset(0, 0),
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: Stack(
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 24,
                    ),
                    decoration: BoxDecoration(
                      color: BBColors.lightGrayBG,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: BBText(
                            data: "Battle invitation",
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Center(
                          child: BBText(
                            data: "Get invitation code from your friend.",
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 30),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(codeLength, (index) {
                            currentInd = index;
                            return SizedBox(
                              width: 46,
                              height: 56,
                              child: TextField(
                                controller: controllers[index],
                                focusNode: focusNodes[index],
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(1),
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.zero,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: BBColors.primaryColor,
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                ),
                                onChanged: (value) {
                                  if (value.isNotEmpty &&
                                      index < codeLength - 1) {
                                    focusNodes[index + 1].requestFocus();
                                  } else if (value.isEmpty && index > 0) {
                                    focusNodes[index - 1].requestFocus();
                                  }

                                  if (controllers.every(
                                    (controller) => controller.text.isNotEmpty,
                                  )) {}
                                },
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: 30),

                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            color: BBColors.primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () {
                                // String code = getCode();
                                // if (code.length == codeLength) {
                                //   Navigator.of(context).pop(code);
                                // }
                              },
                              child: const Center(
                                child: BBText(
                                  data: "Enter match",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Align(
                  alignment: const Alignment(0.95, -0.32),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: BBColors.lightGrayBG,
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: const [
                          BoxShadow(
                            color: BBColors.disabledText,
                            spreadRadius: 0.5,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: BBColors.secondaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  } finally {
    if (currentInd >= 5) {
      disposeResources();
    }
  }
}
