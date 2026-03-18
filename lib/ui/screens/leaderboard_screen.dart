import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../data/providers/leaderboard_provider.dart';
import '../../data/models/score_model.dart';

class LeaderboardScreen extends StatefulWidget {
  static const routeName = '/leaderboard';
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LeaderboardProvider>().fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LeaderboardProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('LEADERBOARD'),
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Tab bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                _TabChip(
                  label: 'GLOBAL',
                  selected:
                      provider.selectedTab == LeaderboardTab.global,
                  onTap: () =>
                      provider.selectTab(LeaderboardTab.global),
                ),
                const SizedBox(width: 12),
                _TabChip(
                  label: 'WEEKLY',
                  selected:
                      provider.selectedTab == LeaderboardTab.weekly,
                  onTap: () =>
                      provider.selectTab(LeaderboardTab.weekly),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: provider.loading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  )
                : provider.error != null
                    ? _ErrorView(message: provider.error!)
                    : provider.currentScores.isEmpty
                        ? const _EmptyView()
                        : _ScoreList(scores: provider.currentScores),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: selected ? AppColors.background : AppColors.textMuted,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

class _ScoreList extends StatelessWidget {
  final List<ScoreModel> scores;
  const _ScoreList({required this.scores});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: scores.length,
      itemBuilder: (context, index) {
        final score = scores[index];
        return _ScoreRow(score: score, index: index)
            .animate()
            .fadeIn(delay: Duration(milliseconds: index * 40));
      },
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final ScoreModel score;
  final int index;

  const _ScoreRow({required this.score, required this.index});

  @override
  Widget build(BuildContext context) {
    final rank = score.rank ?? (index + 1);
    Color rankColor;
    String rankEmoji;
    if (rank == 1) {
      rankColor = AppColors.vip;
      rankEmoji = '🥇';
    } else if (rank == 2) {
      rankColor = AppColors.textSecondary;
      rankEmoji = '🥈';
    } else if (rank == 3) {
      rankColor = AppColors.neonOrange;
      rankEmoji = '🥉';
    } else {
      rankColor = AppColors.textMuted;
      rankEmoji = '$rank';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: rank <= 3 ? AppColors.cardBg : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: rank <= 3 ? rankColor.withOpacity(0.4) : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              rankEmoji,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: rank > 3 ? 12 : 18,
                color: rankColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  score.username,
                  style: const TextStyle(
                    fontFamily: 'Rajdhani',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  score.gameMode.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          Text(
            score.score.toString().padLeft(6, '0'),
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: rankColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off, color: AppColors.textMuted, size: 48),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No scores yet.\nBe the first to play!',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.textMuted,
          fontSize: 16,
        ),
      ),
    );
  }
}
