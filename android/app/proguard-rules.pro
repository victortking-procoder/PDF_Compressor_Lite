# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Google Mobile Ads
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }

# PDF library
-keep class com.itextpdf.** { *; }

# Play Core library (required by Flutter)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**
