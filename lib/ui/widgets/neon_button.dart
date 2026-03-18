import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class NeonButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color color;
  final double? width;
  final IconData? icon;
  final bool outlined;

  const NeonButton({
    super.key,
    required this.label,
    this.onTap,
    this.color = AppColors.primary,
    this.width,
    this.icon,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 2),
          boxShadow: onTap != null
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: outlined ? color : AppColors.background, size: 18),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: outlined ? color : AppColors.background,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
