# Publishing Checklist - PDF Compressor Lite

Complete this checklist before submitting to Amazon Appstore or Google Play Store.

## Pre-Build Checklist

### ✅ Code Review

- [ ] Replaced all AdMob test IDs with production IDs
  - `lib/services/ad_service.dart` - Rewarded, Interstitial, Banner IDs
  - `android/app/src/main/AndroidManifest.xml` - App ID
- [ ] Updated `applicationId` in `android/app/build.gradle` (if needed)
- [ ] Verified app version in `pubspec.yaml` (e.g., 1.0.0+1)
- [ ] Removed all debug `print()` statements
- [ ] Checked for hardcoded API keys or secrets (should be none)
- [ ] Privacy policy text reviewed and accurate

### ✅ Testing

- [ ] Tested on Android 11 (API 30)
- [ ] Tested on Android 12 (API 31)
- [ ] Tested on Android 13 (API 33)
- [ ] Tested on Android 14 (API 34)
- [ ] Tested on low-end device (2GB RAM)
- [ ] Tested on high-end device (8GB+ RAM)
- [ ] Tested with PDFs of various sizes (1MB, 10MB, 50MB)
- [ ] Verified storage permissions work on all Android versions
- [ ] Confirmed ads load and display correctly
- [ ] Tested rewarded ad flow (watch ad → unlock compressions)
- [ ] Tested interstitial ads appear after compression
- [ ] Verified daily limit resets at midnight
- [ ] Checked compression produces valid PDFs
- [ ] Tested share functionality
- [ ] Tested open file functionality
- [ ] Verified history persistence
- [ ] Tested with no internet (offline compression works)
- [ ] Tested ad failure scenarios (graceful handling)

## Build Steps

### 1. Clean Build

```bash
flutter clean
rm -rf build/
flutter pub get
```

### 2. Update Version

In `pubspec.yaml`:
```yaml
version: 1.0.0+1  # 1.0.0 = version name, 1 = version code
```

For updates, increment:
- Patch: 1.0.1+2
- Minor: 1.1.0+3
- Major: 2.0.0+4

### 3. Generate Signing Key (First Time Only)

```bash
keytool -genkey -v -keystore ~/pdf-compressor-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias pdf-compressor
```

Save password securely!

### 4. Configure Signing

Create `android/key.properties`:
```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=pdf-compressor
storeFile=/path/to/pdf-compressor-key.jks
```

Add to `android/app/build.gradle`:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### 5. Build Release APK

```bash
flutter build apk --release --split-per-abi
```

Output: `build/app/outputs/flutter-apk/`

**Files generated:**
- `app-armeabi-v7a-release.apk` (32-bit ARM)
- `app-arm64-v8a-release.apk` (64-bit ARM) ← Most common
- `app-x86_64-release.apk` (x86)

### 6. Build App Bundle (Recommended)

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

**Use App Bundle for:**
- Google Play Store (required)
- Amazon Appstore (supported)

## Assets Preparation

### ✅ App Icon

- [ ] Created 512x512 PNG icon
- [ ] Icon has no transparency (solid background)
- [ ] Icon clearly represents "PDF compression"
- [ ] Icon looks good at small sizes (48x48)
- [ ] Icon follows Material Design guidelines

**Tools:**
- Use https://romannurik.github.io/AndroidAssetStudio/ for icon generation
- Or design in Figma/Adobe Illustrator

### ✅ Screenshots

Prepare 4-8 screenshots (1080x1920 or higher):

1. **Home Screen** - Shows compression counter, select PDF button
2. **Compression Options** - Shows 3 levels (Light, Recommended, Strong)
3. **Progress** - Shows compression in progress
4. **Results** - Shows before/after sizes, % saved
5. **History** - Shows compression history list
6. **Privacy Policy** - Shows privacy commitment (optional)

**Tips:**
- Use real app screenshots (not mockups)
- Show key features clearly
- Add text overlays highlighting features (optional)
- Consistent device frame (Pixel 6 recommended)

