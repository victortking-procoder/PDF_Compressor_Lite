import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';
import '../services/storage_service.dart';
import '../widgets/history_item.dart';
import '../widgets/limit_dialog.dart';
import 'compression_screen.dart';
import 'privacy_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final adService = context.read<AdService>();
    await adService.init();
    adService.loadBannerAd();
  }

  Future<void> _pickPdf() async {
    // FilePicker uses Storage Access Framework - no permissions needed

    // Check compression limit
    final adService = context.read<AdService>();
    if (!adService.canCompress) {
      if (mounted) {
        _showLimitDialog();
      }
      return;
    }

    // Pick file
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CompressionScreen(file: file),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showLimitDialog() {
    showDialog(
      context: context,
      builder: (context) => const LimitDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adService = context.watch<AdService>();
    final storageService = context.watch<StorageService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Compressor Lite'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.privacy_tip_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacyScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              child: Column(
                children: [
            // Free compressions counter
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(context).colorScheme.secondaryContainer,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.compress,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Free Compressions Today',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${adService.compressionsRemaining} remaining',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),

            // Select PDF button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: _pickPdf,
                  icon: const Icon(Icons.file_upload, size: 24),
                  label: const Text(
                    'Select PDF to Compress',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms).scale(begin: const Offset(0.9, 0.9)),

            const SizedBox(height: 24),

            // History section
            if (storageService.history.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Compressions',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Clear History'),
                            content: const Text(
                              'Are you sure you want to clear all compression history?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Clear'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true && mounted) {
                          storageService.clearHistory();
                        }
                      },
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: storageService.history.length,
                  itemBuilder: (context, index) {
                    return HistoryItem(
                      file: storageService.history[index],
                    ).animate().fadeIn(
                      delay: (100 * index).ms,
                      duration: 300.ms,
                    ).slideX(begin: 0.2, end: 0);
                  },
                ),
              ),
            ] else
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No compression history yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 600.ms),
              ),
          ],
        ),
      ),
          ),
          
          // Banner Ad at bottom
          if (adService.bannerAd != null)
            Container(
              alignment: Alignment.center,
              width: adService.bannerAd!.size.width.toDouble(),
              height: adService.bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: adService.bannerAd!),
            ),
        ],
      ),
    );
  }
}
