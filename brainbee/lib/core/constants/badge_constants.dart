class AppConstants {
  // Error Messages
  static const String noEarnedBadgesMessage =
      "You haven't earned any badges yet. Keep learning to unlock achievements!";

  static const String badgeLoadErrorMessage =
      "Could not load badges. Please check your internet connection and try again.";

  static const String retryButtonText = "Retry";
  static const String cancelButtonText = "Cancel";

  // UI Constants
  static const double badgeGridSpacing = 12.0;
  static const double sectionVerticalSpacing = 24.0;
  static const double badgeItemBorderRadius = 12.0;
  static const double dialogBorderRadius = 16.0;

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
}