**Tools:**
- Android Studio → Run app → Screenshot from emulator
- Use https://screenshots.pro/ for device frames

### ✅ Feature Graphic (Google Play Only)

- [ ] Created 1024x500 PNG
- [ ] Shows app icon + tagline
- [ ] High quality, professional design

**Example:**
```
[App Icon] | PDF Compressor Lite
           | Compress PDFs in Seconds
```

## Store Listings

### ✅ App Title

**Options:**
- PDF Compressor Lite
- PDF Compressor - Reduce Size
- PDF Size Reducer - Compressor

**Max length:** 30 characters

**Chosen:** ___________________

### ✅ Short Description (80 chars)

**Example:**
"Compress PDF files fast to reduce size. Free, offline, no ads on core features."

**Chosen:** 
```
________________________________________________
```

### ✅ Full Description

**Template:**

```
Compress PDF files quickly on your Android device to reduce file size for easy sharing and storage.

✨ KEY FEATURES
• Three compression levels: Light, Recommended, Strong
• See size reduction before saving
• Share compressed PDFs instantly
• View compression history
• 100% offline - no internet required
• Fast and reliable compression

🔒 PRIVACY FIRST
All compression happens locally on your device. Your files never leave your phone.

💎 FREE TO USE
• 4 free compressions daily
• Watch optional ads for more

📱 SIMPLE & CLEAN
Minimalist design focused on speed and ease of use. No bloated features.

Perfect for:
✓ Reducing email attachment sizes
✓ Freeing up phone storage
✓ Faster file uploads
✓ Sharing large documents

Download now and start compressing!
```

**Chosen:**
```
[Paste your customized description]
```

### ✅ Keywords (Separated by Commas)

**Examples:**
- PDF compressor, reduce PDF size, PDF optimizer, compress PDF, PDF tools
- PDF editor, document scanner, file compressor, shrink PDF
- PDF converter, merge PDF, split PDF

**Limit:** 100-150 characters total

**Chosen:**
```
___________________________________________________________________
```

### ✅ Category

**Options:**
- Productivity (Recommended)
- Tools
- Business

**Chosen:** ___________________

### ✅ Content Rating

**Age:** 4+ / Everyone

**Content:**
- No violence
- No adult content
- No gambling
- Contains ads ← Select this!

### ✅ Privacy Policy URL

**Required!** Host privacy policy on:
- GitHub Pages (free): `https://yourusername.github.io/pdf-compressor/privacy.html`
- Google Sites (free)
- Your website

**Template:**

```html
<!DOCTYPE html>
<html>
<head>
    <title>Privacy Policy - PDF Compressor Lite</title>
</head>
<body>
    <h1>Privacy Policy</h1>
    <p><strong>Last updated:</strong> February 2026</p>
    
    <h2>Data Processing</h2>
    <p>All PDF compression happens locally on your device. Your files never leave your phone and are not sent to any server.</p>
    
    <h2>Permissions</h2>
    <p>This app requests storage permissions only to access and save PDF files on your device. No other data is collected or accessed.</p>
    
    <h2>Advertising</h2>
    <p>This app displays ads provided by Google AdMob. AdMob may collect anonymous usage data for ad personalization. For more information, please visit Google's privacy policy.</p>
    
    <h2>Data Storage</h2>
    <p>The app stores compression history locally on your device. This data can be cleared at any time from the app settings.</p>
    
    <h2>Contact</h2>
    <p>For questions, contact us at: your-email@example.com</p>
</body>
</html>
```

**Your URL:** ___________________________________

## Amazon Appstore Submission

### Account Setup

1. Go to https://developer.amazon.com/apps-and-games
2. Create developer account ($99/year)
3. Complete tax forms

### Submission Steps

1. **App Info**
   - Title: PDF Compressor Lite
   - Category: Productivity
   - Keywords: [your keywords]

2. **Content Rating**
   - Select "Everyone"
   - Questionnaire: Answer "No" to violence/gambling/etc.

3. **Availability**
   - Countries: All countries
   - Pricing: Free

