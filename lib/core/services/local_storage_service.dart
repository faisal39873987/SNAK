import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  LocalStorageService._();
  static final LocalStorageService instance = LocalStorageService._();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── Keys ─────────────────────────────────────────────────────────────────

  static const String _keyUserId = 'user_id';
  static const String _keyUsername = 'username';
  static const String _keyHighScore = 'high_score';
  static const String _keyHighScoreSurvival = 'high_score_survival';
  static const String _keyCoins = 'coins';
  static const String _keyEquippedSkin = 'equipped_skin';
  static const String _keyUnlockedSkins = 'unlocked_skins';
  static const String _keySoundEnabled = 'sound_enabled';
  static const String _keyVibrationEnabled = 'vibration_enabled';
  static const String _keyIsVip = 'is_vip';
  static const String _keyGamesPlayed = 'games_played';
  static const String _keyTotalScore = 'total_score';

  // ── User ─────────────────────────────────────────────────────────────────

  String? get userId => _prefs.getString(_keyUserId);
  set userId(String? v) =>
      v != null ? _prefs.setString(_keyUserId, v) : _prefs.remove(_keyUserId);

  String get username => _prefs.getString(_keyUsername) ?? 'Player';
  set username(String v) => _prefs.setString(_keyUsername, v);

  // ── Scores ────────────────────────────────────────────────────────────────

  int get highScore => _prefs.getInt(_keyHighScore) ?? 0;
  set highScore(int v) => _prefs.setInt(_keyHighScore, v);

  int get highScoreSurvival => _prefs.getInt(_keyHighScoreSurvival) ?? 0;
  set highScoreSurvival(int v) => _prefs.setInt(_keyHighScoreSurvival, v);

  int get gamesPlayed => _prefs.getInt(_keyGamesPlayed) ?? 0;
  set gamesPlayed(int v) => _prefs.setInt(_keyGamesPlayed, v);

  int get totalScore => _prefs.getInt(_keyTotalScore) ?? 0;
  set totalScore(int v) => _prefs.setInt(_keyTotalScore, v);

  // ── Economy ───────────────────────────────────────────────────────────────

  int get coins => _prefs.getInt(_keyCoins) ?? 0;
  set coins(int v) => _prefs.setInt(_keyCoins, v);

  void addCoins(int amount) => coins = coins + amount;
  bool spendCoins(int amount) {
    if (coins < amount) return false;
    coins = coins - amount;
    return true;
  }

  // ── Skins ─────────────────────────────────────────────────────────────────

  String get equippedSkin => _prefs.getString(_keyEquippedSkin) ?? 'default';
  set equippedSkin(String v) => _prefs.setString(_keyEquippedSkin, v);

  List<String> get unlockedSkins {
    final raw = _prefs.getStringList(_keyUnlockedSkins);
    return raw ?? ['default'];
  }

  set unlockedSkins(List<String> v) =>
      _prefs.setStringList(_keyUnlockedSkins, v);

  void unlockSkin(String skinId) {
    final skins = unlockedSkins;
    if (!skins.contains(skinId)) {
      skins.add(skinId);
      unlockedSkins = skins;
    }
  }

  bool isSkinUnlocked(String skinId) => unlockedSkins.contains(skinId);

  // ── Settings ──────────────────────────────────────────────────────────────

  bool get soundEnabled => _prefs.getBool(_keySoundEnabled) ?? true;
  set soundEnabled(bool v) => _prefs.setBool(_keySoundEnabled, v);

  bool get vibrationEnabled => _prefs.getBool(_keyVibrationEnabled) ?? true;
  set vibrationEnabled(bool v) => _prefs.setBool(_keyVibrationEnabled, v);

  bool get isVip => _prefs.getBool(_keyIsVip) ?? false;
  set isVip(bool v) => _prefs.setBool(_keyIsVip, v);

  // ── Generic helpers ────────────────────────────────────────────────────────

  List<String>? getStringList(String key) => _prefs.getStringList(key);

  Future<bool> setStringList(String key, List<String> value) =>
      _prefs.setStringList(key, value);
}
