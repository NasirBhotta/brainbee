import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'constants.dart';

class Helpers {
  // Format date to readable string
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
  
  // Format date and time to readable string
  static String formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy - hh:mm a').format(date);
  }
  
  // Format time to readable string
  static String formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }
  
  // Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < (1024 * 1024)) {
      double kb = bytes / 1024;
      return '${kb.toStringAsFixed(1)} KB';
    } else {
      double mb = bytes / (1024 * 1024);
      return '${mb.toStringAsFixed(1)} MB';
    }
  }
  
  // Validate email address
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  // Check if file type is allowed for upload
  static bool isAllowedFileType(String fileName) {
    if (fileName.isEmpty) return false;
    
    String extension = fileName.split('.').last.toLowerCase();
    return AppConstants.allowedFileTypes.contains(extension);
  }
  
  // Check if file size is within limits
  static bool isAllowedFileSize(int fileSize) {
    return fileSize <= AppConstants.maxFileSize;
  }
  
  // Show snackbar message
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(10),
      ),
    );
  }
  
  // Get initials from a name
  static String getInitials(String name) {
    if (name.isEmpty) return '';
    
    List<String> nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return nameParts[0][0].toUpperCase();
  }
  
  // Determine text color based on background for contrast
  static Color getTextColorForBackground(Color backgroundColor) {
    // Calculate luminance - if it's greater than 0.5, use dark text
    return backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
  
  // Get appropriate grade color based on score
  static Color getGradeColor(double score) {
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.lightGreen;
    if (score >= 70) return Colors.amber;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
  
  // Get letter grade from numerical score
  static String getLetterGrade(double score) {
    if (score >= 90) return 'A';
    if (score >= 80) return 'B';
    if (score >= 70) return 'C';
    if (score >= 60) return 'D';
    return 'F';
  }
}