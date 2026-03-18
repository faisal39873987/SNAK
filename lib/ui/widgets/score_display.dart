import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class ScoreDisplay extends StatelessWidget {
  final int score;
  final int? highScore;
  final bool isNew;

  const ScoreDisplay({
    super.key,
    required this.score,
    this.highScore,
    this.isNew = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isNew)
          const Text(
            'NEW BEST!',
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 11,
              color: AppColors.neonYellow,
              letterSpacing: 3,
            ),
          ),
        Text(
          score.toString().padLeft(6, '0'),
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: isNew ? AppColors.neonYellow : AppColors.primary,
            letterSpacing: 4,
            shadows: [
              Shadow(
                color: (isNew ? AppColors.neonYellow : AppColors.primary)
                    .withOpacity(0.8),
                blurRadius: 12,
              ),
            ],
          ),
        ),
        if (highScore != null)
          Text(
            'BEST: ${highScore.toString().padLeft(6, '0')}',
            style: const TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 11,
              color: AppColors.textMuted,
              letterSpacing: 2,
            ),
          ),
      ],
    );
  }
}
