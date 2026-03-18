import 'package:shared_preferences/shared_preferences.dart';

class CoinService {
  static const String _coinsKey = 'user_coins';
  static const String _highScoreKey = 'high_score';
  
  static final CoinService _instance = CoinService._internal();
  factory CoinService() => _instance;
  CoinService._internal();
  
  SharedPreferences? _prefs;
  int _coins = 0;
  int _highScore = 0;
  int _sessionCoins = 0; // Coins earned in current game
  
  int get coins => _coins;
  int get highScore => _highScore;
  int get sessionCoins => _sessionCoins;
  
  // Prices
  static const int continuePrice = 50;
  static const int speedBoostPrice = 30;
  static const int shieldPrice = 40;
  static const int magnetPrice = 35;
  static const int adReward = 100;
  
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _coins = _prefs?.getInt(_coinsKey) ?? 0;
    _highScore = _prefs?.getInt(_highScoreKey) ?? 0;
  }
  
  Future<void> _saveCoins() async {
    await _prefs?.setInt(_coinsKey, _coins);
  }
  
  Future<void> _saveHighScore() async {
    await _prefs?.setInt(_highScoreKey, _highScore);
  }
  
  /// Start a new game session
  void startSession() {
    _sessionCoins = 0;
  }
  
  /// Add coins for eating food
  void onFoodEaten() {
    _sessionCoins += 1;
  }
  
  /// Calculate and add bonus coins based on score
  int calculateBonusCoins(int score) {
    // Bonus tiers
    if (score >= 500) return 50;
    if (score >= 300) return 30;
    if (score >= 200) return 20;
    if (score >= 100) return 10;
    if (score >= 50) return 5;
    return 0;
  }
  
  /// End game session and save coins
  Future<int> endSession(int score) async {
    final bonusCoins = calculateBonusCoins(score);
    final totalEarned = _sessionCoins + bonusCoins;
    _coins += totalEarned;
    
    if (score > _highScore) {
      _highScore = score;
      await _saveHighScore();
    }
    
    await _saveCoins();
    return totalEarned;
  }
  
  /// Check if player can afford to continue
  bool canContinue() => _coins >= continuePrice;
  
  /// Spend coins to continue after death
  Future<bool> spendToContinue() async {
    if (!canContinue()) return false;
    _coins -= continuePrice;
    await _saveCoins();
    return true;
  }
  
  /// Check if can afford power-up
  bool canAffordPowerUp(String type) {
    final price = _getPowerUpPrice(type);
    return _coins >= price;
  }
  
  /// Buy a power-up
  Future<bool> buyPowerUp(String type) async {
    final price = _getPowerUpPrice(type);
    if (_coins < price) return false;
    _coins -= price;
    await _saveCoins();
    return true;
  }
  
  int _getPowerUpPrice(String type) {
    switch (type) {
      case 'speedBoost': return speedBoostPrice;
      case 'shield': return shieldPrice;
      case 'magnet': return magnetPrice;
      default: return 0;
    }
  }
  
  /// Simulate watching an ad to get coins
  Future<void> watchAd() async {
    _coins += adReward;
    await _saveCoins();
  }
  
  /// Add coins (for testing/debugging)
  Future<void> addCoins(int amount) async {
    _coins += amount;
    await _saveCoins();
  }
}
