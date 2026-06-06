import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.backgroundStart,
        onSurface: AppColors.dark,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: -0.02, color: AppColors.dark),
        displayMedium: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: -0.02, color: AppColors.dark),
        displaySmall: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: -0.02, color: AppColors.dark),
        headlineMedium: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: -0.02, color: AppColors.dark),
        titleLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: -0.02, color: AppColors.dark),
      ),
      scaffoldBackgroundColor: AppColors.backgroundStart,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.dark),
        titleTextStyle: TextStyle(color: AppColors.dark, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          elevation: 2,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 2)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 2)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.primaryLight, // Brighter green for dark mode
        secondary: AppColors.secondary,
        surface: const Color(0xFF0F172A), // Dark blue/black
        onSurface: Colors.white,
        onPrimary: Colors.white,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: -0.02, color: Colors.white),
        displayMedium: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: -0.02, color: Colors.white),
        displaySmall: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: -0.02, color: Colors.white),
        headlineMedium: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: -0.02, color: Colors.white),
        titleLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: -0.02, color: Colors.white),
        bodyLarge: const TextStyle(color: Color(0xFFE2E8F0)),
        bodyMedium: const TextStyle(color: Color(0xFF94A3B8)),
      ),
      scaffoldBackgroundColor: const Color(0xFF020617), // Near black
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          elevation: 0,
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E293B),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF334155), width: 2)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF334155), width: 2)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryLight, width: 2)),
        contentPadding: const EdgeInsets.all(16),
        labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
      ),
    );
  }
}

