import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../data/models/skin_model.dart';
import '../../game/engine/game_engine.dart';
import '../painters/food_painter.dart';
import '../painters/grid_painter.dart';
import '../painters/snake_painter.dart';

/// The main game board widget. It renders the grid, snake, food and power-ups.
class GameBoard extends StatefulWidget {
  final GameEngine engine;
  final SnakeSkin skin;

  const GameBoard({super.key, required this.engine, required this.skin});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate board size maintaining the grid aspect ratio
        final maxW = constraints.maxWidth;
        final maxH = constraints.maxHeight;
        final cellSize = (maxW / AppSizes.gridColumns)
            .clamp(0.0, maxH / AppSizes.gridRows);
        final boardW = cellSize * AppSizes.gridColumns;
        final boardH = cellSize * AppSizes.gridRows;

        return Center(
          child: Container(
            width: boardW,
            height: boardH,
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border.all(color: AppColors.border, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.15),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, __) {
                return Stack(
                  children: [
                    // Grid lines
                    const CustomPaint(
                      painter: GridPainter(),
                      size: Size.infinite,
                    ),
                    // Food & power-ups
                    CustomPaint(
                      painter: FoodPainter(
                        food: widget.engine.food,
                        powerup: widget.engine.spawnedPowerup,
                        animValue: _pulseAnim.value,
                      ),
                      size: Size.infinite,
                    ),
                    // Snake
                    CustomPaint(
                      painter: SnakePainter(
                        body: widget.engine.snake.body,
                        skin: widget.skin,
                      ),
                      size: Size.infinite,
                    ),
                    // Shield glow overlay
                    if (widget.engine.shieldActive)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.powerupShield
                                    .withOpacity(0.4 + _pulseAnim.value * 0.3),
                                width: 3,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
