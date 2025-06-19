import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/widgets/popups/bb_model_button.dart';
import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmButtonText;
  final String cancelButtonText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final Color? backgroundColor;
  final Color? primaryColor;
  final Color? borderColor;
  final bool showCloseButton;
  final String? barrierLabel;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    this.confirmButtonText = "Confirm",
    this.cancelButtonText = "Cancel",
    this.onCancel,
    this.backgroundColor,
    this.primaryColor,
    this.borderColor,
    this.showCloseButton = true,
    this.barrierLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color:
                    backgroundColor ?? Theme.of(context).dialogBackgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(color: BBColors.borderGray),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Expanded(child: SizedBox.shrink()),
                      buildStudyModeButton(
                        context,
                        label: cancelButtonText,
                        onTap: () {
                          Navigator.pop(context);
                          onCancel?.call();
                        },
                      ),
                      const SizedBox(width: 20),
                      buildStudyModeButton(
                        context,
                        label: confirmButtonText,
                        onTap: () {
                          Navigator.pop(context);
                          onConfirm();
                        },
                      ),
                      const Expanded(child: SizedBox.shrink()),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (showCloseButton)
            Align(
              alignment: const Alignment(0.95, -0.145),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                  onCancel?.call();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color:
                        backgroundColor ??
                        Theme.of(context).dialogBackgroundColor,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 0.5,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.close,
                    size: 20,
                    color: primaryColor ?? Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Extension method to show the dialog easily
extension ConfirmationDialogExtension on BuildContext {
  Future<void> showConfirmationDialog({
    required String title,
    required String message,
    required VoidCallback onConfirm,
    String confirmButtonText = "Confirm",
    String cancelButtonText = "Cancel",
    VoidCallback? onCancel,
    Color? backgroundColor,
    Color? primaryColor,
    Color? borderColor,
    bool showCloseButton = true,
    String? barrierLabel,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog(
      context: this,
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel ?? "confirmation_dialog",
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.2),
            end: const Offset(0, 0),
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          ),
          child: ConfirmationDialog(
            title: title,
            message: message,
            onConfirm: onConfirm,
            confirmButtonText: confirmButtonText,
            cancelButtonText: cancelButtonText,
            onCancel: onCancel,
            backgroundColor: backgroundColor,
            primaryColor: primaryColor,
            borderColor: borderColor,
            showCloseButton: showCloseButton,
            barrierLabel: barrierLabel,
          ),
        );
      },
    );
  }
}
