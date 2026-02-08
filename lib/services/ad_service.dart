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
  
  int _compressionsUsedToday = 0;
  int _bonusCompressions = 0;
  String? _lastResetDate;

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
    
    _checkAndResetDaily();
    _loadInterstitialAd();
  }

  void _checkAndResetDaily() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    if (_lastResetDate != today) {
      _compressionsUsedToday = 0;
      _bonusCompressions = 0;
      _lastResetDate = today;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('compressions_used', 0);
      await prefs.setInt('bonus_compressions', 0);
      await prefs.setString('last_reset_date', today);
      
      notifyListeners();
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
    
    _rewardedAd?.show(
      onUserEarnedReward: (ad, reward) {
        rewarded = true;
        addBonusCompressions();
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
          _setupInterstitialAdCallbacks();
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) {
            print('InterstitialAd failed to load: $error');
          }
        },
      ),
    );
  }

  void _setupInterstitialAdCallbacks() {
    _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadInterstitialAd(); // Load next ad
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        if (kDebugMode) {
          print('InterstitialAd failed to show: $error');
        }
        ad.dispose();
        _loadInterstitialAd(); // Load next ad
      },
    );
  }

  void showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd?.show();
      _interstitialAd = null;
    }
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }
}
