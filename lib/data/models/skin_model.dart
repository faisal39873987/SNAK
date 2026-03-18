import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

enum SkinRarity { common, rare, epic, legendary }

class SnakeSkin {
  final String id;
  final String name;
  final String description;
  final Color headColor;
  final Color bodyColor;
  final Color glowColor;
  final int price;
  final SkinRarity rarity;
  final bool isVipOnly;

  const SnakeSkin({
    required this.id,
    required this.name,
    required this.description,
    required this.headColor,
    required this.bodyColor,
    required this.glowColor,
    required this.price,
    this.rarity = SkinRarity.common,
    this.isVipOnly = false,
  });

  static List<SnakeSkin> get all => [
        const SnakeSkin(
          id: 'default',
          name: 'DEFAULT',
          description: 'The classic look.',
          headColor: AppColors.neonGreen,
          bodyColor: Color(0xFF00CC66),
          glowColor: AppColors.neonGreen,
          price: 0,
          rarity: SkinRarity.common,
        ),
        const SnakeSkin(
          id: 'neon',
          name: 'NEON',
          description: 'Bright neon glow that cuts through the dark.',
          headColor: AppColors.neonCyan,
          bodyColor: AppColors.neonBlue,
          glowColor: AppColors.neonCyan,
          price: 200,
          rarity: SkinRarity.rare,
        ),
        const SnakeSkin(
          id: 'fire',
          name: 'FIRE',
          description: 'Blaze through the board in flames.',
          headColor: AppColors.skinFireHead,
          bodyColor: AppColors.skinFireBody,
          glowColor: AppColors.neonOrange,
          price: 500,
          rarity: SkinRarity.epic,
        ),
        const SnakeSkin(
          id: 'gold',
          name: 'GOLD',
          description: 'Wealth and glory await the golden snake.',
          headColor: AppColors.skinGoldHead,
          bodyColor: AppColors.skinGoldBody,
          glowColor: AppColors.vipGlow,
          price: 1000,
          rarity: SkinRarity.legendary,
        ),
        const SnakeSkin(
          id: 'funny',
          name: 'FUNNY',
          description: 'Who said snakes can\'t be fun?',
          headColor: AppColors.skinFunnyHead,
          bodyColor: AppColors.skinFunnyBody,
          glowColor: AppColors.neonPink,
          price: 300,
          rarity: SkinRarity.rare,
        ),
        const SnakeSkin(
          id: 'vip_purple',
          name: 'PHANTOM',
          description: 'Exclusive VIP skin. Pure purple power.',
          headColor: AppColors.neonPurple,
          bodyColor: Color(0xFF8800CC),
          glowColor: AppColors.neonPurple,
          price: 0,
          rarity: SkinRarity.legendary,
          isVipOnly: true,
        ),
      ];

  static SnakeSkin getById(String id) {
    return all.firstWhere((s) => s.id == id, orElse: () => all.first);
  }

  Color get rarityColor {
    switch (rarity) {
      case SkinRarity.common:
        return AppColors.textMuted;
      case SkinRarity.rare:
        return AppColors.neonBlue;
      case SkinRarity.epic:
        return AppColors.neonPurple;
      case SkinRarity.legendary:
        return AppColors.vip;
    }
  }

  String get rarityLabel {
    switch (rarity) {
      case SkinRarity.common:
        return 'COMMON';
      case SkinRarity.rare:
        return 'RARE';
      case SkinRarity.epic:
        return 'EPIC';
      case SkinRarity.legendary:
        return 'LEGENDARY';
    }
  }
}
