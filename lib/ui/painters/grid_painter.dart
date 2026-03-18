import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

class GridPainter extends CustomPainter {
  const GridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / AppSizes.gridColumns;
    final cellH = size.height / AppSizes.gridRows;

    final paint = Paint()
      ..color = AppColors.gridLine
      ..strokeWidth = 0.5;

    for (int x = 0; x <= AppSizes.gridColumns; x++) {
      canvas.drawLine(
        Offset(x * cellW, 0),
        Offset(x * cellW, size.height),
        paint,
      );
    }
    for (int y = 0; y <= AppSizes.gridRows; y++) {
      canvas.drawLine(
        Offset(0, y * cellH),
        Offset(size.width, y * cellH),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
