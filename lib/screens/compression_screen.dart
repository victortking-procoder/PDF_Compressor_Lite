import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/compression_level.dart';
import '../models/compressed_file.dart';
import '../services/compression_service.dart';
import '../services/storage_service.dart';
import '../services/ad_service.dart';
import 'result_screen.dart';

class CompressionScreen extends StatefulWidget {
  final File file;

  const CompressionScreen({super.key, required this.file});

  @override
  State<CompressionScreen> createState() => _CompressionScreenState();
}

class _CompressionScreenState extends State<CompressionScreen> {
  CompressionLevel _selectedLevel = CompressionLevel.recommended;
  bool _isCompressing = false;
  double _progress = 0.0;
  int? _fileSize;

  @override
  void initState() {
    super.initState();
    _loadFileSize();
  }

  Future<void> _loadFileSize() async {
    final size = await widget.file.length();
    setState(() {
      _fileSize = size;
    });
  }

  Future<void> _compress() async {
    setState(() {
      _isCompressing = true;
      _progress = 0.0;
    });

    try {
      final compressionService = context.read<CompressionService>();
      final storageService = context.read<StorageService>();
      final adService = context.read<AdService>();

      final compressedFile = await compressionService.compressPdf(
        inputFile: widget.file,
        level: _selectedLevel,
        onProgress: (progress) {
          setState(() {
            _progress = progress;
          });
        },
      );

      final originalSize = await widget.file.length();
      final compressedSize = await compressedFile.length();

      final result = CompressedFile(
        originalPath: widget.file.path,
        compressedPath: compressedFile.path,
        originalSize: originalSize,
        compressedSize: compressedSize,
        timestamp: DateTime.now(),
        compressionLevel: _selectedLevel.displayName,
      );

      await storageService.addToHistory(result);
      
      // Use one compression from the daily limit
      await adService.useCompression();

      if (mounted) {
        // Show interstitial ad AFTER successful compression
        adService.showInterstitialAd();

        // Navigate to result screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(result: result),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Compression failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isCompressing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final compressionService = context.read<CompressionService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compress PDF'),
        centerTitle: true,
      ),
      body: _isCompressing ? _buildProgressView() : _buildSelectionView(compressionService),
    );
  }

  Widget _buildProgressView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              value: _progress,
              strokeWidth: 6,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Compressing PDF...',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            '${(_progress * 100).toInt()}%',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text('Please wait, this may take a moment'),
        ],
      ).animate().fadeIn(duration: 300.ms),
    );
  }

  Widget _buildSelectionView(CompressionService compressionService) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // File info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.picture_as_pdf,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.file.path.split('/').last,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          if (_fileSize != null)
                            Text(
                              'Size: ${compressionService.formatFileSize(_fileSize!)}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),

            const SizedBox(height: 24),

            Text(
              'Select Compression Level',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Compression level options
            ...CompressionLevel.values.map((level) {
              return _buildLevelOption(level);
            }).toList(),

            const Spacer(),

            // Info box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'All compression happens on your device. Your file never leaves your phone.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

            const SizedBox(height: 16),

            // Compress button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: _compress,
                child: const Text(
                  'Compress PDF',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 400.ms).scale(begin: const Offset(0.95, 0.95)),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelOption(CompressionLevel level) {
    final isSelected = _selectedLevel == level;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedLevel = level;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isSelected
                ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
                : null,
          ),
          child: Row(
            children: [
              Radio<CompressionLevel>(
                value: level,
                groupValue: _selectedLevel,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedLevel = value;
                    });
                  }
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      level.displayName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      level.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(
      delay: (100 * level.index).ms,
      duration: 300.ms,
    ).slideX(begin: 0.2, end: 0);
  }
}
