# Monetization Guide - PDF Compressor Lite

## Revenue Model Overview

PDF Compressor Lite uses a **freemium model** with Google AdMob:

- ✅ 4 free compressions per day
- ✅ Rewarded ads unlock 2 more compressions
- ✅ Interstitial ads after successful compression
- ✅ Optional banner ads (currently disabled)

This model balances user experience with revenue generation while staying compliant with app store policies.

## Ad Types Implemented

### 1. Rewarded Ads ⭐ (Primary Revenue)

**Trigger:** When user exhausts their 4 free daily compressions

**User Flow:**
1. User tries to compress 5th PDF
2. Dialog appears: "Free limit reached. Watch a short ad to unlock 2 more compressions."
3. User clicks "Watch Ad" (optional, not forced)
4. 15-30 second video ad plays
5. User earns 2 additional compressions

**Revenue:** Highest eCPM (~$3-15), fully user-initiated

**Code Location:** `lib/widgets/limit_dialog.dart`, `lib/services/ad_service.dart`

**Why This Works:**
- Users are motivated (need more compressions)
- Not intrusive (optional)
- High completion rate
- Policy compliant (user choice)

### 2. Interstitial Ads (Secondary Revenue)

**Trigger:** After every successful PDF compression

**User Flow:**
1. User compresses PDF
2. Compression completes successfully
3. Full-screen ad shows (can be closed after 5 seconds)
4. User sees result screen

**Revenue:** Medium eCPM (~$2-8)

**Code Location:** `lib/screens/compression_screen.dart` (line ~87)

```dart
// Show interstitial ad AFTER successful compression
adService.showInterstitialAd();

// Navigate to result screen
Navigator.pushReplacement(...);
```

**Important:** Ads show AFTER compression, never before or during. This prevents:
- User frustration
- Accidental clicks (policy violation)
- Interruption of core workflow

### 3. Banner Ads (Optional - Currently Disabled)

**Potential Placements:**
- Home screen (bottom)
- History screen (bottom)
- Privacy policy screen (bottom)

**Revenue:** Low eCPM (~$0.50-2), but passive

**Implementation:**
```dart
// In home_screen.dart (example)
BannerAd? _bannerAd;

void _loadBannerAd() {
  _bannerAd = BannerAd(
    adUnitId: AdService.bannerAdUnitId,
    size: AdSize.banner,
    request: AdRequest(),
    listener: BannerAdListener(...),
  )..load();
}
```

**Why Disabled:**
- Keeps UI clean
- Reduces accidental clicks
- Focus on rewarded/interstitial revenue
- Can enable later if needed

## Daily Limit System

### How It Works

**Code:** `lib/services/ad_service.dart`

```dart
static const int maxFreeCompressions = 4;
static const int rewardedAdBonus = 2;
```

**Storage:**
- Uses `SharedPreferences` (local device storage)
- Tracks: compressions used, bonus compressions, last reset date
- Resets automatically at midnight

**Algorithm:**
```
Total Available = 4 (free) + bonus (from ads)
Remaining = Total Available - Used Today
Can Compress? = Remaining > 0
```

### Customization

Want to change limits? Edit `ad_service.dart`:

```dart
static const int maxFreeCompressions = 5; // Change to 5 free
static const int rewardedAdBonus = 3;     // Give 3 per ad
```

## Revenue Projections (Example)

Based on typical AdMob CPM rates:

| Metric | Conservative | Realistic | Optimistic |
|--------|-------------|-----------|------------|
| Daily Active Users | 100 | 500 | 2000 |
| Rewarded Ad Fill Rate | 60% | 75% | 85% |
| Rewarded Ad eCPM | $4 | $8 | $12 |
| Interstitial Fill Rate | 70% | 80% | 90% |
| Interstitial eCPM | $3 | $5 | $8 |
| **Daily Revenue** | **$8** | **$65** | **$320** |
| **Monthly Revenue** | **$240** | **$1,950** | **$9,600** |

**Note:** Actual revenue varies by geography, ad quality, and user engagement.

## Maximizing Revenue (Without Compromising UX)

### ✅ DO:

1. **Keep free limit at 4** (sweet spot - useful but limited)
2. **Show interstitial after compression** (natural break point)
3. **Make rewarded ads valuable** (2 compressions is good motivation)
4. **Test ad placements** (use Firebase A/B testing)
5. **Monitor ad frequency** (avoid ad fatigue)

### ❌ DON'T:

