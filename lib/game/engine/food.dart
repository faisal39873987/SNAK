import 'dart:math';

import '../../core/constants/app_sizes.dart';
import 'snake.dart';

enum FoodType { normal, special }

class Food {
  final GridPosition position;
  final FoodType type;
  final int value;

  const Food({
    required this.position,
    required this.type,
    required this.value,
  });

  static final Random _rng = Random();

  /// Spawns food at a random position not occupied by the snake or powerups.
  factory Food.spawn({
    required List<GridPosition> occupied,
    bool forceSpecial = false,
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

    final isSpecial = forceSpecial || _rng.nextInt(10) == 0; // 10% chance
    return Food(
      position: pos,
      type: isSpecial ? FoodType.special : FoodType.normal,
      value: isSpecial ? AppSizes.foodScoreSpecial : AppSizes.foodScoreNormal,
    );
  }
}
