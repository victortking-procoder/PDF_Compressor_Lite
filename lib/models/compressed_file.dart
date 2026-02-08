class CompressedFile {
  final String originalPath;
  final String compressedPath;
  final int originalSize;
  final int compressedSize;
  final DateTime timestamp;
  final String compressionLevel;

  CompressedFile({
    required this.originalPath,
    required this.compressedPath,
    required this.originalSize,
    required this.compressedSize,
    required this.timestamp,
    required this.compressionLevel,
  });

  double get reductionPercentage {
    if (originalSize == 0) return 0;
    return ((originalSize - compressedSize) / originalSize) * 100;
  }

  String get fileName {
    return originalPath.split('/').last;
  }

  Map<String, dynamic> toJson() {
    return {
      'originalPath': originalPath,
      'compressedPath': compressedPath,
      'originalSize': originalSize,
      'compressedSize': compressedSize,
      'timestamp': timestamp.toIso8601String(),
      'compressionLevel': compressionLevel,
    };
  }

  factory CompressedFile.fromJson(Map<String, dynamic> json) {
    return CompressedFile(
      originalPath: json['originalPath'] as String,
      compressedPath: json['compressedPath'] as String,
      originalSize: json['originalSize'] as int,
      compressedSize: json['compressedSize'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      compressionLevel: json['compressionLevel'] as String,
    );
  }
}