1. **Force rewarded ads** (must be optional)
2. **Show ads during compression** (interrupts workflow)
3. **Place ads over file picker** (accidental clicks)
4. **Reduce free limit below 3** (users will uninstall)
5. **Show multiple interstitials in a row** (policy violation)

## App Store Compliance

### Amazon Appstore
- ✅ Clearly state free limit
- ✅ Rewarded ads are optional
- ✅ Ads don't interfere with core function
- ✅ Privacy policy mentions ads

### Google Play Store
- ✅ Same as Amazon
- ✅ Data safety form declares ad tracking
- ✅ No misleading ad placements
- ✅ No incentivized clicks

## AdMob Account Setup

### Step 1: Create AdMob Account
1. Go to https://admob.google.com
2. Sign in with Google account
3. Create new app: "PDF Compressor Lite"

### Step 2: Generate Ad Unit IDs

**Rewarded Ad:**
1. AdMob → Apps → PDF Compressor Lite → Ad Units → Add Ad Unit
2. Choose "Rewarded"
3. Name: "Unlock More Compressions"
4. Copy ID: `ca-app-pub-XXXXXXXX/XXXXXXXXXX`

**Interstitial Ad:**
1. Add Ad Unit → Choose "Interstitial"
2. Name: "Post Compression"
3. Copy ID

**App ID:**
1. App Settings → Copy App ID
2. Format: `ca-app-pub-XXXXXXXX~XXXXXXXXXX`

### Step 3: Update Code

**In `lib/services/ad_service.dart`:**
```dart
static String get rewardedAdUnitId {
  if (Platform.isAndroid) {
    return 'ca-app-pub-YOUR_ID/YOUR_REWARDED_ID'; // YOUR ID
  }
  // ... iOS
}

static String get interstitialAdUnitId {
  if (Platform.isAndroid) {
    return 'ca-app-pub-YOUR_ID/YOUR_INTERSTITIAL_ID'; // YOUR ID
  }
  // ... iOS
}
```

**In `android/app/src/main/AndroidManifest.xml`:**
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-YOUR_ID~YOUR_APP_ID"/>
```

### Step 4: Test Production Ads

1. Add test devices to AdMob
2. Build release APK
3. Install on test device
4. Verify ads load and display correctly

## Monitoring Performance

### Key Metrics (AdMob Dashboard)

1. **Impressions** - How many ads shown
2. **eCPM** - Earnings per 1000 impressions
3. **Fill Rate** - % of ad requests that returned an ad
4. **Click Rate** - % of ads clicked (should be low for non-banner)

### Red Flags

- Fill rate < 50% → Check ad unit setup
- Click rate > 5% on interstitials → Possible accidental clicks (policy risk)
- eCPM dropping → May need better ad networks (mediation)

## Advanced: Ad Mediation

To maximize revenue, consider adding more ad networks:

1. **AdMob Mediation** (built-in)
   - Facebook Audience Network
   - Unity Ads
   - AppLovin

2. **Benefits:**
   - Higher fill rates
   - Better eCPM (networks compete)
   - More consistent revenue

3. **Setup:**
   - AdMob Dashboard → Mediation → Add Networks
   - Follow integration guides
   - Test thoroughly

## Legal Requirements

### Privacy Policy Must State:
- "This app displays ads provided by Google AdMob"
- "AdMob may collect anonymous usage data for ad personalization"
- "Users can opt out via device settings"

### App Store Listing:
- Mention "Contains ads" in description
- Select "Ads" category in store listing
- Be honest about free limits

## Frequently Asked Questions

**Q: Can I increase free limit to 10?**
A: Yes, but revenue will drop significantly. 4-5 is optimal.

**Q: Should I add banner ads?**
A: Optional. Test it - if clicks are low and users don't complain, keep them.

**Q: How long before I see revenue?**
A: AdMob has $100 minimum payout. With 500 DAU, expect payout in 2-3 months.

**Q: Can I remove ads with in-app purchase?**
A: Yes! Add a "Remove Ads" IAP for $2.99. Many users will pay.

**Q: Is rewarded ad skip rate high?**
A: Typically 20-40%. That's normal. Motivated users (need compressions) will watch.

## Next Steps

1. ✅ Test app with current test IDs
2. ✅ Create AdMob account
3. ✅ Generate production ad unit IDs
4. ✅ Update code with real IDs
5. ✅ Build and test release APK
6. ✅ Submit to app stores
7. ✅ Monitor AdMob dashboard
8. ✅ Optimize based on data

---

**Revenue Starts Here!** 💰

Focus on user experience first, revenue second. Happy users = more impressions = more money.
