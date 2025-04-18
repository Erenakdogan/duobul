import 'package:flutter/material.dart';



final ThemeData duoBulDarkPurpleTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF1C1B2A), // arka plan
  primaryColor: const Color(0xFF3C096C), // mor

  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF3C096C),
    brightness: Brightness.dark,
    primary: const Color(0xFF3C096C),
    secondary: const Color(0xFFD0A2F7),
    tertiary: const Color(0xFF39FF14),
    background: const Color(0xFF1C1B2A),
    onPrimary: Colors.white,
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF2A2A40),
    foregroundColor: Colors.white,
    elevation: 0,
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF3C096C),
    foregroundColor: Colors.white,
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF3C096C),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF2A2A40),
    labelStyle: const TextStyle(color: Color(0xFFD0A2F7)),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0xFF39FF14), width: 2),
      borderRadius: BorderRadius.circular(20),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0xFF4A4A6A)),
      borderRadius: BorderRadius.circular(20),
    ),
    prefixIconColor: const Color(0xFF39FF14),
  ),

  textTheme: const TextTheme(
    headlineSmall: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    bodyMedium: TextStyle(
      fontSize: 16,
      color: Color(0xFFD1C4E9),
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  ),

  cardTheme: CardTheme(
    color: const Color(0xFF2A2A40),
    shadowColor: Colors.black.withOpacity(0.3),
    elevation: 5,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
);
