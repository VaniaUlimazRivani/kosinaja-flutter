import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.interTextTheme();
    final headingTextTheme = GoogleFonts.plusJakartaSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: Colors.white,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        error: AppColors.error,
        onError: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: headingTextTheme.displayLarge?.copyWith(
          color: AppColors.text,
          fontWeight: FontWeight.w800,
        ),
        displayMedium: headingTextTheme.displayMedium?.copyWith(
          color: AppColors.text,
          fontWeight: FontWeight.w800,
        ),
        headlineLarge: headingTextTheme.headlineLarge?.copyWith(
          color: AppColors.text,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: headingTextTheme.headlineMedium?.copyWith(
          color: AppColors.text,
          fontWeight: FontWeight.w700,
        ),
        headlineSmall: headingTextTheme.headlineSmall?.copyWith(
          color: AppColors.text,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: headingTextTheme.titleLarge?.copyWith(
          color: AppColors.text,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: headingTextTheme.titleMedium?.copyWith(
          color: AppColors.text,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: headingTextTheme.titleSmall?.copyWith(
          color: AppColors.text,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: AppColors.text,
          fontSize: 16,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
        bodySmall: baseTextTheme.bodySmall?.copyWith(
          color: AppColors.textMuted,
          fontSize: 12,
        ),
        labelLarge: headingTextTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
        labelMedium: headingTextTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.text),
        titleTextStyle: headingTextTheme.titleLarge?.copyWith(
          color: AppColors.text,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: headingTextTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        hintStyle: baseTextTheme.bodyMedium?.copyWith(
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}
