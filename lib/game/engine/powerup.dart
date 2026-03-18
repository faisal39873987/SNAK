import 'dart:math';

import '../../core/constants/app_sizes.dart';
import 'snake.dart';

enum PowerupType { speedBoost, shield, freeze, magnet }

class Powerup {
  final GridPosition position;
  final PowerupType type;
  final int durationMs;

  const Powerup({
    required this.position,
    required this.type,
    required this.durationMs,
  });

  static final Random _rng = Random();

  factory Powerup.spawn({
    required List<GridPosition> occupied,
    PowerupType? forceType,
  }) {
    GridPosition pos;
    int attempts = 0;
    do {
      pos = GridPosition(
        _rng.nextInt(AppSizes.gridColumns),
        _rng.nextInt(AppSizes.gridRows),
      );
      attempts++;
    } while (occupied.contains(pos) && attempts < 200);

    final type = forceType ??
        PowerupType.values[_rng.nextInt(PowerupType.values.length)];

    int duration;
    switch (type) {
      case PowerupType.speedBoost:
        duration = AppSizes.powerupDuration;
      case PowerupType.shield:
        duration = AppSizes.shieldDuration;
      case PowerupType.freeze:
        duration = AppSizes.freezeDuration;
      case PowerupType.magnet:
        duration = AppSizes.magnetDuration;
    }

    return Powerup(position: pos, type: type, durationMs: duration);
  }

  String get label {
    switch (type) {
      case PowerupType.speedBoost:
        return 'SPEED';
      case PowerupType.shield:
        return 'SHIELD';
      case PowerupType.freeze:
        return 'FREEZE';
      case PowerupType.magnet:
        return 'MAGNET';
    }
  }
}

/// Tracks an active (consumed) power-up with remaining time.
class ActivePowerup {
  final PowerupType type;
  final int startMs;
  final int durationMs;

  const ActivePowerup({
    required this.type,
    required this.startMs,
    required this.durationMs,
  });

  int get endMs => startMs + durationMs;

  double remainingFraction(int nowMs) {
    final remaining = endMs - nowMs;
    if (remaining <= 0) return 0;
    return remaining / durationMs;
  }

  bool isExpired(int nowMs) => nowMs >= endMs;
}