4. **Binary Files**
   - Upload: `app-release.aab` or `app-arm64-v8a-release.apk`
   - Device support: Select all Android devices

5. **Images**
   - Upload all screenshots
   - Upload 512x512 icon

6. **Description**
   - Short: [your short description]
   - Full: [your full description]
   - Privacy policy: [your URL]

7. **Content Rating**
   - Complete questionnaire
   - Declare "Contains Ads"

8. **Submit for Review**

**Review time:** 3-7 days

## Google Play Store Submission

### Account Setup

1. Go to https://play.google.com/console
2. Create developer account ($25 one-time fee)
3. Complete payment profile

### Submission Steps

1. **Create App**
   - App name: PDF Compressor Lite
   - Default language: English (United States)

2. **App Access**
   - All functionality available without restrictions

3. **Ads**
   - Select "Yes, my app contains ads"

4. **Content Rating**
   - Complete questionnaire (select "Everyone")

5. **Target Audience**
   - Age groups: 18+ (or all ages if appropriate)

6. **Data Safety**
   - Data collected: Location (NO), Personal info (NO), Photos/Videos (NO)
   - Data shared: With advertising partners
   - Security practices: Data encrypted in transit (NO - local only)

7. **App Category**
   - Category: Tools or Productivity
   - Tags: PDF, Compression, Productivity

8. **Store Listing**
   - Upload all screenshots (2-8 required)
   - Upload feature graphic (1024x500)
   - Upload app icon (512x512)
   - Short description: [yours]
   - Full description: [yours]

9. **Production Release**
   - Upload: `app-release.aab`
   - Release name: 1.0.0
   - Release notes: "Initial release"
   - Rollout: 100%

10. **Review & Publish**

**Review time:** 24-48 hours (typically)

## Post-Submission Checklist

### ✅ Monitor

- [ ] Check app store review status daily
- [ ] Respond to reviewer questions within 24 hours
- [ ] Test app on fresh device after approval

### ✅ AdMob Setup

- [ ] Link AdMob account to app
- [ ] Verify ads are showing in production
- [ ] Monitor fill rate (should be >60%)
- [ ] Check for policy violations (in AdMob dashboard)

### ✅ Analytics (Optional but Recommended)

- [ ] Set up Firebase Analytics
- [ ] Track key events: compression_started, compression_completed, ad_watched
- [ ] Monitor crash reports

### ✅ Marketing

- [ ] Share on social media
- [ ] Post on Reddit (r/androidapps, r/productivity)
- [ ] Create simple landing page
- [ ] Ask friends/family for reviews

## Common Rejection Reasons & Fixes

### Amazon Appstore

**Issue:** "App crashes on launch"
**Fix:** Test on clean device, check permissions

**Issue:** "Misleading description"
**Fix:** Remove superlatives like "best", "fastest", "#1"

**Issue:** "Privacy policy missing"
**Fix:** Add valid URL in app listing

### Google Play Store

**Issue:** "Deceptive behavior - Ads"
**Fix:** Ensure ads don't cover file picker, no accidental clicks

**Issue:** "Permissions not disclosed"
**Fix:** Add permission requests to Data Safety form

**Issue:** "Target API level too low"
**Fix:** Update `targetSdk` to 34 (Android 14)

## Version Updates

When releasing updates:

1. Increment version in `pubspec.yaml`
2. Update "What's New" text
3. Build new APK/AAB
4. Upload to stores
5. Monitor crash reports for new issues

## Success Metrics

Track these after launch:

- **Installs:** Target 1000+ in first month
- **Active Users:** Target 500+ DAU
- **Retention:** Target 30%+ after 7 days
- **Rating:** Target 4.0+ stars
- **Revenue:** Target $100+ in first 2 months

## Final Notes

- Keep app updated regularly (monthly)
- Respond to user reviews (especially negative ones)
- Monitor AdMob for policy violations
- Consider A/B testing ad placements
- Add features based on user feedback

---

**Ready to Launch!** 🚀

Good luck with your app store submission!
