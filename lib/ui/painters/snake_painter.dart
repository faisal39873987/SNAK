import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../data/models/skin_model.dart';
import '../../game/engine/snake.dart';

class SnakePainter extends CustomPainter {
  final List<GridPosition> body;
  final SnakeSkin skin;

  const SnakePainter({required this.body, required this.skin});

  @override
  void paint(Canvas canvas, Size size) {
    if (body.isEmpty) return;

    final cellW = size.width / AppSizes.gridColumns;
    final cellH = size.height / AppSizes.gridRows;
    final cellSize = Size(cellW, cellH);

    for (int i = body.length - 1; i >= 0; i--) {
      final pos = body[i];
      final isHead = i == 0;
      final rect = Rect.fromLTWH(
        pos.x * cellW + 1,
        pos.y * cellH + 1,
        cellW - 2,
        cellH - 2,
      );

      // Glow effect
      final glowPaint = Paint()
        ..color = skin.glowColor.withOpacity(isHead ? 0.6 : 0.25)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, isHead ? 6 : 3);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.inflate(2), const Radius.circular(4)),
        glowPaint,
      );

      // Body segment
      final bodyPaint = Paint()
        ..color = isHead ? skin.headColor : skin.bodyColor
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(isHead ? 5 : 3)),
        bodyPaint,
      );

      // Head eyes
      if (isHead) {
        _drawHeadDetails(canvas, pos, cellSize, body.length > 1 ? body[1] : null);
      }
    }
  }

  void _drawHeadDetails(
    Canvas canvas,
    GridPosition head,
    Size cell,
    GridPosition? neck,
  ) {
    final eyePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final pupilPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    // Simple eyes as circles
    final cx = head.x * cell.width + cell.width / 2;
    final cy = head.y * cell.height + cell.height / 2;
    final r = cell.width * 0.15;
    final offset = cell.width * 0.18;

    // Two eyes offset perpendicular to movement direction
    canvas.drawCircle(Offset(cx - offset, cy - offset), r, eyePaint);
    canvas.drawCircle(Offset(cx + offset, cy - offset), r, eyePaint);
    canvas.drawCircle(
        Offset(cx - offset, cy - offset), r * 0.5, pupilPaint);
    canvas.drawCircle(
        Offset(cx + offset, cy - offset), r * 0.5, pupilPaint);
  }

  @override
  bool shouldRepaint(covariant SnakePainter oldDelegate) =>
      oldDelegate.body != body || oldDelegate.skin != skin;
}
