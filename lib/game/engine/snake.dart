import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';

/// A position on the game grid.
@immutable
class GridPosition {
  final int x;
  final int y;

  const GridPosition(this.x, this.y);

  GridPosition operator +(GridPosition other) =>
      GridPosition(x + other.x, y + other.y);

  @override
  bool operator ==(Object other) =>
      other is GridPosition && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => '($x, $y)';
}

/// Movement direction.
enum Direction { up, down, left, right }

extension DirectionExt on Direction {
  GridPosition get delta {
    switch (this) {
      case Direction.up:
        return const GridPosition(0, -1);
      case Direction.down:
        return const GridPosition(0, 1);
      case Direction.left:
        return const GridPosition(-1, 0);
      case Direction.right:
        return const GridPosition(1, 0);
    }
  }

  bool isOppositeOf(Direction other) {
    return (this == Direction.up && other == Direction.down) ||
        (this == Direction.down && other == Direction.up) ||
        (this == Direction.left && other == Direction.right) ||
        (this == Direction.right && other == Direction.left);
  }
}

/// The snake entity.
class Snake {
  List<GridPosition> _body;
  Direction _direction;
  Direction _nextDirection;
  bool _growing = false;

  Snake({
    required List<GridPosition> initialBody,
    required Direction initialDirection,
  })  : _body = List.from(initialBody),
        _direction = initialDirection,
        _nextDirection = initialDirection;

  List<GridPosition> get body => List.unmodifiable(_body);
  GridPosition get head => _body.first;
  Direction get direction => _direction;

  void changeDirection(Direction newDir) {
    if (!newDir.isOppositeOf(_direction)) {
      _nextDirection = newDir;
    }
  }

  /// Returns the position the head will move to next.
  GridPosition get nextHeadPosition => head + _nextDirection.delta;

  /// Moves the snake one step. Returns true if it consumed food (grew).
  bool move({bool grow = false}) {
    _direction = _nextDirection;
    final newHead = nextHeadPosition;
    _body.insert(0, newHead);
    if (!grow) {
      _body.removeLast();
      return false;
    }
    return true;
  }

  /// Tells the snake to grow on the next move.
  void queueGrow() => _growing = true;

  bool get shouldGrow {
    if (_growing) {
      _growing = false;
      return true;
    }
    return false;
  }

  int get length => _body.length;

  bool collidesWithSelf() {
    for (int i = 1; i < _body.length; i++) {
      if (_body[i] == head) return true;
    }
    return false;
  }

  bool isOutOfBounds(int cols, int rows) {
    return head.x < 0 || head.x >= cols || head.y < 0 || head.y >= rows;
  }

  /// Factory: creates a new snake in the centre of the grid.
  factory Snake.initial() {
    const midX = AppSizes.gridColumns ~/ 2;
    const midY = AppSizes.gridRows ~/ 2;
    final body = List.generate(
      AppSizes.initialSnakeLength,
      (i) => GridPosition(midX - i, midY),
    );
    return Snake(initialBody: body, initialDirection: Direction.right);
  }
}
