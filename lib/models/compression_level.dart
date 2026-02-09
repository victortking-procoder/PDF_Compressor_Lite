enum CompressionLevel {
  light,
  recommended,
  strong;

  String get displayName {
    switch (this) {
      case CompressionLevel.light:
        return 'Light';
      case CompressionLevel.recommended:
        return 'Recommended';
      case CompressionLevel.strong:
        return 'Strong';
    }
  }

  String get description {
    switch (this) {
      case CompressionLevel.light:
        return 'Fast, small reduction';
      case CompressionLevel.recommended:
        return 'Balanced quality & size';
      case CompressionLevel.strong:
        return 'Maximum compression';
    }
  }

  int get quality {
    switch (this) {
      case CompressionLevel.light:
        return 150; // High quality DPI
      case CompressionLevel.recommended:
        return 100; // Medium quality DPI
      case CompressionLevel.strong:
        return 72; // Lower quality DPI for max compression
    }
  }

  double get imageScale {
    switch (this) {
      case CompressionLevel.light:
        return 0.9;
      case CompressionLevel.recommended:
        return 0.7;
      case CompressionLevel.strong:
        return 0.5;
    }
  }
}
