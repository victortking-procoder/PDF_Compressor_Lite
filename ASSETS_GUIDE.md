# Assets Guide - PDF Compressor Lite

This guide explains how to add icons, images, and other assets to your app.

## Required Assets

### 1. App Icon (Required)

**Specifications:**
- Size: 512x512 pixels
- Format: PNG with transparency OR solid background
- Content: Should represent PDF compression visually
- Style: Material Design 3 compliant

**Design Ideas:**
- PDF document icon with compression arrows
- File icon with downward arrow
- Document being compressed visually
- Minimalist geometric design

**Free Icon Tools:**
- https://www.canva.com/create/icons/
- https://www.figma.com/community/
- https://romannurik.github.io/AndroidAssetStudio/icons-launcher.html

**Steps to Add:**

1. Create or download 512x512 icon
2. Use Flutter icon generator:
   ```bash
   flutter pub add flutter_launcher_icons --dev
   ```

3. Create `flutter_launcher_icons.yaml`:
   ```yaml
   flutter_launcher_icons:
     android: true
     ios: false
     image_path: "assets/icon/app_icon.png"
     adaptive_icon_background: "#FFFFFF"
     adaptive_icon_foreground: "assets/icon/app_icon_foreground.png"
   ```

4. Place your icon in `assets/icon/app_icon.png`

5. Generate icons:
   ```bash
   flutter pub run flutter_launcher_icons
   ```

### 2. Screenshots (Required for Stores)

**Specifications:**
- Size: 1080x1920 pixels minimum (phone), 2560x1600 (tablet optional)
- Format: PNG or JPEG
- Count: 4-8 screenshots
- Quality: High resolution, clear text

**Required Screenshots:**

1. **Home Screen** 
   - Shows: Free compressions counter, Select PDF button
   - Caption: "Quick and Easy PDF Compression"

2. **Compression Options**
   - Shows: 3 compression levels with descriptions
   - Caption: "Choose Your Compression Level"

3. **Compression Progress**
   - Shows: Progress indicator, percentage
   - Caption: "Fast On-Device Processing"

4. **Results Screen**
   - Shows: Before/after sizes, percentage saved
   - Caption: "See Instant Results"

5. **History Screen** (Optional)
   - Shows: List of compressed PDFs
   - Caption: "Track Your Compression History"

**How to Capture:**

1. Run app on emulator (Pixel 6 recommended)
2. Perform actions for each screenshot
3. Click camera icon in Android Studio
4. Save to `assets/screenshots/`

**Adding Text Overlays (Optional):**
- Use https://screenshots.pro/
- Or Figma/Canva for professional frames

### 3. Feature Graphic (Google Play Only)

**Specifications:**
- Size: 1024x500 pixels
- Format: PNG or JPEG
- Content: App icon + tagline

**Template Layout:**
```
┌─────────────────────────────────────────┐
│  [App Icon]  PDF Compressor Lite       │
│   (200x200)  Compress PDFs in Seconds   │
└─────────────────────────────────────────┘
```

**Design Tools:**
- Canva: https://www.canva.com/
- Figma: https://www.figma.com/
- Adobe Express: https://www.adobe.com/express/

### 4. Promotional Images (Optional)

For marketing and social media:
- **Twitter/X Card**: 1200x628
- **Facebook Post**: 1200x630
- **Instagram Post**: 1080x1080

## Current Assets Structure

```
assets/
├── icon/
│   └── app_icon.png              # 512x512 app icon
├── screenshots/
│   ├── home_screen.png           # 1080x1920
│   ├── compression_options.png   # 1080x1920
│   ├── progress.png              # 1080x1920
│   ├── results.png               # 1080x1920
│   └── history.png               # 1080x1920 (optional)
└── feature_graphic.png           # 1024x500 (Google Play)
```

## Icon Design Best Practices

### ✅ DO:
- Use simple, recognizable shapes
- Ensure icon works at small sizes (48x48)
- Use high contrast colors
- Follow Material Design guidelines
- Make icon unique and memorable

