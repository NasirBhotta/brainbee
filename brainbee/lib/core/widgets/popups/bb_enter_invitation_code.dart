import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_text.dart';

Future<String?> showInvitationCodePopUp(BuildContext context) async {
  return showGeneralDialog<String>(
    context: context,
    barrierDismissible: true,
    barrierLabel: "battleInvitation",
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionBuilder: (dialogContext, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
        child: _InvitationCodeDialog(),
      );
    },
  );
}

// Separate StatefulWidget for the dialog content
class _InvitationCodeDialog extends StatefulWidget {
  @override
  State<_InvitationCodeDialog> createState() => _InvitationCodeDialogState();
}

class _InvitationCodeDialogState extends State<_InvitationCodeDialog> {
  static const int codeLength = 6;

  late List<TextEditingController> controllers;
  late List<FocusNode> focusNodes;

  @override
  void initState() {
    super.initState();
    controllers = List.generate(codeLength, (_) => TextEditingController());
    focusNodes = List.generate(codeLength, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (var c in controllers) {
      c.dispose();
    }
    for (var f in focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String getCode() {
    return controllers.map((c) => c.text).join();
  }

  void _onCodeChanged(String value, int index) {
    if (value.isNotEmpty && index < codeLength - 1) {
      focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }

    if (getCode().length == codeLength) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  void _submitCode() {
    final code = getCode();
    if (code.length == codeLength) {
      Navigator.of(context).pop(code);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the full 6-digit code.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              decoration: BoxDecoration(
                color: BBColors.lightGrayBG,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title
                  const BBText(
                    data: "Enter Invitation Code",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: BBColors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  BBText(
                    data: "Enter the 6-digit code shared by your friend",
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  // Code Input Fields
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(codeLength, (index) {
                      return SizedBox(
                        width: 46,
                        height: 56,
                        child: TextField(
                          controller: controllers[index],
                          focusNode: focusNodes[index],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.characters,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(1),
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[A-Za-z0-9]'),
                            ),
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
                          onChanged: (value) => _onCodeChanged(value, index),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 30),

                  // Enter Match Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _submitCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BBColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const BBText(
                        data: "Enter match",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Close button
          Positioned(
            top: MediaQuery.of(context).size.height * 0.28,
            right: 25,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(null),
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: BBColors.lightGrayBG,
                  borderRadius: BorderRadius.circular(4),
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
    );
  }
}
