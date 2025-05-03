import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BrainBeeTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: BBColors.primaryColor,
    scaffoldBackgroundColor: BBColors.lightGrayBG,
    appBarTheme: const AppBarTheme(
      backgroundColor: BBColors.secondaryColor,
      elevation: 0,
    ),
    textTheme: TextTheme(
      // For main title like "Nasir Bhotta"
      headlineSmall: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),

      // For section titles like "Mathematics", "Science"
      titleMedium: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),

      // For small subtitles like "Quiz Level 1 - Science Process Skills"
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),

      // For body text l[ike “RM50 Daily Lucky draw...”
      bodySmall: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w400),

      // For buttons like "Answer Quiz"
      labelLarge: GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),

      // For streak highlights like “0 Day Streak”
      headlineMedium: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),

      // For streak detail like “Longest Streak: 1 Day”
      titleSmall: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 18.0,
        horizontal: 16.0,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(
          color: BBColors.bodyText, // light grey border
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(
          color: BBColors.bodyText, // light grey border
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(
          color: Color(0xFF4CAF50), // green (same as button)
          width: 2.0,
        ),
      ),
      hintStyle: GoogleFonts.poppins(
        fontSize: 14,
        color: const Color(0xFFBDBDBD),
      ),
      labelStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
      errorStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.red),
    ),
  );
}
