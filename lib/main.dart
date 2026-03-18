import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/services/local_storage_service.dart';
import 'core/services/supabase_service.dart';
import 'data/providers/game_provider.dart';
import 'data/providers/leaderboard_provider.dart';
import 'data/providers/player_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Immersive full-screen mode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Initialize local storage
  await LocalStorageService.instance.init();

  // Initialize Supabase.
  // For local development, pass credentials via --dart-define:
  //   flutter run --dart-define=SUPABASE_URL=https://... --dart-define=SUPABASE_ANON_KEY=...
  // The app works offline when credentials are not configured.
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
    await SupabaseService.instance.init(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
  // If credentials are missing, the app continues in fully offline mode.

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => LeaderboardProvider()),
      ],
      child: const SnakApp(),
    ),
  );
}
