import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/player_model.dart';
import '../../data/models/skin_model.dart';
import '../../data/providers/game_provider.dart';
import '../../data/providers/player_provider.dart';
import '../../game/engine/game_engine.dart';
import '../widgets/neon_button.dart';
import 'challenges_screen.dart';
import 'game_screen.dart';
import 'leaderboard_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'shop_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  void _startGame(BuildContext context, GameMode mode) {
    final player = context.read<PlayerProvider>().player;
    final skin = SnakeSkin.getById(player.equippedSkin);
    context.read<GameProvider>().startGame(mode: mode, skin: skin);
    Navigator.of(context).pushNamed(
      GameScreen.routeName,
      arguments: mode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>().player;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Animated background blobs
          _AnimatedBackground(controller: _bgController),
          SafeArea(
            child: Column(
              children: [
                _TopBar(player: player),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        // Title
                        _TitleBanner().animate().fadeIn().slideY(begin: -0.2),
                        const SizedBox(height: 32),
                        // High score
                        _HighScoreCard(player: player)
                            .animate()
                            .fadeIn(delay: 100.ms),
                        const SizedBox(height: 24),
                        // Game mode buttons
                        _GameModeCard(
                          title: 'CLASSIC',
                          subtitle: 'Timeless snake. Beat your best.',
                          icon: '🎮',
                          color: AppColors.neonGreen,
                          onTap: () => _startGame(context, GameMode.classic),
                        ).animate().fadeIn(delay: 150.ms).slideX(begin: -0.2),
                        const SizedBox(height: 12),
                        _GameModeCard(
                          title: 'SURVIVAL',
                          subtitle: 'Speed ramps up. Survive as long as you can.',
                          icon: '🔥',
                          color: AppColors.neonOrange,
                          onTap: () => _startGame(context, GameMode.survival),
                        ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.2),
                        const SizedBox(height: 12),
                        _GameModeCard(
                          title: 'ARENA',
                          subtitle: 'Global competition. Coming soon!',
                          icon: '⚔️',
                          color: AppColors.neonPurple,
                          onTap: () => _startGame(context, GameMode.arena),
                        ).animate().fadeIn(delay: 250.ms).slideX(begin: -0.2),
                        const SizedBox(height: 32),
                        // Quick actions
                        _QuickActions().animate().fadeIn(delay: 300.ms),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _AnimatedBackground extends StatelessWidget {
  final AnimationController controller;
  const _AnimatedBackground({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) => Stack(
        children: [
          Positioned(
            top: -80 + controller.value * 40,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.neonGreen.withOpacity(0.04),
              ),
            ),
          ),
          Positioned(
            bottom: 80 + controller.value * 30,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.neonBlue.withOpacity(0.04),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final PlayerModel player;
  const _TopBar({required this.player});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Avatar
          GestureDetector(
            onTap: () => Navigator.of(context).pushNamed(ProfileScreen.routeName),
            child: CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.15),
              child: Text(
                player.username.isNotEmpty
                    ? player.username[0].toUpperCase()
                    : 'P',
                style: const TextStyle(
                  fontFamily: 'Orbitron',
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              player.username,
              style: const TextStyle(
                fontFamily: 'Rajdhani',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          // Coins
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.vip.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🪙', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  '${player.coins}',
                  style: const TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 12,
                    color: AppColors.vip,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.textMuted),
            onPressed: () =>
                Navigator.of(context).pushNamed(SettingsScreen.routeName),
          ),
        ],
      ),
    );
  }
}

class _TitleBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          '🐍',
          style: TextStyle(fontSize: 48),
        ),
        const SizedBox(height: 8),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.neonGreen, AppColors.neonCyan],
          ).createShader(bounds),
          child: const Text(
            'SNAK',
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 52,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 10,
            ),
          ),
        ),
      ],
    );
  }
}

class _HighScoreCard extends StatelessWidget {
  final PlayerModel player;
  const _HighScoreCard({required this.player});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(
            label: 'BEST',
            value: player.highScore.toString(),
            color: AppColors.neonGreen,
          ),
          Container(width: 1, height: 40, color: AppColors.border),
          _StatItem(
            label: 'SURVIVAL',
            value: player.highScoreSurvival.toString(),
            color: AppColors.neonOrange,
          ),
          Container(width: 1, height: 40, color: AppColors.border),
          _StatItem(
            label: 'GAMES',
            value: player.gamesPlayed.toString(),
            color: AppColors.neonBlue,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 9,
            color: AppColors.textMuted,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

class _GameModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String icon;
  final Color color;
  final VoidCallback onTap;

  const _GameModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.4)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionTile(
            icon: Icons.emoji_events_outlined,
            label: 'Leaderboard',
            color: AppColors.neonYellow,
            onTap: () =>
                Navigator.of(context).pushNamed(LeaderboardScreen.routeName),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionTile(
            icon: Icons.task_alt_outlined,
            label: 'Challenges',
            color: AppColors.neonCyan,
            onTap: () =>
                Navigator.of(context).pushNamed(ChallengesScreen.routeName),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionTile(
            icon: Icons.storefront_outlined,
            label: 'Shop',
            color: AppColors.neonPurple,
            onTap: () =>
                Navigator.of(context).pushNamed(ShopScreen.routeName),
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
