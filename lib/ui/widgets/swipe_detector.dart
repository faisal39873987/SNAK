import 'package:flutter/material.dart';

import '../../game/engine/snake.dart';

/// Detects swipe gestures and maps them to [Direction].
class SwipeDetector extends StatelessWidget {
  final Widget child;
  final void Function(Direction direction) onSwipe;

  const SwipeDetector({
    super.key,
    required this.child,
    required this.onSwipe,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragEnd: (details) {
        final dy = details.primaryVelocity ?? 0;
        if (dy.abs() < 100) return;
        onSwipe(dy < 0 ? Direction.up : Direction.down);
      },
      onHorizontalDragEnd: (details) {
        final dx = details.primaryVelocity ?? 0;
        if (dx.abs() < 100) return;
        onSwipe(dx < 0 ? Direction.left : Direction.right);
      },
      child: child,
    );
  }
}
