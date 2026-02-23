import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors from the reference image (Medical App)
  static const Color primaryTeal = Color(0xFF26A69A); // Main Teal
  static const Color darkTeal = Color(0xFF00796B); // For text/icons
  static const Color lightTeal = Color(0xFFB2DFDB); // Background accents
  static const Color backgroundWhite = Color(0xFFF5F7FA); // Very light grey/blue bg
  static const Color cardWhite = Colors.white;
  static const Color textDark = Color(0xFF2D3E50); // Dark Blue/Grey for headings
  static const Color textGrey = Color(0xFF90A4AE); // Secondary text
  static const Color accentOrange = Color(0xFFFF9800); // Kept for status/warnings if needed
  static const Color errorRed = Color(0xFFE57373);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4DB6AC), Color(0xFF00897B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Technician Theme Colors
  static const Color primaryOrange = Color(0xFFFF5722);
  static const LinearGradient orangeGradient = LinearGradient(
    colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundWhite,
      primaryColor: primaryTeal,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryTeal,
        primary: primaryTeal,
        secondary: darkTeal,
        background: backgroundWhite,
        surface: cardWhite,
        error: errorRed,
      ),
      
      // Typography
      textTheme: GoogleFonts.poppinsTextTheme().apply(
        bodyColor: textDark,
        displayColor: textDark,
      ),

      // Card Theme - Highly rounded
      cardTheme: CardThemeData(
        color: cardWhite,
        elevation: 0, // Flat or very subtle shadow handled by containers usually
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textDark),
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins'
        ),
      ),

      // Input Decoration - Rounded and Filled
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: primaryTeal, width: 1.5),
        ),
        hintStyle: TextStyle(color: textGrey, fontSize: 14),
        prefixIconColor: textGrey,
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(), 
      ),
    );
  }
}
