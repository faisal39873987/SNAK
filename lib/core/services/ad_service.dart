import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  AdService._();
  static final AdService instance = AdService._();

  bool _initialized = false;
  RewardedAd? _rewardedAd;
  InterstitialAd? _interstitialAd;

  // TODO: Replace with real ad unit IDs in production
  static const String _rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917'; // test ID
  static const String _interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712'; // test ID

  Future<void> init() async {
    if (_initialized) return;
    await MobileAds.instance.initialize();
    _initialized = true;
    _loadRewardedAd();
    _loadInterstitialAd();
  }

  // ── Rewarded Ad ───────────────────────────────────────────────────────────

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewardedAd = ad,
        onAdFailedToLoad: (_) => _rewardedAd = null,
      ),
    );
  }

  Future<bool> showRewardedAd({
    required void Function() onRewarded,
  }) async {
    if (_rewardedAd == null) return false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _rewardedAd = null;
        _loadRewardedAd();
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (_, __) => onRewarded(),
    );
    return true;
  }

  bool get isRewardedAdReady => _rewardedAd != null;

  // ── Interstitial Ad ───────────────────────────────────────────────────────

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (_) => _interstitialAd = null,
      ),
    );
  }

  Future<void> showInterstitialAd() async {
    if (_interstitialAd == null) return;

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitialAd();
      },
    );

    await _interstitialAd!.show();
  }

  bool get isInterstitialAdReady => _interstitialAd != null;
}
