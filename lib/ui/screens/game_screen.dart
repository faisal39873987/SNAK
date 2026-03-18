import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/player_model.dart';
import '../../data/models/skin_model.dart';
import '../../data/providers/game_provider.dart';
import '../../data/providers/player_provider.dart';
import '../../game/engine/game_engine.dart';
import '../widgets/game_board.dart';
import '../widgets/neon_button.dart';
import '../widgets/powerup_indicator.dart';
import '../widgets/score_display.dart';
import '../widgets/swipe_detector.dart';

class GameScreen extends StatefulWidget {
  static const routeName = '/game';
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();
    // Start the engine on next frame so it's mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final engine = context.read<GameProvider>().engine;
      if (engine?.status == GameStatus.idle) {
        engine?.start();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final engine = gameProvider.engine;

    if (engine == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final playerProvider = context.read<PlayerProvider>();
    final player = playerProvider.player;
    final skin = SnakeSkin.getById(player.equippedSkin);
    final highScore = engine.mode == GameMode.survival
        ? player.highScoreSurvival
        : player.highScore;
    final isNewHigh = engine.score > highScore;
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // HUD
                _GameHud(
                  engine: engine,
                  highScore: highScore,
                  isNewHigh: isNewHigh,
                  nowMs: nowMs,
                  onPause: () {
                    if (engine.status == GameStatus.running) {
                      engine.pause();
                    } else if (engine.status == GameStatus.paused) {
                      engine.resume();
                    }
                  },
                ),
                // Game board
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: SwipeDetector(
                      onSwipe: engine.changeDirection,
                      child: GameBoard(engine: engine, skin: skin),
                    ),
                  ),
                ),
                // Level indicator
                _LevelBar(engine: engine),
                const SizedBox(height: 8),
              ],
            ),
            // Pause overlay
            if (engine.status == GameStatus.paused)
              _PauseOverlay(engine: engine),
            // Game over overlay
            if (engine.status == GameStatus.gameOver)
              _GameOverOverlay(
                engine: engine,
                player: player,
                gameProvider: gameProvider,
                playerProvider: playerProvider,
              ),
          ],
        ),
      ),
    );
  }
}

// ── HUD ───────────────────────────────────────────────────────────────────────

class _GameHud extends StatelessWidget {
  final GameEngine engine;
  final int highScore;
  final bool isNewHigh;
  final int nowMs;
  final VoidCallback onPause;

  const _GameHud({
    required this.engine,
    required this.highScore,
    required this.isNewHigh,
    required this.nowMs,
    required this.onPause,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Back
          GestureDetector(
            onTap: () {
              engine.pause();
              Navigator.of(context).pop();
            },
            child: const Icon(
              Icons.arrow_back_ios,
              color: AppColors.textMuted,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          // Score
          Expanded(
            child: ScoreDisplay(
              score: engine.score,
              isNew: isNewHigh,
            ),
          ),
          // Power-up indicators
          PowerupIndicator(
            activePowerups: engine.activePowerups,
            nowMs: nowMs,
          ),
          const SizedBox(width: 8),
          // Pause button
          GestureDetector(
            onTap: onPause,
            child: Icon(
              engine.status == GameStatus.paused
                  ? Icons.play_arrow
                  : Icons.pause,
              color: AppColors.textSecondary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelBar extends StatelessWidget {
  final GameEngine engine;
  const _LevelBar({required this.engine});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            'LVL ${engine.level}',
            style: const TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 10,
              color: AppColors.textMuted,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(width: 8),
          if (engine.mode == GameMode.survival)
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: (engine.elapsedSeconds % 10) / 10,
                  minHeight: 3,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.neonOrange,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Pause overlay ─────────────────────────────────────────────────────────────

class _PauseOverlay extends StatelessWidget {
  final GameEngine engine;
  const _PauseOverlay({required this.engine});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'PAUSED',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                letterSpacing: 6,
              ),
            ),
            const SizedBox(height: 32),
            NeonButton(
              label: 'RESUME',
              icon: Icons.play_arrow,
              onTap: engine.resume,
              width: 200,
            ),
            const SizedBox(height: 16),
            NeonButton(
              label: 'QUIT',
              icon: Icons.exit_to_app,
              onTap: () => Navigator.of(context).pop(),
              color: AppColors.neonRed,
              outlined: true,
              width: 200,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }
}

// ── Game Over overlay ─────────────────────────────────────────────────────────

class _GameOverOverlay extends StatefulWidget {
  final GameEngine engine;
  final PlayerModel player;
  final GameProvider gameProvider;
  final PlayerProvider playerProvider;

  const _GameOverOverlay({
    required this.engine,
    required this.player,
    required this.gameProvider,
    required this.playerProvider,
  });

  @override
  State<_GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<_GameOverOverlay> {
  bool _resultSaved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_resultSaved) {
        _resultSaved = true;
        widget.playerProvider.reportGameResult(
          score: widget.engine.score,
          gameMode: widget.engine.mode.name,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final engine = widget.engine;
    final player = widget.player;
    final isNewHigh = engine.mode == GameMode.survival
        ? engine.score > player.highScoreSurvival
        : engine.score > player.highScore;

    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('💀', style: TextStyle(fontSize: 56)),
                const SizedBox(height: 16),
                const Text(
                  'GAME OVER',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neonRed,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 24),
                ScoreDisplay(
                  score: engine.score,
                  highScore: engine.mode == GameMode.survival
                      ? player.highScoreSurvival
                      : player.highScore,
                  isNew: isNewHigh,
                ),
                const SizedBox(height: 8),
                Text(
                  'Food eaten: ${engine.foodEaten}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),
                // Revive with ad
                if (!widget.gameProvider.reviveUsed)
                  Column(
                    children: [
                      NeonButton(
                        label: 'REVIVE (WATCH AD)',
                        icon: Icons.play_circle_outline,
                        color: AppColors.neonYellow,
                        width: double.infinity,
                        onTap: () async {
                          final success =
                              await widget.gameProvider.tryReviveWithAd();
                          if (!success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('No ad available right now.')),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                NeonButton(
                  label: 'PLAY AGAIN',
                  icon: Icons.refresh,
                  width: double.infinity,
                  onTap: engine.restart,
                ),
                const SizedBox(height: 12),
                NeonButton(
                  label: 'HOME',
                  icon: Icons.home_outlined,
                  color: AppColors.neonBlue,
                  outlined: true,
                  width: double.infinity,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1);
  }
}
