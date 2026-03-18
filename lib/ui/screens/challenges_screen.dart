import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/challenge_model.dart';
import '../../data/providers/player_provider.dart';
import '../../core/services/supabase_service.dart';

class ChallengesScreen extends StatefulWidget {
  static const routeName = '/challenges';
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  List<ChallengeModel> _challenges = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadChallenges();
  }

  Future<void> _loadChallenges() async {
    try {
      final remote = await SupabaseService.instance.getDailyChallenges();
      if (remote.isNotEmpty) {
        setState(() {
          _challenges = remote.map(ChallengeModel.fromJson).toList();
          _loading = false;
        });
        return;
      }
    } catch (_) {}

    // Fallback to local default challenges
    setState(() {
      _challenges = ChallengeModel.defaultChallenges;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('CHALLENGES'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _challenges.length,
              itemBuilder: (context, index) {
                return _ChallengeCard(
                  challenge: _challenges[index],
                  onClaim: (challenge) => _claimReward(context, challenge),
                ).animate().fadeIn(delay: Duration(milliseconds: index * 100));
              },
            ),
    );
  }

  void _claimReward(BuildContext context, ChallengeModel challenge) {
    if (!challenge.isCompleted) return;
    context.read<PlayerProvider>().addCoins(challenge.rewardCoins);
    setState(() {
      final index = _challenges.indexWhere((c) => c.id == challenge.id);
      if (index != -1) {
        _challenges[index] = challenge.copyWith(isCompleted: true);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Claimed ${challenge.rewardCoins} coins for "${challenge.title}"!'),
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  final ChallengeModel challenge;
  final void Function(ChallengeModel) onClaim;

  const _ChallengeCard({required this.challenge, required this.onClaim});

  @override
  Widget build(BuildContext context) {
    final progress = challenge.progress;
    final isDone = challenge.isCompleted || progress >= 1.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDone
              ? AppColors.primary.withOpacity(0.5)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _challengeIcon(challenge.type),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge.title,
                      style: const TextStyle(
                        fontFamily: 'Rajdhani',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      challenge.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              // Reward
              Column(
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 18)),
                  Text(
                    '+${challenge.rewardCoins}',
                    style: const TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 11,
                      color: AppColors.vip,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDone ? AppColors.primary : AppColors.neonBlue,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${challenge.currentValue} / ${challenge.targetValue}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
              if (isDone && !challenge.isCompleted)
                GestureDetector(
                  onTap: () => onClaim(challenge),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'CLAIM',
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.background,
                      ),
                    ),
                  ),
                )
              else if (challenge.isCompleted)
                const Text(
                  '✓ DONE',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 10,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _challengeIcon(ChallengeType type) {
    switch (type) {
      case ChallengeType.scoreGoal:
        return const Text('🏆', style: TextStyle(fontSize: 28));
      case ChallengeType.foodCount:
        return const Text('🍎', style: TextStyle(fontSize: 28));
      case ChallengeType.surviveTime:
        return const Text('⏱️', style: TextStyle(fontSize: 28));
      case ChallengeType.usesPowerup:
        return const Text('⚡', style: TextStyle(fontSize: 28));
    }
  }
}
