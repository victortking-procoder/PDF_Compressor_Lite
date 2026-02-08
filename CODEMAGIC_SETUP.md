# Codemagic Setup Guide - PDF Compressor Lite

This guide will help you set up automated builds for your PDF Compressor Lite app using Codemagic.

## 🚀 Why Codemagic?

- ✅ Automated builds in the cloud
- ✅ No need for local Android Studio setup
- ✅ Automatic signing and versioning
- ✅ Direct publishing to app stores
- ✅ Free tier: 500 build minutes/month

## 📋 Prerequisites

1. **GitHub/GitLab/Bitbucket account** (to host your code)
2. **Codemagic account** (free): https://codemagic.io
3. **Keystore file** (for signing APKs)
4. **AdMob IDs** (replace test IDs first)

---

## Step 1: Prepare Your Repository

### 1.1 Create Git Repository

```bash
cd pdf_compressor_lite
git init
git add .
git commit -m "Initial commit - PDF Compressor Lite"
```

### 1.2 Push to GitHub/GitLab

**GitHub:**
```bash
# Create repo at https://github.com/new
git remote add origin https://github.com/YOUR_USERNAME/pdf-compressor-lite.git
git branch -M main
git push -u origin main
```

**GitLab:**
```bash
# Create repo at https://gitlab.com/projects/new
git remote add origin https://gitlab.com/YOUR_USERNAME/pdf-compressor-lite.git
git push -u origin main
```

---

## Step 2: Generate Android Keystore

You need a keystore to sign your release APKs.

### 2.1 Create Keystore

```bash
keytool -genkey -v -keystore pdf-compressor-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias pdf-compressor
```

**Prompts:**
- **Password**: Choose a strong password (save it!)
- **Name**: Your name or company
- **Organization**: Your company name (or personal)
- **City, State, Country**: Your location
- **Confirm**: Type "yes"

**IMPORTANT:** Save these values:
- Keystore password: ________________
- Key alias: `pdf-compressor`
- Key password: ________________

### 2.2 Secure Your Keystore

**DO NOT commit keystore to Git!**

The `.gitignore` file already excludes `*.jks` files.

---

## Step 3: Set Up Codemagic

### 3.1 Create Codemagic Account

1. Go to https://codemagic.io
2. Sign up (free account)
3. Connect your GitHub/GitLab/Bitbucket account

### 3.2 Add Your App

1. Click "Add application"
2. Select your repository: `pdf-compressor-lite`
3. Choose "Flutter App" as project type
4. Click "Finish"

---

## Step 4: Configure Code Signing

### 4.1 Upload Keystore to Codemagic

1. In Codemagic, go to your app
2. Click "Settings" → "Code signing identities"
3. Under "Android", click "Add key"
4. Upload your `pdf-compressor-release.jks` file
5. Enter:
   - **Keystore password**: [your password]
   - **Key alias**: `pdf-compressor`
   - **Key password**: [your key password]
6. Reference name: `keystore_reference`
7. Click "Save"

### 4.2 Update android/app/build.gradle

The app is already configured to use Codemagic signing, but verify:

```gradle
android {
    ...
    signingConfigs {
        release {
            if (System.getenv()["CI"]) { // Codemagic environment
                storeFile file(System.getenv()["CM_KEYSTORE_PATH"])
                storePassword System.getenv()["CM_KEYSTORE_PASSWORD"]
                keyAlias System.getenv()["CM_KEY_ALIAS"]
                keyPassword System.getenv()["CM_KEY_PASSWORD"]
            } else if (keystorePropertiesFile.exists()) { // Local
                keyAlias keystoreProperties['keyAlias']
                keyPassword keystoreProperties['keyPassword']
                storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
                storePassword keystoreProperties['storePassword']
            }
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

**Note:** I'll add this to the build.gradle file for you.

---

## Step 5: Configure codemagic.yaml

The `codemagic.yaml` file is already in your project with 3 workflows:

### Workflow 1: `android-release`
- Builds signed **App Bundle (.aab)**
- For Google Play Store submission
- Includes ProGuard/R8 optimization

### Workflow 2: `android-apk`
- Builds signed **APKs** (split per ABI)
- For Amazon Appstore or direct distribution
- Creates: arm64-v8a, armeabi-v7a, x86_64 APKs

### Workflow 3: `android-debug`
- Builds debug APK
- For testing only
- Faster builds

### 5.1 Update Email Notifications

Edit `codemagic.yaml`:

```yaml
publishing:
  email:
    recipients:
      - your-email@example.com # ← Change this!