### ❌ DON'T:
- Use text in the icon (illegible at small sizes)
- Use too many colors (keep it simple)
- Copy competitors' designs
- Use low-resolution images
- Include thin lines (won't be visible)

## Color Schemes (Suggestions)

### Option 1: Professional Blue
- Primary: #2196F3 (Blue)
- Secondary: #1976D2 (Dark Blue)
- Accent: #FFC107 (Amber)

### Option 2: Modern Purple
- Primary: #9C27B0 (Purple)
- Secondary: #7B1FA2 (Dark Purple)
- Accent: #00BCD4 (Cyan)

### Option 3: Eco Green
- Primary: #4CAF50 (Green)
- Secondary: #388E3C (Dark Green)
- Accent: #FF9800 (Orange)

## Quick Icon Creation Steps

### Method 1: Use Canva (Free)

1. Go to https://www.canva.com/
2. Create Design → Custom Size → 512x512
3. Search for "PDF icon" or "document icon"
4. Add compression arrows or indicators
5. Download as PNG
6. Save to `assets/icon/app_icon.png`

### Method 2: Use Material Symbols

1. Go to https://fonts.google.com/icons
2. Search "compress" or "file"
3. Download SVG
4. Convert to PNG at 512x512
5. Add background color if needed

### Method 3: Commission a Designer

Platforms:
- Fiverr: $5-50 for simple icons
- Upwork: $20-100 for professional design
- 99designs: $100-500 for comprehensive branding

## Screenshot Enhancement Tips

1. **Add Device Frames**
   - https://screenshots.pro/
   - Makes screenshots look professional

2. **Add Text Overlays**
   - Use Canva or Figma
   - Highlight key features
   - Keep text minimal and readable

3. **Show Real Data**
   - Use actual PDF files
   - Show realistic compression results
   - Don't exaggerate percentages

4. **Consistent Styling**
   - Same device frame for all screenshots
   - Consistent text placement
   - Same color scheme

## Testing Your Assets

### Icon Test
1. Install app on device
2. Check icon in app drawer
3. Verify icon at different sizes
4. Test on light and dark backgrounds

### Screenshot Test
1. View on phone screen
2. Ensure text is readable
3. Check for any UI glitches
4. Verify colors look good

## Asset Checklist

Before submitting to stores:

- [ ] App icon created (512x512)
- [ ] Icon added to `assets/icon/`
- [ ] Icon generated for all densities
- [ ] 4-8 screenshots captured
- [ ] Screenshots saved at 1080x1920+
- [ ] Feature graphic created (Google Play)
- [ ] All images high quality (no pixelation)
- [ ] Text is readable in screenshots
- [ ] Assets follow store guidelines
- [ ] Tested icon on device

## Store-Specific Requirements

### Amazon Appstore
- Icon: 512x512 or 1024x1024
- Screenshots: 3-10 images
- Feature graphic: Not required
- Video: Optional

### Google Play Store
- Icon: 512x512 (required)
- Screenshots: 2-8 images (required)
- Feature graphic: 1024x500 (required)
- Promotional video: Optional

## Common Mistakes to Avoid

1. ❌ Low resolution icons (pixelated)
2. ❌ Text in app icon
3. ❌ Screenshots with personal data visible
4. ❌ Inconsistent screenshot dimensions
5. ❌ Feature graphic with wrong aspect ratio
6. ❌ Using copyrighted images
7. ❌ Screenshots showing fake data
8. ❌ Icon too complex (hard to see at small size)

## Resources

### Icon Design
- Material Design Icons: https://fonts.google.com/icons
- Flaticon: https://www.flaticon.com/ (check license)
- Icons8: https://icons8.com/

### Screenshot Tools
- Android Studio: Built-in screenshot tool
- Screenshots Pro: https://screenshots.pro/
- Device Art Generator: https://developer.android.com/distribute/marketing-tools/device-art-generator

### Design Software
- Figma (Free): https://www.figma.com/
- Canva (Free): https://www.canva.com/
- GIMP (Free): https://www.gimp.org/
- Photoshop (Paid): https://www.adobe.com/photoshop

## Need Help?

If you're not comfortable with design:

1. **Hire on Fiverr**: $5-50 for app icon
2. **Use Templates**: Many free icon templates available
3. **Simple is Better**: A clean, simple icon often works best

---

**Remember:** Good assets improve conversion rates by 20-30%!

Invest time in creating quality assets - users DO judge apps by their icons and screenshots.
