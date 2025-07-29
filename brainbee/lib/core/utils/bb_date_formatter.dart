import 'package:intl/intl.dart';

class DateFormatter {
  static String formatBadgeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  static String formatBadgeDetailDate(DateTime date) {
    return DateFormat('EEEE, MMMM d, yyyy').format(date);
  }
}
