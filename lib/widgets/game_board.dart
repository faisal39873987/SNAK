import 'package:flutter/material.dart';
import '../game/snake_game.dart';

class GameBoard extends StatefulWidget {
  final SnakeGame game;
  final double size;

  const GameBoard({
    super.key,
    required this.game,
    required this.size,
  });

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _powerUpController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _powerUpAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _powerUpController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
    _powerUpAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _powerUpController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(GameBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.game.foodEatenEffect) {
      _pulseController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _powerUpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cellSize = widget.size / SnakeGame.gridSize;

    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _powerUpController]),
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: const Color(0xFF1a1a2e),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.game.hasShield 
                  ? const Color(0xFF00ff88)
                  : const Color(0xFF0f3460),
              width: widget.game.hasShield ? 3 : 2,
            ),
            boxShadow: widget.game.hasShield
                ? [
                    BoxShadow(
                      color: const Color(0xFF00ff88).withValues(alpha: 0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _GameBoardPainter(
                snake: widget.game.snake,
                foodPosition: widget.game.foodPosition,
                cellSize: cellSize,
                gridSize: SnakeGame.gridSize,
                powerUp: widget.game.currentPowerUp,
                hasShield: widget.game.hasShield,
                hasSpeedBoost: widget.game.getActivePowerUp(PowerUpType.speedBoost) != null,
                hasMagnet: widget.game.getActivePowerUp(PowerUpType.magnet) != null,
                pulseValue: _pulseAnimation.value,
                powerUpPulse: _powerUpAnimation.value,
                foodEatenEffect: widget.game.foodEatenEffect,
                lastEatenPosition: widget.game.lastEatenPosition,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GameBoardPainter extends CustomPainter {
  final List<int> snake;
  final int foodPosition;
  final double cellSize;
  final int gridSize;
  final PowerUp? powerUp;
  final bool hasShield;
  final bool hasSpeedBoost;
  final bool hasMagnet;
  final double pulseValue;
  final double powerUpPulse;
  final bool foodEatenEffect;
  final int? lastEatenPosition;

  _GameBoardPainter({
    required this.snake,
    required this.foodPosition,
    required this.cellSize,
    required this.gridSize,
    this.powerUp,
    this.hasShield = false,
    this.hasSpeedBoost = false,
    this.hasMagnet = false,
    this.pulseValue = 1.0,
    this.powerUpPulse = 1.0,
    this.foodEatenEffect = false,
    this.lastEatenPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF252540)
      ..strokeWidth = 0.5;

    for (int i = 0; i <= gridSize; i++) {
      final pos = i * cellSize;
      canvas.drawLine(Offset(pos, 0), Offset(pos, size.height), gridPaint);
      canvas.drawLine(Offset(0, pos), Offset(size.width, pos), gridPaint);
    }

    if (foodEatenEffect && lastEatenPosition != null) {
      _drawEatEffect(canvas, lastEatenPosition!);
    }

    if (powerUp != null) {
      _drawPowerUp(canvas, powerUp!);
    }

    _drawFood(canvas);
    _drawSnake(canvas);

    if (hasMagnet) {
      _drawMagnetEffect(canvas);
    }
  }

  void _drawEatEffect(Canvas canvas, int position) {
    final x = (position % gridSize) * cellSize;
    final y = (position ~/ gridSize) * cellSize;
    final center = Offset(x + cellSize / 2, y + cellSize / 2);

    final ringPaint = Paint()
      ..color = const Color(0xFFe94560).withValues(alpha: (2 - pulseValue) * 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(center, cellSize * pulseValue, ringPaint);
  }

  void _drawPowerUp(Canvas canvas, PowerUp powerUp) {
    final x = (powerUp.position % gridSize) * cellSize;
    final y = (powerUp.position ~/ gridSize) * cellSize;
    final center = Offset(x + cellSize / 2, y + cellSize / 2);
    final radius = cellSize * 0.4 * powerUpPulse;

    Color color;
    String icon;
    switch (powerUp.type) {
      case PowerUpType.speedBoost:
        color = const Color(0xFFFFD700);
        icon = '⚡';
        break;
      case PowerUpType.shield:
        color = const Color(0xFF00FF88);
        icon = '🛡️';
        break;
      case PowerUpType.magnet:
        color = const Color(0xFFFF6B6B);
        icon = '🧲';
        break;
    }

    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(center, radius * 1.8, glowPaint);

    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 1.2, bgPaint);

    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, borderPaint);

    final textPainter = TextPainter(
      text: TextSpan(text: icon, style: TextStyle(fontSize: cellSize * 0.6)),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2),
    );
  }

  void _drawFood(Canvas canvas) {
    final x = (foodPosition % gridSize) * cellSize;
    final y = (foodPosition ~/ gridSize) * cellSize;
    final center = Offset(x + cellSize / 2, y + cellSize / 2);
    final radius = cellSize * 0.4;

    final glowPaint = Paint()
      ..color = const Color(0xFFe94560).withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(center, radius * 1.6, glowPaint);

    final foodPaint = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFFFF6B6B), const Color(0xFFe94560)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, foodPaint);

    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(center.dx - radius * 0.3, center.dy - radius * 0.3),
      radius * 0.25,
      highlightPaint,
    );
  }

  void _drawSnake(Canvas canvas) {
    if (snake.isEmpty) return;

    for (int i = snake.length - 1; i >= 0; i--) {
      final pos = snake[i];
      final x = (pos % gridSize) * cellSize;
      final y = (pos ~/ gridSize) * cellSize;
      final rect = Rect.fromLTWH(x + 1, y + 1, cellSize - 2, cellSize - 2);

      Color headColor = const Color(0xFF00d9ff);
      Color tailColor = const Color(0xFF0077b6);

      if (hasShield) {
        headColor = const Color(0xFF00FF88);
        tailColor = const Color(0xFF00AA55);
      } else if (hasSpeedBoost) {
        headColor = const Color(0xFFFFD700);
        tailColor = const Color(0xFFFF8C00);
      } else if (hasMagnet) {
        headColor = const Color(0xFFFF6B6B);
        tailColor = const Color(0xFFCC4444);
      }

      final progress = i / (snake.length > 1 ? snake.length - 1 : 1);
      final color = Color.lerp(headColor, tailColor, progress)!;

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      if (i == 0) {
        final glowPaint = Paint()
          ..color = headColor.withValues(alpha: 0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect.inflate(3), const Radius.circular(8)),
          glowPaint,
        );
      }

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(i == 0 ? 8 : 5)),
        paint,
      );

      if (i == 0) {
        _drawEyes(canvas, x, y);
      }
    }
  }

  void _drawEyes(Canvas canvas, double x, double y) {
    final eyePaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    final pupilPaint = Paint()..color = Colors.black..style = PaintingStyle.fill;

    final eyeSize = cellSize * 0.12;
    final pupilSize = cellSize * 0.06;

    final cx = x + cellSize / 2;
    final cy = y + cellSize / 2;
    
    final eye1 = Offset(cx - cellSize * 0.15, cy - cellSize * 0.1);
    final eye2 = Offset(cx + cellSize * 0.15, cy - cellSize * 0.1);

    canvas.drawCircle(eye1, eyeSize, eyePaint);
    canvas.drawCircle(eye2, eyeSize, eyePaint);
    canvas.drawCircle(eye1, pupilSize, pupilPaint);
    canvas.drawCircle(eye2, pupilSize, pupilPaint);
  }

  void _drawMagnetEffect(Canvas canvas) {
    if (snake.isEmpty) return;
    
    final head = snake.first;
    final headX = (head % gridSize) * cellSize + cellSize / 2;
    final headY = (head ~/ gridSize) * cellSize + cellSize / 2;
    final foodX = (foodPosition % gridSize) * cellSize + cellSize / 2;
    final foodY = (foodPosition ~/ gridSize) * cellSize + cellSize / 2;

    final linePaint = Paint()
      ..color = const Color(0xFFFF6B6B).withValues(alpha: 0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(headX, headY);
    
    final midX = (headX + foodX) / 2;
    final midY = (headY + foodY) / 2 - 20;
    path.quadraticBezierTo(midX, midY, foodX, foodY);
    
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _GameBoardPainter oldDelegate) {
    return oldDelegate.snake != snake ||
        oldDelegate.foodPosition != foodPosition ||
        oldDelegate.powerUp != powerUp ||
        oldDelegate.hasShield != hasShield ||
        oldDelegate.hasSpeedBoost != hasSpeedBoost ||
        oldDelegate.hasMagnet != hasMagnet ||
        oldDelegate.pulseValue != pulseValue ||
        oldDelegate.powerUpPulse != powerUpPulse ||
        oldDelegate.foodEatenEffect != foodEatenEffect;
  }
}
