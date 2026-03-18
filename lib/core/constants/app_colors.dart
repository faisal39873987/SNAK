import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Background
  static const Color background = Color(0xFF0A0A0F);
  static const Color surface = Color(0xFF12121A);
  static const Color cardBg = Color(0xFF1A1A26);

  // Neon accents
  static const Color neonGreen = Color(0xFF00FF88);
  static const Color neonBlue = Color(0xFF00BFFF);
  static const Color neonPurple = Color(0xFFBF00FF);
  static const Color neonPink = Color(0xFFFF0080);
  static const Color neonOrange = Color(0xFFFF6600);
  static const Color neonYellow = Color(0xFFFFFF00);
  static const Color neonCyan = Color(0xFF00FFFF);
  static const Color neonRed = Color(0xFFFF2244);

  // Primary palette
  static const Color primary = neonGreen;
  static const Color secondary = neonBlue;
  static const Color accent = neonPurple;

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0C8);
  static const Color textMuted = Color(0xFF606080);

  // Snake skins
  static const Color skinNeonBody = neonGreen;
  static const Color skinNeonHead = Color(0xFF00FF44);
  static const Color skinFireBody = neonOrange;
  static const Color skinFireHead = Color(0xFFFF3300);
  static const Color skinGoldBody = Color(0xFFFFD700);
  static const Color skinGoldHead = Color(0xFFFFA500);
  static const Color skinFunnyBody = neonPink;
  static const Color skinFunnyHead = neonYellow;

  // Power-ups
  static const Color powerupSpeed = neonYellow;
  static const Color powerupShield = neonBlue;
  static const Color powerupFreeze = neonCyan;
  static const Color powerupMagnet = neonPurple;

  // Food
  static const Color food = neonPink;
  static const Color foodSpecial = neonYellow;

  // UI elements
  static const Color border = Color(0xFF2A2A3A);
  static const Color divider = Color(0xFF1E1E2E);
  static const Color success = neonGreen;
  static const Color error = neonRed;
  static const Color warning = neonOrange;

  // Grid
  static const Color gridLine = Color(0xFF0D0D1A);

  // VIP / Gold
  static const Color vip = Color(0xFFFFD700);
  static const Color vipGlow = Color(0xFFFFAA00);
}
