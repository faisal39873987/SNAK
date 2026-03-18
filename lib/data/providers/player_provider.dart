import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../core/services/local_storage_service.dart';
import '../../core/services/supabase_service.dart';
import '../models/player_model.dart';
import '../models/skin_model.dart';

class PlayerProvider extends ChangeNotifier {
  late PlayerModel _player;
  bool _loading = true;

  PlayerModel get player => _player;
  bool get loading => _loading;

  PlayerProvider() {
    _loadPlayer();
  }

  Future<void> _loadPlayer() async {
    final storage = LocalStorageService.instance;

    // Generate a persistent local user ID if needed
    var userId = storage.userId;
    if (userId == null) {
      userId = const Uuid().v4();
      storage.userId = userId;
    }

    _player = PlayerModel(
      id: userId,
      username: storage.username,
      highScore: storage.highScore,
      highScoreSurvival: storage.highScoreSurvival,
      coins: storage.coins,
      gamesPlayed: storage.gamesPlayed,
      totalScore: storage.totalScore,
      equippedSkin: storage.equippedSkin,
      unlockedSkins: storage.unlockedSkins,
      isVip: storage.isVip,
    );

    // Try to sync with remote profile
    try {
      final remote =
          await SupabaseService.instance.getPlayerProfile(userId);
      if (remote != null) {
        _player = PlayerModel.fromJson(remote);
      }
    } catch (_) {}

    _loading = false;
    notifyListeners();
  }

  Future<void> updateUsername(String username) async {
    final trimmed = username.trim();
    if (trimmed.isEmpty) return;
    LocalStorageService.instance.username = trimmed;
    _player = _player.copyWith(username: trimmed);
    notifyListeners();
    await _syncRemote();
  }

  void reportGameResult({
    required int score,
    required String gameMode,
  }) {
    final storage = LocalStorageService.instance;
    storage.gamesPlayed = storage.gamesPlayed + 1;
    storage.totalScore = storage.totalScore + score;

    if (gameMode == 'survival') {
      if (score > storage.highScoreSurvival) {
        storage.highScoreSurvival = score;
      }
    } else {
      if (score > storage.highScore) {
        storage.highScore = score;
      }
    }

    _player = _player.copyWith(
      highScore: storage.highScore,
      highScoreSurvival: storage.highScoreSurvival,
      gamesPlayed: storage.gamesPlayed,
      totalScore: storage.totalScore,
    );
    notifyListeners();
    _syncRemote();
  }

  void addCoins(int amount) {
    LocalStorageService.instance.addCoins(amount);
    _player = _player.copyWith(coins: LocalStorageService.instance.coins);
    notifyListeners();
  }

  bool purchaseSkin(SnakeSkin skin) {
    if (_player.unlockedSkins.contains(skin.id)) return true;
    if (!LocalStorageService.instance.spendCoins(skin.price)) return false;
    LocalStorageService.instance.unlockSkin(skin.id);
    _player = _player.copyWith(
      coins: LocalStorageService.instance.coins,
      unlockedSkins: LocalStorageService.instance.unlockedSkins,
    );
    notifyListeners();
    _syncRemote();
    return true;
  }

  void equipSkin(String skinId) {
    if (!_player.unlockedSkins.contains(skinId)) return;
    LocalStorageService.instance.equippedSkin = skinId;
    _player = _player.copyWith(equippedSkin: skinId);
    notifyListeners();
  }

  void setVip(bool value) {
    LocalStorageService.instance.isVip = value;
    _player = _player.copyWith(isVip: value);
    notifyListeners();
    _syncRemote();
  }

  Future<void> _syncRemote() async {
    try {
      await SupabaseService.instance.upsertPlayerProfile(_player.toJson());
    } catch (_) {}
  }
}
