import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          tertiary: AppColors.accent,
          surface: AppColors.surface,
          error: AppColors.error,
          onPrimary: AppColors.background,
          onSecondary: AppColors.background,
          onSurface: AppColors.textPrimary,
          onError: AppColors.textPrimary,
        ),
        fontFamily: 'Rajdhani',
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: 4,
          ),
          displayMedium: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: 3,
          ),
          displaySmall: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: 2,
          ),
          headlineLarge: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: 2,
          ),
          headlineMedium: TextStyle(
            fontFamily: 'Rajdhani',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: 1,
          ),
          titleLarge: TextStyle(
            fontFamily: 'Rajdhani',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          bodyLarge: TextStyle(
            fontFamily: 'Rajdhani',
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Rajdhani',
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
          bodySmall: TextStyle(
            fontFamily: 'Rajdhani',
            fontSize: 12,
            color: AppColors.textMuted,
          ),
          labelLarge: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: 2,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: AppColors.primary),
          titleTextStyle: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            letterSpacing: 3,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: const TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
        cardTheme: CardTheme(
          color: AppColors.cardBg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          labelStyle: const TextStyle(color: AppColors.textMuted),
          hintStyle: const TextStyle(color: AppColors.textMuted),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.divider,
          thickness: 1,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.cardBg,
          contentTextStyle: const TextStyle(color: AppColors.textPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
}
