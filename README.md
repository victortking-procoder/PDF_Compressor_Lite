# PDF Compressor Lite

A minimalist, fast, and offline-first Android utility app for compressing PDF files. Built with Flutter and optimized for Amazon Appstore approval and Google AdMob monetization.

## Features

✅ **Core Functionality**
- Pick PDF files from device storage
- 3 compression levels: Light, Recommended, Strong
- Real-time compression progress
- Before/after size comparison with reduction percentage
- Share and open compressed PDFs
- Compression history

✅ **Monetization**
- Google AdMob integration with test IDs
- 4 free compressions per day
- Rewarded ads to unlock 2 additional compressions
- Interstitial ads after successful compression (never before)
- Banner ads on non-critical screens
- Policy-compliant ad placements

✅ **User Experience**
- Material 3 design
- Clean, minimalist interface
- Fast performance on low RAM devices
- Smooth animations
- Dark mode support
- Offline-first architecture

✅ **Privacy & Compliance**
- All compression happens locally on device
- Minimal permissions (storage only)
- Privacy policy page included
- No data collection
- Appstore-safe (no false claims)

## Tech Stack

- **Framework**: Flutter 3.x (null-safe)
- **Architecture**: Clean architecture with Provider state management
- **PDF Processing**: pdf, printing packages
- **Ads**: Google Mobile Ads SDK
- **Storage**: shared_preferences for local data
- **UI**: Material 3 with flutter_animate

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   ├── compression_level.dart
│   └── compressed_file.dart
├── screens/
│   ├── home_screen.dart      # Main screen with file selection
│   ├── compression_screen.dart  # Compression level selection
│   ├── result_screen.dart    # Results display
│   └── privacy_screen.dart   # Privacy policy
├── services/
│   ├── ad_service.dart       # AdMob integration
│   ├── compression_service.dart  # PDF compression logic
│   └── storage_service.dart  # History management
└── widgets/
    ├── history_item.dart     # History list item
    └── limit_dialog.dart     # Daily limit dialog with rewarded ad
```

## Setup Instructions

### Prerequisites

1. Install Flutter SDK (3.0.0 or higher)
2. Install Android Studio with Android SDK
3. Set up an Android emulator or physical device

### Installation

1. Clone or extract the project:
```bash
cd pdf_compressor_lite
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Building for Production

### Android APK/AAB

1. Build APK:
```bash
flutter build apk --release
```

2. Build App Bundle for Google Play/Amazon Appstore:
```bash
flutter build appbundle --release
```

The output will be in `build/app/outputs/`

### Important: Replace Test Ad IDs

Before publishing, replace test AdMob IDs in `lib/services/ad_service.dart`:

```dart
// Current (Test IDs)
static String get rewardedAdUnitId {
  return 'ca-app-pub-3940256099942544/5224354917'; // TEST
}

// Replace with your real IDs:
static String get rewardedAdUnitId {
  return 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'; // YOUR ID
}
```

Also update `AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX"/>
```

## AdMob Integration

The app uses the following ad types:

1. **Rewarded Ads**: Shown when user reaches daily compression limit
2. **Interstitial Ads**: Shown after successful compression
3. **Banner Ads**: Can be added to non-critical screens (currently disabled)

### Daily Limit System

- Users get 4 free compressions per day
- Resets automatically at midnight
- Users can watch rewarded ads to unlock 2 more compressions
- Limit is stored locally using SharedPreferences

## Compression Logic

The app compresses PDFs by:

1. Rasterizing each PDF page as images
2. Applying quality and scale adjustments based on compression level
3. Reconstructing the PDF with compressed images
4. Saving as a new file (never overwrites original)

**Compression Levels:**
- **Light**: 85% quality, 90% scale
- **Recommended**: 70% quality, 70% scale
- **Strong**: 50% quality, 50% scale

## Permissions

The app requires minimal permissions:

- `READ_EXTERNAL_STORAGE` / `READ_MEDIA_*`: To access PDF files
- `WRITE_EXTERNAL_STORAGE`: To save compressed PDFs (API < 30)
- `INTERNET`: For AdMob ads

All permissions are explained to users within the app.

## Privacy Compliance

- All PDF processing happens locally
- No files are uploaded to servers
- No user data is collected
- AdMob may collect anonymous usage data (disclosed in privacy policy)
- Privacy policy accessible from app settings

## Testing Checklist

Before submitting to app stores:

- [ ] Replace all AdMob test IDs with production IDs
- [ ] Test on low-end devices (2GB RAM)
- [ ] Test with various PDF sizes and types
- [ ] Verify ad placements don't interfere with UX
- [ ] Test permission requests on Android 13+
- [ ] Verify privacy policy is accessible
- [ ] Test daily limit reset functionality
- [ ] Test rewarded ad flow
- [ ] Ensure no crashes on large PDFs
- [ ] Test share and open file functionality

## App Store Submission

### Amazon Appstore

1. Create developer account
2. Build signed APK/AAB
3. Prepare:
   - App icon (512x512)
   - Screenshots (1080x1920 or higher)
   - Feature graphic
   - Privacy policy link
   - App description (avoid false claims)
4. Submit for review

### Google Play Store

Same process as Amazon, with additional requirements:
- App bundle (.aab) required
- Content rating questionnaire
- Data safety form

## Known Limitations

- Compression quality varies based on original PDF
- Very large PDFs (>50MB) may take longer to process
- Scanned PDFs compress better than text-heavy PDFs
- Some PDFs with complex layouts may have formatting changes

## Future Enhancements (Optional)

- Batch compression
- Custom compression settings
- Cloud backup integration
- OCR for scanned PDFs
- PDF merge/split tools

## License

This project is provided as-is for educational and commercial use.

## Support

For issues or questions, contact through:
- GitHub Issues (if applicable)
- App store review section
- Email: [your-email@example.com]

---

**Built with Flutter** 💙

Last updated: February 2026
