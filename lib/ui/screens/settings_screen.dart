import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/local_storage_service.dart';
import '../../data/providers/player_provider.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings';
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _sound;
  late bool _vibration;

  @override
  void initState() {
    super.initState();
    final storage = LocalStorageService.instance;
    _sound = storage.soundEnabled;
    _vibration = storage.vibrationEnabled;
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>().player;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('SETTINGS'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SettingsSection(
            title: 'AUDIO & HAPTICS',
            children: [
              _ToggleTile(
                title: 'Sound Effects',
                subtitle: 'Game sounds and music',
                icon: Icons.volume_up_outlined,
                value: _sound,
                onChanged: (v) {
                  setState(() => _sound = v);
                  LocalStorageService.instance.soundEnabled = v;
                },
              ),
              _ToggleTile(
                title: 'Vibration',
                subtitle: 'Haptic feedback on events',
                icon: Icons.vibration,
                value: _vibration,
                onChanged: (v) {
                  setState(() => _vibration = v);
                  LocalStorageService.instance.vibrationEnabled = v;
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            title: 'ACCOUNT',
            children: [
              _InfoTile(
                title: 'Player ID',
                subtitle: player.id.substring(0, 12) + '...',
                icon: Icons.fingerprint,
              ),
              _InfoTile(
                title: 'Username',
                subtitle: player.username,
                icon: Icons.person_outline,
              ),
              _InfoTile(
                title: 'VIP Status',
                subtitle: player.isVip ? 'Active ⭐' : 'Not subscribed',
                icon: Icons.star_outline,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            title: 'ABOUT',
            children: [
              _InfoTile(
                title: 'Version',
                subtitle: '1.0.0',
                icon: Icons.info_outline,
              ),
              _ActionTile(
                title: 'Privacy Policy',
                icon: Icons.privacy_tip_outlined,
                onTap: () {},
              ),
              _ActionTile(
                title: 'Terms of Service',
                icon: Icons.article_outlined,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 10,
              color: AppColors.textMuted,
              letterSpacing: 3,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(
        title,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
        inactiveTrackColor: AppColors.border,
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _InfoTile({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textMuted, size: 22),
      title: Text(
        title,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
      ),
      trailing: Text(
        subtitle,
        style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textMuted, size: 22),
      title: Text(
        title,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
      ),
      trailing: const Icon(Icons.arrow_forward_ios,
          color: AppColors.textMuted, size: 14),
      onTap: onTap,
    );
  }
}
