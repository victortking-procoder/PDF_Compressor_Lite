# Ad Debugging Guide for PDF Compressor Lite

## Changes Made

### 1. **AdMob SDK Initialization** (main.dart)
- ✅ AdMob now fully initializes BEFORE any ads are loaded
- ✅ Added 1-second delay after initialization for SDK to be completely ready
- ✅ Added retry logic if initialization fails
- ✅ Added RequestConfiguration for test mode
- ✅ Comprehensive logging at every step

### 2. **Ad Service** (ad_service.dart)
- ✅ Added 500ms delay before loading ads to ensure SDK is ready
- ✅ Detailed error logging for all ad types
- ✅ Better callbacks with success/failure tracking
- ✅ Try-catch blocks around ad.show() calls

### 3. **Interstitial Ads** (compression_screen.dart)
- ✅ Shows after EVERY compression (was every 2)
- ✅ 1-second delay after navigation before showing
- ✅ Added debug logging

## How to Debug

### Step 1: Check Console Logs

When you run the app, you should see these logs in order:

```
🚀 Starting AdMob initialization...
✅ AdMob initialized successfully!
✅ AdMob ready to load ads
📱 AdService initialized - Compressions remaining: 4
📢 Starting to load ads...
=== INTERSTITIAL AD LOADING ===
Starting to load interstitial ad...
✓ InterstitialAd loaded successfully!
Banner ad loaded
```

### Step 2: Compress a PDF

After compressing, look for:

```
📱 Now attempting to show interstitial ad after navigation...
=== INTERSTITIAL AD DEBUG ===
Compressions since last ad: 1
Ad ready: true
Ad object exists: true
🎬 Attempting to show interstitial ad NOW
✓ Interstitial ad show() called successfully
✅ Interstitial ad displayed successfully
```

### Step 3: Test Rewarded Ad

When you hit the limit and click "Watch Ad":

```
=== REWARDED AD LOADING ===
Starting to load rewarded ad...
✓ Rewarded ad loaded successfully!
🎬 Attempting to show rewarded ad...
✅ Rewarded ad displayed successfully
🎉 User earned reward! Amount: 1, Type: <reward_type>
```

## Common Issues and Solutions

### Issue 1: "Ad failed to load" with error code 3

**Error:**
```
✗ InterstitialAd failed to load:
  Code: 3
  Message: No fill
```

**Solution:** This is NORMAL for test ads! Error code 3 means no ad inventory. Test ads don't always have inventory. Wait 30 seconds and it will retry automatically.

### Issue 2: Ad loads but doesn't show

**Logs to check:**
```
✗ Interstitial ad NOT shown:
  - Ad not ready
  - Ad object is null
```

**Solution:** The ad hasn't loaded yet. Wait longer or compress another PDF.

### Issue 3: Banner works but not interstitial/rewarded

**This means:**
- ✅ SDK is initialized correctly
- ✅ Internet connection works
- ❌ Interstitial/Rewarded ads take longer to load

**Solution:** Wait 1-2 minutes after app starts, then try compressing a PDF.

### Issue 4: All ads fail

**Check:**
1. Internet connection is active
2. You're not on a restricted network (VPN, corporate network)
3. Google Play Services is updated on your device

## Getting Your Test Device ID (Optional but Recommended)

To get better test ad delivery, add your device as a test device:

### On Android:

1. Run the app
2. Trigger an ad
3. Look in logcat for a message like:
   ```
   I/Ads: Use RequestConfiguration.Builder().setTestDeviceIds(Arrays.asList("33BE2250B43518CCDA7DE426D04EE231"))
   ```
4. Copy that device ID

5. In `main.dart`, replace:
   ```dart
   testDeviceIds: ['YOUR_TEST_DEVICE_ID'],
   ```
   with:
   ```dart
   testDeviceIds: ['33BE2250B43518CCDA7DE426D04EE231'],
   ```

## Expected Behavior

✅ **Banner Ad:** Shows immediately on home screen (within 1-3 seconds)

✅ **Interstitial Ad:** 
- Loads in background (30-60 seconds after app start)
- Shows AFTER you compress a PDF
- Shows after navigation to results screen

✅ **Rewarded Ad:**
- Loads on-demand when you click "Watch Ad"
- Takes 3-10 seconds to load
- Shows immediately after loading

## Production Checklist

Before releasing to production:

1. ❌ Replace ALL test ad unit IDs with real ones from AdMob console
2. ❌ Replace test App ID in AndroidManifest.xml
3. ❌ Remove or comment out test device ID configuration
4. ❌ Set `minifyEnabled` and `shrinkResources` to `true` (already done)
5. ❌ Test ads thoroughly with real ad units

## Need More Help?

If ads still don't show after following this guide:

1. Share the FULL console logs from app start to when you try to show an ad
2. Note your location (some countries have limited ad inventory)
3. Check if you're using a VPN or ad blocker
4. Verify Google Play Services is up to date on your device

## Quick Test Commands

To see all ad-related logs, filter logcat:

```bash
# Android Studio / Logcat
Filter: AdMob|Ads|INTERSTITIAL|REWARDED

# Command line
adb logcat | grep -E "AdMob|Ads|INTERSTITIAL|REWARDED"
```
