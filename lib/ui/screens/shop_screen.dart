import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/skin_model.dart';
import '../../data/providers/player_provider.dart';
import '../widgets/neon_button.dart';

class ShopScreen extends StatelessWidget {
  static const routeName = '/shop';
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final playerProvider = context.watch<PlayerProvider>();
    final player = playerProvider.player;
    final skins = SnakeSkin.all;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('SHOP'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🪙', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 4),
                Text(
                  '${player.coins}',
                  style: const TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 14,
                    color: AppColors.vip,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // VIP Banner
            if (!player.isVip) _VipBanner(playerProvider: playerProvider),
            if (!player.isVip) const SizedBox(height: 24),

            const Text(
              'SNAKE SKINS',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 12,
                color: AppColors.textMuted,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 16),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: skins.length,
              itemBuilder: (context, index) {
                final skin = skins[index];
                return _SkinCard(
                  skin: skin,
                  isOwned: player.unlockedSkins.contains(skin.id),
                  isEquipped: player.equippedSkin == skin.id,
                  canAfford: player.coins >= skin.price,
                  isVip: player.isVip,
                  onAction: () =>
                      _handleSkinAction(context, skin, playerProvider),
                ).animate().fadeIn(delay: Duration(milliseconds: index * 80));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleSkinAction(
    BuildContext context,
    SnakeSkin skin,
    PlayerProvider provider,
  ) {
    if (skin.isVipOnly && !provider.player.isVip) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This skin requires VIP!')),
      );
      return;
    }

    if (provider.player.equippedSkin == skin.id) return;

    if (provider.player.unlockedSkins.contains(skin.id)) {
      provider.equipSkin(skin.id);
    } else {
      final purchased = provider.purchaseSkin(skin);
      if (!purchased) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Not enough coins!')),
        );
      } else {
        provider.equipSkin(skin.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${skin.name} skin unlocked!')),
        );
      }
    }
  }
}

class _VipBanner extends StatelessWidget {
  final PlayerProvider playerProvider;
  const _VipBanner({required this.playerProvider});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => _VipDialog(playerProvider: playerProvider),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2A1A00), Color(0xFF1A0A20)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.vip.withOpacity(0.6), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.vip.withOpacity(0.15),
              blurRadius: 16,
            ),
          ],
        ),
        child: Row(
          children: [
            const Text('⭐', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GO VIP',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.vip,
                      letterSpacing: 3,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'No ads • Exclusive skins • Bonus coins',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: AppColors.vip, size: 16),
          ],
        ),
      ),
    );
  }
}

class _VipDialog extends StatelessWidget {
  final PlayerProvider playerProvider;
  const _VipDialog({required this.playerProvider});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        '⭐ VIP MEMBERSHIP',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Orbitron',
          color: AppColors.vip,
          fontSize: 16,
          letterSpacing: 2,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '• Remove all ads\n• Exclusive VIP skins\n• 2x coins per game\n• Priority support',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 20),
          NeonButton(
            label: 'SUBSCRIBE \$2.99/mo',
            color: AppColors.vip,
            width: double.infinity,
            onTap: () {
              // TODO: Connect to in-app purchase
              playerProvider.setVip(true);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Welcome to VIP! 🎉')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SkinCard extends StatelessWidget {
  final SnakeSkin skin;
  final bool isOwned;
  final bool isEquipped;
  final bool canAfford;
  final bool isVip;
  final VoidCallback onAction;

  const _SkinCard({
    required this.skin,
    required this.isOwned,
    required this.isEquipped,
    required this.canAfford,
    required this.isVip,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final locked = skin.isVipOnly && !isVip && !isOwned;

    return GestureDetector(
      onTap: locked ? null : onAction,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isEquipped
                ? skin.glowColor
                : locked
                    ? AppColors.border
                    : skin.glowColor.withOpacity(0.3),
            width: isEquipped ? 2 : 1,
          ),
          boxShadow: isEquipped
              ? [
                  BoxShadow(
                    color: skin.glowColor.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 1,
                  )
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Preview snake segment
            _SnakePreview(skin: skin, locked: locked),
            const SizedBox(height: 8),
            // Name
            Text(
              skin.name,
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: locked ? AppColors.textMuted : skin.glowColor,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 2),
            // Rarity
            Text(
              skin.rarityLabel,
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 9,
                color: skin.rarityColor,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            // Action label
            if (isEquipped)
              const Text(
                'EQUIPPED',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 9,
                  color: AppColors.primary,
                  letterSpacing: 2,
                ),
              )
            else if (isOwned)
              const Text(
                'EQUIP',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 9,
                  color: AppColors.textSecondary,
                  letterSpacing: 2,
                ),
              )
            else if (skin.isVipOnly)
              const Text(
                'VIP ONLY',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 9,
                  color: AppColors.vip,
                  letterSpacing: 2,
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 2),
                  Text(
                    '${skin.price}',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 11,
                      color:
                          canAfford ? AppColors.vip : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _SnakePreview extends StatelessWidget {
  final SnakeSkin skin;
  final bool locked;

  const _SnakePreview({required this.skin, required this.locked});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 32,
      child: locked
          ? const Icon(Icons.lock_outline, color: AppColors.textMuted, size: 28)
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                final isHead = i == 0;
                return Container(
                  width: 14,
                  height: isHead ? 16 : 12,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: isHead ? skin.headColor : skin.bodyColor,
                    borderRadius: BorderRadius.circular(isHead ? 4 : 3),
                    boxShadow: [
                      BoxShadow(
                        color: skin.glowColor.withOpacity(0.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                );
              }),
            ),
    );
  }
}
