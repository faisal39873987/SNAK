import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'ui/screens/challenges_screen.dart';
import 'ui/screens/game_screen.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/leaderboard_screen.dart';
import 'ui/screens/profile_screen.dart';
import 'ui/screens/settings_screen.dart';
import 'ui/screens/shop_screen.dart';
import 'ui/screens/splash_screen.dart';

class SnakApp extends StatelessWidget {
  const SnakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SNAK',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (_) => const SplashScreen(),
        HomeScreen.routeName: (_) => const HomeScreen(),
        GameScreen.routeName: (_) => const GameScreen(),
        LeaderboardScreen.routeName: (_) => const LeaderboardScreen(),
        ProfileScreen.routeName: (_) => const ProfileScreen(),
        ShopScreen.routeName: (_) => const ShopScreen(),
        ChallengesScreen.routeName: (_) => const ChallengesScreen(),
        SettingsScreen.routeName: (_) => const SettingsScreen(),
      },
    );
  }
}
