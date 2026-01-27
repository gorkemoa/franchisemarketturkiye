import 'package:flutter/material.dart';

class AppTheme {
  // 🎨 Colors
  static const Color primaryColor = Color.fromARGB(255, 221, 15, 0);
  static const Color secondaryColor = Color(0xFF1A1A1A);
  static const Color backgroundColor = Colors.white;
  static const Color cardColor = Colors.white;
  static const Color borderColor = Color(0xFFEEEEEE);

  static const Color textPrimary = Colors.black;
  static const Color textSecondary = Color(0xFF787878);
  static const Color textTertiary = Color(0xFFBABABA);

  static const Color tagBackground = Color(0xFFFEECEE);
  static const Color sliderBackground = Color(0xFF0D1B2A);

  // 🔤 Font Family
  static const String fontFamily = 'Inter';

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,

      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,

      // 🧭 AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 16, // Reduced from 20
          fontWeight: FontWeight.w700,
        ),
      ),

      // 🎨 Color Scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        background: backgroundColor,
      ),

      // 🔤 Text Theme
      textTheme: const TextTheme(
        // 🔴 Section Titles
        headlineLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: 'BioSans',
          color: textPrimary,
          height: 1.4,
        ),
        headlineMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          height: 1.4,
        ),
        headlineSmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          height: 1.4,
        ),

        // 🔴 Content Title (Blog title in card)
        titleLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          height: 1.4,
        ),

        // 🟢 Author Name
        titleMedium: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),

        // 🔵 Description
        bodyLarge: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          height: 1.4,
        ),
        bodyMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          height: 1.4,
        ),

        // ⚪ Date
        bodySmall: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w400,
          color: textTertiary,
        ),

        // 🟠 Tag Text (Also used for buttons)
        labelLarge: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: primaryColor,
        ),
      ),
    );
  }
}
