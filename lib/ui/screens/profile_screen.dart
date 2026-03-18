import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../data/providers/player_provider.dart';
import '../widgets/neon_button.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _usernameController;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    final player = context.read<PlayerProvider>().player;
    _usernameController = TextEditingController(text: player.username);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _saveUsername() async {
    await context
        .read<PlayerProvider>()
        .updateUsername(_usernameController.text);
    setState(() => _editing = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username updated!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>().player;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('PROFILE'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.primary.withOpacity(0.15),
              child: Text(
                player.username.isNotEmpty
                    ? player.username[0].toUpperCase()
                    : 'P',
                style: const TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // VIP badge
            if (player.isVip)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.vip, AppColors.vipGlow],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '⭐ VIP MEMBER',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.background,
                    letterSpacing: 2,
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Username field
            _SectionCard(
              title: 'USERNAME',
              child: _editing
                  ? Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _usernameController,
                            autofocus: true,
                            maxLength: 20,
                            decoration: const InputDecoration(
                              hintText: 'Enter username',
                              counterText: '',
                            ),
                            style: const TextStyle(
                              fontFamily: 'Rajdhani',
                              fontSize: 18,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        NeonButton(
                          label: 'SAVE',
                          onTap: _saveUsername,
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Text(
                          player.username,
                          style: const TextStyle(
                            fontFamily: 'Rajdhani',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined,
                              color: AppColors.primary),
                          onPressed: () => setState(() => _editing = true),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 16),

            // Stats
            _SectionCard(
              title: 'STATS',
              child: Column(
                children: [
                  _StatRow(
                    label: 'Best Score (Classic)',
                    value: player.highScore.toString(),
                    color: AppColors.neonGreen,
                  ),
                  _StatRow(
                    label: 'Best Score (Survival)',
                    value: player.highScoreSurvival.toString(),
                    color: AppColors.neonOrange,
                  ),
                  _StatRow(
                    label: 'Games Played',
                    value: player.gamesPlayed.toString(),
                    color: AppColors.neonBlue,
                  ),
                  _StatRow(
                    label: 'Total Score',
                    value: player.totalScore.toString(),
                    color: AppColors.neonPurple,
                  ),
                  _StatRow(
                    label: 'Coins',
                    value: '${player.coins} 🪙',
                    color: AppColors.vip,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Skins
            _SectionCard(
              title: 'UNLOCKED SKINS',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: player.unlockedSkins.map((skinId) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: skinId == player.equippedSkin
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    child: Text(
                      skinId.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 10,
                        color: skinId == player.equippedSkin
                            ? AppColors.primary
                            : AppColors.textMuted,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 10,
              color: AppColors.textMuted,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
