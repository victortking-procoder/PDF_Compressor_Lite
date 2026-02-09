import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdService extends ChangeNotifier {
  static const int maxFreeCompressions = 4;
  static const int rewardedAdBonus = 2;
  
  // AdMob Test IDs
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

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Test ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // Test ID
    }
    throw UnsupportedError('Unsupported platform');
  }

  RewardedAd? _rewardedAd;
  InterstitialAd? _interstitialAd;
  BannerAd? _bannerAd;
  bool _isInterstitialAdReady = false;
  bool _isBannerAdReady = false;
  
  int _compressionsUsedToday = 0;
  int _bonusCompressions = 0;
  int _compressionsSinceLastAd = 0;
  String? _lastResetDate;
  
  BannerAd? get bannerAd => _isBannerAdReady ? _bannerAd : null;

  int get compressionsRemaining {
    final total = maxFreeCompressions + _bonusCompressions;
    final remaining = total - _compressionsUsedToday;
    return remaining > 0 ? remaining : 0;
  }

  bool get canCompress => compressionsRemaining > 0;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _compressionsUsedToday = prefs.getInt('compressions_used') ?? 0;
    _bonusCompressions = prefs.getInt('bonus_compressions') ?? 0;
    _lastResetDate = prefs.getString('last_reset_date');
    
    // Check and reset AFTER loading saved values
    await _checkAndResetDaily();
    
    // Load ads
    _loadInterstitialAd();
    
    // Notify listeners so UI updates with correct values
    notifyListeners();
  }

  Future<void> _checkAndResetDaily() async {
    final now = DateTime.now();
    final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    
    if (_lastResetDate != today) {
      _compressionsUsedToday = 0;
      _bonusCompressions = 0;
      _lastResetDate = today;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('compressions_used', 0);
      await prefs.setInt('bonus_compressions', 0);
      await prefs.setString('last_reset_date', today);
      
      if (kDebugMode) {
        print('Daily reset: new date is $today');
      }
    }
  }

  Future<void> useCompression() async {
    if (!canCompress) return;
    
    _compressionsUsedToday++;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('compressions_used', _compressionsUsedToday);
    
    notifyListeners();
  }

  Future<void> addBonusCompressions() async {
    _bonusCompressions += rewardedAdBonus;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('bonus_compressions', _bonusCompressions);
    
    notifyListeners();
  }

  // Rewarded Ad
  void loadRewardedAd({required VoidCallback onAdLoaded, required VoidCallback onAdFailedToLoad}) {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _setupRewardedAdCallbacks();
          onAdLoaded();
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) {
            print('RewardedAd failed to load: $error');
          }
          onAdFailedToLoad();
        },
      ),
    );
  }

  void _setupRewardedAdCallbacks() {
    _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        if (kDebugMode) {
          print('RewardedAd failed to show: $error');
        }
        ad.dispose();
        _rewardedAd = null;
      },
    );
  }

  Future<bool> showRewardedAd() async {
    if (_rewardedAd == null) return false;

    bool rewarded = false;
    
    await _rewardedAd?.show(
      onUserEarnedReward: (ad, reward) async {
        rewarded = true;
        await addBonusCompressions();
      },
    );

    _rewardedAd = null;
    return rewarded;
  }

  // Interstitial Ad
  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          _setupInterstitialAdCallbacks();
          if (kDebugMode) {
            print('InterstitialAd loaded successfully');
          }
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdReady = false;
          if (kDebugMode) {
            print('InterstitialAd failed to load: $error');
          }
          // Retry after 30 seconds
          Future.delayed(const Duration(seconds: 30), () {
            _loadInterstitialAd();
          });
        },
      ),
    );
  }

  void _setupInterstitialAdCallbacks() {
    _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isInterstitialAdReady = false;
        _loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        if (kDebugMode) {
          print('InterstitialAd failed to show: $error');
        }
        ad.dispose();
        _isInterstitialAdReady = false;
        _loadInterstitialAd();
      },
    );
  }

  void showInterstitialAd() {
    _compressionsSinceLastAd++;
    
    // Show ad every 2 compressions
    if (_compressionsSinceLastAd >= 2 && _isInterstitialAdReady && _interstitialAd != null) {
      if (kDebugMode) {
        print('Showing interstitial ad');
      }
      _interstitialAd?.show();
      _interstitialAd = null;
      _isInterstitialAdReady = false;
      _compressionsSinceLastAd = 0;
    } else {
      if (kDebugMode) {
        print('Interstitial ad not ready or not time yet. Count: $_compressionsSinceLastAd');
      }
    }
  }

  // Banner Ad
  void loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isBannerAdReady = true;
          notifyListeners();
          if (kDebugMode) {
            print('Banner ad loaded');
          }
        },
        onAdFailedToLoad: (ad, error) {
          _isBannerAdReady = false;
          ad.dispose();
          if (kDebugMode) {
            print('Banner ad failed to load: $error');
          }
        },
      ),
    );
    
    _bannerAd?.load();
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    _interstitialAd?.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }
}
