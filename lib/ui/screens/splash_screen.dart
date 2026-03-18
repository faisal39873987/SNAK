import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../data/providers/player_provider.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Navigate after player data is loaded
    _navigateWhenReady();
  }

  Future<void> _navigateWhenReady() async {
    // Wait for player provider to finish loading
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    final playerProvider = context.read<PlayerProvider>();
    while (playerProvider.loading) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
    }

    // Min splash time for aesthetics
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Snake emoji icon
            const Text('🐍', style: TextStyle(fontSize: 80))
                .animate()
                .scale(
                  begin: const Offset(0, 0),
                  end: const Offset(1, 1),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                ),
            const SizedBox(height: 24),
            // Title
            AnimatedBuilder(
              animation: _glowController,
              builder: (_, __) {
                return Text(
                  'SNAK',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    letterSpacing: 12,
                    shadows: [
                      Shadow(
                        color: AppColors.primary
                            .withOpacity(0.4 + _glowController.value * 0.6),
                        blurRadius: 20 + _glowController.value * 20,
                      ),
                    ],
                  ),
                );
              },
            ).animate().fadeIn(duration: const Duration(milliseconds: 800)),
            const SizedBox(height: 8),
            const Text(
              'SLITHER TO GLORY',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 13,
                letterSpacing: 6,
                color: AppColors.textMuted,
              ),
            ).animate().fadeIn(
                  delay: const Duration(milliseconds: 400),
                  duration: const Duration(milliseconds: 600),
                ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ).animate().fadeIn(delay: const Duration(milliseconds: 800)),
          ],
        ),
      ),
    );
  }
}