```

---

## Step 6: Environment Variables (Optional)

### 6.1 Add AdMob App ID (if not hardcoded)

1. Codemagic → Settings → Environment variables
2. Add variable:
   - **Name**: `ADMOB_APP_ID`
   - **Value**: `ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX`
   - **Secure**: Yes

### 6.2 Access in build.gradle (if needed)

```gradle
android {
    defaultConfig {
        resValue "string", "admob_app_id", System.getenv("ADMOB_APP_ID") ?: "ca-app-pub-test"
    }
}
```

Then in AndroidManifest.xml:
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="@string/admob_app_id"/>
```

---

## Step 7: Trigger Your First Build

### 7.1 Manual Build

1. In Codemagic, go to your app
2. Click "Start new build"
3. Select workflow: `android-apk` (for testing)
4. Click "Start build"

Build takes ~5-10 minutes.

### 7.2 Automatic Builds (Push to Git)

Codemagic can auto-build on:
- Push to `main` branch
- Pull request creation
- Tag creation

**Configure:**
1. Settings → Triggering
2. Enable "Trigger on push"
3. Select branch: `main`
4. Select workflow: `android-apk`

### 7.3 Tag-Based Releases (Recommended)

Build only on version tags:

```bash
# In your local repo
git tag v1.0.0
git push origin v1.0.0
```

**Configure in codemagic.yaml:**
```yaml
triggering:
  events:
    - tag
  tag_patterns:
    - pattern: 'v*'
      include: true
```

---

## Step 8: Download & Test Your Build

### 8.1 Download Artifacts

1. After build completes, click on the build
2. Go to "Artifacts" tab
3. Download:
   - `app-arm64-v8a-release.apk` (most common)
   - `app-release.aab` (for stores)

### 8.2 Test APK

```bash
# Install on device
adb install app-arm64-v8a-release.apk

# Or send to yourself and install manually
```

---

## Step 9: Versioning

### 9.1 Update Version in pubspec.yaml

```yaml
version: 1.0.1+2  # 1.0.1 = version name, 2 = version code
```

### 9.2 Commit and Push

```bash
git add pubspec.yaml
git commit -m "Bump version to 1.0.1"
git push
```

### 9.3 Create Tag (Optional)

```bash
git tag v1.0.1
git push origin v1.0.1
```

Codemagic will auto-build if configured.

---

## Step 10: Publishing to Stores

### 10.1 Google Play Store (with Codemagic)

1. **Set up Google Play Console API access**:
   - Go to Google Play Console
   - Create service account
   - Download JSON key

2. **Upload to Codemagic**:
   - Settings → Publishing → Google Play
   - Upload service account JSON
   - Select track: Internal/Alpha/Beta/Production

3. **Update codemagic.yaml**:
```yaml
publishing:
  google_play:
    credentials: $GCLOUD_SERVICE_ACCOUNT_CREDENTIALS
    track: internal # or alpha, beta, production
```

4. **Build & Publish**:
   - Codemagic will build AAB
   - Automatically upload to Google Play
   - Set rollout percentage

### 10.2 Amazon Appstore (Manual)

1. Build AAB/APK with Codemagic
2. Download from Artifacts
3. Upload manually to Amazon Developer Console

---

## Troubleshooting

### Build Fails: "Keystore not found"

**Fix:** Ensure keystore uploaded with reference name `keystore_reference`

### Build Fails: "Gradle error"

