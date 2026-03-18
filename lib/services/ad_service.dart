import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // Test Ad Unit IDs (replace with real IDs for production)
  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917'; // Test ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313'; // Test ID
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712'; // Test ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910'; // Test ID
    }
    throw UnsupportedError('Unsupported platform');
  }

  RewardedAd? _rewardedAd;
  InterstitialAd? _interstitialAd;
  
  bool _isRewardedAdLoading = false;
  bool _isInterstitialAdLoading = false;
  
  int _gameOverCount = 0;
  static const int _interstitialFrequency = 3; // Show ad every 3 game overs

  bool get isRewardedAdReady => _rewardedAd != null;
  bool get isRewardedAdLoading => _isRewardedAdLoading;
  bool get isInterstitialAdReady => _interstitialAd != null;

  /// Initialize the Mobile Ads SDK
  Future<void> init() async {
    await MobileAds.instance.initialize();
    
    // Start loading ads
    loadRewardedAd();
    loadInterstitialAd();
  }

  /// Load a rewarded ad
  void loadRewardedAd() {
    if (_rewardedAd != null || _isRewardedAdLoading) return;
    
    _isRewardedAdLoading = true;
    
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdLoading = false;
          
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _rewardedAd = null;
              loadRewardedAd(); // Preload next ad
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _rewardedAd = null;
              loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isRewardedAdLoading = false;
          // Retry after delay
          Future.delayed(const Duration(seconds: 30), loadRewardedAd);
        },
      ),
    );
  }

  /// Show rewarded ad and return true if reward was earned
  Future<bool> showRewardedAd({
    required Function(int amount) onRewarded,
    Function()? onAdNotReady,
  }) async {
    if (_rewardedAd == null) {
      onAdNotReady?.call();
      loadRewardedAd();
      return false;
    }

    bool rewarded = false;

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        rewarded = true;
        onRewarded(reward.amount.toInt());
      },
    );

    return rewarded;
  }

  /// Load an interstitial ad
  void loadInterstitialAd() {
    if (_interstitialAd != null || _isInterstitialAdLoading) return;
    
    _isInterstitialAdLoading = true;
    
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoading = false;
          
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              loadInterstitialAd(); // Preload next ad
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialAd = null;
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdLoading = false;
          // Retry after delay
          Future.delayed(const Duration(seconds: 30), loadInterstitialAd);
        },
      ),
    );
  }

  /// Track game over and show interstitial if needed
  Future<bool> onGameOver() async {
    _gameOverCount++;
    
    if (_gameOverCount >= _interstitialFrequency && _interstitialAd != null) {
      _gameOverCount = 0;
      await _interstitialAd!.show();
      return true;
    }
    
    return false;
  }

  /// Clean up ads
  void dispose() {
    _rewardedAd?.dispose();
    _interstitialAd?.dispose();
  }
}
