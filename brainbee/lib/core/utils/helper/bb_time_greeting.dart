// lib/core/utils/helper/bb_time_greeting.dart

/// Helper class to generate time-based greetings
class TimeGreeting {
  /// Get greeting based on current device time
  static String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 0 && hour < 12) {
      return "Good Morning";
    } else if (hour >= 12 && hour < 17) {
      return "Good Afternoon";
    } else if (hour >= 17 && hour < 21) {
      return "Good Evening";
    } else {
      return "Good Night";
    }
  }

  /// Get greeting with emoji
  static String getGreetingWithEmoji() {
    final hour = DateTime.now().hour;

    if (hour >= 0 && hour < 12) {
      return "Good Morning ☀️";
    } else if (hour >= 12 && hour < 17) {
      return "Good Afternoon 🌤️";
    } else if (hour >= 17 && hour < 21) {
      return "Good Evening 🌆";
    } else {
      return "Good Night 🌙";
    }
  }

  /// Get greeting icon based on time
  static String getGreetingIcon() {
    final hour = DateTime.now().hour;

    if (hour >= 0 && hour < 12) {
      return "☀️";
    } else if (hour >= 12 && hour < 17) {
      return "🌤️";
    } else if (hour >= 17 && hour < 21) {
      return "🌆";
    } else {
      return "🌙";
    }
  }

  /// Get detailed time period
  static String getTimePeriod() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 8) {
      return "Early Morning";
    } else if (hour >= 8 && hour < 12) {
      return "Morning";
    } else if (hour >= 12 && hour < 13) {
      return "Noon";
    } else if (hour >= 13 && hour < 17) {
      return "Afternoon";
    } else if (hour >= 17 && hour < 20) {
      return "Evening";
    } else if (hour >= 20 && hour < 22) {
      return "Late Evening";
    } else {
      return "Night";
    }
  }

  /// Get motivational message based on time
  static String getMotivationalMessage() {
    final hour = DateTime.now().hour;

    if (hour >= 0 && hour < 5) {
      return "Burning the midnight oil? 🔥";
    } else if (hour >= 5 && hour < 8) {
      return "Early bird catches the worm! 🐦";
    } else if (hour >= 8 && hour < 12) {
      return "Let's make today count! 💪";
    } else if (hour >= 12 && hour < 17) {
      return "Keep up the great work! 🎯";
    } else if (hour >= 17 && hour < 21) {
      return "Time to review your progress! 📚";
    } else {
      return "Rest well, learn tomorrow! 😴";
    }
  }
}
