import 'package:flutter/material.dart';

class AppTheme {
  // Spiritual color palette - saffron, gold, deep maroon, cream
  static const Color saffron = Color(0xFFFF6B00);
  static const Color gold = Color(0xFFD4A017);
  static const Color deepMaroon = Color(0xFF4A0E0E);
  static const Color lightMaroon = Color(0xFF8B1A1A);
  static const Color cream = Color(0xFFFFF8F0);
  static const Color lightCream = Color(0xFFFFFBF5);
  static const Color darkBg = Color(0xFF1A0A00);
  static const Color cardBg = Color(0xFFFFF3E0);
  static const Color divineYellow = Color(0xFFFFC107);
  static const Color softGold = Color(0xFFE8C547);

  static ThemeData get theme {
    return ThemeData(
      fontFamily: 'Poppins',
      scaffoldBackgroundColor: lightCream,
      colorScheme: const ColorScheme.light(
        primary: saffron,
        secondary: gold,
        surface: cream,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: deepMaroon),
        titleTextStyle: TextStyle(
          color: deepMaroon,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          fontFamily: 'Poppins',
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: saffron,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: gold, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: gold, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: saffron, width: 2),
        ),
        hintStyle: const TextStyle(color: Color(0xFFBBAA99)),
      ),
    );
  }
}
