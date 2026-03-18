import 'package:flutter/foundation.dart';

import '../../core/services/ad_service.dart';
import '../../core/services/local_storage_service.dart';
import '../../core/services/supabase_service.dart';
import '../models/skin_model.dart';
import '../../game/engine/game_engine.dart';

class GameProvider extends ChangeNotifier {
  GameEngine? _engine;
  bool _reviveUsed = false;

  GameEngine? get engine => _engine;
  bool get reviveUsed => _reviveUsed;

  bool get hasActiveGame => _engine != null;

  void startGame({required GameMode mode, required SnakeSkin skin}) {
    _engine?.dispose();
    _engine = GameEngine(mode: mode, skin: skin);
    _reviveUsed = false;
    _engine!.addListener(_onEngineChanged);
    notifyListeners();
  }

  void _onEngineChanged() {
    notifyListeners();
  }

  Future<bool> tryReviveWithAd() async {
    if (_reviveUsed) return false;
    final success = await AdService.instance.showRewardedAd(
      onRewarded: () {
        _engine?.revive();
        _reviveUsed = true;
      },
    );
    return success;
  }

  /// Called when a game session ends: save scores.
  Future<void> finalizeGame({
    required String userId,
    required String username,
  }) async {
    final engine = _engine;
    if (engine == null) return;

    final storage = LocalStorageService.instance;
    final modeName = engine.mode.name;

    // Save score remotely
    await SupabaseService.instance.submitScore(
      userId: userId,
      username: username,
      score: engine.score,
      gameMode: modeName,
    );

    // Update local stats
    storage.gamesPlayed = storage.gamesPlayed + 1;
    storage.totalScore = storage.totalScore + engine.score;
    if (modeName == 'survival') {
      if (engine.score > storage.highScoreSurvival) {
        storage.highScoreSurvival = engine.score;
      }
    } else {
      if (engine.score > storage.highScore) {
        storage.highScore = engine.score;
      }
    }

    // Coins reward
    final coinsEarned = (engine.score ~/ 10).clamp(1, 500);
    storage.addCoins(coinsEarned);

    notifyListeners();
  }

  void disposeEngine() {
    _engine?.removeListener(_onEngineChanged);
    _engine?.dispose();
    _engine = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _engine?.removeListener(_onEngineChanged);
    _engine?.dispose();
    super.dispose();
  }
}
