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
      headlineSmall: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),

      titleMedium: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),

      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),

      bodySmall: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w400),

      labelLarge: GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),

      headlineMedium: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),

      titleSmall: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),

      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),

      displayMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
      ),

      displaySmall: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),

      headlineLarge: GoogleFonts.poppins(fontSize: 22),

      titleLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),

      bodyLarge: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w400),

      labelMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),

      labelSmall: GoogleFonts.poppins(
        fontSize: 12,
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
        borderSide: const BorderSide(color: BBColors.bodyText, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: BBColors.bodyText, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2.0),
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
