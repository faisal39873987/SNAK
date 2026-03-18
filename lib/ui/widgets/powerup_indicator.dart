import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../game/engine/powerup.dart';

class PowerupIndicator extends StatelessWidget {
  final List<ActivePowerup> activePowerups;
  final int nowMs;

  const PowerupIndicator({
    super.key,
    required this.activePowerups,
    required this.nowMs,
  });

  @override
  Widget build(BuildContext context) {
    if (activePowerups.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: activePowerups
          .map((p) => _PowerupChip(powerup: p, nowMs: nowMs))
          .toList(),
    );
  }
}

class _PowerupChip extends StatelessWidget {
  final ActivePowerup powerup;
  final int nowMs;

  const _PowerupChip({required this.powerup, required this.nowMs});

  @override
  Widget build(BuildContext context) {
    final fraction = powerup.remainingFraction(nowMs);
    final color = _color(powerup.type);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1.5),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.3), blurRadius: 6),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _icon(powerup.type),
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 2),
          SizedBox(
            width: 28,
            height: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: fraction,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _color(PowerupType type) {
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

  String _icon(PowerupType type) {
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
}
