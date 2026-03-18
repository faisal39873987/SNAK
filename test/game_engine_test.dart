import 'package:flutter_test/flutter_test.dart';

import 'package:snak/game/engine/snake.dart';
import 'package:snak/game/engine/food.dart';
import 'package:snak/game/engine/powerup.dart';
import 'package:snak/core/constants/app_sizes.dart';

void main() {
  group('GridPosition', () {
    test('equality works', () {
      expect(const GridPosition(2, 3), equals(const GridPosition(2, 3)));
      expect(const GridPosition(2, 3), isNot(equals(const GridPosition(3, 2))));
    });

    test('addition works', () {
      const a = GridPosition(3, 4);
      const b = GridPosition(1, 2);
      expect(a + b, equals(const GridPosition(4, 6)));
    });
  });

  group('Direction', () {
    test('opposite detection', () {
      expect(Direction.up.isOppositeOf(Direction.down), isTrue);
      expect(Direction.left.isOppositeOf(Direction.right), isTrue);
      expect(Direction.up.isOppositeOf(Direction.left), isFalse);
    });

    test('delta values are correct', () {
      expect(Direction.up.delta, equals(const GridPosition(0, -1)));
      expect(Direction.down.delta, equals(const GridPosition(0, 1)));
      expect(Direction.left.delta, equals(const GridPosition(-1, 0)));
      expect(Direction.right.delta, equals(const GridPosition(1, 0)));
    });
  });

  group('Snake', () {
    test('initial snake is created correctly', () {
      final snake = Snake.initial();
      expect(snake.body.length, equals(AppSizes.initialSnakeLength));
      expect(snake.direction, equals(Direction.right));
    });

    test('direction change is accepted', () {
      final snake = Snake.initial();
      snake.changeDirection(Direction.up);
      expect(snake.direction, Direction.right); // not yet applied
      snake.move();
      expect(snake.direction, Direction.up);
    });

    test('opposite direction is rejected', () {
      final snake = Snake.initial(); // starts moving right
      snake.changeDirection(Direction.left);
      snake.move();
      // Direction should remain right, not left
      expect(snake.direction, Direction.right);
    });

    test('snake grows when queueGrow is called', () {
      final snake = Snake.initial();
      final initialLength = snake.length;
      snake.queueGrow();
      snake.move(grow: snake.shouldGrow);
      expect(snake.length, equals(initialLength + 1));
    });

    test('no growth when queueGrow not called', () {
      final snake = Snake.initial();
      final initialLength = snake.length;
      snake.move(grow: snake.shouldGrow);
      expect(snake.length, equals(initialLength));
    });

    test('out of bounds detection', () {
      final snake = Snake(
        initialBody: [const GridPosition(-1, 5)],
        initialDirection: Direction.left,
      );
      expect(
        snake.isOutOfBounds(AppSizes.gridColumns, AppSizes.gridRows),
        isTrue,
      );
    });

    test('in-bounds snake is not out of bounds', () {
      final snake = Snake.initial();
      expect(
        snake.isOutOfBounds(AppSizes.gridColumns, AppSizes.gridRows),
        isFalse,
      );
    });

    test('self collision detection', () {
      // Create a snake that overlaps itself
      final snake = Snake(
        initialBody: [
          const GridPosition(5, 5),
          const GridPosition(5, 6),
          const GridPosition(5, 5), // duplicate head position
        ],
        initialDirection: Direction.up,
      );
      expect(snake.collidesWithSelf(), isTrue);
    });

    test('no self collision with normal snake', () {
      final snake = Snake.initial();
      expect(snake.collidesWithSelf(), isFalse);
    });
  });

  group('Food', () {
    test('food spawns within grid bounds', () {
      final snake = Snake.initial();
      final food = Food.spawn(occupied: snake.body);
      expect(food.position.x, greaterThanOrEqualTo(0));
      expect(food.position.x, lessThan(AppSizes.gridColumns));
      expect(food.position.y, greaterThanOrEqualTo(0));
      expect(food.position.y, lessThan(AppSizes.gridRows));
    });

    test('food spawns with correct values', () {
      final food = Food.spawn(occupied: [], forceSpecial: true);
      expect(food.type, equals(FoodType.special));
      expect(food.value, equals(AppSizes.foodScoreSpecial));
    });

    test('normal food has correct score value', () {
      // Spawn many normal foods until we get one
      bool foundNormal = false;
      for (int i = 0; i < 50; i++) {
        final food = Food.spawn(occupied: []);
        if (food.type == FoodType.normal) {
          expect(food.value, equals(AppSizes.foodScoreNormal));
          foundNormal = true;
          break;
        }
      }
      expect(foundNormal, isTrue);
    });
  });

  group('Powerup', () {
    test('powerup spawns within grid', () {
      final powerup = Powerup.spawn(occupied: []);
      expect(powerup.position.x, greaterThanOrEqualTo(0));
      expect(powerup.position.x, lessThan(AppSizes.gridColumns));
      expect(powerup.position.y, greaterThanOrEqualTo(0));
      expect(powerup.position.y, lessThan(AppSizes.gridRows));
    });

    test('powerup type can be forced', () {
      for (final type in PowerupType.values) {
        final powerup = Powerup.spawn(occupied: [], forceType: type);
        expect(powerup.type, equals(type));
      }
    });

    test('active powerup expires correctly', () {
      final now = DateTime.now().millisecondsSinceEpoch;
      final active = ActivePowerup(
        type: PowerupType.shield,
        startMs: now - 8000,
        durationMs: 7000,
      );
      expect(active.isExpired(now), isTrue);
    });

    test('active powerup not expired when still running', () {
      final now = DateTime.now().millisecondsSinceEpoch;
      final active = ActivePowerup(
        type: PowerupType.shield,
        startMs: now,
        durationMs: 7000,
      );
      expect(active.isExpired(now), isFalse);
    });

    test('remaining fraction is correct', () {
      final now = DateTime.now().millisecondsSinceEpoch;
      final active = ActivePowerup(
        type: PowerupType.magnet,
        startMs: now - 3000,
        durationMs: 6000,
      );
      final fraction = active.remainingFraction(now);
      // Should be roughly 0.5 (half way through)
      expect(fraction, closeTo(0.5, 0.1));
    });
  });

  group('AppSizes', () {
    test('grid dimensions are positive', () {
      expect(AppSizes.gridColumns, greaterThan(0));
      expect(AppSizes.gridRows, greaterThan(0));
    });

    test('speed values are in correct order', () {
      expect(AppSizes.speedSlow, greaterThan(AppSizes.speedNormal));
      expect(AppSizes.speedNormal, greaterThan(AppSizes.speedFast));
      expect(AppSizes.speedFast, greaterThan(AppSizes.speedMax));
    });

    test('initial snake length is reasonable', () {
      expect(AppSizes.initialSnakeLength, greaterThanOrEqualTo(2));
      expect(AppSizes.initialSnakeLength,
          lessThan(AppSizes.gridColumns));
    });
  });
}