**Fix:** Check `android/build.gradle` has correct Gradle version:
```gradle
classpath 'com.android.tools.build:gradle:8.1.0'
```

### APK Not Signed

**Fix:** 
1. Check signing config in `build.gradle`
2. Verify keystore credentials in Codemagic

### Build Takes Too Long (>20 mins)

**Fix:**
- Use `mac_mini_m1` instance (faster)
- Enable Gradle caching:
```yaml
cache:
  cache_paths:
    - ~/.gradle/caches
```

### "Permission denied" on APK install

**Fix:** APK is signed correctly. Enable "Install from unknown sources" on your device.

---

## Build Time Optimization

### 1. Enable Caching

Add to `codemagic.yaml`:
```yaml
cache:
  cache_paths:
    - $HOME/.gradle/caches
    - $FLUTTER_ROOT/.pub-cache
```

### 2. Use Faster Instance

```yaml
instance_type: mac_mini_m1  # Faster than linux_x2
```

### 3. Skip Tests (if needed)

Remove or comment out:
```yaml
# - name: Run tests
#   script: flutter test
```

---

## Cost Management (Free Tier)

**Codemagic Free Tier:**
- 500 build minutes/month
- Unlimited team size
- Concurrent builds: 1

**Typical Build Times:**
- Debug APK: 5-7 mins
- Release APK: 8-10 mins
- Release AAB: 10-12 mins

**Monthly Builds (Free):**
- ~50 debug builds
- ~40 release builds

**Tips:**
- Build only on tags/releases
- Use debug builds for testing
- Build release only when ready to publish

---

## Advanced: Automated Testing

### Add Tests to Workflow

```yaml
scripts:
  - name: Run Flutter tests
    script: flutter test
    
  - name: Run integration tests
    script: flutter drive --target=test_driver/app.dart
```

---

## Advanced: Slack Notifications

### 1. Create Slack Webhook

1. Go to https://api.slack.com/apps
2. Create app → Incoming Webhooks
3. Copy webhook URL

### 2. Add to codemagic.yaml

```yaml
publishing:
  slack:
    channel: '#builds'
    notify_on_build_start: true
    notify:
      success: true
      failure: true
```

### 3. Add Webhook to Codemagic

Settings → Environment variables:
- Name: `SLACK_WEBHOOK_URL`
- Value: [your webhook URL]
- Secure: Yes

---

## Workflow Comparison

| Workflow | Output | Time | Use Case |
|----------|--------|------|----------|
| **android-debug** | Debug APK | 5-7 min | Quick testing |
| **android-apk** | Signed APKs | 8-10 min | Distribution, Amazon |
| **android-release** | Signed AAB | 10-12 min | Google Play |

---

## Sample Git Workflow

### Development:
```bash
git checkout -b feature/new-feature
# Make changes
git commit -m "Add new feature"
git push origin feature/new-feature
```

### Release:
```bash
git checkout main
git merge feature/new-feature
# Update version in pubspec.yaml to 1.0.1+2
git add pubspec.yaml
git commit -m "Release v1.0.1"
git tag v1.0.1
git push origin main --tags
```

Codemagic auto-builds on tag push.

---

## Next Steps

1. ✅ Set up Git repository
2. ✅ Generate keystore
3. ✅ Create Codemagic account
4. ✅ Connect repository
5. ✅ Upload keystore
6. ✅ Update email in codemagic.yaml
7. ✅ Trigger first build
8. ✅ Download and test APK

---

## Resources

- **Codemagic Docs**: https://docs.codemagic.io/flutter/
- **Flutter CI/CD**: https://docs.flutter.dev/deployment/cd
- **Keystore Guide**: https://developer.android.com/studio/publish/app-signing

---

## Support

If you get stuck:
1. Check Codemagic build logs
2. Search Codemagic docs
3. Ask in Codemagic Slack community

---

**Happy Building!** 🚀

Your builds will now run automatically in the cloud, producing production-ready APKs and AABs without local setup.
