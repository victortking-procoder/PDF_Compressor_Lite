# Quick Setup Guide - PDF Compressor Lite

## Getting Started in 5 Minutes

### Step 1: Prerequisites
```bash
# Verify Flutter installation
flutter doctor

# Expected: All green checkmarks for Android development
```

### Step 2: Get Dependencies
```bash
cd pdf_compressor_lite
flutter pub get
```

### Step 3: Run the App
```bash
# On connected Android device or emulator
flutter run

# Or specify device
flutter devices
flutter run -d <device-id>
```

## Testing AdMob Integration

The app is pre-configured with **AdMob test IDs**, so you can test ads immediately:

### Test Rewarded Ads
1. Open the app
2. Compress 4 PDFs (exhausts free limit)
3. Try to compress another PDF
4. A dialog appears: "Free limit reached"
5. Click "Watch Ad"
6. Test ad will play
7. After watching, you get 2 more compressions

### Test Interstitial Ads
1. Compress any PDF
2. After compression completes, an interstitial test ad will show
3. Click X to close

## File Structure Quick Reference

```
lib/
├── main.dart              → App entry, AdMob init
├── models/                → Data models
├── screens/               → UI screens
│   ├── home_screen.dart   → Main screen
│   ├── compression_screen.dart → Compression options
│   └── result_screen.dart → Results display
├── services/              → Business logic
│   ├── ad_service.dart    → AdMob (4/day limit, rewarded, interstitial)
│   ├── compression_service.dart → PDF compression
│   └── storage_service.dart → History persistence
└── widgets/               → Reusable components
```

## Key Configuration Files

### AdMob IDs (lib/services/ad_service.dart)
```dart
// Currently using TEST IDs - safe for development
static String get rewardedAdUnitId {
  return 'ca-app-pub-3940256099942544/5224354917'; // TEST
}
```

### Permissions (android/app/src/main/AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.INTERNET"/>
```

## Common Commands

```bash
# Hot reload (during development)
Press 'r' in terminal while app is running

# Hot restart
Press 'R'

# Clean build
flutter clean
flutter pub get
flutter run

# Build release APK
flutter build apk --release

# Build App Bundle (for stores)
flutter build appbundle --release
```

## Testing PDF Compression

1. You need a PDF file on your Android device
2. You can download any PDF from the internet first
3. Or use `adb` to push a test PDF:
```bash
adb push test.pdf /sdcard/Download/
```

## Troubleshooting

### "Storage permission denied"
- Android 13+: Manually grant permission in Settings → Apps → PDF Compressor Lite → Permissions

### "Ad failed to load"
- Normal for test ads in some regions
- Will work fine with real AdMob IDs in production

### Build errors
```bash
flutter clean
flutter pub get
cd android && ./gradlew clean
cd ..
flutter run
```

## Before Publishing

1. **Replace test AdMob IDs** with your production IDs
2. **Update AndroidManifest.xml** with your AdMob App ID
3. **Test on low-end devices** (2GB RAM)
4. **Generate signed APK/AAB** for app stores
5. **Review privacy policy** text

## Production Checklist

- [ ] Real AdMob IDs configured
- [ ] App signed with release keystore
- [ ] Privacy policy reviewed
- [ ] Screenshots prepared (1080x1920+)
- [ ] App icon finalized (512x512)
- [ ] Tested on Android 11, 12, 13, 14
- [ ] Proguard rules verified (build/app/outputs/)

## Need Help?

- Check README.md for detailed documentation
- Review inline code comments
- Test with Flutter DevTools: `flutter run --observatory-port=8888`

---

**Ready to build!** 🚀

The app is production-ready with test ads. Just replace AdMob IDs when you're ready to publish.
