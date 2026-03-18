import 'package:flutter/material.dart';
import '../game/snake_game.dart';

class GameBoard extends StatelessWidget {
  final SnakeGame game;
  final double size;

  const GameBoard({
    super.key,
    required this.game,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final cellSize = size / SnakeGame.gridSize;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF0f3460),
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: CustomPaint(
          size: Size(size, size),
          painter: _GameBoardPainter(
            snake: game.snake,
            foodPosition: game.foodPosition,
            cellSize: cellSize,
            gridSize: SnakeGame.gridSize,
          ),
        ),
      ),
    );
  }
}

class _GameBoardPainter extends CustomPainter {
  final List<int> snake;
  final int foodPosition;
  final double cellSize;
  final int gridSize;

  _GameBoardPainter({
    required this.snake,
    required this.foodPosition,
    required this.cellSize,
    required this.gridSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw grid lines (subtle)
    final gridPaint = Paint()
      ..color = const Color(0xFF252540)
      ..strokeWidth = 0.5;

    for (int i = 0; i <= gridSize; i++) {
      final pos = i * cellSize;
      // Vertical lines
      canvas.drawLine(Offset(pos, 0), Offset(pos, size.height), gridPaint);
      // Horizontal lines
      canvas.drawLine(Offset(0, pos), Offset(size.width, pos), gridPaint);
    }

    // Draw food
    _drawFood(canvas);

    // Draw snake
    _drawSnake(canvas);
  }

  void _drawFood(Canvas canvas) {
    final x = (foodPosition % gridSize) * cellSize;
    final y = (foodPosition ~/ gridSize) * cellSize;
    final center = Offset(x + cellSize / 2, y + cellSize / 2);
    final radius = cellSize * 0.4;

    // Glow effect
    final glowPaint = Paint()
      ..color = const Color(0xFFe94560).withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center, radius * 1.5, glowPaint);

    // Main food circle
    final foodPaint = Paint()
      ..color = const Color(0xFFe94560)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, foodPaint);

    // Highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(center.dx - radius * 0.3, center.dy - radius * 0.3),
      radius * 0.25,
      highlightPaint,
    );
  }

  void _drawSnake(Canvas canvas) {
    if (snake.isEmpty) return;

    for (int i = 0; i < snake.length; i++) {
      final pos = snake[i];
      final x = (pos % gridSize) * cellSize;
      final y = (pos ~/ gridSize) * cellSize;
      final rect = Rect.fromLTWH(
        x + 1,
        y + 1,
        cellSize - 2,
        cellSize - 2,
      );

      // Color gradient from head to tail
      final headColor = const Color(0xFF00d9ff);
      final tailColor = const Color(0xFF0077b6);
      final progress = i / (snake.length > 1 ? snake.length - 1 : 1);
      final color = Color.lerp(headColor, tailColor, progress)!;

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      // Head is slightly larger with glow
      if (i == 0) {
        // Glow effect for head
        final glowPaint = Paint()
          ..color = headColor.withValues(alpha: 0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            rect.inflate(2),
            const Radius.circular(6),
          ),
          glowPaint,
        );
      }

      // Rounded rectangle for snake segment
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          rect,
          Radius.circular(i == 0 ? 6 : 4),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GameBoardPainter oldDelegate) {
    return oldDelegate.snake != snake ||
        oldDelegate.foodPosition != foodPosition;
  }
}
