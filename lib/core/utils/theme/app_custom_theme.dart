import 'package:flutter/material.dart';

class AppCustomTheme {
  // Define custom colors
  static const Color primaryColor = Color(0xFF4CAF50); // Green
  static const Color secondaryColor = Color(0xFF8BC34A); // Light Green
  static const Color errorColor = Color(0xFFB71C1C); // Red

  // Light Color Scheme
  static final ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primaryColor,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFC8E6C9),
    onPrimaryContainer: primaryColor,
    secondary: secondaryColor,
    onSecondary: Colors.black,
    secondaryContainer: Color(0xFFC8E6C9),
    onSecondaryContainer: secondaryColor,
    surface: Colors.white, // White for cards, dialogs, etc.
    onSurface: Colors.black,
    error: errorColor,
    onError: Colors.white,
  );

  static ThemeData lightTheme() {
    return ThemeData.from(colorScheme: lightColorScheme).copyWith(
      scaffoldBackgroundColor: lightColorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: lightColorScheme.primary,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: lightColorScheme.onPrimary,
        ),
        iconTheme: IconThemeData(color: lightColorScheme.onPrimary),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: lightColorScheme.primary,
        foregroundColor: lightColorScheme.onPrimary,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(fontSize: 16),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightColorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: lightColorScheme.primary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: lightColorScheme.primary, width: 2),
        ),
        hintStyle: TextStyle(color: Colors.black54),
        labelStyle: TextStyle(color: lightColorScheme.onSurface),
      ),
    );
  }

  // Dark Color Scheme
  static final ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: primaryColor,
    onPrimary: Colors.black,
    primaryContainer: Color(0xFF388E3C),
    onPrimaryContainer: Colors.white,
    secondary: secondaryColor,
    onSecondary: Colors.black,
    secondaryContainer: Color(0xFF33691E),
    onSecondaryContainer: Colors.white,
    surface: Color(0xFF37474F), // Dark slate for surface items
    onSurface: Colors.white70,
    error: Color(0xFFCF6679),
    onError: Colors.black,
  );

  static ThemeData darkTheme() {
    return ThemeData.from(colorScheme: darkColorScheme).copyWith(
      scaffoldBackgroundColor: darkColorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: darkColorScheme.primary,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: darkColorScheme.onPrimary,
        ),
        iconTheme: IconThemeData(color: darkColorScheme.onPrimary),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: darkColorScheme.primary,
        foregroundColor: darkColorScheme.onPrimary,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        bodyLarge: TextStyle(fontSize: 16, color: Colors.white70),
        bodyMedium: TextStyle(color: Colors.white60),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkColorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: darkColorScheme.primary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: darkColorScheme.primary, width: 2),
        ),
        hintStyle: TextStyle(color: Colors.white70),
        labelStyle: TextStyle(color: darkColorScheme.onSurface),
      ),
      cardColor: darkColorScheme.surface, dialogTheme: DialogThemeData(backgroundColor: darkColorScheme.surface),
    );
  }
}