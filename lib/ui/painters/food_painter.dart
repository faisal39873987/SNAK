import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../game/engine/food.dart';
import '../../game/engine/powerup.dart';

class FoodPainter extends CustomPainter {
  final Food food;
  final Powerup? powerup;
  final double animValue; // 0..1 pulsing animation

  const FoodPainter({
    required this.food,
    this.powerup,
    required this.animValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / AppSizes.gridColumns;
    final cellH = size.height / AppSizes.gridRows;

    _drawFood(canvas, cellW, cellH);
    if (powerup != null) {
      _drawPowerup(canvas, cellW, cellH, powerup!);
    }
  }

  void _drawFood(Canvas canvas, double cellW, double cellH) {
    final fp = food.position;
    final cx = fp.x * cellW + cellW / 2;
    final cy = fp.y * cellH + cellH / 2;
    final radius = (cellW * 0.38) * (1.0 + animValue * 0.12);

    final color = food.type == FoodType.special
        ? AppColors.foodSpecial
        : AppColors.food;

    // Glow
    final glowPaint = Paint()
      ..color = color.withOpacity(0.5)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6 + animValue * 4);
    canvas.drawCircle(Offset(cx, cy), radius * 1.5, glowPaint);

    // Main circle
    final foodPaint = Paint()..color = color;
    canvas.drawCircle(Offset(cx, cy), radius, foodPaint);

    // Shine
    final shinePaint = Paint()
      ..color = Colors.white.withOpacity(0.6);
    canvas.drawCircle(
      Offset(cx - radius * 0.3, cy - radius * 0.3),
      radius * 0.25,
      shinePaint,
    );
  }

  void _drawPowerup(
    Canvas canvas,
    double cellW,
    double cellH,
    Powerup p,
  ) {
    final pp = p.position;
    final cx = pp.x * cellW + cellW / 2;
    final cy = pp.y * cellH + cellH / 2;
    final radius = (cellW * 0.42) * (1.0 + animValue * 0.15);
    final color = _powerupColor(p.type);

    // Outer glow
    final glowPaint = Paint()
      ..color = color.withOpacity(0.4)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8 + animValue * 4);
    canvas.drawCircle(Offset(cx, cy), radius * 1.8, glowPaint);

    // Ring
    final ringPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset(cx, cy), radius, ringPaint);

    // Inner fill
    final fillPaint = Paint()
      ..color = color.withOpacity(0.3);
    canvas.drawCircle(Offset(cx, cy), radius * 0.8, fillPaint);

    // Icon letter
    final textPainter = TextPainter(
      text: TextSpan(
        text: _powerupIcon(p.type),
        style: TextStyle(
          color: color,
          fontSize: cellW * 0.5,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(cx - textPainter.width / 2, cy - textPainter.height / 2),
    );
  }

  Color _powerupColor(PowerupType type) {
    switch (type) {
      case PowerupType.speedBoost:
        return AppColors.powerupSpeed;
      case PowerupType.shield:
        return AppColors.powerupShield;
      case PowerupType.freeze:
        return AppColors.powerupFreeze;
      case PowerupType.magnet:
        return AppColors.powerupMagnet;
    }
  }

  String _powerupIcon(PowerupType type) {
    switch (type) {
      case PowerupType.speedBoost:
        return '⚡';
      case PowerupType.shield:
        return '🛡';
      case PowerupType.freeze:
        return '❄';
      case PowerupType.magnet:
        return '🧲';
    }
  }

  @override
  bool shouldRepaint(covariant FoodPainter oldDelegate) =>
      oldDelegate.food != food ||
      oldDelegate.powerup != powerup ||
      oldDelegate.animValue != animValue;
}
