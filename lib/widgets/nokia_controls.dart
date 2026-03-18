import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NokiaControls extends StatelessWidget {
  final VoidCallback onUp;
  final VoidCallback onDown;
  final VoidCallback onLeft;
  final VoidCallback onRight;

  const NokiaControls({
    Key? key,
    required this.onUp,
    required this.onDown,
    required this.onLeft,
    required this.onRight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: 210,
            height: 210,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [const Color(0xFF2a3a5a), const Color(0xFF1a2a3a)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.6),
                  blurRadius: 18,
                  offset: const Offset(0, 7),
                ),
                BoxShadow(
                  color: const Color(0xFF4a9eff).withOpacity(0.3),
                  blurRadius: 25,
                  spreadRadius: -4,
                ),
              ],
            ),
          ),
          // Center circle
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1a2a3a),
              border: Border.all(
                color: const Color(0xFF4a9eff).withOpacity(0.4),
                width: 2,
              ),
            ),
          ),
          // UP button
          Positioned(
            top: 10,
            child: _buildDirectionButton(
              onTap: () {
                HapticFeedback.heavyImpact();
                onUp();
              },
              icon: Icons.keyboard_arrow_up_rounded,
            ),
          ),
          // DOWN button
          Positioned(
            bottom: 10,
            child: _buildDirectionButton(
              onTap: () {
                HapticFeedback.heavyImpact();
                onDown();
              },
              icon: Icons.keyboard_arrow_down_rounded,
            ),
          ),
          // LEFT button
          Positioned(
            left: 10,
            child: _buildDirectionButton(
              onTap: () {
                HapticFeedback.heavyImpact();
                onLeft();
              },
              icon: Icons.keyboard_arrow_left_rounded,
            ),
          ),
          // RIGHT button
          Positioned(
            right: 10,
            child: _buildDirectionButton(
              onTap: () {
                HapticFeedback.heavyImpact();
                onRight();
              },
              icon: Icons.keyboard_arrow_right_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectionButton({
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [const Color(0xFF4a9eff), const Color(0xFF2a6ecc)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4a9eff).withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(child: Icon(icon, color: Colors.white, size: 38)),
      ),
    );
  }
}
