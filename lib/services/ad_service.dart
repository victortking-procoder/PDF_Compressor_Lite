import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdService extends ChangeNotifier {
  static const int maxFreeCompressions = 4;
  static const int rewardedAdBonus = 2;
  
  // AdMob IDs
  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-4724124049234023/4719912270'; // Production ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313'; // Test ID (iOS not configured yet)
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-4724124049234023/9230729279'; // Production ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910'; // Test ID (iOS not configured yet)
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-4724124049234023/9640222578'; // Production ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // Test ID (iOS not configured yet)
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
    
    if (kDebugMode) {
      print('📱 AdService initialized - Compressions remaining: $compressionsRemaining');
    }
    
    // Wait a bit to ensure MobileAds is fully ready
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Load ads
    if (kDebugMode) {
      print('📢 Starting to load ads...');
    }
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
    if (kDebugMode) {
      print('=== REWARDED AD LOADING ===');
      print('Starting to load rewarded ad...');
    }
    
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _setupRewardedAdCallbacks();
          if (kDebugMode) {
            print('✓ Rewarded ad loaded successfully!');
          }
          onAdLoaded();
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) {
            print('✗ RewardedAd failed to load:');
            print('  Code: ${error.code}');
            print('  Domain: ${error.domain}');
            print('  Message: ${error.message}');
            print('  Response Info: ${error.responseInfo}');
          }
          onAdFailedToLoad();
        },
      ),
    );
  }

  void _setupRewardedAdCallbacks() {
    _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        if (kDebugMode) {
          print('✅ Rewarded ad displayed successfully');
        }
      },
      onAdDismissedFullScreenContent: (ad) {
        if (kDebugMode) {
          print('Rewarded ad dismissed');
        }
        ad.dispose();
        _rewardedAd = null;
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        if (kDebugMode) {
          print('✗ RewardedAd failed to show:');
          print('  Code: ${error.code}');
          print('  Message: ${error.message}');
        }
        ad.dispose();
        _rewardedAd = null;
      },
    );
  }

  Future<bool> showRewardedAd() async {
    if (_rewardedAd == null) {
      if (kDebugMode) {
        print('❌ Cannot show rewarded ad - ad is null');
      }
      return false;
    }

    if (kDebugMode) {
      print('🎬 Attempting to show rewarded ad...');
    }

    bool rewarded = false;
    
    try {
      await _rewardedAd?.show(
        onUserEarnedReward: (ad, reward) async {
          if (kDebugMode) {
            print('🎉 User earned reward! Amount: ${reward.amount}, Type: ${reward.type}');
          }
          rewarded = true;
          await addBonusCompressions();
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error showing rewarded ad: $e');
      }
    }

    _rewardedAd = null;
    return rewarded;
  }

  // Interstitial Ad
  void _loadInterstitialAd() {
    if (kDebugMode) {
      print('=== INTERSTITIAL AD LOADING ===');
      print('Starting to load interstitial ad...');
    }
    
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          _setupInterstitialAdCallbacks();
          if (kDebugMode) {
            print('✓ InterstitialAd loaded successfully!');
          }
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdReady = false;
          if (kDebugMode) {
            print('✗ InterstitialAd failed to load:');
            print('  Code: ${error.code}');
            print('  Domain: ${error.domain}');
            print('  Message: ${error.message}');
            print('  Response Info: ${error.responseInfo}');
            print('  Will retry in 30 seconds...');
          }
          // Retry after 30 seconds
          Future.delayed(const Duration(seconds: 30), () {
            if (kDebugMode) {
              print('Retrying interstitial ad load...');
            }
            _loadInterstitialAd();
          });
        },
      ),
    );
  }

  void _setupInterstitialAdCallbacks() {
    _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        if (kDebugMode) {
          print('✅ Interstitial ad displayed successfully');
        }
      },
      onAdDismissedFullScreenContent: (ad) {
        if (kDebugMode) {
          print('Interstitial ad dismissed - loading new ad');
        }
        ad.dispose();
        _isInterstitialAdReady = false;
        _loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        if (kDebugMode) {
          print('✗ InterstitialAd failed to show:');
          print('  Code: ${error.code}');
          print('  Message: ${error.message}');
        }
        ad.dispose();
        _isInterstitialAdReady = false;
        _loadInterstitialAd();
      },
    );
  }

  void showInterstitialAd() {
    _compressionsSinceLastAd++;
    
    if (kDebugMode) {
      print('=== INTERSTITIAL AD DEBUG ===');
      print('Compressions since last ad: $_compressionsSinceLastAd');
      print('Ad ready: $_isInterstitialAdReady');
      print('Ad object exists: ${_interstitialAd != null}');
    }
    
    // Show ad every 1 compression for better user experience
    if (_compressionsSinceLastAd >= 1 && _isInterstitialAdReady && _interstitialAd != null) {
      if (kDebugMode) {
        print('🎬 Attempting to show interstitial ad NOW');
      }
      
      try {
        _interstitialAd?.show();
        _interstitialAd = null;
        _isInterstitialAdReady = false;
        _compressionsSinceLastAd = 0;
        
        if (kDebugMode) {
          print('✓ Interstitial ad show() called successfully');
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Error calling show() on interstitial: $e');
        }
        _interstitialAd = null;
        _isInterstitialAdReady = false;
        _loadInterstitialAd();
      }
    } else {
      if (kDebugMode) {
        print('✗ Interstitial ad NOT shown:');
        if (_compressionsSinceLastAd < 1) print('  - Not enough compressions');
        if (!_isInterstitialAdReady) print('  - Ad not ready');
        if (_interstitialAd == null) print('  - Ad object is null');
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
